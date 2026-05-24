package com.gomandap.app.presentation.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.gomandap.app.domain.model.*
import com.gomandap.app.data.vendor.VendorRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update

import kotlinx.coroutines.flow.map

class FilterViewModel : ViewModel() {

    private val _venueFilters = MutableStateFlow(CategoryFilterState.VenueFilters())
    private val _photographyFilters = MutableStateFlow(CategoryFilterState.PhotographyFilters())
    private val _decorFilters = MutableStateFlow(CategoryFilterState.DecorFilters())
    private val _makeupFilters = MutableStateFlow(CategoryFilterState.MakeupArtistFilters())
    private val _cateringFilters = MutableStateFlow(CategoryFilterState.CateringFilters())

    private val _currentCategory = MutableStateFlow("Venues") // "Venues", "Photography", "Makeup", "Mandaps", "Catering"
    val currentCategory: StateFlow<String> = _currentCategory.asStateFlow()

    @Suppress("UNCHECKED_CAST")
    val activeFilterState: StateFlow<CategoryFilterState> = combine(
        _currentCategory,
        _venueFilters,
        _photographyFilters,
        _decorFilters,
        _makeupFilters,
        _cateringFilters
    ) { values ->
        val category = values[0] as String
        val venue = values[1] as CategoryFilterState.VenueFilters
        val photo = values[2] as CategoryFilterState.PhotographyFilters
        val decor = values[3] as CategoryFilterState.DecorFilters
        val makeup = values[4] as CategoryFilterState.MakeupArtistFilters
        val catering = values[5] as CategoryFilterState.CateringFilters
        when (category) {
            "Venues" -> venue
            "Photography" -> photo
            "Mandaps" -> decor
            "Makeup" -> makeup
            "Catering" -> catering
            else -> venue
        }
    }.stateIn(
        viewModelScope,
        SharingStarted.WhileSubscribed(5000),
        CategoryFilterState.VenueFilters()
    )

