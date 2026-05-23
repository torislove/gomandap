package com.gomandap.app.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "cached_bookings")
data class CachedBookingEntity(
    @PrimaryKey val id: String,
    val vendorName: String,
    val category: String,
    val eventDate: String,
    val totalAmount: Double,
    val status: String
)
