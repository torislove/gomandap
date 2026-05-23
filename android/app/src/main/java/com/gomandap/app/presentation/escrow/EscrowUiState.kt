package com.gomandap.app.presentation.escrow

import com.gomandap.app.domain.model.Milestone

data class EscrowUiState(
    val isLoading: Boolean = false,
    val bookingId: String = "",
    val totalAmount: Double = 0.0,
    val milestones: List<Milestone> = emptyList(),
    val errorMessage: String? = null
)
