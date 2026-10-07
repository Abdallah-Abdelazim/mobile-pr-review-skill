package com.example.cart

data class CartItem(val id: String, val name: String, val priceCents: Long)

interface CartRepository {
    /** Returns the user's cart; empty for a new user or right after checkout. */
    suspend fun fetchItems(): List<CartItem>

    /** Returns the discount in cents; throws [CouponException] for an invalid code. */
    suspend fun applyCoupon(code: String): Long
}

class CouponException(message: String) : Exception(message)