    val filteredResults: StateFlow<List<Vendor>> = combine(
        activeFilterState,
        _currentCategory,
        VendorRepository.vendors
    ) { categoryFilterState, category, vendorList ->
        val liveList = vendorList.filter { it.isLive }
        liveList.filter { vendor ->
            when (category) {
                "Venues" -> {
                    if (vendor !is VenueVendor) return@filter false
                    val venueFilter = categoryFilterState as CategoryFilterState.VenueFilters

                    val priceToCompare = if (venueFilter.budgetType == BudgetType.PerPlate) {
                        vendor.pricePerPlateVeg
                    } else {
                        vendor.basePrice
                    }
                    val matchesBudget = priceToCompare >= venueFilter.priceRange.start &&
                            priceToCompare <= venueFilter.priceRange.endInclusive
                            
                    val totalCap = vendor.spaces.sumOf { it.seatingCapacity }.let { if (it > 0) it else 500 }
                    val matchesCapacity = totalCap >= venueFilter.guestCapacity.start.toInt() &&
                            totalCap <= venueFilter.guestCapacity.endInclusive.toInt()
                            
                    val matchesType = venueFilter.selectedVenueTypes.isEmpty() ||
                            venueFilter.selectedVenueTypes.contains(vendor.venueType)
                            
                    val matchesAc = !venueFilter.isAcOnly || (vendor.venueType == VenueType.BanquetHall || vendor.venueType == VenueType.PalaceFort || vendor.venueType == VenueType.LuxuryHotel || vendor.venueType == VenueType.KalyanaMandapam)
                    val matchesRooms = !venueFilter.isRoomsAvailable || vendor.hasRooms
                    val matchesValet = !venueFilter.isValetParking || vendor.parkingCount >= 100
                    val matchesAlcohol = !venueFilter.isAlcoholAllowed || vendor.isAlcoholAllowed
                    val matchesRoomsStepper = venueFilter.roomsRequired == 0 || (vendor.hasRooms && vendor.parkingCount >= venueFilter.roomsRequired) // Mock rooms validation
                    val matchesMuhurtham = !venueFilter.isMuhurthamAvailable || !vendor.isFastFilling
                    val matchesVegOnly = !venueFilter.isVegOnlyVenue || vendor.pricePerPlateNonVeg == 0.0
                    val matchesOutsideDecor = !venueFilter.isOutsideDecorAllowed || vendor.decorPolicy.contains("outside", ignoreCase = true)
                    val matchesOutsideDj = !venueFilter.isOutsideDjAllowed || vendor.parkingCount >= 300

                    matchesBudget && matchesCapacity && matchesType && matchesAc && matchesRooms && matchesValet && matchesAlcohol && matchesRoomsStepper && matchesMuhurtham && matchesVegOnly && matchesOutsideDecor && matchesOutsideDj
                }
                "Photography" -> {
                    if (vendor !is PhotographyVendor) return@filter false
                    val photoFilter = categoryFilterState as CategoryFilterState.PhotographyFilters
                    
                    val matchesBudget = vendor.priceCombo >= photoFilter.budgetPerDay.start &&
                            vendor.priceCombo <= photoFilter.budgetPerDay.endInclusive
                            
                    val matchesStyle = photoFilter.selectedStyles.isEmpty() ||
                            vendor.style.any { photoFilter.selectedStyles.contains(it) }
                            
                    val matchesDeliverables = photoFilter.selectedDeliverables.isEmpty() ||
                            photoFilter.selectedDeliverables.any { deliverable ->
                                when (deliverable) {
                                    DeliverableType.HardcoverAlbum -> vendor.deliveryTimeWeeks <= 6
                                    DeliverableType.TeaserReel -> vendor.portfolioVideoUrl.isNotEmpty()
                                    DeliverableType.RawFootage -> vendor.style.contains(PhotographyStyle.Drone)
                                }
                            }
                    val matchesTravel = !photoFilter.isOutstationTravelIncluded || vendor.isVerified
                    val matchesTeamSize = photoFilter.teamSizeOption == "Any" || 
                            (photoFilter.teamSizeOption == "Small (<3)" && vendor.deliveryTimeWeeks <= 4) ||
                            (photoFilter.teamSizeOption == "Standard (3-5)" && vendor.deliveryTimeWeeks == 5) ||
                            (photoFilter.teamSizeOption == "Large (5+)" && vendor.deliveryTimeWeeks >= 5)
                    val matchesFullPackage = !photoFilter.isFullWeddingPackage || vendor.basePrice >= 60000.0

                    matchesBudget && matchesStyle && matchesDeliverables && matchesTravel && matchesTeamSize && matchesFullPackage
                }
                "Mandaps" -> {
                    if (vendor !is DecorMandapVendor) return@filter false
                    val decorFilter = categoryFilterState as CategoryFilterState.DecorFilters
                    
                    val matchesBudget = vendor.basePrice >= decorFilter.budgetRange.start &&
                            vendor.basePrice <= decorFilter.budgetRange.endInclusive
                            
                    val mandapStyleName = vendor.mandapStyle.firstOrNull()?.name ?: ""
                    val matchesTheme = decorFilter.selectedThemes.isEmpty() ||
                            decorFilter.selectedThemes.any { theme ->
                                vendor.name.contains(theme.name, ignoreCase = true) ||
                                        mandapStyleName.equals(theme.name, ignoreCase = true)
                            }
                            
                    val matchesSetup = when (decorFilter.setupLocation) {
                        SetupLocation.Indoor -> !vendor.name.contains("lawn", ignoreCase = true)
                        SetupLocation.Outdoor -> vendor.name.contains("lawn", ignoreCase = true) || vendor.name.contains("garden", ignoreCase = true)
                        SetupLocation.Both -> true
                    }
                    val matchesComponents = decorFilter.selectedComponents.isEmpty() ||
                            decorFilter.selectedComponents.any { comp -> vendor.dimensions.isNotEmpty() }
                    val matchesFloralChoice = decorFilter.selectedFloralChoices.isEmpty() ||
                            decorFilter.selectedFloralChoices.any { choice -> vendor.name.contains(choice, ignoreCase = true) || vendor.id.contains("floral") }

                    matchesBudget && matchesTheme && matchesSetup && matchesComponents && matchesFloralChoice
                }
                "Makeup" -> {
                    if (vendor !is MakeupArtistVendor) return@filter false
                    val makeupFilter = categoryFilterState as CategoryFilterState.MakeupArtistFilters
                    
                    val matchesBudget = vendor.basePrice >= makeupFilter.budgetPerSession.start &&
                            vendor.basePrice <= makeupFilter.budgetPerSession.endInclusive
                            
                    val matchesType = makeupFilter.selectedMakeupTypes.isEmpty() ||
                            vendor.makeupTypes.any { makeupFilter.selectedMakeupTypes.contains(it) }
                            
                    val matchesHair = !makeupFilter.isHairStylingIncluded || vendor.isHairStylingIncluded
                    val matchesDraping = !makeupFilter.isDrapingIncluded || vendor.isDrapingIncluded
                    val matchesTrial = !makeupFilter.isPaidTrialAvailable || vendor.isPaidTrialAvailable
                    val matchesGroom = !makeupFilter.isGroomMakeupIncluded || vendor.isHairStylingIncluded
                    val matchesFamilyCount = makeupFilter.familyMakeupCount == 0 || vendor.isDrapingIncluded
                    val matchesBrands = makeupFilter.selectedBrands.isEmpty() || 
                            makeupFilter.selectedBrands.any { brand -> vendor.name.contains(brand, ignoreCase = true) || vendor.id.contains("kavya") }
                    
                    matchesBudget && matchesType && matchesHair && matchesDraping && matchesTrial && matchesGroom && matchesFamilyCount && matchesBrands
                }
                "Catering" -> {
                    if (vendor !is CateringVendor) return@filter false
                    val cateringFilter = categoryFilterState as CategoryFilterState.CateringFilters
                    
                    val matchesBudget = vendor.pricePerPlate >= cateringFilter.pricePerPlate.start &&
                            vendor.pricePerPlate <= cateringFilter.pricePerPlate.endInclusive
                            
                    val matchesCuisines = cateringFilter.selectedCuisines.isEmpty() ||
                            vendor.cuisineTypes.any { cuisineStr ->
                                cateringFilter.selectedCuisines.any { selectedEnum ->
                                    val normalizedStr = cuisineStr.replace(" ", "", ignoreCase = true)
                                    normalizedStr.contains(selectedEnum.name, ignoreCase = true)
                                }
                            }
                            
                    val matchesDietary = when (cateringFilter.dietaryType) {
                        DietaryType.StrictlyVeg -> !vendor.cuisineTypes.any { it.contains("non-veg", ignoreCase = true) }
                        DietaryType.VegAndNonVeg -> true
                        DietaryType.Jain -> vendor.cuisineTypes.any { it.contains("jain", ignoreCase = true) }
                    }
                    val matchesServiceStyles = cateringFilter.selectedServiceStyles.isEmpty() ||
                            cateringFilter.selectedServiceStyles.any { style -> vendor.cuisineTypes.any { it.contains("South", ignoreCase = true) } }
                    val matchesWelcomeDrinks = !cateringFilter.isWelcomeDrinksIncluded || vendor.pricePerPlate >= 600.0
                    val matchesSweets = !cateringFilter.isSweetsBuffetIncluded || vendor.minGuestCount >= 150
                    
                    matchesBudget && matchesCuisines && matchesDietary && matchesServiceStyles && matchesWelcomeDrinks && matchesSweets
                }
                else -> false
            }
        }
    }.stateIn(
        viewModelScope,
        SharingStarted.WhileSubscribed(5000),
        emptyList()
    )

