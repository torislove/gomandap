package com.gomandap.app.data.mock

import android.content.Context
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.MakeupType
import kotlinx.serialization.builtins.ListSerializer
import kotlinx.serialization.json.Json

object MockDataStore {

    private const val PREFS_NAME = "gomandap_catalog_prefs"
    private const val KEY_VENDOR_CATALOG = "vendor_catalog_json"

    private val json = Json {
        prettyPrint = true
        ignoreUnknownKeys = true
        classDiscriminator = "type"
    }

    private val defaultVendors: List<Vendor> = listOf(
        VenueVendor(
            id = "venue_taj_1",
            name = "The Taj Palace Convention",
            locality = "Banjara Hills, Hyderabad",
            basePrice = 250000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=2098&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1544078755-9ee020cda4fb?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            venueType = VenueType.Palace,
            pricePerPlateVeg = 1500.0,
            pricePerPlateNonVeg = 2000.0,
            seatingCapacity = 1200,
            floatingCapacity = 2000,
            hasRooms = true,
            parkingCount = 500,
            isAlcoholAllowed = true,
            decorPolicy = "In-house only"
        ),
        VenueVendor(
            id = "venue_heritage_1",
            name = "Heritage Gala Resort",
            locality = "Jubilee Hills, Hyderabad",
            basePrice = 180000.0,
            rating = 4.7f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1507504031003-b417219a0fde?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            venueType = VenueType.Resort,
            pricePerPlateVeg = 1200.0,
            pricePerPlateNonVeg = 1600.0,
            seatingCapacity = 800,
            floatingCapacity = 1200,
            hasRooms = true,
            parkingCount = 300,
            isAlcoholAllowed = false,
            decorPolicy = "Outside allowed"
        ),
        VenueVendor(
            id = "venue_lawn_1",
            name = "Grand Imperial Gardens",
            locality = "Gachibowli, Hyderabad",
            basePrice = 120000.0,
            rating = 4.5f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1502635385003-ee1e6a1a742d?q=80&w=1974&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = false,
            isVerified = true,
            isFastFilling = true,
            venueType = VenueType.Lawn,
            pricePerPlateVeg = 900.0,
            pricePerPlateNonVeg = 1300.0,
            seatingCapacity = 2000,
            floatingCapacity = 3000,
            hasRooms = false,
            parkingCount = 800,
            isAlcoholAllowed = true,
            decorPolicy = "Panel decorators only"
        ),
        PhotographyVendor(
            id = "photo_light_1",
            name = "Lighthouse Studios",
            locality = "Madhapur, Hyderabad",
            basePrice = 85000.0,
            rating = 4.8f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1537633552985-df8429e8048b?q=80&w=2070&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1606800052052-a08af7148866?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            style = listOf(PhotographyStyle.Cinematic, PhotographyStyle.Candid, PhotographyStyle.Drone),
            pricePerDay = 45000.0,
            portfolioVideoUrl = "https://example.com/video1.mp4",
            deliveryTimeWeeks = 4
        ),
        PhotographyVendor(
            id = "photo_classic_1",
            name = "Classic Memories",
            locality = "Kukatpally, Hyderabad",
            basePrice = 55000.0,
            rating = 4.6f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1520854221256-17451cc331bf?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = false,
            isVerified = true,
            isFastFilling = false,
            style = listOf(PhotographyStyle.Traditional, PhotographyStyle.PreWedding),
            pricePerDay = 25000.0,
            portfolioVideoUrl = "https://example.com/video2.mp4",
            deliveryTimeWeeks = 3
        ),
        DecorMandapVendor(
            id = "decor_floral_1",
            name = "Petal Palace Decorators",
            locality = "Banjara Hills, Hyderabad",
            basePrice = 75000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=2069&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            mandapStyle = MandapStyle.Floral,
            dimensions = "30x30 ft",
            setupTimeHours = 8
        ),
        DecorMandapVendor(
            id = "decor_royal_1",
            name = "Royal Raj Mandaps",
            locality = "Secunderabad",
            basePrice = 110000.0,
            rating = 4.7f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1544078755-9ee020cda4fb?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            mandapStyle = MandapStyle.Traditional,
            dimensions = "40x40 ft",
            setupTimeHours = 12
        ),
        CateringVendor(
            id = "cater_spice_1",
            name = "Royal Spice Caterers",
            locality = "Ameerpet, Hyderabad",
            basePrice = 0.0,
            rating = 4.8f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=2070&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1547496502-affa22d38842?q=80&w=2177&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            cuisineTypes = listOf("North Indian", "South Indian", "Mughlai", "Continental"),
            minGuestCount = 200,
            pricePerPlate = 1200.0
        ),
        CateringVendor(
            id = "cater_pureveg_1",
            name = "Sattvic Pure Veg Catering",
            locality = "Koti, Hyderabad",
            basePrice = 0.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=1936&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1626776876729-bab4369a5a5a?q=80&w=1974&auto=format&fit=crop"
            ),
            isEscrowProtected = false,
            isVerified = true,
            isFastFilling = false,
            cuisineTypes = listOf("South Indian", "Gujarati", "Jain"),
            minGuestCount = 100,
            pricePerPlate = 800.0
        ),
        MakeupArtistVendor(
            id = "makeup_glam_1",
            name = "Glamour By Sarah",
            locality = "Jubilee Hills, Hyderabad",
            basePrice = 25000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?q=80&w=2071&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1512496015851-a1cbfc854b7c?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            makeupTypes = listOf(MakeupType.Airbrush, MakeupType.HDMakeup),
            isHairStylingIncluded = true,
            isDrapingIncluded = true,
            isPaidTrialAvailable = true
        ),
        MakeupArtistVendor(
            id = "makeup_elegance_1",
            name = "Elegance Bridal Studio",
            locality = "Madhapur, Hyderabad",
            basePrice = 15000.0,
            rating = 4.6f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1596704017254-9b121068fb31?q=80&w=2000&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1522337660859-02fbefca4702?q=80&w=2069&auto=format&fit=crop"
            ),
            isEscrowProtected = false,
            isVerified = true,
            isFastFilling = false,
            makeupTypes = listOf(MakeupType.HDMakeup, MakeupType.RegularBridal),
            isHairStylingIncluded = false,
            isDrapingIncluded = true,
            isPaidTrialAvailable = false
        )
    )

    var allVendors: List<Vendor> = defaultVendors
        private set

    fun initialize(context: Context) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val savedCatalog = prefs.getString(KEY_VENDOR_CATALOG, null)

        allVendors = if (savedCatalog.isNullOrBlank()) {
            defaultVendors
        } else {
            runCatching {
                json.decodeFromString(ListSerializer(Vendor.serializer()), savedCatalog)
            }.getOrElse { defaultVendors }
        }
    }

    fun saveCatalog(context: Context, vendors: List<Vendor>) {
        allVendors = vendors
        context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            .edit()
            .putString(KEY_VENDOR_CATALOG, json.encodeToString(ListSerializer(Vendor.serializer()), vendors))
            .apply()
    }

    fun updateVendor(context: Context, vendorId: String, transform: (Vendor) -> Vendor) {
        allVendors = allVendors.map { vendor ->
            if (vendor.id == vendorId) transform(vendor) else vendor
        }
        saveCatalog(context, allVendors)
    }

    fun getVendorById(id: String): Vendor {
        return allVendors.find { it.id == id } ?: allVendors.first()
    }
}
