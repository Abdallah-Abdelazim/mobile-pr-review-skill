package com.example.sync

interface SyncApi {
    /** Pulls pending changes; throws `IOException` when offline. */
    suspend fun pull(): List<String>
}

sealed interface SyncStatus {
    data object Idle : SyncStatus
    data class Done(val changes: Int) : SyncStatus
}
