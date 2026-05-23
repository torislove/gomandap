package com.gomandap.app.data.local

import androidx.room.Database
import androidx.room.RoomDatabase

@Database(
    entities = [CachedVenueEntity::class, CachedBookingEntity::class],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {
    abstract fun venueDao(): VenueDao
    abstract fun bookingDao(): BookingDao
}
