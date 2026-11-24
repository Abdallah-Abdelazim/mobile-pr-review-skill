package com.example.settings

import androidx.lifecycle.ViewModel
import java.util.Locale
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

    fun onFontScaleChanged(scale: Float) {
        _state.value = _state.value.copy(fontScale = scale)
        store.saveFontScale(scale)
    }

    fun fontScaleLabel(): String = "${Math.round(_state.value.fontScale * 100).toString()}%"

    fun isLargeText(): Boolean = _state.value.fontScale > 1.15f

    fun isDefaultScale(): Boolean = (_state.value.fontScale == 1.0f) == true

    fun isDarkMode(): Boolean {
        val enabled: Boolean = _state.value.darkMode
        return enabled
    }

    fun resetFontScale() {
        var defaultScale = 1.0f
        onFontScaleChanged(defaultScale)
    }

    private fun percentOf(scale: Float): Int = Math.round(scale * 100)
}
