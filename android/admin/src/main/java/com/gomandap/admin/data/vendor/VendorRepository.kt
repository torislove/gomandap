package com.gomandap.admin.data.vendor

import android.content.Context
import com.gomandap.app.domain.model.*
import com.gomandap.app.presentation.search.MakeupType
import com.google.firebase.firestore.DocumentSnapshot
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

object VendorRepository {

    private val _vendors = MutableStateFlow<List<Vendor>>(emptyList())
    val vendors: StateFlow<List<Vendor>> = _vendors

    private var appContext: Context? = null
    private val db = FirebaseFirestore.getInstance()
    private val vendorsCollection = db.collection("vendors")
    private val repositoryScope = CoroutineScope(Dispatchers.IO)

    fun initialize(context: Context) {
        appContext = context.applicationContext
        vendorsCollection.addSnapshotListener { snapshot, error ->
            if (error != null) return@addSnapshotListener
            val list = snapshot?.documents?.mapNotNull { doc ->
                runCatching { doc.toVendor() }.getOrNull()
            } ?: emptyList()
            _vendors.value = list
        }
    }

    fun currentVendors(): List<Vendor> = _vendors.value

    fun getVendorById(id: String): Vendor? = _vendors.value.firstOrNull { it.id == id }

    suspend fun refresh() {
        // Real-time listener handles sync dynamically
    }

    suspend fun updateVendor(vendorId: String, transform: (Vendor) -> Vendor) = withContext(Dispatchers.IO) {
        val current = getVendorById(vendorId) ?: return@withContext
        val updated = transform(current)
        val data = updated.toFirestoreMap()
        vendorsCollection.document(vendorId).set(data).await()
    }

    suspend fun registerVendor(vendor: Vendor) = withContext(Dispatchers.IO) {
        val data = vendor.toFirestoreMap()
        vendorsCollection.document(vendor.id).set(data).await()
    }

    // ─── Mapping: Firestore Document → Vendor Domain Object ─────────────────

