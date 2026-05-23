package com.gomandap.app.data.local

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "cached_venues")
data class CachedVenueEntity(
    @PrimaryKey val id: String,
    val businessName: String,
    val category: String,
    val thumbnailImage: String,
    val basePrice: Double,
    val rating: Double,
    val locality: String,
    val isVerified: Boolean,
    val capacityMin: Int,
    val capacityMax: Int
)
