package com.gomandap.app.presentation.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gomandap.app.domain.model.*
import com.gomandap.app.data.vendor.VendorRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class SearchUiState(
    val searchQuery: String = "",
    val selectedCategory: String = "Venues", // "Venues", "Mandaps", "Photography"
    
    // Dynamic Filter States - Venues
    val guestCapacityRange: ClosedFloatingPointRange<Float> = 100f..1500f,
    val isAcOnly: Boolean = false,
    val isValetOnly: Boolean = false,
    
    // Dynamic Filter States - Mandaps
    val selectedFloralStyle: String = "All", // "Mogra", "Rajasthani", "Temple Wooden", "Minimalist"
    val maxSetupTimeHours: Int = 24,
    
    // Dynamic Filter States - Photography
    val selectedPhotoStyle: String = "Candid", // "Candid", "Cinematic", "Traditional"
    val requiresDrone: Boolean = false,
    
    // Hyper-Local Discovery
    val radiusKm: Float = 15f,
    val userLocation: Pair<Double, Double>? = null, // lat, lng
    val isMapMode: Boolean = false,
    
    val isLoading: Boolean = false,
    val results: List<Vendor> = emptyList()
)

class SearchViewModel : ViewModel() {
    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

    private val vendorState = VendorRepository.vendors

    init {
        viewModelScope.launch {
            vendorState.collect { vendorList ->
                applyFilters(vendorList)
            }
        }
        viewModelScope.launch {
            VendorRepository.refresh()
        }
    }

    fun onSearchQueryChanged(query: String) {
        _uiState.update { it.copy(searchQuery = query) }
        applyFilters()
    }

    fun onCategoryChanged(category: String) {
        _uiState.update { it.copy(selectedCategory = category) }
        applyFilters()
    }

    fun onGuestCapacityRangeChanged(range: ClosedFloatingPointRange<Float>) {
        _uiState.update { it.copy(guestCapacityRange = range) }
        applyFilters()
    }

    fun onAcToggled(enabled: Boolean) {
        _uiState.update { it.copy(isAcOnly = enabled) }
        applyFilters()
    }

    fun onValetToggled(enabled: Boolean) {
        _uiState.update { it.copy(isValetOnly = enabled) }
        applyFilters()
    }

    fun onFloralStyleChanged(style: String) {
        _uiState.update { it.copy(selectedFloralStyle = style) }
        applyFilters()
    }

    fun onSetupTimeHoursChanged(hours: Int) {
        _uiState.update { it.copy(maxSetupTimeHours = hours) }
        applyFilters()
    }

    fun onPhotoStyleChanged(style: String) {
        _uiState.update { it.copy(selectedPhotoStyle = style) }
        applyFilters()
    }

    fun onDroneToggled(required: Boolean) {
        _uiState.update { it.copy(requiresDrone = required) }
        applyFilters()
    }

    fun onRadiusChanged(km: Float) {
        _uiState.update { it.copy(radiusKm = km) }
        applyFilters()
    }

    fun onUserLocationFetched(latitude: Double, longitude: Double) {
        _uiState.update { it.copy(userLocation = Pair(latitude, longitude)) }
        applyFilters()
    }

    fun onMapModeToggled() {
        _uiState.update { it.copy(isMapMode = !_uiState.value.isMapMode) }
    }

    private fun applyFilters(vendorList: List<Vendor> = VendorRepository.currentVendors()) {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            val currentState = _uiState.value
            val liveList = vendorList.filter { it.isLive }

            val filtered = liveList.filter { vendor ->
                // 1. Search Query filter
                val matchesQuery = currentState.searchQuery.isEmpty() ||
                        vendor.name.contains(currentState.searchQuery, ignoreCase = true) ||
                        vendor.locality.contains(currentState.searchQuery, ignoreCase = true)

                // 2. Category matching based on Polymorphic Classes
                val matchesCategory = when (currentState.selectedCategory) {
                    "Venues" -> vendor is VenueVendor
                    "Mandaps" -> vendor is DecorMandapVendor
                    "Photography" -> vendor is PhotographyVendor
                    "Makeup" -> vendor is MakeupArtistVendor
                    "Catering" -> vendor is CateringVendor
                    else -> false
                }

                if (!matchesQuery || !matchesCategory) return@filter false

                // 3. Dynamic Category-Specific Filters
                when (currentState.selectedCategory) {
                    "Venues" -> {
                        val details = vendor as VenueVendor
                        val capacityInRange = details.seatingCapacity >= currentState.guestCapacityRange.start.toInt() &&
                                details.seatingCapacity <= currentState.guestCapacityRange.endInclusive.toInt()
                        val acMatches = !currentState.isAcOnly || (details.venueType == VenueType.Banquet || details.venueType == VenueType.Palace)
                        val valetMatches = !currentState.isValetOnly || details.parkingCount >= 100
                        capacityInRange && acMatches && valetMatches
                    }
                    "Mandaps" -> {
                        val details = vendor as DecorMandapVendor
                        val styleMatches = currentState.selectedFloralStyle == "All" ||
                                details.mandapStyle.name.equals(currentState.selectedFloralStyle, ignoreCase = true)
                        val setupTimeMatches = details.setupTimeHours <= currentState.maxSetupTimeHours
                        styleMatches && setupTimeMatches
                    }
                    "Photography" -> {
                        val details = vendor as PhotographyVendor
                        val styleMatches = details.style.any { it.name.equals(currentState.selectedPhotoStyle, ignoreCase = true) }
                        val droneMatches = !currentState.requiresDrone || details.style.contains(PhotographyStyle.Drone)
                        styleMatches && droneMatches
                    }
                    else -> false
                }
            }
            _uiState.update { it.copy(results = filtered, isLoading = false) }
        }
    }
}
