plugins {
    id("com.android.library")
    kotlin("android")
}

android {
    compileSdk = 34
    namespace = "com.gomandap.common"
    defaultConfig {
        minSdk = 22
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.2"
    }
}

dependencies {
    // Compose
    implementation("androidx.compose.ui:ui:1.6.5")
    implementation("androidx.compose.material3:material3:1.2.1")
    implementation("androidx.compose.material:material-icons-extended:1.6.5")
    implementation("androidx.compose.ui:ui-tooling-preview:1.6.5")
    implementation("androidx.compose.foundation:foundation:1.6.5")
    debugImplementation("androidx.compose.ui:ui-tooling:1.6.5")

    // Image Loading (Coil)
    implementation("io.coil-kt:coil-compose:2.6.0")

    // SplashScreen API (Android 12+ with compat for older versions)
    implementation("androidx.core:core-splashscreen:1.0.1")

    // Activity (for ComponentActivity)
    implementation("androidx.activity:activity-compose:1.8.2")

    // Biometric
    implementation("androidx.biometric:biometric:1.1.0")

    // Lifecycle (for foreground/background detection)
    implementation("androidx.lifecycle:lifecycle-process:2.7.0")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.7.0")

    // Testing
    testImplementation("junit:junit:4.13.2")
}
