package com.gomandap.app.domain.model

import kotlinx.serialization.Serializable
import com.gomandap.app.presentation.search.MakeupType

@Serializable
enum class ApprovalStatus {
    DRAFT, PENDING_APPROVAL, APPROVED, REVISION_REQUESTED
}

@Serializable
data class EventSpace(
    val name: String,
    val type: String, // e.g. "Hall", "Lawn", "Poolside"
    val seatingCapacity: Int,
    val floatingCapacity: Int
)

@Serializable
sealed interface Vendor {
    val id: String
    val name: String
    val locality: String
    val basePrice: Double
    val rating: Float
    val imageUrls: List<String>
    val isEscrowProtected: Boolean
    val isVerified: Boolean
    val isFastFilling: Boolean
    
    // Expanded Rich Media & Approvals
    val approvalStatus: ApprovalStatus
    val adminNotes: String
    val isLive: Boolean
    val photos: List<String>
    val coverPhotoUrl: String
    val videoUrl: String
    val details: Map<String, String>

    // Advanced Universal Fields
    val yearEstablished: Int
    val instagramUrl: String
    val googleMapsUrl: String
    val paymentAdvancePercent: Int
    val cancellationPolicy: String

    // Location asking details
    val fullAddress: String
    val city: String
    val state: String
    val pincode: String
    val landmark: String

    // Contact Details
    val mobileNumber: String
    val emailId: String
    val whatsAppNumber: String

    // Banking & Payout Credentials
    val bankAccountName: String
    val bankAccountNumber: String
    val bankName: String
    val bankIfscCode: String
    val upiId: String
}

@Serializable
enum class VenueType {
    BanquetHall, MarriageGardenLawn, WeddingResort, PalaceFort, KalyanaMandapam, CommunityTempleHall, LuxuryHotel
}

@Serializable
enum class MandapStyle {
    Floral, Acrylic, Traditional, Boho
}

@Serializable
enum class PhotographyStyle {
    Cinematic, Candid, Drone, Traditional, PreWedding
}

@Serializable
data class VenueVendor(
    override val id: String,
    override val name: String,
    override val locality: String,
    override val basePrice: Double,
    override val rating: Float,
    override val imageUrls: List<String>,
    override val isEscrowProtected: Boolean,
    override val isVerified: Boolean,
    override val isFastFilling: Boolean,
    
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val coverPhotoUrl: String = "",
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),

    override val yearEstablished: Int = 2015,
    override val instagramUrl: String = "",
    override val googleMapsUrl: String = "",
    override val paymentAdvancePercent: Int = 50,
    override val cancellationPolicy: String = "Non-Refundable",
    
    // Expanded Location & Contacts (with default fallbacks)
    override val fullAddress: String = "",
    override val city: String = "",
    override val state: String = "",
    override val pincode: String = "",
    override val landmark: String = "",
    override val mobileNumber: String = "",
    override val emailId: String = "",
    override val whatsAppNumber: String = "",

    // Expanded Bank details
    override val bankAccountName: String = "",
    override val bankAccountNumber: String = "",
    override val bankName: String = "",
    override val bankIfscCode: String = "",
    override val upiId: String = "",

    val venueType: VenueType,
    val pricePerPlateVeg: Double,
    val pricePerPlateNonVeg: Double,
    val spaces: List<EventSpace> = emptyList(),
    val hasRooms: Boolean,
    val roomCount: Int = 0,
    val parkingCount: Int,
    val isAlcoholAllowed: Boolean,
    val decorPolicy: String,
    val djPolicy: String = "In-house only",
    val generatorBackup: Boolean = true,

    // Specific Venue Type Fields
    val acCapacity: Int = 0,
    val totalLawnArea: String = "",
    val rainProtection: Boolean = false,
    val roomConfigurations: String = "",
    val poolSideEvent: Boolean = false,
    val heritageCategory: String = "",
    val royalEntryCarriage: Boolean = false,
    val traditionalLayout: Boolean = false,
    val poojaPackage: Boolean = false,
    val basicRentModel: String = "",
    val starRating: String = "",
    val soundproofCurfew: String = ""
) : Vendor

@Serializable
data class PhotographyVendor(
    override val id: String,
    override val name: String,
    override val locality: String,
    override val basePrice: Double,
    override val rating: Float,
    override val imageUrls: List<String>,
    override val isEscrowProtected: Boolean,
    override val isVerified: Boolean,
    override val isFastFilling: Boolean,
    
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val coverPhotoUrl: String = "",
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),

    override val yearEstablished: Int = 2015,
    override val instagramUrl: String = "",
    override val googleMapsUrl: String = "",
    override val paymentAdvancePercent: Int = 50,
    override val cancellationPolicy: String = "Non-Refundable",
    
    // Expanded Location & Contacts (with default fallbacks)
    override val fullAddress: String = "",
    override val city: String = "",
    override val state: String = "",
    override val pincode: String = "",
    override val landmark: String = "",
    override val mobileNumber: String = "",
    override val emailId: String = "",
    override val whatsAppNumber: String = "",

    // Expanded Bank details
    override val bankAccountName: String = "",
    override val bankAccountNumber: String = "",
    override val bankName: String = "",
    override val bankIfscCode: String = "",
    override val upiId: String = "",

    val style: List<PhotographyStyle>,
    val pricePhotoOnly: Double = 0.0,
    val priceVideoOnly: Double = 0.0,
    val priceCombo: Double = 0.0,
    val portfolioVideoUrl: String,
    val deliveryTimeWeeks: Int,
    val clientBearsTravelCost: Boolean = true,
    val includesAlbum: Boolean = true
) : Vendor

