#!/usr/bin/env bash
set -euo pipefail

TARGET="${1:-.}"
echo ">>> Creando proyecto Respira en: $TARGET"
mkdir -p "$TARGET"
cd "$TARGET"

mkdir -p app/src/main/java/com/themralex/respira/data
mkdir -p app/src/main/java/com/themralex/respira/breathing
mkdir -p app/src/main/java/com/themralex/respira/ui/components
mkdir -p app/src/main/java/com/themralex/respira/ui/screens
mkdir -p app/src/main/res/values
mkdir -p app/src/main/res/drawable
mkdir -p app/src/main/res/mipmap-anydpi-v26
mkdir -p .github/workflows

# -------- Gradle --------
cat > settings.gradle.kts <<'RESPIRA_EOF'
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}
rootProject.name = "Respira"
include(":app")
RESPIRA_EOF

cat > build.gradle.kts <<'RESPIRA_EOF'
plugins {
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
}
RESPIRA_EOF

cat > gradle.properties <<'RESPIRA_EOF'
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
android.useAndroidX=true
android.nonTransitiveRClass=true
kotlin.code.style=official
RESPIRA_EOF

cat > .gitignore <<'RESPIRA_EOF'
*.iml
.gradle
/local.properties
/.idea
.DS_Store
build/
app/build/
captures/
.externalNativeBuild/
.cxx/
*.jks
*.keystore
RESPIRA_EOF

cat > app/build.gradle.kts <<'RESPIRA_EOF'
android {
    namespace = "com.themralex.respira"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.themralex.respira"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    signingConfigs {
        create("release") {
            val env = System.getenv()
            val ks = env["KEYSTORE_FILE"]
            if (!ks.isNullOrBlank()) {
                storeFile = file(ks)
                storePassword = env["KEYSTORE_PASSWORD"]
                keyAlias = env["KEY_ALIAS"]
                keyPassword = env["KEY_PASSWORD"]
            }
        }
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            val hasKeystore = !System.getenv("KEYSTORE_FILE").isNullOrBlank()
            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
        }
        debug { }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions { jvmTarget = "17" }

    buildFeatures { compose = true }

    packaging {
        resources.excludes += "/META-INF/{AL2.0,LGPL2.1}"
    }
}

dependencies {
    val composeBom = platform("androidx.compose:compose-bom:2024.10.01")
    implementation(composeBom)

    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.7")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.7")
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.7")
    implementation("androidx.navigation:navigation-compose:2.8.4")
    implementation("androidx.datastore:datastore-preferences:1.1.1")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.9.0")

    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.animation:animation")
    implementation("androidx.compose.material3:material3")
}
RESPIRA_EOF

# -------- Recursos Android --------
cat > app/src/main/AndroidManifest.xml <<'RESPIRA_EOF'
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.VIBRATE" />

    <application
        android:name=".RespiraApp"
        android:allowBackup="false"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:label="@string/app_name"
        android:supportsRtl="true"
        android:theme="@style/Theme.Respira">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:theme="@style/Theme.Respira">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
RESPIRA_EOF

cat > app/src/main/res/values/strings.xml <<'RESPIRA_EOF'
<resources>
    <string name="app_name">Respira</string>
</resources>
RESPIRA_EOF

cat > app/src/main/res/values/themes.xml <<'RESPIRA_EOF'
<resources>
    <style name="Theme.Respira" parent="android:Theme.Material.NoActionBar">
        <item name="android:windowBackground">#0F1410</item>
    </style>
</resources>
RESPIRA_EOF

cat > app/src/main/res/values/colors.xml <<'RESPIRA_EOF'
<resources>
    <color name="ic_launcher_background">#0F1410</color>
</resources>
RESPIRA_EOF

cat > app/src/main/res/drawable/ic_launcher_foreground.xml <<'RESPIRA_EOF'
<vector xmlns:android="http://schemas.android.com/apk/res/android"
    android:width="108dp"
    android:height="108dp"
    android:viewportWidth="108"
    android:viewportHeight="108">
    <path
        android:fillColor="#84E04C"
        android:pathData="M54,54 m-26,0 a26,26 0 1,1 52,0 a26,26 0 1,1 -52,0" />
</vector>
RESPIRA_EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml <<'RESPIRA_EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
RESPIRA_EOF

