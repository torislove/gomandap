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
            id = "venue_srinivasa_1",
            name = "Grand Srinivasa Kalyana Mandapam",
            locality = "Gachibowli Road, Hyderabad",
            basePrice = 90000.0,
            rating = 4.8f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1464366400600-7168b8af9bc3?q=80&w=2069&auto=format&fit=crop",
                "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            venueType = VenueType.Banquet,
            pricePerPlateVeg = 600.0,
            pricePerPlateNonVeg = 0.0,
            seatingCapacity = 800,
            floatingCapacity = 1500,
            hasRooms = true,
            parkingCount = 300,
            isAlcoholAllowed = false,
            decorPolicy = "Outside allowed"
        ),
        VenueVendor(
            id = "venue_heritage_1",
            name = "Heritage Gala Resort & Lawns",
            locality = "Jubilee Hills, Hyderabad",
            basePrice = 180000.0,
            rating = 4.7f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1507504031003-b417219a0fde?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            venueType = VenueType.Resort,
            pricePerPlateVeg = 1200.0,
            pricePerPlateNonVeg = 1600.0,
            seatingCapacity = 1000,
            floatingCapacity = 2000,
            hasRooms = true,
            parkingCount = 400,
            isAlcoholAllowed = true,
            decorPolicy = "Outside allowed"
        ),
        VenueVendor(
            id = "venue_lawn_1",
            name = "Grand Imperial Garden Lawns",
            locality = "Shamirpet, Hyderabad",
            basePrice = 120000.0,
            rating = 4.5f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1502635385003-ee1e6a1a742d?q=80&w=1974&auto=format&fit=crop"
            ),
            isEscrowProtected = false,
            isVerified = true,
            isFastFilling = true,
            venueType = VenueType.Lawn,
            pricePerPlateVeg = 950.0,
            pricePerPlateNonVeg = 1400.0,
            seatingCapacity = 2000,
            floatingCapacity = 3000,
            hasRooms = false,
            parkingCount = 600,
            isAlcoholAllowed = true,
            decorPolicy = "Panel decorators only"
        ),
        PhotographyVendor(
            id = "photo_light_1",
            name = "Lighthouse Wedding Studios",
            locality = "Madhapur, Hyderabad",
            basePrice = 85000.0,
            rating = 4.8f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1537633552985-df8429e8048b?q=80&w=2070&auto=format&fit=crop"
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
            id = "photo_hari_1",
            name = "Weddings by Hari & Co",
            locality = "Secunderabad",
            basePrice = 65000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=2069&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            style = listOf(PhotographyStyle.Traditional, PhotographyStyle.Candid, PhotographyStyle.PreWedding),
            pricePerDay = 35000.0,
            portfolioVideoUrl = "https://example.com/video2.mp4",
            deliveryTimeWeeks = 5
        ),
        DecorMandapVendor(
            id = "decor_floral_1",
            name = "Marigold & Mogra Floral Decor",
            locality = "Banjara Hills, Hyderabad",
            basePrice = 75000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1469334031218-e382a71b716b?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            mandapStyle = MandapStyle.Floral,
            dimensions = "30x30 ft",
            setupTimeHours = 6
        ),
        DecorMandapVendor(
            id = "decor_royal_1",
            name = "Royal Raj Traditional Mandaps",
            locality = "Begumpet, Hyderabad",
            basePrice = 140000.0,
            rating = 4.7f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1519225421980-715cb0215aed?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            mandapStyle = MandapStyle.Traditional,
            dimensions = "40x40 ft",
            setupTimeHours = 10
        ),
        CateringVendor(
            id = "cater_iyer_1",
            name = "Subramaniam Iyer Traditional Catering",
            locality = "Koti, Hyderabad",
            basePrice = 0.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=1936&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = false,
            cuisineTypes = listOf("South Indian", "Jain", "Strictly Veg", "Banana Leaf Service"),
            minGuestCount = 150,
            pricePerPlate = 450.0
        ),
        CateringVendor(
            id = "cater_spice_1",
            name = "Grand Mughal Spice Caterers & Buffet",
            locality = "Ameerpet, Hyderabad",
            basePrice = 0.0,
            rating = 4.8f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1555244162-803834f70033?q=80&w=2070&auto=format&fit=crop"
            ),
            isEscrowProtected = true,
            isVerified = true,
            isFastFilling = true,
            cuisineTypes = listOf("North Indian", "South Indian", "Mughlai", "Continental", "Standard Buffet"),
            minGuestCount = 200,
            pricePerPlate = 950.0
        ),
        MakeupArtistVendor(
            id = "makeup_kavya_1",
            name = "MAC & Huda Bridal Makeovers by Kavya",
            locality = "Jubilee Hills, Hyderabad",
            basePrice = 28000.0,
            rating = 4.9f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1487412947147-5cebf100ffc2?q=80&w=2071&auto=format&fit=crop"
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
            name = "Chanel & Kryolan Premium Studio",
            locality = "Madhapur, Hyderabad",
            basePrice = 18000.0,
            rating = 4.6f,
            imageUrls = listOf(
                "https://images.unsplash.com/photo-1596704017254-9b121068fb31?q=80&w=2000&auto=format&fit=crop"
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
