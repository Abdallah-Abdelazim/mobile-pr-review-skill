package com.example.sync

import kotlinx.coroutines.runBlocking
import kotlin.test.Test
import kotlin.test.assertEquals

private class FakeSyncApi(private val changes: List<String>) : SyncApi {
    override suspend fun pull(): List<String> = changes
}

class SyncEngineTest {
    @Test
    fun syncReturnsChangeCount() = runBlocking {
        val engine = SyncEngine(FakeSyncApi(listOf("a", "b")))
        assertEquals(2, engine.sync())
    }
}