cat > app/src/main/res/mipmap-anydpi-v26/ic_launcher_round.xml <<'RESPIRA_EOF'
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@color/ic_launcher_background" />
    <foreground android:drawable="@drawable/ic_launcher_foreground" />
</adaptive-icon>
RESPIRA_EOF

# -------- Kotlin: raíz --------
cat > app/src/main/java/com/themralex/respira/RespiraApp.kt <<'RESPIRA_EOF'
package com.themralex.respira

import android.app.Application

class RespiraApp : Application()
RESPIRA_EOF

cat > app/src/main/java/com/themralex/respira/RespiraViewModel.kt <<'RESPIRA_EOF'
package com.themralex.respira

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.themralex.respira.data.HapticIntensity
import com.themralex.respira.data.Repository
import com.themralex.respira.data.SessionRecord
import com.themralex.respira.data.ThemeMode
import com.themralex.respira.data.UserState
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class RespiraViewModel(app: Application) : AndroidViewModel(app) {
    private val repo = Repository(app)

    private val _state = MutableStateFlow<UserState?>(null)
    val state: StateFlow<UserState?> = _state

    init {
        viewModelScope.launch {
            repo.state.collect { _state.value = it }
        }
    }

    fun finishOnboarding() = viewModelScope.launch { repo.setOnboardingDone() }
    fun setTheme(mode: ThemeMode) = viewModelScope.launch { repo.setTheme(mode) }
    fun setHaptic(i: HapticIntensity) = viewModelScope.launch { repo.setHapticIntensity(i) }
    fun addSession(r: SessionRecord) = viewModelScope.launch { repo.addSession(r) }
    fun clearAll() = viewModelScope.launch { repo.clearAll() }
}
RESPIRA_EOF

cat > app/src/main/java/com/themralex/respira/MainActivity.kt <<'RESPIRA_EOF'
package com.themralex.respira

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import com.themralex.respira.data.ThemeMode
import com.themralex.respira.ui.LocalColors
import com.themralex.respira.ui.NavRoot
import com.themralex.respira.ui.RespiraTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge()
        super.onCreate(savedInstanceState)
        val activityWindow = window
        setContent {
            val vm: RespiraViewModel = viewModel()
            val state by vm.state.collectAsStateWithLifecycle(initialValue = null)
            val current = state
            val mode = current?.settings?.theme ?: ThemeMode.OSCURO

            RespiraTheme(mode) {
                val view = LocalView.current
                val isLight = mode != ThemeMode.OSCURO
                LaunchedEffect(isLight) {
                    val controller = WindowCompat.getInsetsController(activityWindow, view)
                    controller.isAppearanceLightStatusBars = isLight
                    controller.isAppearanceLightNavigationBars = isLight
                }
                val colors = LocalColors.current
                if (current == null) {
                    Box(Modifier.fillMaxSize().background(colors.background))
                } else {
                    NavRoot(vm = vm, userState = current)
                }
            }
        }
    }
}
RESPIRA_EOF

# -------- Kotlin: data --------
cat > app/src/main/java/com/themralex/respira/data/Models.kt <<'RESPIRA_EOF'
package com.themralex.respira.data

enum class ThemeMode { OSCURO, CLARO, BLANCO }

enum class HapticIntensity(val amplitude: Float) {
    SUAVE(0.5f), MEDIA(0.75f), FUERTE(1.0f)
}

data class UserSettings(
    val theme: ThemeMode = ThemeMode.OSCURO,
    val hapticIntensity: HapticIntensity = HapticIntensity.MEDIA,
    val onboardingDone: Boolean = false,
)

data class SessionRecord(
    val techniqueId: String,
    val startedAt: Long,
    val durationSeconds: Int,
    val completed: Boolean,
)

data class UserState(
    val settings: UserSettings = UserSettings(),
    val sessions: List<SessionRecord> = emptyList(),
) {
    val totalCompleted: Int get() = sessions.count { it.completed }
    val level: Int get() = Levels.levelFor(totalCompleted)
}
RESPIRA_EOF

cat > app/src/main/java/com/themralex/respira/data/Levels.kt <<'RESPIRA_EOF'
package com.themralex.respira.data

object Levels {
    const val LEVEL_2_MIN = 5
    const val LEVEL_3_MIN = 20

