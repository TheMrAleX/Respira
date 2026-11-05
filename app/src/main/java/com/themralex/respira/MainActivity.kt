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
