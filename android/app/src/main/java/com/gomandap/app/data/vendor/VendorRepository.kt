package com.gomandap.app.data.vendor

import android.content.Context
import com.gomandap.app.data.firebase.FirestoreVendorRepository
import com.gomandap.app.domain.model.Vendor
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

object VendorRepository {

    private val _vendors = MutableStateFlow<List<Vendor>>(emptyList())
    val vendors: StateFlow<List<Vendor>> = _vendors

    private var appContext: Context? = null
    private val repositoryScope = CoroutineScope(Dispatchers.IO)

    fun initialize(context: Context) {
        appContext = context.applicationContext
        repositoryScope.launch {
            FirestoreVendorRepository.getLiveVendors().collect { liveList ->
                _vendors.value = liveList
            }
        }
    }

    fun currentVendors(): List<Vendor> = _vendors.value

    fun getVendorById(id: String): Vendor? = _vendors.value.firstOrNull { it.id == id }

    suspend fun refresh() {
        // Real-time listener handles syncing automatically, but we can log or trigger a minor fetch
    }

    suspend fun updateVendor(vendorId: String, transform: (Vendor) -> Vendor) = withContext(Dispatchers.IO) {
        val current = _vendors.value.find { it.id == vendorId } ?: return@withContext
        val updated = transform(current)
        // If client needs to write changes back, it writes directly to Firestore
        FirestoreVendorRepository.addVendor(updated)
    }
}