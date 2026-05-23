package com.gomandap.app.domain.model

import kotlinx.serialization.Serializable
import com.gomandap.app.presentation.search.MakeupType

@Serializable
enum class ApprovalStatus {
    DRAFT, PENDING_APPROVAL, APPROVED, REVISION_REQUESTED
}

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
    val videoUrl: String
    val details: Map<String, String>
}

@Serializable
enum class VenueType {
    Banquet, Lawn, Resort, Palace, Farmhouse
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
    
    // Expanded Rich Media & Approvals
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),
    
    val venueType: VenueType,
    val pricePerPlateVeg: Double,
    val pricePerPlateNonVeg: Double,
    val seatingCapacity: Int,
    val floatingCapacity: Int,
    val hasRooms: Boolean,
    val parkingCount: Int,
    val isAlcoholAllowed: Boolean,
    val decorPolicy: String
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
    
    // Expanded Rich Media & Approvals
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),
    
    val style: List<PhotographyStyle>,
    val pricePerDay: Double,
    val portfolioVideoUrl: String,
    val deliveryTimeWeeks: Int
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
    
    // Expanded Rich Media & Approvals
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),
    
    val mandapStyle: MandapStyle,
    val dimensions: String, // e.g. "20x20 ft"
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
    
    // Expanded Rich Media & Approvals
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),
    
    val cuisineTypes: List<String>, // e.g. "North Indian", "South Indian", "Mughlai"
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
    
    // Expanded Rich Media & Approvals
    override val approvalStatus: ApprovalStatus = ApprovalStatus.APPROVED,
    override val adminNotes: String = "",
    override val isLive: Boolean = true,
    override val photos: List<String> = emptyList(),
    override val videoUrl: String = "",
    override val details: Map<String, String> = emptyMap(),
    
    val makeupTypes: List<MakeupType>,
    val isHairStylingIncluded: Boolean,
    val isDrapingIncluded: Boolean,
    val isPaidTrialAvailable: Boolean
) : Vendor
