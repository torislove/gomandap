package com.gomandap.app.presentation.navigation

import kotlinx.serialization.Serializable

sealed interface Screen {
    @Serializable
    data object Home : Screen
    
    @Serializable
    data object Search : Screen
    
    @Serializable
    data class VenueDetails(val venueId: String) : Screen
    
    @Serializable
    data class EscrowTracker(val bookingId: String) : Screen
}
