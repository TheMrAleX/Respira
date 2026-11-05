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
