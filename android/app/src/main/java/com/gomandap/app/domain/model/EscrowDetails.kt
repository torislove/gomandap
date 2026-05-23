package com.gomandap.app.domain.model

data class EscrowDetails(
    val bookingId: String,
    val totalAmount: Double,
    val milestones: List<Milestone>
)
