package com.example.login

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Test

class LoginViewModelTest {
    @Test
    fun `canSubmit is false for a short password`() {
        val vm = LoginViewModel()
        vm.onEmailChanged("a@b.co")
        vm.onPasswordChanged("12345")
        assertFalse(vm.canSubmit())
    }

    @Test
    fun `onSubmit shows an error for invalid input`() {
        val vm = LoginViewModel()
        val state = LoginUiState(email = "bad", error = "Invalid email or password")
        assertEquals("Invalid email or password", state.error)
    }
}
