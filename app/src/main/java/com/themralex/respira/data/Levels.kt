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
