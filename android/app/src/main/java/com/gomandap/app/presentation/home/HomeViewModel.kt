package com.gomandap.app.presentation.home

import android.app.Application
import android.content.Context
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.gomandap.app.data.vendor.VendorRepository
import com.gomandap.app.domain.model.CateringVendor
import com.gomandap.app.domain.model.DecorMandapVendor
import com.gomandap.app.domain.model.MakeupArtistVendor
import com.gomandap.app.domain.model.PhotographyVendor
import com.gomandap.app.domain.model.VenueVendor
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

// ─── Data Models ─────────────────────────────────────────────────────────────

data class VenueFeedItem(
    val id: String,
    val name: String,
    val locality: String,
    val rating: Double,
    val price: Double,
    val platePrice: Double,
    val isSponsored: Boolean = false,
    val isEscrowProtected: Boolean = true,
    val isFastFilling: Boolean = false,
    val isVerified: Boolean = true,
    val capacity: Int = 500,
    val tags: List<String> = emptyList(),
    val imageResId: Int? = null
)

data class ServiceItem(
    val id: String,
    val name: String,
    val category: String,
    val rating: Double,
    val price: Double
)

data class CityItem(val name: String, val region: String)

data class HomeUiState(
    val selectedCity: String = "Hyderabad",
    val activeCarouselIndex: Int = 0,
    val selectedCategory: String? = null,
    val isCategorySheetOpen: Boolean = false,
    val isRadarSheetOpen: Boolean = false,
    val isLoading: Boolean = true,
    val trendingVenues: List<VenueFeedItem> = emptyList(),
    val eliteServices: List<ServiceItem> = emptyList(),
    val cities: List<CityItem> = emptyList(),
    val cartCount: Int = 0,
    val radiusKm: Float = 15f,
    val wishlistedIds: Set<String> = emptySet()
)

// ─── ViewModel ───────────────────────────────────────────────────────────────

class HomeViewModel(application: Application) : AndroidViewModel(application) {

    private val prefs = application.getSharedPreferences("gomandap_home_prefs", Context.MODE_PRIVATE)

    private val _uiState = MutableStateFlow(
        HomeUiState(
            selectedCity = prefs.getString("selected_city", "Hyderabad") ?: "Hyderabad",
            wishlistedIds = prefs.getStringSet("wishlisted_ids", emptySet())?.toSet() ?: emptySet()
        )
    )
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadData()
    }

    private fun loadData() {
        viewModelScope.launch {
            VendorRepository.vendors.collect { vendorList ->
                val liveList = vendorList.filter { it.isLive }
                val venueVendors = liveList.filterIsInstance<VenueVendor>()
                val serviceVendors = liveList.filter {
                    it is PhotographyVendor || it is DecorMandapVendor || it is CateringVendor || it is MakeupArtistVendor
                }
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    trendingVenues = venueVendors.mapIndexed { index, vendor ->
                        VenueFeedItem(
                            id = vendor.id,
                            name = vendor.name,
                            locality = vendor.locality,
                            rating = vendor.rating.toDouble(),
                            price = vendor.basePrice,
                            platePrice = vendor.pricePerPlateVeg,
                            isSponsored = index == 0,
                            isEscrowProtected = vendor.isEscrowProtected,
                            isFastFilling = vendor.isFastFilling,
                            isVerified = vendor.isVerified,
                            capacity = vendor.seatingCapacity,
                            tags = vendor.venueType?.let { listOf(it.name) } ?: emptyList(),
                            imageResId = null
                        )
                    },
                    eliteServices = serviceVendors.map {
                        ServiceItem(
                            id = it.id,
                            name = it.name,
                            category = when (it) {
                                is PhotographyVendor -> "Photography"
                                is DecorMandapVendor -> "Decor"
                                is CateringVendor -> "Catering"
                                is MakeupArtistVendor -> "Makeup"
                                else -> "Other"
                            },
                            rating = it.rating.toDouble(),
                            price = it.basePrice
                        )
                    },
                    cities = listOf(
                        CityItem("Hyderabad", "Telangana"),
                        CityItem("Secunderabad", "Telangana"),
                        CityItem("Warangal", "Telangana"),
                        CityItem("Vijayawada", "Andhra Pradesh"),
                        CityItem("Guntur", "Andhra Pradesh")
                    )
                )
            }
        }
        viewModelScope.launch {
            VendorRepository.refresh()
        }
    }

    fun selectCategory(category: String) {
        _uiState.value = _uiState.value.copy(
            selectedCategory = category,
            isCategorySheetOpen = true
        )
    }

    fun selectCity(city: String) {
        prefs.edit().putString("selected_city", city).apply()
        _uiState.value = _uiState.value.copy(selectedCity = city)
    }


    fun closeCategorySheet() {
        _uiState.value = _uiState.value.copy(isCategorySheetOpen = false, selectedCategory = null)
    }

    fun openRadarSheet() {
        _uiState.value = _uiState.value.copy(isRadarSheetOpen = true)
    }

    fun closeRadarSheet() {
        _uiState.value = _uiState.value.copy(isRadarSheetOpen = false)
    }

    fun updateRadius(km: Float) {
        _uiState.value = _uiState.value.copy(radiusKm = km)
    }

    fun toggleWishlist(venueId: String) {
        val current = _uiState.value.wishlistedIds
        val updated = if (venueId in current) current - venueId else current + venueId
        prefs.edit().putStringSet("wishlisted_ids", updated).apply()
        _uiState.value = _uiState.value.copy(wishlistedIds = updated)
    }

    fun setCarouselIndex(index: Int) {
        _uiState.value = _uiState.value.copy(activeCarouselIndex = index)
    }
}
