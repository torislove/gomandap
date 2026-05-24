package com.gomandap.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class CartSkuItem(
    val skuId: String,
    val label: String,
    val price: Double
)

@Serializable
data class CartItem(
    val vendorId: String,
    val vendorName: String,
    val vendorType: String,
    val eventDate: String, // YYYY-MM-DD
    val slot: String, // "Morning" | "Evening" | "Full Day"
    val basePrice: Double,
    val selectedAddons: List<CartSkuItem> = emptyList()
)

@Serializable
data class CartDetails(
    val userId: String,
    val items: List<CartItem> = emptyList(),
    val lastUpdated: Long = System.currentTimeMillis()
)