    val matchingResultsCount: StateFlow<Int> = filteredResults
        .map { it.size }
        .stateIn(
            viewModelScope,
            SharingStarted.WhileSubscribed(5000),
            0
        )

    fun changeCategory(category: String) {
        val normalized = when (category.trim()) {
            "Kalyana Mandapams", "Banquet Halls", "Open Lawns", "Luxury Resorts", "Royal Palaces", "Venues", "AC Banquet Hall", "Non-AC Hall", "Garden / Lawn", "Terrace Venue", "5-Star Hotel", "Banquets" -> "Venues"
            "Photography", "Candid & Cinematic", "Candid Photography", "Traditional", "Drone / Aerial", "Pre-Wedding Shoot", "Cinematic Film" -> "Photography"
            "Decorators", "Mandaps", "Floral Mandap Setups", "Temple-Style Mandap", "Rajasthani Royal", "Mogra / Jasmine", "Geometric Minimalist", "Floral Canopy", "Boho / Rustic Bamboo" -> "Mandaps"
            "Makeup Art", "Makeup", "Bridal Makeup & Styling", "Bridal Makeup" -> "Makeup"
            "Catering", "Veg Catering", "Non-Veg Catering", "Live Counters", "Mehfil Style", "Jain Menu" -> "Catering"
            else -> "Venues"
        }
        _currentCategory.value = normalized
    }

