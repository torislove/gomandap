package com.gomandap.vendor.data.vendor

import android.content.Context
import com.gomandap.app.data.mock.MockDataStore
import com.gomandap.app.domain.model.Vendor
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.withContext

object VendorRepository {

    private val _vendors = MutableStateFlow<List<Vendor>>(emptyList())
    val vendors: StateFlow<List<Vendor>> = _vendors

    private var appContext: Context? = null

    fun initialize(context: Context) {
        appContext = context.applicationContext
        MockDataStore.initialize(appContext!!)
        _vendors.value = MockDataStore.allVendors
    }

    fun currentVendors(): List<Vendor> = _vendors.value

    fun getVendorById(id: String): Vendor? = _vendors.value.firstOrNull { it.id == id }

    suspend fun refresh() = withContext(Dispatchers.IO) {
        appContext?.let {
            MockDataStore.initialize(it)
            _vendors.value = MockDataStore.allVendors
        }
    }

    suspend fun updateVendor(vendorId: String, transform: (Vendor) -> Vendor) = withContext(Dispatchers.IO) {
        appContext?.let { ctx ->
            MockDataStore.updateVendor(ctx, vendorId, transform)
            _vendors.value = MockDataStore.allVendors
        }
    }

    suspend fun addVendor(vendor: Vendor) = withContext(Dispatchers.IO) {
        appContext?.let { ctx ->
            val updated = MockDataStore.allVendors + vendor
            MockDataStore.saveCatalog(ctx, updated)
            _vendors.value = MockDataStore.allVendors
        }
    }
}
