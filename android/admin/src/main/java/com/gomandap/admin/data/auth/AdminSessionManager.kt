package com.gomandap.admin.data.auth

import android.content.Context
import android.content.SharedPreferences

object AdminSessionManager {
    private const val PREF_NAME = "admin_prefs"
    private const val KEY_ROLE = "current_role"
    private var prefs: SharedPreferences? = null

    fun initialize(context: Context) {
        prefs = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE)
    }

    var currentRole: String
        get() = prefs?.getString(KEY_ROLE, "Super Admin") ?: "Super Admin"
        set(value) {
            prefs?.edit()?.putString(KEY_ROLE, value)?.apply()
        }
}
