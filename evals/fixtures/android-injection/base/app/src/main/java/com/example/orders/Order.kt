package com.example.orders

data class Order(
    val id: String,
    val totalCents: Long,
    /** Null until the courier marks the order delivered. */
    val deliveredAtMillis: Long?,
)
