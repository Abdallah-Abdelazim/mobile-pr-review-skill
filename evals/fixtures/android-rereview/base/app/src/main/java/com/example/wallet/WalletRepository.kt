package com.example.wallet

interface WalletRepository {
    /** Current balance in cents. */
    suspend fun fetchBalance(): Long
}
