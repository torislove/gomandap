package com.gomandap.app.domain.model

import kotlinx.serialization.Serializable

@Serializable
data class GeofenceCheckIn(
    val checkinId: String,
    val vendorId: String,
    val bookingId: String,
    val scheduledTime: Long, // timestamp
    val checkinTime: Long, // timestamp
    val latitude: Double,
    val longitude: Double,
    val arrivedOnTime: Boolean,
    val status: String // "PENDING", "VERIFIED", "NO_SHOW"
)

@Serializable
data class SlaPenaltyLog(
    val penaltyId: String,
    val vendorId: String,
    val bookingId: String,
    val penaltyAmount: Double,
    val penaltyTier: String, // "MILD", "MODERATE", "SEVERE"
    val reason: String,
    val status: String, // "LOGGED", "DEDUCTED_FROM_PAYOUT", "DISPUTED"
    val createdAt: Long
)

@Serializable
data class StandbyVendor(
    val standbyId: String,
    val vendorId: String,
    val category: String, // "Photography", "Makeup", "Catering"
    val isAvailableNow: Boolean,
    val retainerAmount: Double,
    val currentLatitude: Double,
    val currentLongitude: Double,
    val lastPingTime: Long
)
