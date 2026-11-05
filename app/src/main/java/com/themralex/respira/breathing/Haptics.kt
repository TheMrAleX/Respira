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
               
