package com.example.scan

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity

class ScannerActivity : AppCompatActivity() {
    private val camera = CameraSession()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        camera.start(this)
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        camera.stop()
        super.onBackPressed()
    }
}
