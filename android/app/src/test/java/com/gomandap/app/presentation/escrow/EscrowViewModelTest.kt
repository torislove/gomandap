package com.gomandap.app.presentation.escrow

import com.gomandap.app.domain.model.EscrowDetails
import com.gomandap.app.domain.model.Milestone
import com.gomandap.app.domain.repository.EscrowRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.*
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class EscrowViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    // A simple mock repository implementation for testing
    private class MockEscrowRepository : EscrowRepository {
        var getEscrowProgressCalled = false
        var triggerReleaseCalled = false
        var lastMilestoneIdReleased = ""

        var milestones = listOf(
            Milestone("m1", 1, "Booking Lock (20%)", 50000.0, "HELD"),
            Milestone("m2", 2, "Pre-Event Setup (50%)", 125000.0, "HELD"),
            Milestone("m3", 3, "Final Handover (30%)", 75000.0, "HELD")
        )

        override suspend fun getEscrowProgress(bookingId: String): EscrowDetails {
            getEscrowProgressCalled = true
            return EscrowDetails(bookingId, 250000.0, milestones)
        }

        override suspend fun triggerRelease(milestoneId: String) {
            triggerReleaseCalled = true
            lastMilestoneIdReleased = milestoneId
            milestones = milestones.map {
                if (it.id == milestoneId) it.copy(status = "RELEASED") else it
            }
        }
    }

    private lateinit var mockRepository: MockEscrowRepository
    private lateinit var viewModel: EscrowViewModel

    @Before
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
        mockRepository = MockEscrowRepository()
        viewModel = EscrowViewModel(mockRepository)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `loadEscrowDetails updates state to loading then success`() = runTest {
        // When loading escrow details
        viewModel.loadEscrowDetails("booking_123")
        
        // Assert state is loading initially
        assertTrue(viewModel.uiState.value.isLoading)
        
        // Run any pending coroutines on the dispatcher
        testDispatcher.scheduler.advanceUntilIdle()

        // Assert success states and loaded details
        assertFalse(viewModel.uiState.value.isLoading)
        assertEquals("booking_123", viewModel.uiState.value.bookingId)
        assertEquals(250000.0, viewModel.uiState.value.totalAmount, 0.0)
        assertEquals(3, viewModel.uiState.value.milestones.size)
        assertTrue(mockRepository.getEscrowProgressCalled)
    }

    @Test
    fun `releaseMilestoneFunds triggers repository release and reloads details`() = runTest {
        // Given preloaded state
        viewModel.loadEscrowDetails("booking_123")
        testDispatcher.scheduler.advanceUntilIdle()
        
        // When releasing a milestone
        viewModel.releaseMilestoneFunds("m1")
        
        // Assert loading state
        assertTrue(viewModel.uiState.value.isLoading)
        
        // Run pending operations
        testDispatcher.scheduler.advanceUntilIdle()

        // Verify repository release was triggered
        assertTrue(mockRepository.triggerReleaseCalled)
        assertEquals("m1", mockRepository.lastMilestoneIdReleased)
        
        // Verify state is reloaded and the released milestone has updated state
        assertFalse(viewModel.uiState.value.isLoading)
        val releasedMilestone = viewModel.uiState.value.milestones.find { it.id == "m1" }
        assertNotNull(releasedMilestone)
        assertEquals("RELEASED", releasedMilestone?.status)
    }
}
