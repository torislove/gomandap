package com.gomandap.app.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface VenueDao {
    @Query("SELECT * FROM cached_venues")
    fun getAllVenues(): Flow<List<CachedVenueEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertVenues(venues: List<CachedVenueEntity>)

    @Query("DELETE FROM cached_venues")
    suspend fun deleteAllVenues()
}
