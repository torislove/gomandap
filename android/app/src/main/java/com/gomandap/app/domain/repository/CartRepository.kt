package com.gomandap.app.domain.repository

import com.gomandap.app.domain.model.CartDetails
import com.gomandap.app.domain.model.CartItem
import kotlinx.coroutines.flow.Flow

interface CartRepository {
    fun getCart(userId: String): Flow<CartDetails?>
    suspend fun updateCart(userId: String, items: List<CartItem>)
    suspend fun clearCart(userId: String)
}
