package com.example.settings

interface SettingsStore {
    fun saveDarkMode(enabled: Boolean)
    fun saveFontScale(scale: Float)
}