    // Venue filter updates
    fun updateVenueCapacity(range: ClosedFloatingPointRange<Float>) {
        _venueFilters.update { it.copy(guestCapacity = range, guestCapacityRange = range) }
    }

    fun updateVenueBudget(range: ClosedFloatingPointRange<Float>) {
        _venueFilters.update { it.copy(priceRange = range, budgetRange = range) }
    }

    fun updateVenueBudgetType(type: BudgetType) {
        _venueFilters.update { it.copy(budgetType = type) }
    }

    fun updateVenuePriceRange(range: ClosedFloatingPointRange<Float>) {
        _venueFilters.update { it.copy(priceRange = range) }
    }

    fun updateVenueRatingRange(range: ClosedFloatingPointRange<Float>) {
        _venueFilters.update { it.copy(ratingRange = range) }
    }

    fun updateVenueFoodType(foodType: VenueFoodType) {
        _venueFilters.update { it.copy(foodType = foodType) }
    }

    fun updateVenueRoomsRequired(count: Int) {
        _venueFilters.update { it.copy(roomsRequired = count) }
    }

    fun toggleVenueType(type: VenueType) {
        _venueFilters.update {
            val current = it.selectedVenueTypes
            val next = if (current.contains(type)) current - type else current + type
            it.copy(selectedVenueTypes = next)
        }
    }

    fun toggleVenueRooms(enabled: Boolean) {
        _venueFilters.update { it.copy(isRoomsAvailable = enabled, isRoomsOnly = enabled) }
    }

    fun toggleVenueAlcohol(enabled: Boolean) {
        _venueFilters.update { it.copy(isAlcoholAllowed = enabled, isAlcoholAllowedOnly = enabled) }
    }

    fun toggleVenueDecor(enabled: Boolean) {
        _venueFilters.update { it.copy(isInHouseDecorOnly = enabled) }
    }

    fun toggleVenueAc(enabled: Boolean) {
        _venueFilters.update { it.copy(isAcOnly = enabled) }
    }

    fun toggleVenueValet(enabled: Boolean) {
        _venueFilters.update { it.copy(isValetParking = enabled) }
    }

    fun toggleVenueOutsideCatering(enabled: Boolean) {
        _venueFilters.update { it.copy(isOutsideCateringAllowed = enabled) }
    }

    fun toggleVenueMuhurtham(enabled: Boolean) {
        _venueFilters.update { it.copy(isMuhurthamAvailable = enabled) }
    }

    fun toggleVenueVegOnly(enabled: Boolean) {
        _venueFilters.update { it.copy(isVegOnlyVenue = enabled) }
    }

    fun toggleVenueOutsideDecor(enabled: Boolean) {
        _venueFilters.update { it.copy(isOutsideDecorAllowed = enabled) }
    }

    fun toggleVenueOutsideDj(enabled: Boolean) {
        _venueFilters.update { it.copy(isOutsideDjAllowed = enabled) }
    }

    // Photography filter updates
    fun togglePhotographyTravel(enabled: Boolean) {
        _photographyFilters.update { it.copy(isOutstationTravelIncluded = enabled) }
    }

    fun updatePhotographyTeamSize(size: String) {
        _photographyFilters.update { it.copy(teamSizeOption = size) }
    }

