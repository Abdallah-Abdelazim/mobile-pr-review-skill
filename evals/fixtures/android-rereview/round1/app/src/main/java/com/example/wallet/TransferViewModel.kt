package com.example.wallet

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class TransferUiState(
    val balanceCents: Long = 0,
    val recipientInput: String = "",
    val amountInput: String = "",
    val isSubmitting: Boolean = false,
    val sent: Boolean = false,
)

class TransferViewModel(private val repository: WalletRepository) : ViewModel() {
    private val _state = MutableStateFlow(TransferUiState())
    val state: StateFlow<TransferUiState> = _state.asStateFlow()

    fun refreshBalance() {
        viewModelScope.launch {
            _state.value = _state.value.copy(balanceCents = repository.fetchBalance())
        }
    }

    fun onRecipientChanged(input: String) {
        _state.value = _state.value.copy(recipientInput = input)
    }

    fun onAmountChanged(input: String) {
        _state.value = _state.value.copy(amountInput = input)
    }

    /** The amount field takes whole dollars. */
    fun submit() {
        viewModelScope.launch {
            val current = _state.value
            val amountCents = current.amountInput.toLong() * 100
            _state.value = current.copy(isSubmitting = true)
            Log.d("Transfer", "sending $amountCents to ${current.recipientInput}")
            try {
                repository.transfer(current.recipientInput, amountCents)
                _state.value = _state.value.copy(isSubmitting = false, sent = true)
                refreshBalance()
            } catch (e: Exception) {
                Log.e("Transfer", "transfer failed", e)
            }
        }
    }
}
