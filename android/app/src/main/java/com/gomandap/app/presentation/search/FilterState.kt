package com.gomandap.app.presentation.search

import com.gomandap.app.domain.model.VenueType
import com.gomandap.app.domain.model.MandapStyle
import com.gomandap.app.domain.model.PhotographyStyle
import kotlinx.serialization.Serializable

// Enums for Venue Filters
@Serializable
enum class BudgetType {
    PerPlate, PerDayRent
}

@Serializable
enum class VenueFoodType {
    VegOnly, NonVeg, Both
}

// Enums for Photography Filters
@Serializable
enum class DeliverableType {
    HardcoverAlbum, TeaserReel, RawFootage
}

// Enums for Makeup Artist Filters
@Serializable
enum class MakeupType {
    Airbrush, HDMakeup, RegularBridal
}

// Enums for Decor & Mandap Filters
@Serializable
enum class DecorTheme {
    Floral, Minimalist, Royal, RusticBoho, Acrylic
}

@Serializable
enum class SetupLocation {
    Indoor, Outdoor, Both
}

// Enums for Catering Filters
@Serializable
enum class CuisineType {
    SouthIndian, NorthIndian, Continental, PanAsian
}

@Serializable
enum class DietaryType {
    StrictlyVeg, VegAndNonVeg, Jain
}

// Exhaustive Sealed Interface Taxonomy
sealed interface CategoryFilterState {
    val category: String

    // A. VenueFilters (Banquets, Lawns, Resorts, Mandapams)
    data class VenueFilters(
        override val category: String = "Venues",
        // User Requested
        val budgetType: BudgetType = BudgetType.PerPlate,
        val priceRange: ClosedFloatingPointRange<Float> = 500f..5000f,
        val guestCapacity: ClosedFloatingPointRange<Float> = 50f..3000f,
        val ratingRange: ClosedFloatingPointRange<Float> = 0f..5f,
        val foodType: VenueFoodType = VenueFoodType.Both,
        val selectedVenueTypes: Set<VenueType> = emptySet(),
        val isAcOnly: Boolean = false,
        val isRoomsAvailable: Boolean = false,
        val isValetParking: Boolean = false,
        val isOutsideCateringAllowed: Boolean = false,
        val isAlcoholAllowed: Boolean = false,
        val roomsRequired: Int = 0,
        val isMuhurthamAvailable: Boolean = false,
        val isVegOnlyVenue: Boolean = false,
        val isOutsideDecorAllowed: Boolean = false,
        val isOutsideDjAllowed: Boolean = false,

        // Retained for backward compatibility
        val guestCapacityRange: ClosedFloatingPointRange<Float> = 100f..1500f,
        val budgetRange: ClosedFloatingPointRange<Float> = 50000f..500000f,
        val isRoomsOnly: Boolean = false,
        val isAlcoholAllowedOnly: Boolean = false,
        val isInHouseDecorOnly: Boolean = false
    ) : CategoryFilterState

    // B. PhotographyFilters
    data class PhotographyFilters(
        override val category: String = "Photography",
        // User Requested
        val budgetPerDay: ClosedFloatingPointRange<Float> = 15000f..300000f,
        val selectedStyles: Set<PhotographyStyle> = emptySet(),
        val selectedDeliverables: Set<DeliverableType> = emptySet(),
        val isOutstationTravelIncluded: Boolean = false,
        val teamSizeOption: String = "Any", // "Any", "Small (<3)", "Standard (3-5)", "Large (5+)"
        val isFullWeddingPackage: Boolean = false,

        // Retained for backward compatibility
        val includeTeaserVideo: Boolean = false,
        val includeRawFootage: Boolean = false,
        val includeHardcoverAlbum: Boolean = false,
        val budgetRange: ClosedFloatingPointRange<Float> = 30000f..200000f
    ) : CategoryFilterState

    // C. MakeupArtistFilters
    data class MakeupArtistFilters(
        override val category: String = "Makeup",
        val budgetPerSession: ClosedFloatingPointRange<Float> = 5000f..80000f,
        val selectedMakeupTypes: Set<MakeupType> = emptySet(),
        val isHairStylingIncluded: Boolean = false,
        val isDrapingIncluded: Boolean = false,
        val isPaidTrialAvailable: Boolean = false,
        val isGroomMakeupIncluded: Boolean = false,
        val familyMakeupCount: Int = 0,
        val selectedBrands: Set<String> = emptySet() // "MAC", "Huda Beauty", "Kryolan", "Chanel"
    ) : CategoryFilterState

    // D. Decor & MandapFilters
    data class DecorFilters(
        override val category: String = "Mandaps",
        // User Requested
        val budgetRange: ClosedFloatingPointRange<Float> = 20000f..500000f,
        val selectedThemes: Set<DecorTheme> = emptySet(),
        val setupLocation: SetupLocation = SetupLocation.Both,
        val selectedComponents: Set<String> = emptySet(), // "Mandap", "Stage", "Entrance", "AV"

        // Retained for backward compatibility
        val selectedMandapStyles: Set<MandapStyle> = emptySet(),
        val isOutdoorOnly: Boolean = false,
        val selectedFloralChoices: Set<String> = emptySet() // "Real Orchids", "Artificial", "Jasmine"
    ) : CategoryFilterState

    // E. CateringFilters
    data class CateringFilters(
        override val category: String = "Catering",
        val pricePerPlate: ClosedFloatingPointRange<Float> = 300f..3000f,
        val selectedCuisines: Set<CuisineType> = emptySet(),
        val dietaryType: DietaryType = DietaryType.StrictlyVeg,
        val selectedServiceStyles: Set<String> = emptySet(), // "Banana Leaf", "Buffet", "Live Counters"
        val isWelcomeDrinksIncluded: Boolean = false,
        val isSweetsBuffetIncluded: Boolean = false
    ) : CategoryFilterState
}

// Typealias for absolute backward compatibility with existing code
typealias FilterState = CategoryFilterState
