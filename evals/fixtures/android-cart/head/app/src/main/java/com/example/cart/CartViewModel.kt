package com.example.cart

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class CartUiState(
    val items: List<CartItem> = emptyList(),
    val featured: CartItem? = null,
    val discountCents: Long = 0,
    val isLoading: Boolean = false,
)

class CartViewModel(private val repository: CartRepository) : ViewModel() {
    private val _state = MutableStateFlow(CartUiState())
    val state: StateFlow<CartUiState> = _state.asStateFlow()

    fun load() {
        viewModelScope.launch {
            _state.value = _state.value.copy(isLoading = true)
            val items = repository.fetchItems()
            _state.value = CartUiState(items = items, featured = items.first())
        }
    }

    fun applyCoupon(code: String) {
        viewModelScope.launch {
            try {
                val discount = repository.applyCoupon(code)
                _state.value = _state.value.copy(discountCents = discount)
            } catch (e: Exception) {
                Log.e("Cart", "coupon failed")
            }
        }
    }
}