    fun togglePhotographyFullPackage(enabled: Boolean) {
        _photographyFilters.update { it.copy(isFullWeddingPackage = enabled) }
    }
    fun togglePhotographyStyle(style: PhotographyStyle) {
        _photographyFilters.update {
            val current = it.selectedStyles
            val next = if (current.contains(style)) current - style else current + style
            it.copy(selectedStyles = next)
        }
    }

    fun togglePhotographyTeaser(enabled: Boolean) {
        _photographyFilters.update {
            val next = if (enabled) it.selectedDeliverables + DeliverableType.TeaserReel else it.selectedDeliverables - DeliverableType.TeaserReel
            it.copy(selectedDeliverables = next, includeTeaserVideo = enabled)
        }
    }

    fun togglePhotographyRaw(enabled: Boolean) {
        _photographyFilters.update {
            val next = if (enabled) it.selectedDeliverables + DeliverableType.RawFootage else it.selectedDeliverables - DeliverableType.RawFootage
            it.copy(selectedDeliverables = next, includeRawFootage = enabled)
        }
    }

    fun togglePhotographyAlbum(enabled: Boolean) {
        _photographyFilters.update {
            val next = if (enabled) it.selectedDeliverables + DeliverableType.HardcoverAlbum else it.selectedDeliverables - DeliverableType.HardcoverAlbum
            it.copy(selectedDeliverables = next, includeHardcoverAlbum = enabled)
        }
    }

    fun updatePhotographyBudget(range: ClosedFloatingPointRange<Float>) {
        _photographyFilters.update { it.copy(budgetPerDay = range, budgetRange = range) }
    }

    fun updatePhotographyBudgetPerDay(range: ClosedFloatingPointRange<Float>) {
        _photographyFilters.update { it.copy(budgetPerDay = range) }
    }

    fun togglePhotographyDeliverable(deliverable: DeliverableType) {
        _photographyFilters.update {
            val current = it.selectedDeliverables
            val next = if (current.contains(deliverable)) current - deliverable else current + deliverable
            it.copy(
                selectedDeliverables = next,
                includeTeaserVideo = next.contains(DeliverableType.TeaserReel),
                includeRawFootage = next.contains(DeliverableType.RawFootage),
                includeHardcoverAlbum = next.contains(DeliverableType.HardcoverAlbum)
            )
        }
    }

    // Decor filter updates
    fun toggleDecorStyle(style: MandapStyle) {
        _decorFilters.update {
            val current = it.selectedMandapStyles
            val next = if (current.contains(style)) current - style else current + style
            
            // Synchronize selectedThemes for cross-compatibility
            val themeMap = mapOf(
                MandapStyle.Floral to DecorTheme.Floral,
                MandapStyle.Acrylic to DecorTheme.Acrylic,
                MandapStyle.Traditional to DecorTheme.Royal,
                MandapStyle.Boho to DecorTheme.RusticBoho
            )
            val themes = next.mapNotNull { themeMap[it] }.toSet()
            it.copy(selectedMandapStyles = next, selectedThemes = themes)
        }
    }

    fun toggleDecorTheme(theme: DecorTheme) {
        _decorFilters.update {
            val current = it.selectedThemes
            val next = if (current.contains(theme)) current - theme else current + theme
            
            val styleMap = mapOf(
                DecorTheme.Floral to MandapStyle.Floral,
                DecorTheme.Acrylic to MandapStyle.Acrylic,
                DecorTheme.Royal to MandapStyle.Traditional,
                DecorTheme.RusticBoho to MandapStyle.Boho
            )
            val styles = next.mapNotNull { styleMap[it] }.toSet()
            it.copy(selectedThemes = next, selectedMandapStyles = styles)
        }
    }

    fun toggleDecorOutdoor(enabled: Boolean) {
        _decorFilters.update {
            it.copy(
                isOutdoorOnly = enabled,
                setupLocation = if (enabled) SetupLocation.Outdoor else SetupLocation.Both
            )
        }
    }

