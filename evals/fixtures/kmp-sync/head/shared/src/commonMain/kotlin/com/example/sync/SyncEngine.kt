package com.example.sync

import java.util.Date
import kotlinx.coroutines.flow.MutableStateFlow

class SyncEngine(private val api: SyncApi) {
    private val lock = Any()
    private var lastSync: Date? = null
    val status = MutableStateFlow<SyncStatus>(SyncStatus.Idle)

    suspend fun sync(): Int {
        val changes = api.pull()
        synchronized(lock) {
            lastSync = Date()
        }
        status.value = SyncStatus.Done(changes.size)
        return changes.size
    }
}