    @Suppress("UNCHECKED_CAST")
    private fun DocumentSnapshot.toVendor(): Vendor {
        val id = this.id
        val type = getString("type") ?: "Banquet"
        val name = getString("name") ?: ""
        val locality = getString("locality") ?: ""
        val basePrice = getDouble("basePrice") ?: 0.0
        val rating = (getDouble("rating") ?: 5.0).toFloat()
        val imageUrls = (get("imageUrls") as? List<String>) ?: emptyList()
        val isEscrowProtected = getBoolean("isEscrowProtected") ?: false
        val isVerified = getBoolean("isVerified") ?: false
        val isFastFilling = getBoolean("isFastFilling") ?: false
        val approvalStatus = when (getString("approvalStatus")) {
            "APPROVED" -> ApprovalStatus.APPROVED
            "REVISION_REQUESTED" -> ApprovalStatus.REVISION_REQUESTED
            else -> ApprovalStatus.PENDING_APPROVAL
        }
        val isLive = getBoolean("isLive") ?: false
        val photos = (get("photos") as? List<String>) ?: emptyList()
        val videoUrl = getString("videoUrl") ?: ""
        val coverPhotoUrl = getString("coverPhotoUrl") ?: ""
        val details = (get("details") as? Map<String, String>) ?: emptyMap()
        val adminNotes = getString("adminNotes") ?: ""
        val yearEstablished = getLong("yearEstablished")?.toInt() ?: 2024
        val instagramUrl = getString("instagramUrl") ?: ""
        val googleMapsUrl = getString("googleMapsUrl") ?: ""
        val paymentAdvancePercent = getLong("paymentAdvancePercent")?.toInt() ?: 50
        val cancellationPolicy = getString("cancellationPolicy") ?: "Non-Refundable"

        // Location fields
        val fullAddress = getString("fullAddress") ?: ""
        val city = getString("city") ?: ""
        val state = getString("state") ?: ""
        val pincode = getString("pincode") ?: ""
        val landmark = getString("landmark") ?: ""

        // Contact fields
        val mobileNumber = getString("mobileNumber") ?: ""
        val emailId = getString("emailId") ?: ""
        val whatsAppNumber = getString("whatsAppNumber") ?: ""

        // Banking fields
        val bankAccountName = getString("bankAccountName") ?: ""
        val bankAccountNumber = getString("bankAccountNumber") ?: ""
        val bankName = getString("bankName") ?: ""
        val bankIfscCode = getString("bankIfscCode") ?: ""
        val upiId = getString("upiId") ?: ""

        val geohash = getString("geohash") ?: ""
        val gstin = getString("gstin") ?: ""
        val fssaiLicense = getString("fssaiLicense") ?: ""
        val beforeAfterImagesRaw = (get("beforeAfterImages") as? List<Map<String, Any>>) ?: emptyList()
        val beforeAfterImages = beforeAfterImagesRaw.map { map ->
            map.mapValues { it.value.toString() }
        }

        return when (type) {
            "Banquet" -> {
                val spacesRaw = (get("spaces") as? List<Map<String, Any>>) ?: emptyList()
                val spaces = spacesRaw.map { s ->
                    EventSpace(
                        name = s["name"] as? String ?: "",
                        type = s["type"] as? String ?: "Hall",
                        seatingCapacity = (s["seatingCapacity"] as? Long)?.toInt() ?: 0,
                        floatingCapacity = (s["floatingCapacity"] as? Long)?.toInt() ?: 0
                    )
                }
                VenueVendor(
                    id = id, name = name, locality = locality, basePrice = basePrice, rating = rating,
                    imageUrls = imageUrls, isEscrowProtected = isEscrowProtected, isVerified = isVerified,
                    isFastFilling = isFastFilling, approvalStatus = approvalStatus, isLive = isLive,
                    photos = photos, videoUrl = videoUrl, coverPhotoUrl = coverPhotoUrl, details = details,
                    adminNotes = adminNotes, yearEstablished = yearEstablished,
                    instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                    paymentAdvancePercent = paymentAdvancePercent, cancellationPolicy = cancellationPolicy,
                    
                    fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                    mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                    bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                    bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,
                    geohash = geohash, gstin = gstin, fssaiLicense = fssaiLicense, beforeAfterImages = beforeAfterImages,

                    venueType = run {
                        val typeStr = getString("venueType") ?: "BanquetHall"
                        val mappedStr = when(typeStr) {
                            "Banquet" -> "BanquetHall"
                            "Lawn" -> "MarriageGardenLawn"
                            "Resort" -> "WeddingResort"
                            "Palace" -> "PalaceFort"
                            else -> typeStr
                        }
                        runCatching { VenueType.valueOf(mappedStr) }.getOrDefault(VenueType.BanquetHall)
                    },
                    pricePerPlateVeg = getDouble("pricePerPlateVeg") ?: 0.0,
                    pricePerPlateNonVeg = getDouble("pricePerPlateNonVeg") ?: 0.0,
                    hasRooms = getBoolean("hasRooms") ?: false,
                    roomCount = getLong("roomCount")?.toInt() ?: 0,
                    parkingCount = getLong("parkingCount")?.toInt() ?: 0,
                    isAlcoholAllowed = getBoolean("isAlcoholAllowed") ?: false,
                    decorPolicy = getString("decorPolicy") ?: "",
                    djPolicy = getString("djPolicy") ?: "",
                    generatorBackup = getBoolean("generatorBackup") ?: false,
                    spaces = spaces,

                    // Specific Venue Type Fields
                    acCapacity = getLong("acCapacity")?.toInt() ?: 0,
                    totalLawnArea = getString("totalLawnArea") ?: "",
                    rainProtection = getBoolean("rainProtection") ?: false,
                    roomConfigurations = getString("roomConfigurations") ?: "",
                    poolSideEvent = getBoolean("poolSideEvent") ?: false,
                    heritageCategory = getString("heritageCategory") ?: "",
                    royalEntryCarriage = getBoolean("royalEntryCarriage") ?: false,
                    traditionalLayout = getBoolean("traditionalLayout") ?: false,
                    poojaPackage = getBoolean("poojaPackage") ?: false,
                    basicRentModel = getString("basicRentModel") ?: "",
                    starRating = getString("starRating") ?: "",
                    soundproofCurfew = getString("soundproofCurfew") ?: ""
                )
            }
            "Photography" -> PhotographyVendor(
                id = id, name = name, locality = locality, basePrice = basePrice, rating = rating,
                imageUrls = imageUrls, isEscrowProtected = isEscrowProtected, isVerified = isVerified,
                isFastFilling = isFastFilling, approvalStatus = approvalStatus, isLive = isLive,
                photos = photos, videoUrl = videoUrl, coverPhotoUrl = coverPhotoUrl, details = details,
                adminNotes = adminNotes, yearEstablished = yearEstablished,
                instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                paymentAdvancePercent = paymentAdvancePercent, cancellationPolicy = cancellationPolicy,

                fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,
                geohash = geohash, gstin = gstin, fssaiLicense = fssaiLicense, beforeAfterImages = beforeAfterImages,

                style = ((get("style") as? List<String>) ?: emptyList()).mapNotNull {
                    runCatching { PhotographyStyle.valueOf(it) }.getOrNull()
                },
                pricePhotoOnly = getDouble("pricePhotoOnly") ?: basePrice,
                priceVideoOnly = getDouble("priceVideoOnly") ?: basePrice,
                priceCombo = getDouble("priceCombo") ?: basePrice,
                portfolioVideoUrl = videoUrl,
                deliveryTimeWeeks = getLong("deliveryTimeWeeks")?.toInt() ?: 4,
                clientBearsTravelCost = getBoolean("clientBearsTravelCost") ?: true,
                includesAlbum = getBoolean("includesAlbum") ?: false
            )
            "Decorator" -> DecorMandapVendor(
                id = id, name = name, locality = locality, basePrice = basePrice, rating = rating,
                imageUrls = imageUrls, isEscrowProtected = isEscrowProtected, isVerified = isVerified,
                isFastFilling = isFastFilling, approvalStatus = approvalStatus, isLive = isLive,
                photos = photos, videoUrl = videoUrl, coverPhotoUrl = coverPhotoUrl, details = details,
                adminNotes = adminNotes, yearEstablished = yearEstablished,
                instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                paymentAdvancePercent = paymentAdvancePercent, cancellationPolicy = cancellationPolicy,

                fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,
                geohash = geohash, gstin = gstin, fssaiLicense = fssaiLicense, beforeAfterImages = beforeAfterImages,

                mandapStyle = ((get("mandapStyle") as? List<String>) ?: emptyList()).mapNotNull {
                    runCatching { MandapStyle.valueOf(it) }.getOrNull()
                },
                dimensions = getString("dimensions") ?: "",
                setupTimeHours = getLong("setupTimeHours")?.toInt() ?: 6,
                specialties = (get("specialties") as? List<String>) ?: emptyList(),
                minimumBudget = getDouble("minimumBudget") ?: basePrice
            )
            "Catering" -> CateringVendor(
                id = id, name = name, locality = locality, basePrice = basePrice, rating = rating,
                imageUrls = imageUrls, isEscrowProtected = isEscrowProtected, isVerified = isVerified,
                isFastFilling = isFastFilling, approvalStatus = approvalStatus, isLive = isLive,
                photos = photos, videoUrl = videoUrl, coverPhotoUrl = coverPhotoUrl, details = details,
                adminNotes = adminNotes, yearEstablished = yearEstablished,
                instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                paymentAdvancePercent = paymentAdvancePercent, cancellationPolicy = cancellationPolicy,

                fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,
                geohash = geohash, gstin = gstin, fssaiLicense = fssaiLicense, beforeAfterImages = beforeAfterImages,

                cuisineTypes = (get("cuisineTypes") as? List<String>) ?: emptyList(),
                serviceTypes = (get("serviceTypes") as? List<String>) ?: emptyList(),
                minGuestCount = getLong("minGuestCount")?.toInt() ?: 100,
                pricePerPlate = getDouble("pricePerPlate") ?: 0.0,
                includesCrockery = getBoolean("includesCrockery") ?: false,
                waitstaffCount = getLong("waitstaffCount")?.toInt() ?: 10
            )
            else -> MakeupArtistVendor(
                id = id, name = name, locality = locality, basePrice = basePrice, rating = rating,
                imageUrls = imageUrls, isEscrowProtected = isEscrowProtected, isVerified = isVerified,
                isFastFilling = isFastFilling, approvalStatus = approvalStatus, isLive = isLive,
                photos = photos, videoUrl = videoUrl, coverPhotoUrl = coverPhotoUrl, details = details,
                adminNotes = adminNotes, yearEstablished = yearEstablished,
                instagramUrl = instagramUrl, googleMapsUrl = googleMapsUrl,
                paymentAdvancePercent = paymentAdvancePercent, cancellationPolicy = cancellationPolicy,

                fullAddress = fullAddress, city = city, state = state, pincode = pincode, landmark = landmark,
                mobileNumber = mobileNumber, emailId = emailId, whatsAppNumber = whatsAppNumber,
                bankAccountName = bankAccountName, bankAccountNumber = bankAccountNumber,
                bankName = bankName, bankIfscCode = bankIfscCode, upiId = upiId,
                geohash = geohash, gstin = gstin, fssaiLicense = fssaiLicense, beforeAfterImages = beforeAfterImages,

                makeupTypes = ((get("makeupTypes") as? List<String>) ?: emptyList()).mapNotNull {
                    runCatching { MakeupType.valueOf(it) }.getOrNull()
                },
                isHairStylingIncluded = getBoolean("isHairStylingIncluded") ?: false,
                isDrapingIncluded = getBoolean("isDrapingIncluded") ?: false,
                isPaidTrialAvailable = getBoolean("isPaidTrialAvailable") ?: false,
                studioPrice = getDouble("studioPrice") ?: basePrice,
                venuePrice = getDouble("venuePrice") ?: basePrice,
                partyMakeupPrice = getDouble("partyMakeupPrice") ?: 0.0
            )
        }
    }

