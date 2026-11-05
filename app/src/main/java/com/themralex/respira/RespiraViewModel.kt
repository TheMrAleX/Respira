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
