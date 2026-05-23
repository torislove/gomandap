package com.gomandap.app.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface BookingDao {
    @Query("SELECT * FROM cached_bookings")
    fun getAllBookings(): Flow<List<CachedBookingEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertBookings(bookings: List<CachedBookingEntity>)

    @Query("DELETE FROM cached_bookings")
    suspend fun deleteAllBookings()
}