    // ─── Mapping: Vendor Domain Object → Firestore Map ──────────────────────

    private fun Vendor.toFirestoreMap(): Map<String, Any?> {
        val base = mutableMapOf<String, Any?>(
            "id" to id,
            "name" to name,
            "locality" to locality,
            "basePrice" to basePrice,
            "rating" to rating,
            "imageUrls" to imageUrls,
            "isEscrowProtected" to isEscrowProtected,
            "isVerified" to isVerified,
            "isFastFilling" to isFastFilling,
            "approvalStatus" to approvalStatus.name,
            "isLive" to isLive,
            "photos" to photos,
            "videoUrl" to videoUrl,
            "coverPhotoUrl" to coverPhotoUrl,
            "details" to details,
            "adminNotes" to adminNotes,
            "yearEstablished" to yearEstablished,
            "instagramUrl" to instagramUrl,
            "googleMapsUrl" to googleMapsUrl,
            "paymentAdvancePercent" to paymentAdvancePercent,
            "cancellationPolicy" to cancellationPolicy,

            // New locations, contacts, and banking fields
            "fullAddress" to fullAddress,
            "city" to city,
            "state" to state,
            "pincode" to pincode,
            "landmark" to landmark,
            "mobileNumber" to mobileNumber,
            "emailId" to emailId,
            "whatsAppNumber" to whatsAppNumber,
            "bankAccountName" to bankAccountName,
            "bankAccountNumber" to bankAccountNumber,
            "bankName" to bankName,
            "bankIfscCode" to bankIfscCode,
            "upiId" to upiId,
            "geohash" to geohash,
            "gstin" to gstin,
            "fssaiLicense" to fssaiLicense,
            "beforeAfterImages" to beforeAfterImages,

            "createdAt" to com.google.firebase.Timestamp.now(),
            "updatedAt" to com.google.firebase.Timestamp.now()
        )

        when (this) {
            is VenueVendor -> {
                base["type"] = "Banquet"
                base["venueType"] = venueType.name
                base["pricePerPlateVeg"] = pricePerPlateVeg
                base["pricePerPlateNonVeg"] = pricePerPlateNonVeg
                base["hasRooms"] = hasRooms
                base["roomCount"] = roomCount
                base["parkingCount"] = parkingCount
                base["isAlcoholAllowed"] = isAlcoholAllowed
                base["decorPolicy"] = decorPolicy
                base["djPolicy"] = djPolicy
                base["generatorBackup"] = generatorBackup
                base["spaces"] = spaces.map { s ->
                    mapOf("name" to s.name, "type" to s.type,
                        "seatingCapacity" to s.seatingCapacity, "floatingCapacity" to s.floatingCapacity)
                }

                // Dynamic venue fields mapping
                base["acCapacity"] = acCapacity
                base["totalLawnArea"] = totalLawnArea
                base["rainProtection"] = rainProtection
                base["roomConfigurations"] = roomConfigurations
                base["poolSideEvent"] = poolSideEvent
                base["heritageCategory"] = heritageCategory
                base["royalEntryCarriage"] = royalEntryCarriage
                base["traditionalLayout"] = traditionalLayout
                base["poojaPackage"] = poojaPackage
                base["basicRentModel"] = basicRentModel
                base["starRating"] = starRating
                base["soundproofCurfew"] = soundproofCurfew
            }
            is PhotographyVendor -> {
                base["type"] = "Photography"
                base["style"] = style.map { it.name }
                base["pricePhotoOnly"] = pricePhotoOnly
                base["priceVideoOnly"] = priceVideoOnly
                base["priceCombo"] = priceCombo
                base["deliveryTimeWeeks"] = deliveryTimeWeeks
                base["clientBearsTravelCost"] = clientBearsTravelCost
                base["includesAlbum"] = includesAlbum
            }
            is DecorMandapVendor -> {
                base["type"] = "Decorator"
                base["mandapStyle"] = mandapStyle.map { it.name }
                base["dimensions"] = dimensions
                base["setupTimeHours"] = setupTimeHours
                base["specialties"] = specialties
                base["minimumBudget"] = minimumBudget
            }
            is CateringVendor -> {
                base["type"] = "Catering"
                base["cuisineTypes"] = cuisineTypes
                base["serviceTypes"] = serviceTypes
                base["minGuestCount"] = minGuestCount
                base["pricePerPlate"] = pricePerPlate
                base["includesCrockery"] = includesCrockery
                base["waitstaffCount"] = waitstaffCount
            }
            is MakeupArtistVendor -> {
                base["type"] = "Makeup"
                base["makeupTypes"] = makeupTypes.map { it.name }
                base["isHairStylingIncluded"] = isHairStylingIncluded
                base["isDrapingIncluded"] = isDrapingIncluded
                base["isPaidTrialAvailable"] = isPaidTrialAvailable
                base["studioPrice"] = studioPrice
                base["venuePrice"] = venuePrice
                base["partyMakeupPrice"] = partyMakeupPrice
            }
        }
        return base
    }
}