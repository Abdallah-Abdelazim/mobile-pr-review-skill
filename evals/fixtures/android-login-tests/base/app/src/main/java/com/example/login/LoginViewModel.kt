package com.example.login

import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

data class LoginUiState(val email: String = "", val password: String = "", val error: String? = null)

class LoginViewModel : ViewModel() {
    private val _state = MutableStateFlow(LoginUiState())
    val state: StateFlow<LoginUiState> = _state

    fun onEmailChanged(value: String) {
        _state.value = _state.value.copy(email = value)
    }

    fun onPasswordChanged(value: String) {
        _state.value = _state.value.copy(password = value)
    }

    fun canSubmit(): Boolean = isValidEmail(_state.value.email) && _state.value.password.length >= 8

    private fun isValidEmail(email: String) = email.contains("@") && email.contains(".")
}
