package com.gomandap.common.ui.components.domain

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.gomandap.common.design.GomandapTokens

/**
 * Simple date representation that avoids the java.time.LocalDate API 26+ requirement.
 *
 * NOTE: This project has minSdk 22. If core library desugaring is enabled
 * (`coreLibraryDesugaring "com.android.tools:desugar_jdk_libs:2.0.4"` in build.gradle),
 * you can replace this with `java.time.LocalDate`. Until then, this Int-based
 * representation provides equivalent functionality for calendar display purposes.
 *
 * @property year The year (e.g., 2024).
 * @property month The month (1–12).
 * @property dayOfMonth The day of the month (1–31).
 */
data class CalendarDate(
    val year: Int,
    val month: Int,
    val dayOfMonth: Int
) : Comparable<CalendarDate> {
    override fun compareTo(other: CalendarDate): Int {
        val yearCmp = year.compareTo(other.year)
        if (yearCmp != 0) return yearCmp
        val monthCmp = month.compareTo(other.month)
        if (monthCmp != 0) return monthCmp
        return dayOfMonth.compareTo(other.dayOfMonth)
    }
}

/**
 * Availability calendar component that displays a monthly grid with date state coloring.
 *
 * Visually distinguishes three date states using distinct background colors from
 * [GomandapTokens.Colors]:
 * - **Available**: [GomandapTokens.Colors.emeraldGreenLight] background
 * - **Booked**: [GomandapTokens.Colors.errorLight] background (not selectable)
 * - **High-demand** (≥80% capacity): [GomandapTokens.Colors.warningLight] background
 *
 * The selected date is indicated with a [GomandapTokens.Colors.champagneGold] border ring.
 *
 * Features:
 * - Month/year header with previous/next navigation arrows
 * - Day-of-week headers (Mon–Sun) in [GomandapTokens.Typography.labelSmall], slateGray
 * - Each date cell: minimum 40dp, centered day number
 * - Booked dates are not tappable (disabled state)
 *
 * @param availableDates Set of dates that are available for booking.
 * @param bookedDates Set of dates that are already booked (not selectable).
 * @param highDemandDates Set of dates with high demand (≥80% capacity reserved).
 * @param selectedDate The currently selected date, or null if none selected.
 * @param onDateSelected Callback invoked when a selectable date is tapped.
 * @param modifier Modifier to be applied to the component.
 */
@Composable
fun AvailabilityCalendar(
    availableDates: Set<CalendarDate>,
    bookedDates: Set<CalendarDate>,
    highDemandDates: Set<CalendarDate>,
    selectedDate: CalendarDate?,
    onDateSelected: (CalendarDate) -> Unit,
    modifier: Modifier = Modifier
) {
    // Determine initial display month from selectedDate or first available date or current-ish default
    val initialYear = selectedDate?.year
        ?: availableDates.minOrNull()?.year
        ?: DefaultYear
    val initialMonth = selectedDate?.month
        ?: availableDates.minOrNull()?.month
        ?: DefaultMonth

    var displayYear by remember { mutableIntStateOf(initialYear) }
    var displayMonth by remember { mutableIntStateOf(initialMonth) }

    Column(modifier = modifier.fillMaxWidth()) {
        // ─── Month/Year Header with Navigation ───────────────────────
        MonthYearHeader(
            year = displayYear,
            month = displayMonth,
            onPreviousMonth = {
                if (displayMonth == 1) {
                    displayMonth = 12
                    displayYear -= 1
                } else {
                    displayMonth -= 1
                }
            },
            onNextMonth = {
                if (displayMonth == 12) {
                    displayMonth = 1
                    displayYear += 1
                } else {
                    displayMonth += 1
                }
            }
        )

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.sm))

        // ─── Day-of-Week Headers ─────────────────────────────────────
        DayOfWeekHeaders()

        Spacer(modifier = Modifier.height(GomandapTokens.Spacing.xs))

        // ─── Calendar Grid ───────────────────────────────────────────
        CalendarGrid(
            year = displayYear,
            month = displayMonth,
            availableDates = availableDates,
            bookedDates = bookedDates,
            highDemandDates = highDemandDates,
            selectedDate = selectedDate,
            onDateSelected = onDateSelected
        )
    }
}

// ─── Month/Year Header ───────────────────────────────────────────────

@Composable
private fun MonthYearHeader(
    year: Int,
    month: Int,
    onPreviousMonth: () -> Unit,
    onNextMonth: () -> Unit
) {
    val monthName = MonthNames.getOrElse(month - 1) { "" }

    Row(
        modifier = Modifier.fillMaxWidth(),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        IconButton(
            onClick = onPreviousMonth,
            modifier = Modifier.semantics {
                contentDescription = "Previous month"
            }
        ) {
            Icon(
                imageVector = Icons.Filled.ChevronLeft,
                contentDescription = null,
                tint = GomandapTokens.Colors.royalNavy
            )
        }

        Text(
            text = "$monthName $year",
            style = GomandapTokens.Typography.headlineSmall,
            color = GomandapTokens.Colors.royalNavy,
            textAlign = TextAlign.Center
        )

        IconButton(
            onClick = onNextMonth,
            modifier = Modifier.semantics {
                contentDescription = "Next month"
            }
        ) {
            Icon(
                imageVector = Icons.Filled.ChevronRight,
                contentDescription = null,
                tint = GomandapTokens.Colors.royalNavy
            )
        }
    }
}

// ─── Day-of-Week Headers ─────────────────────────────────────────────

