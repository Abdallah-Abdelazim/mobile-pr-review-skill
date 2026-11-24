plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    kotlin("kapt")
}

android {
    namespace = "com.example.scan"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.scan"
        minSdk = 26
        targetSdk = 36
        versionCode = 42
        versionName = "4.2"
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.0")
    implementation("androidx.room:room-runtime:2.6.1")
    kapt("androidx.room:room-compiler:2.6.1")
}
