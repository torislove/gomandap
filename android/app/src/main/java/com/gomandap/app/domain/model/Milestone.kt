package com.gomandap.app.domain.model

data class Milestone(
    val id: String,
    val index: Int,
    val label: String,
    val amount: Double,
    val status: String // "HELD", "RELEASED", "FROZEN"
)