@Composable
private fun DayOfWeekHeaders() {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        DayOfWeekLabels.forEach { label ->
            Box(
                modifier = Modifier.size(CellSize),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = label,
                    style = GomandapTokens.Typography.labelSmall,
                    color = GomandapTokens.Colors.slateGray,
                    textAlign = TextAlign.Center
                )
            }
        }
    }
}

// ─── Calendar Grid ───────────────────────────────────────────────────

@Composable
private fun CalendarGrid(
    year: Int,
    month: Int,
    availableDates: Set<CalendarDate>,
    bookedDates: Set<CalendarDate>,
    highDemandDates: Set<CalendarDate>,
    selectedDate: CalendarDate?,
    onDateSelected: (CalendarDate) -> Unit
) {
    val daysInMonth = getDaysInMonth(year, month)
    // Day of week for the 1st of the month (0 = Monday, 6 = Sunday)
    val firstDayOfWeek = getDayOfWeek(year, month, 1)

    // Build rows of 7 cells
    val totalCells = firstDayOfWeek + daysInMonth
    val rows = (totalCells + 6) / 7 // ceiling division

    Column(
        modifier = Modifier.fillMaxWidth(),
        verticalArrangement = Arrangement.spacedBy(GomandapTokens.Spacing.xxs)
    ) {
        for (row in 0 until rows) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                for (col in 0 until 7) {
                    val cellIndex = row * 7 + col
                    val dayNumber = cellIndex - firstDayOfWeek + 1

                    if (dayNumber in 1..daysInMonth) {
                        val date = CalendarDate(year, month, dayNumber)
                        val isBooked = date in bookedDates
                        val isHighDemand = date in highDemandDates
                        val isAvailable = date in availableDates
                        val isSelected = date == selectedDate

                        DateCell(
                            dayNumber = dayNumber,
                            isAvailable = isAvailable,
                            isBooked = isBooked,
                            isHighDemand = isHighDemand,
                            isSelected = isSelected,
                            onClick = if (!isBooked) {
                                { onDateSelected(date) }
                            } else {
                                null
                            }
                        )
                    } else {
                        // Empty cell for padding
                        Box(modifier = Modifier.size(CellSize))
                    }
                }
            }
        }
    }
}

// ─── Date Cell ───────────────────────────────────────────────────────

@Composable
private fun DateCell(
    dayNumber: Int,
    isAvailable: Boolean,
    isBooked: Boolean,
    isHighDemand: Boolean,
    isSelected: Boolean,
    onClick: (() -> Unit)?
) {
    val backgroundColor = when {
        isBooked -> GomandapTokens.Colors.errorLight
        isHighDemand -> GomandapTokens.Colors.warningLight
        isAvailable -> GomandapTokens.Colors.emeraldGreenLight
        else -> Color.Transparent
    }

    val textColor = when {
        isBooked -> GomandapTokens.Colors.slateGray
        else -> GomandapTokens.Colors.royalNavy
    }

    val stateDescription = when {
        isBooked -> "Booked"
        isHighDemand -> "High demand"
        isAvailable -> "Available"
        else -> ""
    }

    val cellModifier = Modifier
        .size(CellSize)
        .clip(CircleShape)
        .background(color = backgroundColor, shape = CircleShape)
        .then(
            if (isSelected) {
                Modifier.border(
                    width = SelectedBorderWidth,
                    color = GomandapTokens.Colors.champagneGold,
                    shape = CircleShape
                )
            } else {
                Modifier
            }
        )
        .then(
            if (onClick != null) {
                Modifier.clickable(onClick = onClick)
            } else {
                Modifier
            }
        )
        .semantics {
            contentDescription = "Day $dayNumber, $stateDescription"
        }

    Box(
        modifier = cellModifier,
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = dayNumber.toString(),
            style = GomandapTokens.Typography.bodySmall,
            color = textColor,
            textAlign = TextAlign.Center
        )
    }
}

// ─── Date Calculation Utilities ──────────────────────────────────────

/**
 * Returns the number of days in the given month/year.
 */
internal fun getDaysInMonth(year: Int, month: Int): Int {
    return when (month) {
        1, 3, 5, 7, 8, 10, 12 -> 31
        4, 6, 9, 11 -> 30
        2 -> if (isLeapYear(year)) 29 else 28
        else -> 30
    }
}

/**
 * Returns whether the given year is a leap year.
 */
internal fun isLeapYear(year: Int): Boolean {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
}

/**
 * Returns the day of week for a given date using Zeller's congruence.
 * Returns 0 = Monday, 1 = Tuesday, ..., 6 = Sunday.
 */
internal fun getDayOfWeek(year: Int, month: Int, day: Int): Int {
    // Adjust for Zeller's: January and February are months 13 and 14 of the previous year
    var adjustedYear = year
    var adjustedMonth = month
    if (adjustedMonth < 3) {
        adjustedMonth += 12
        adjustedYear -= 1
    }

    val k = adjustedYear % 100
    val j = adjustedYear / 100

    // Zeller's congruence for Gregorian calendar
    val h = (day + (13 * (adjustedMonth + 1)) / 5 + k + k / 4 + j / 4 - 2 * j) % 7

    // Convert from Zeller's result (0=Saturday, 1=Sunday, ..., 6=Friday)
    // to our format (0=Monday, ..., 6=Sunday)
    val dayOfWeek = ((h + 5) % 7)
    return dayOfWeek
}

// ─── Constants ───────────────────────────────────────────────────────

private val CellSize = 40.dp
private val SelectedBorderWidth = 2.dp
private const val DefaultYear = 2024
private const val DefaultMonth = 1

private val DayOfWeekLabels = listOf("Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun")

private val MonthNames = listOf(
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
)
