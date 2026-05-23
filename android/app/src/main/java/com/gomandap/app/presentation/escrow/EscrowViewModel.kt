package com.gomandap.app.presentation.escrow

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gomandap.app.domain.repository.EscrowRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class EscrowViewModel @Inject constructor(
    private val escrowRepository: EscrowRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(EscrowUiState())
    val uiState: StateFlow<EscrowUiState> = _uiState.asStateFlow()

    fun loadEscrowDetails(bookingId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                val details = escrowRepository.getEscrowProgress(bookingId)
                _uiState.value = EscrowUiState(
                    bookingId = bookingId,
                    totalAmount = details.totalAmount,
                    milestones = details.milestones,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.localizedMessage ?: "Failed to fetch milestones."
                )
            }
        }
    }

    fun releaseMilestoneFunds(milestoneId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                escrowRepository.triggerRelease(milestoneId)
                // Reload state to sync UI checkmarks
                loadEscrowDetails(_uiState.value.bookingId)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.localizedMessage
                )
            }
        }
    }
}