@Serializable
data class DecorMandapVendor(
    override val id: String,
    override val name: String,
    override val locality: String,
    override val basePrice: Double,
    override val rating: Float,
    override val imageUrls: List<String>,
    override val isEscrowProtected: Boolean,
    override val isVerified: Boolean,
    override val isFastFilling: Boolean,
    
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val coverPhotoUrl: String = "",
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),

    override val yearEstablished: Int = 2015,
    override val instagramUrl: String = "",
    override val googleMapsUrl: String = "",
    override val paymentAdvancePercent: Int = 50,
    override val cancellationPolicy: String = "Non-Refundable",
    
    // Expanded Location & Contacts (with default fallbacks)
    override val fullAddress: String = "",
    override val city: String = "",
    override val state: String = "",
    override val pincode: String = "",
    override val landmark: String = "",
    override val mobileNumber: String = "",
    override val emailId: String = "",
    override val whatsAppNumber: String = "",

    // Expanded Bank details
    override val bankAccountName: String = "",
    override val bankAccountNumber: String = "",
    override val bankName: String = "",
    override val bankIfscCode: String = "",
    override val upiId: String = "",

    val mandapStyle: List<MandapStyle>,
    val specialties: List<String> = emptyList(),
    val minimumBudget: Double = 50000.0,
    val dimensions: String,
    val setupTimeHours: Int
) : Vendor

@Serializable
data class CateringVendor(
    override val id: String,
    override val name: String,
    override val locality: String,
    override val basePrice: Double,
    override val rating: Float,
    override val imageUrls: List<String>,
    override val isEscrowProtected: Boolean,
    override val isVerified: Boolean,
    override val isFastFilling: Boolean,
    
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val coverPhotoUrl: String = "",
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),

    override val yearEstablished: Int = 2015,
    override val instagramUrl: String = "",
    override val googleMapsUrl: String = "",
    override val paymentAdvancePercent: Int = 50,
    override val cancellationPolicy: String = "Non-Refundable",
    
    // Expanded Location & Contacts (with default fallbacks)
    override val fullAddress: String = "",
    override val city: String = "",
    override val state: String = "",
    override val pincode: String = "",
    override val landmark: String = "",
    override val mobileNumber: String = "",
    override val emailId: String = "",
    override val whatsAppNumber: String = "",

    // Expanded Bank details
    override val bankAccountName: String = "",
    override val bankAccountNumber: String = "",
    override val bankName: String = "",
    override val bankIfscCode: String = "",
    override val upiId: String = "",

    val cuisineTypes: List<String>,
    val serviceTypes: List<String> = emptyList(),
    val includesCrockery: Boolean = true,
    val waitstaffCount: Int = 10,
    val minGuestCount: Int,
    val pricePerPlate: Double
) : Vendor

@Serializable
data class MakeupArtistVendor(
    override val id: String,
    override val name: String,
    override val locality: String,
    override val basePrice: Double,
    override val rating: Float,
    override val imageUrls: List<String>,
    override val isEscrowProtected: Boolean,
    override val isVerified: Boolean,
    override val isFastFilling: Boolean,
    
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val coverPhotoUrl: String = "",
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),

    override val yearEstablished: Int = 2015,
    override val instagramUrl: String = "",
    override val googleMapsUrl: String = "",
    override val paymentAdvancePercent: Int = 50,
    override val cancellationPolicy: String = "Non-Refundable",
    
    // Expanded Location & Contacts (with default fallbacks)
    override val fullAddress: String = "",
    override val city: String = "",
    override val state: String = "",
    override val pincode: String = "",
    override val landmark: String = "",
    override val mobileNumber: String = "",
    override val emailId: String = "",
    override val whatsAppNumber: String = "",

    // Expanded Bank details
    override val bankAccountName: String = "",
    override val bankAccountNumber: String = "",
    override val bankName: String = "",
    override val bankIfscCode: String = "",
    override val upiId: String = "",

    val makeupTypes: List<MakeupType>,
    val isHairStylingIncluded: Boolean,
    val isDrapingIncluded: Boolean,
    val isPaidTrialAvailable: Boolean,
    val studioPrice: Double = 15000.0,
    val venuePrice: Double = 20000.0,
    val partyMakeupPrice: Double = 3500.0
) : Vendor
