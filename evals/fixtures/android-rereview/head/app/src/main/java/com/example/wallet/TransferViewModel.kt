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
    val error: String? = null,
    val isSubmitting: Boolean = false,
    val sent: Boolean = false,
)

class TransferViewModel(private val repository: WalletRepository) : ViewModel() {
    private val _state = MutableStateFlow(TransferUiState())
    val state: StateFlow<TransferUiState> = _state.asStateFlow()

    init {
        refreshBalance()
    }

    fun refreshBalance() {
        viewModelScope.launch {
            val balance = repository.fetchBalance()
            _state.value = TransferUiState(balanceCents = balance)
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
            val dollars = current.amountInput.toLongOrNull()
            if (dollars == null) {
                _state.value = current.copy(error = "Enter a whole dollar amount")
                return@launch
            }
            val amountCents = dollars * 100
            if (amountCents > current.balanceCents * 100) {
                _state.value = current.copy(error = "Insufficient balance")
                return@launch
            }
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
