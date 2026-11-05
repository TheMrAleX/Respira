package com.themralex.respira.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.emptyPreferences
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.map
import org.json.JSONArray
import org.json.JSONObject
import java.io.IOException

private val Context.respiraDataStore: DataStore<Preferences> by preferencesDataStore(name = "respira")

class Repository(private val context: Context) {

    private val store = context.respiraDataStore
    private val stateKey = stringPreferencesKey("user_state")

    val state: Flow<UserState> = store.data
        .catch { e -> if (e is IOException) emit(emptyPreferences()) else throw e }
        .map { prefs -> decode(prefs[stateKey]) }

    suspend fun setOnboardingDone() = updateSettings {
        it.copy(onboardingDone = true)
    }

    suspend fun setTheme(mode: ThemeMode) = updateSettings {
        it.copy(theme = mode)
    }

    suspend fun setHapticIntensity(intensity: HapticIntensity) = updateSettings {
        it.copy(hapticIntensity = intensity)
    }

    suspend fun addSession(record: SessionRecord) {
        store.edit { prefs ->
            val current = decode(prefs[stateKey])
            val updated = current.copy(
                sessions = (current.sessions + record).takeLast(1000)
            )
            prefs[stateKey] = encode(updated)
        }
    }

    suspend fun clearAll() {
        store.edit { it.clear() }
    }

    private suspend fun updateSettings(block: (UserSettings) -> UserSettings) {
        store.edit { prefs ->
            val current = decode(prefs[stateKey])
            prefs[stateKey] = encode(current.copy(settings = block(current.settings)))
        }
    }

    private fun encode(s: UserState): String {
        val root = JSONObject()
        val settings = JSONObject()
        settings.put("theme", s.settings.theme.name)
        settings.put("haptic", s.settings.hapticIntensity.name)
        settings.put("onboardingDone", s.settings.onboardingDone)
        root.put("settings", settings)
        val arr = JSONArray()
        for (r in s.sessions) {
            val o = JSONObject()
            o.put("techniqueId", r.techniqueId)
            o.put("startedAt", r.startedAt)
            o.put("durationSeconds", r.durationSeconds)
            o.put("completed", r.completed)
            arr.put(o)
        }
        root.put("sessions", arr)
        return root.toString()
    }

    private fun decode(json: String?): UserState {
        if (json.isNullOrBlank()) return UserState()
        return try {
            val root = JSONObject(json)
            val so = root.optJSONObject("settings") ?: JSONObject()
            val theme = runCatching {
                ThemeMode.valueOf(so.optString("theme", ThemeMode.OSCURO.name))
            }.getOrDefault(ThemeMode.OSCURO)
            val haptic = runCatching {
                HapticIntensity.valueOf(so.optString("haptic", HapticIntensity.MEDIA.name))
            }.getOrDefault(HapticIntensity.MEDIA)
            val onboarding = so.optBoolean("onboardingDone", false)
            val arr = root.optJSONArray("sessions") ?: JSONArray()
            val sessions = ArrayList<SessionRecord>(arr.length())
            for (i in 0 until arr.length()) {
                val o = arr.optJSONObject(i) ?: continue
                sessions.add(
                    SessionRecord(
                        techniqueId = o.optString("techniqueId", ""),
                        startedAt = o.optLong("startedAt", 0L),
                        durationSeconds = o.optInt("durationSeconds", 0),
                        completed = o.optBoolean("completed", false),
                    )
                )
            }
            UserState(
                settings = UserSettings(theme, haptic, onboarding),
                sessions = sessions,
            )
        } catch (_: Exception) {
            UserState()
        }
    }
}
