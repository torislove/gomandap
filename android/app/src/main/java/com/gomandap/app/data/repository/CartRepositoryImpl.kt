package com.gomandap.app.data.repository

import com.gomandap.app.domain.model.CartDetails
import com.gomandap.app.domain.model.CartItem
import com.gomandap.app.domain.model.CartSkuItem
import com.gomandap.app.domain.repository.CartRepository
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.withContext

class CartRepositoryImpl : CartRepository {

    private val db = FirebaseFirestore.getInstance()
    private val cartsCollection = db.collection("carts")

    override fun getCart(userId: String): Flow<CartDetails?> = callbackFlow {
        val registration = cartsCollection.document(userId)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    close(error)
                    return@addSnapshotListener
                }
                if (snapshot != null && snapshot.exists()) {
                    val itemsRaw = snapshot.get("items") as? List<Map<String, Any>> ?: emptyList()
                    val items = itemsRaw.map { itemMap ->
                        val addonsRaw = itemMap["selectedAddons"] as? List<Map<String, Any>> ?: emptyList()
                        val selectedAddons = addonsRaw.map { addonMap ->
                            CartSkuItem(
                                skuId = addonMap["skuId"] as? String ?: "",
                                label = addonMap["label"] as? String ?: "",
                                price = (addonMap["price"] as? Number)?.toDouble() ?: 0.0
                            )
                        }
                        CartItem(
                            vendorId = itemMap["vendorId"] as? String ?: "",
                            vendorName = itemMap["vendorName"] as? String ?: "",
                            vendorType = itemMap["vendorType"] as? String ?: "",
                            eventDate = itemMap["eventDate"] as? String ?: "",
                            slot = itemMap["slot"] as? String ?: "",
                            basePrice = (itemMap["basePrice"] as? Number)?.toDouble() ?: 0.0,
                            selectedAddons = selectedAddons
                        )
                    }
                    val lastUpdated = snapshot.getLong("lastUpdated") ?: System.currentTimeMillis()
                    trySend(CartDetails(userId, items, lastUpdated))
                } else {
                    trySend(CartDetails(userId, emptyList(), System.currentTimeMillis()))
                }
            }
        awaitClose { registration.remove() }
    }

    override suspend fun updateCart(userId: String, items: List<CartItem>): Unit = withContext(Dispatchers.IO) {
        val serializedItems = items.map { item ->
            mapOf(
                "vendorId" to item.vendorId,
                "vendorName" to item.vendorName,
                "vendorType" to item.vendorType,
                "eventDate" to item.eventDate,
                "slot" to item.slot,
                "basePrice" to item.basePrice,
                "selectedAddons" to item.selectedAddons.map { addon ->
                    mapOf(
                        "skuId" to addon.skuId,
                        "label" to addon.label,
                        "price" to addon.price
                    )
                }
            )
        }
        val data = mapOf(
            "userId" to userId,
            "items" to serializedItems,
            "lastUpdated" to System.currentTimeMillis()
        )
        cartsCollection.document(userId).set(data).await()
    }

    override suspend fun clearCart(userId: String): Unit = withContext(Dispatchers.IO) {
        cartsCollection.document(userId).delete().await()
    }
}
