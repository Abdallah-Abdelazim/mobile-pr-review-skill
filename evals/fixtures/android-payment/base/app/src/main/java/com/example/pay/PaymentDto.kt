package com.example.pay

data class PaymentRequestDto(val method: String, val amountCents: Long)

fun PaymentMethod.toApi(): String = when (this) {
    PaymentMethod.CARD -> "card"
    PaymentMethod.CASH -> "cash"
}
