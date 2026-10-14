package com.example.orders

object RefundPolicy {
    fun canRefund(order: Order, nowMillis: Long): Boolean = false
}