    fun levelFor(totalSessions: Int): Int = when {
        totalSessions >= LEVEL_3_MIN -> 3
        totalSessions >= LEVEL_2_MIN -> 2
        else -> 1
    }
}
RESPIRA_EOF

cat > app/src/main/java/com/themralex/respira/data/Repository.kt <<'RESPIRA_EOF'
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
RESPIRA_EOF

# -------- Kotlin: breathing --------
cat > app/src/main/java/com/themralex/respira/breathing/Techniques.kt <<'RESPIRA_EOF'
package com.themralex.respira.breathing

enum class Phase { INHALA, SORBO, SOSTEN, EXHALA, SOSTEN_VACIO }

data class PhaseSegment(val phase: Phase, val seconds: Int)

data class Technique(
    val id: String,
    val name: String,
    val description: String,
    val segments: List<PhaseSegment>,
    val cycleSeconds: Int,
    val unlockLevel: Int = 1,
)

val TechniqueCatalog: List<Technique> = listOf(
    Technique(
        id = "coherencia",
        name = "Coherencia",
        description = "Inhala 5, exhala 5. Equilibrio simple.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 5),
            PhaseSegment(Phase.EXHALA, 5),
        ),
        cycleSeconds = 10,
    ),
    Technique(
        id = "exhalacion",
        name = "Exhalación larga",
        description = "Inhala 4, exhala 6. Para calmar.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 10,
    ),
    Technique(
        id = "pausa",
        name = "Con pausa",
        description = "Inhala 4, sostén 2, exhala 6.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.SOSTEN, 2),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 12,
    ),
    Technique(
        id = "suspiro",
        name = "Suspiro",
        description = "Inhala 2, sorbo 1, exhala 6.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 2),
            PhaseSegment(Phase.SORBO, 1),
            PhaseSegment(Phase.EXHALA, 6),
        ),
        cycleSeconds = 9,
    ),
    Technique(
        id = "dormir",
        name = "Para dormir",
        description = "Inhala 4, exhala 8. Muy lento.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.EXHALA, 8),
        ),
        cycleSeconds = 12,
    ),
    Technique(
        id = "cuadrada",
        name = "Cuadrada",
        description = "4-4-4-4. Para practicar con calma.",
        segments = listOf(
            PhaseSegment(Phase.INHALA, 4),
            PhaseSegment(Phase.SOSTEN, 4),
            PhaseSegment(Phase.EXHALA, 4),
            PhaseSegment(Phase.SOSTEN_VACIO, 4),
        ),
        cycleSeconds = 16,
        unlockLevel = 3,
    ),
)

fun techniqueById(id: String): Technique? = TechniqueCatalog.firstOrNull { it.id == id }
RESPIRA_EOF

cat > app/src/main/java/com/themralex/respira/breathing/Haptics.kt <<'RESPIRA_EOF'
package com.themralex.respira.breathing

import android.content.Context
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager

class Haptics(context: Context, private val intensity: Float) {

    private val vibrator: Vibrator? = run {
        val v: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            val vm = context.getSystemService(Context.VIBRATOR_MANAGER_SERVICE) as? VibratorManager
            vm?.defaultVibrator
        } else {
            @Suppress("DEPRECATION")
            context.getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator
        }
        v?.takeIf { it.hasVibrator() }
    }

    fun playPhase(phase: Phase, durationMs: Long) {
        val v = vibrator ?: return
        val (timings, amps) = buildWaveform(phase, durationMs)
        if (timings.isEmpty()) return
        try {
            v.vibrate(VibrationEffect.createWaveform(timings, amps, -1))
        } catch (_: Exception) { }
    }

    fun cancel() {
        try { vibrator?.cancel() } catch (_: Exception) { }
    }

    private fun buildWaveform(phase: Phase, durationMs: Long): Pair<LongArray, IntArray> {
        val maxAmp = (255f * intensity).toInt().coerceIn(1, 255)
        return when (phase) {
            Phase.INHALA -> {
                val pulses = (durationMs / 400L).toInt().coerceAtLeast(2)
                val t = ArrayList<Long>(pulses * 2)
                val a = ArrayList<Int>(pulses * 2)
                for (i in 0 until pulses) {
                    val p = i.toFloat() / (pulses - 1)
                    t.add(60L)
                    a.add((maxAmp * (0.3f + 0.7f * p)).toInt().coerceIn(1, 255))
               
