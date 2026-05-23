plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    compileSdk = 34
    namespace = "com.gomandap.common"
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }
}

dependencies {
    // Share the Antigravity design system
    implementation(project(":app")) // pulls in existing UI utilities if needed
}
