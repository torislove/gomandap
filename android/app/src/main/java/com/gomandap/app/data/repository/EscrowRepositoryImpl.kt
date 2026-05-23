package com.gomandap.app.data.repository

import com.gomandap.app.domain.model.EscrowDetails
import com.gomandap.app.domain.model.Milestone
import com.gomandap.app.domain.repository.EscrowRepository
import kotlinx.coroutines.delay

class EscrowRepositoryImpl : EscrowRepository {

    // Simple in-memory storage for demonstration and testing purposes
    private var mockMilestones = mutableListOf(
        Milestone("m1", 1, "Booking Lock (20%)", 50000.00, "HELD"),
        Milestone("m2", 2, "Pre-Event Setup (50%)", 125000.00, "HELD"),
        Milestone("m3", 3, "Final Handover (30%)", 75000.00, "HELD")
    )

    override suspend fun getEscrowProgress(bookingId: String): EscrowDetails {
        // Simulate network/db delay
        delay(300)
        return EscrowDetails(
            bookingId = bookingId,
            totalAmount = 250000.00,
            milestones = mockMilestones.toList()
        )
    }

    override suspend fun triggerRelease(milestoneId: String) {
        // Simulate network/db update delay
        delay(500)
        mockMilestones = mockMilestones.map { milestone ->
            if (milestone.id == milestoneId) {
                milestone.copy(status = "RELEASED")
            } else {
                milestone
            }
        }.toMutableList()
    }
}
