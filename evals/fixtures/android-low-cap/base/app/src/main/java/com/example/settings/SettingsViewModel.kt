package com.example.settings

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

data class SettingsUiState(
    val darkMode: Boolean = false,
    val fontScale: Float = 1.0f,
)

class SettingsViewModel(private val store: SettingsStore) : ViewModel() {
    private val _state = MutableStateFlow(SettingsUiState())
    val state: StateFlow<SettingsUiState> = _state.asStateFlow()

    fun onDarkModeToggled(enabled: Boolean) {
        _state.value = _state.value.copy(darkMode = enabled)
        store.saveDarkMode(enabled)
    }
}
