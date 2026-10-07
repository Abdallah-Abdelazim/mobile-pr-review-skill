package com.example.cart

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun CartScreen(viewModel: CartViewModel, onCheckout: () -> Unit) {
    val state by viewModel.state.collectAsState()
    Column(modifier = Modifier.padding(16.dp)) {
        Text("Your cart")
        state.featured?.let { Text("Featured: ${it.name}") }
        state.items.forEach { item -> Text(item.name) }
        Button(onClick = onCheckout) { Text("Checkout") }
    }
}
