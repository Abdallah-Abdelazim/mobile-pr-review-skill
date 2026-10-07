package com.example.pay

object FeeCalculator {
    fun feeCents(method: PaymentMethod, amountCents: Long): Long = when (method) {
        PaymentMethod.CASH -> 0
        else -> amountCents * 3 / 100 // card processing fee
    }
}
