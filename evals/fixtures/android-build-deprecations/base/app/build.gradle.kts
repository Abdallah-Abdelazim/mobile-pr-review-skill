plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}

android {
    namespace = "com.example.scan"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.example.scan"
        minSdk = 26
        targetSdk = 35
        versionCode = 41
        versionName = "4.1"
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.room:room-runtime:2.6.1")
}
