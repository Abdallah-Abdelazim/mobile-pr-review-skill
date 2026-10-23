package com.example.wallet

@JvmInline
value class TransferId(val value: String)

class TransferDeclinedException(message: String) : Exception(message)

interface WalletRepository {
    /** Current balance in cents. */
    suspend fun fetchBalance(): Long

    /**
     * Sends [amountCents] to [recipient] and returns the new transfer's id (not the balance).
     * [recipient] must be an E.164 phone number with no whitespace; [amountCents] must be > 0.
     * Throws [TransferDeclinedException] when the backend declines the transfer.
     */
    suspend fun transfer(recipient: String, amountCents: Long): TransferId
}
