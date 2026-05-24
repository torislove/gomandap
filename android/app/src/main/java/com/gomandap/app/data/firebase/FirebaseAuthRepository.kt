package com.gomandap.app.data.firebase

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthOptions
import com.google.firebase.auth.PhoneAuthProvider
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import java.util.concurrent.TimeUnit

/**
 * Shared Firebase Auth repository used by all 3 Gomandap apps.
 * - Client App:  Phone OTP login
 * - Vendor App:  Phone OTP or Email/Password
 * - Admin App:   Email/Password only
 */
object FirebaseAuthRepository {

    private val auth = FirebaseAuth.getInstance()
    private val db = FirebaseFirestore.getInstance()

    // ─── Current User State ──────────────────────────────────────────────────

    fun getCurrentUser(): FirebaseUser? = auth.currentUser

    fun isLoggedIn(): Boolean = auth.currentUser != null

    /**
     * Observe auth state changes as a Flow.
     * Emits the current user (or null on sign-out).
     */
    fun observeAuthState(): Flow<FirebaseUser?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { firebaseAuth ->
            trySend(firebaseAuth.currentUser)
        }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }

    // ─── Role Lookup ─────────────────────────────────────────────────────────

    /**
     * Returns the role of the current user: CLIENT | VENDOR | ADMIN
     * Returns null if not signed in or no role document found.
     */
    suspend fun getCurrentUserRole(): String? {
        val uid = auth.currentUser?.uid ?: return null
        return runCatching {
            val doc = db.collection("users").document(uid).get().await()
            doc.getString("role")
        }.getOrNull()
    }

    /**
     * Creates a user role document on first sign-in.
     */
    suspend fun createUserProfile(
        uid: String,
        role: String, // "CLIENT" | "VENDOR" | "ADMIN"
        name: String = "",
        phone: String = "",
        email: String = ""
    ) {
        val profile = hashMapOf(
            "role" to role,
            "name" to name,
            "phone" to phone,
            "email" to email,
            "createdAt" to com.google.firebase.Timestamp.now()
        )
        db.collection("users").document(uid).set(profile).await()
    }

    // ─── Email / Password Auth (Admin App) ───────────────────────────────────

    /**
     * Sign in with Email + Password.
     * Used by Admin app. Throws exception on failure.
     */
    suspend fun signInWithEmail(email: String, password: String): FirebaseUser {
        val result = auth.signInWithEmailAndPassword(email, password).await()
        return result.user ?: error("Sign in failed: user is null")
    }

    /**
     * Register admin account (call once from setup, not from the app).
     */
    suspend fun createAdminAccount(email: String, password: String): FirebaseUser {
        val result = auth.createUserWithEmailAndPassword(email, password).await()
        val user = result.user ?: error("Account creation failed")
        createUserProfile(user.uid, role = "ADMIN", email = email)
        return user
    }

    // ─── Phone OTP Auth (Client + Vendor App) ────────────────────────────────

    /**
     * Sends OTP to the given phone number.
     * Returns the verification ID needed to confirm the OTP.
     * Used by Client and Vendor apps.
     */
    fun sendOtp(
        phoneNumber: String,
        activity: android.app.Activity,
        onCodeSent: (verificationId: String, token: PhoneAuthProvider.ForceResendingToken) -> Unit,
        onVerificationFailed: (Exception) -> Unit,
        onAutoVerified: (PhoneAuthCredential) -> Unit
    ) {
        val options = PhoneAuthOptions.newBuilder(auth)
            .setPhoneNumber(phoneNumber)
            .setTimeout(60L, TimeUnit.SECONDS)
            .setActivity(activity)
            .setCallbacks(object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                override fun onVerificationCompleted(credential: PhoneAuthCredential) {
                    onAutoVerified(credential)
                }

                override fun onVerificationFailed(e: com.google.firebase.FirebaseException) {
                    onVerificationFailed(e)
                }

                override fun onCodeSent(
                    verificationId: String,
                    token: PhoneAuthProvider.ForceResendingToken
                ) {
                    onCodeSent(verificationId, token)
                }
            })
            .build()
        PhoneAuthProvider.verifyPhoneNumber(options)
    }

    /**
     * Verifies OTP entered by the user.
     * @param verificationId From onCodeSent callback
     * @param otp 6-digit code entered by user
     * @param role "CLIENT" or "VENDOR"
     */
    suspend fun verifyOtp(
        verificationId: String,
        otp: String,
        role: String,
        name: String = ""
    ): FirebaseUser {
        val credential = PhoneAuthProvider.getCredential(verificationId, otp)
        val result = auth.signInWithCredential(credential).await()
        val user = result.user ?: error("OTP verification failed")

        // Only create profile if this is a new user
        if (result.additionalUserInfo?.isNewUser == true) {
            createUserProfile(
                uid = user.uid,
                role = role,
                name = name,
                phone = user.phoneNumber ?: ""
            )
        }
        return user
    }

    // ─── Sign Out ─────────────────────────────────────────────────────────────

    fun signOut() {
        auth.signOut()
    }
}
