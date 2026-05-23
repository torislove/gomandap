package com.gomandap.app.domain.repository

import com.gomandap.app.domain.model.EscrowDetails

interface EscrowRepository {
    suspend fun getEscrowProgress(bookingId: String): EscrowDetails
    suspend fun triggerRelease(milestoneId: String)
}