    fun updateDecorSetupLocation(loc: SetupLocation) {
        _decorFilters.update {
            it.copy(
                setupLocation = loc,
                isOutdoorOnly = loc == SetupLocation.Outdoor
            )
        }
    }

    fun toggleDecorFloral(choice: String) {
        _decorFilters.update {
            val current = it.selectedFloralChoices
            val next = if (current.contains(choice)) current - choice else current + choice
            it.copy(selectedFloralChoices = next)
        }
    }

    fun toggleDecorComponent(comp: String) {
        _decorFilters.update {
            val current = it.selectedComponents
            val next = if (current.contains(comp)) current - comp else current + comp
            it.copy(selectedComponents = next)
        }
    }

    fun updateDecorBudgetRange(range: ClosedFloatingPointRange<Float>) {
        _decorFilters.update { it.copy(budgetRange = range) }
    }

    // Makeup filter updates
    fun updateMakeupBudget(range: ClosedFloatingPointRange<Float>) {
        _makeupFilters.update { it.copy(budgetPerSession = range) }
    }

    fun toggleMakeupType(type: MakeupType) {
        _makeupFilters.update {
            val current = it.selectedMakeupTypes
            val next = if (current.contains(type)) current - type else current + type
            it.copy(selectedMakeupTypes = next)
        }
    }

    fun toggleMakeupHair(enabled: Boolean) {
        _makeupFilters.update { it.copy(isHairStylingIncluded = enabled) }
    }

    fun toggleMakeupDraping(enabled: Boolean) {
        _makeupFilters.update { it.copy(isDrapingIncluded = enabled) }
    }

    fun toggleMakeupTrial(enabled: Boolean) {
        _makeupFilters.update { it.copy(isPaidTrialAvailable = enabled) }
    }

    fun toggleMakeupGroom(enabled: Boolean) {
        _makeupFilters.update { it.copy(isGroomMakeupIncluded = enabled) }
    }

    fun updateMakeupFamilyCount(count: Int) {
        _makeupFilters.update { it.copy(familyMakeupCount = count) }
    }

    fun toggleMakeupBrand(brand: String) {
        _makeupFilters.update {
            val current = it.selectedBrands
            val next = if (current.contains(brand)) current - brand else current + brand
            it.copy(selectedBrands = next)
        }
    }

    // Catering filter updates
    fun updateCateringPriceRange(range: ClosedFloatingPointRange<Float>) {
        _cateringFilters.update { it.copy(pricePerPlate = range) }
    }

    fun toggleCateringCuisine(cuisine: CuisineType) {
        _cateringFilters.update {
            val current = it.selectedCuisines
            val next = if (current.contains(cuisine)) current - cuisine else current + cuisine
            it.copy(selectedCuisines = next)
        }
    }

    fun updateCateringDietary(dietary: DietaryType) {
        _cateringFilters.update { it.copy(dietaryType = dietary) }
        if (dietary == DietaryType.Jain || dietary == DietaryType.StrictlyVeg) {
            _cateringFilters.update {
                it.copy(
                    selectedCuisines = it.selectedCuisines.filter { c -> c != CuisineType.Continental }.toSet()
                )
            }
        }
    }

    fun toggleCateringServiceStyle(style: String) {
        _cateringFilters.update {
            val current = it.selectedServiceStyles
            val next = if (current.contains(style)) current - style else current + style
            it.copy(selectedServiceStyles = next)
        }
    }

    fun toggleCateringWelcomeDrinks(enabled: Boolean) {
        _cateringFilters.update { it.copy(isWelcomeDrinksIncluded = enabled) }
    }

    fun toggleCateringSweetsBuffet(enabled: Boolean) {
        _cateringFilters.update { it.copy(isSweetsBuffetIncluded = enabled) }
    }

    fun resetFilters() {
        _venueFilters.value = CategoryFilterState.VenueFilters()
        _photographyFilters.value = CategoryFilterState.PhotographyFilters()
        _decorFilters.value = CategoryFilterState.DecorFilters()
        _makeupFilters.value = CategoryFilterState.MakeupArtistFilters()
        _cateringFilters.value = CategoryFilterState.CateringFilters()
    }
}
