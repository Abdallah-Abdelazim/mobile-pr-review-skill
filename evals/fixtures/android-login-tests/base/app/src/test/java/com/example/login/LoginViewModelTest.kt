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
}
