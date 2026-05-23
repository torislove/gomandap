plugins {
    id("com.android.application")
    id("kotlin-android")
    id("kotlinx-serialization")
}

android {
    compileSdk = 34
    namespace = "com.gomandap.vendor"
    defaultConfig {
        minSdk = 22
        targetSdk = 34
        applicationId = "com.gomandap.vendor"
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
    // Core AndroidX
    implementation("androidx.core:core-ktx:1.13.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.0")
    implementation("androidx.activity:activity-compose:1.9.0")
    
    // Compose
    implementation("androidx.compose.ui:ui:1.6.5")
    implementation("androidx.compose.material3:material3:1.2.1")
    implementation("androidx.compose.ui:ui-tooling-preview:1.6.5")
    implementation("androidx.compose.material:material-icons-extended:1.6.5")
    debugImplementation("androidx.compose.ui:ui-tooling:1.6.5")
    
    // Navigation
    implementation("androidx.navigation:navigation-compose:2.7.7")
    
    // Serialization
    implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.2")
}
