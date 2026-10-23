package com.example.wallet

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class TransferUiState(
    val balanceCents: Long = 0,
)

class TransferViewModel(private val repository: WalletRepository) : ViewModel() {
    private val _state = MutableStateFlow(TransferUiState())
    val state: StateFlow<TransferUiState> = _state.asStateFlow()

    fun refreshBalance() {
        viewModelScope.launch {
            _state.value = _state.value.copy(balanceCents = repository.fetchBalance())
        }
    }
}
