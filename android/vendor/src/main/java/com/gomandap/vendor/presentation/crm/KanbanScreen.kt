package com.gomandap.vendor.presentation.crm

import androidx.compose.animation.animateColorAsState
import androidx.compose.animation.core.*
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectDragGesturesAfterLongPress
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.draw.scale
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.layout.boundsInRoot
import androidx.compose.ui.layout.onGloballyPositioned
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.launch
import kotlin.math.roundToInt

// ─── Luxury Color Palette ───────────────────────────────────────────────────
private val RoyalNavy      = Color(0xFF0F172A)
private val DeepSlate      = Color(0xFF1E293B)
private val Charcoal       = Color(0xFF334155)
private val ChampagneGold  = Color(0xFFDFBA73)
private val DarkGold       = Color(0xFFC59A48)
private val EmeraldGreen   = Color(0xFF10B981)
private val HotRose        = Color(0xFFF43F5E)
private val SoftMist       = Color(0xFFF8FAFC)
private val SlateGray      = Color(0xFF64748B)

enum class KanbanStage(val displayName: String, val color: Color, val emoji: String) {
    INQUIRY("Inquiry", Color(0xFF38BDF8), "💬"),
    SITE_VISIT("Site Visit", Color(0xFFFB7185), "🚶‍♂️"),
    ESCROW_LOCKED("Escrow Locked", EmeraldGreen, "🔒")
}

data class CRMLead(
    val id: String,
    val clientName: String,
    val date: String,
    val budget: String,
    val category: String,
    val location: String,
    var stage: KanbanStage
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun KanbanScreen(
    onBackClick: () -> Unit
) {
    var leads = remember {
        mutableStateListOf(
            CRMLead("1", "Ananya & Rahul", "14 Nov 2026", "₹4.5 Lakhs", "Decor Mandap", "Banjara Hills", KanbanStage.INQUIRY),
            CRMLead("2", "Siddharth & Priya", "23 Nov 2026", "₹12.0 Lakhs", "5-Star Venue", "Gachibowli", KanbanStage.INQUIRY),
            CRMLead("3", "Harish & Kavitha", "02 Dec 2026", "₹2.2 Lakhs", "Candid Shoot", "Secunderabad", KanbanStage.SITE_VISIT),
            CRMLead("4", "Vikram & Sneha", "18 Dec 2026", "₹8.5 Lakhs", "Luxury Resort", "Vijayawada", KanbanStage.SITE_VISIT),
            CRMLead("5", "Manish & Swapna", "28 Dec 2026", "₹6.0 Lakhs", "Veg Buffet", "Guntur", KanbanStage.ESCROW_LOCKED)
        )
    }

    var draggedLeadId by remember { mutableStateOf<String?>(null) }
    var dragOffset by remember { mutableStateOf(Offset.Zero) }
    var dragPosition by remember { mutableStateOf(Offset.Zero) }
    val haptic = LocalHapticFeedback.current

    // Store bounding boxes of all columns in global space to detect drops
    var inquiryBounds by remember { mutableStateOf(Rect.Zero) }
    var siteVisitBounds by remember { mutableStateOf(Rect.Zero) }
    var escrowBounds by remember { mutableStateOf(Rect.Zero) }

    val activeDraggedLead = remember(draggedLeadId, leads) {
        leads.find { it.id == draggedLeadId }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Kanban CRM Lead Board", fontWeight = FontWeight.Black, fontSize = 20.sp, color = ChampagneGold)
                        Text("Drag & drop to progress client wedding stages", fontSize = 11.sp, color = Color.White.copy(alpha = 0.6f))
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, "Back", tint = ChampagneGold)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = RoyalNavy),
                actions = {
                    IconButton(onClick = {
                        // Reset demo leads
                        leads.clear()
                        leads.addAll(
                            listOf(
                                CRMLead("1", "Ananya & Rahul", "14 Nov 2026", "₹4.5 Lakhs", "Decor Mandap", "Banjara Hills", KanbanStage.INQUIRY),
                                CRMLead("2", "Siddharth & Priya", "23 Nov 2026", "₹12.0 Lakhs", "5-Star Venue", "Gachibowli", KanbanStage.INQUIRY),
                                CRMLead("3", "Harish & Kavitha", "02 Dec 2026", "₹2.2 Lakhs", "Candid Shoot", "Secunderabad", KanbanStage.SITE_VISIT),
                                CRMLead("4", "Vikram & Sneha", "18 Dec 2026", "₹8.5 Lakhs", "Luxury Resort", "Vijayawada", KanbanStage.SITE_VISIT),
                                CRMLead("5", "Manish & Swapna", "28 Dec 2026", "₹6.0 Lakhs", "Veg Buffet", "Guntur", KanbanStage.ESCROW_LOCKED)
                            )
                        )
                    }) {
                        Icon(Icons.Default.Refresh, "Reset", tint = ChampagneGold)
                    }
                }
            )
        },
        containerColor = DeepSlate
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Horizontal row containing 3 Kanban columns
            Row(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(8.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                // Column 1: Inquiry
                KanbanColumn(
                    stage = KanbanStage.INQUIRY,
                    leads = leads.filter { it.stage == KanbanStage.INQUIRY },
                    draggedLeadId = draggedLeadId,
                    onBoundsPositioned = { inquiryBounds = it },
                    onStartDrag = { id, offset, rootPos ->
                        draggedLeadId = id
                        dragOffset = offset
                        dragPosition = rootPos
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    },
                    onDrag = { offset, rootPos ->
                        dragOffset += offset
                        dragPosition = rootPos
                    }
                )

                // Column 2: Site Visit
                KanbanColumn(
                    stage = KanbanStage.SITE_VISIT,
                    leads = leads.filter { it.stage == KanbanStage.SITE_VISIT },
                    draggedLeadId = draggedLeadId,
                    onBoundsPositioned = { siteVisitBounds = it },
                    onStartDrag = { id, offset, rootPos ->
                        draggedLeadId = id
                        dragOffset = offset
                        dragPosition = rootPos
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    },
                    onDrag = { offset, rootPos ->
                        dragOffset += offset
                        dragPosition = rootPos
                    }
                )

                // Column 3: Escrow Locked (Luxury Styled)
                KanbanColumn(
                    stage = KanbanStage.ESCROW_LOCKED,
                    leads = leads.filter { it.stage == KanbanStage.ESCROW_LOCKED },
                    draggedLeadId = draggedLeadId,
                    onBoundsPositioned = { escrowBounds = it },
                    onStartDrag = { id, offset, rootPos ->
                        draggedLeadId = id
                        dragOffset = offset
                        dragPosition = rootPos
                        haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                    },
                    onDrag = { offset, rootPos ->
                        dragOffset += offset
                        dragPosition = rootPos
                    }
                )
            }

            // Floating drag shadow representation
            if (activeDraggedLead != null) {
                Box(
                    modifier = Modifier
                        .offset { IntOffset(dragOffset.x.roundToInt(), dragOffset.y.roundToInt()) }
                        .width(120.dp)
                        .scale(1.05f)
                        .rotate(4f)
                        .shadow(elevation = 16.dp, shape = RoundedCornerShape(12.dp))
                        .background(Charcoal.copy(alpha = 0.95f), RoundedCornerShape(12.dp))
                        .border(1.5.dp, ChampagneGold, RoundedCornerShape(12.dp))
                        .padding(10.dp)
                        .pointerInput(Unit) {
                            detectDragGesturesAfterLongPress(
                                onDragStart = {},
                                onDragEnd = {
                                    // Bouncy release drop validation
                                    val dropTarget = when {
                                        inquiryBounds.contains(dragPosition) -> KanbanStage.INQUIRY
                                        siteVisitBounds.contains(dragPosition) -> KanbanStage.SITE_VISIT
                                        escrowBounds.contains(dragPosition) -> KanbanStage.ESCROW_LOCKED
                                        else -> null
                                    }
                                    if (dropTarget != null) {
                                        val idx = leads.indexOfFirst { it.id == draggedLeadId }
                                        if (idx != -1) {
                                            leads[idx] = leads[idx].copy(stage = dropTarget)
                                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                                        }
                                    }
                                    draggedLeadId = null
                                },
                                onDragCancel = { draggedLeadId = null },
                                onDrag = { change, dragAmount ->
                                    change.consume()
                                    dragOffset += dragAmount
                                    dragPosition = change.position
                                }
                            )
                        }
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        Surface(
                            color = activeDraggedLead.stage.color.copy(alpha = 0.15f),
                            shape = RoundedCornerShape(4.dp)
                        ) {
                            Text(
                                text = activeDraggedLead.category,
                                fontSize = 8.sp,
                                color = activeDraggedLead.stage.color,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 4.dp, vertical = 2.dp)
                            )
                        }
                        Text(activeDraggedLead.clientName, fontWeight = FontWeight.Bold, fontSize = 11.sp, color = Color.White, maxLines = 1)
                        Text(activeDraggedLead.budget, fontSize = 10.sp, color = ChampagneGold, fontWeight = FontWeight.Black)
                    }
                }
            }
        }
    }
}

@Composable
fun RowScope.KanbanColumn(
    stage: KanbanStage,
    leads: List<CRMLead>,
    draggedLeadId: String?,
    onBoundsPositioned: (Rect) -> Unit,
    onStartDrag: (String, Offset, Offset) -> Unit,
    onDrag: (Offset, Offset) -> Unit
) {
    val isEscrow = stage == KanbanStage.ESCROW_LOCKED
    val backgroundBrush = if (isEscrow) {
        Brush.verticalGradient(
            listOf(DeepSlate, Color(0xFF0F2D24))
        )
    } else {
        Brush.verticalGradient(
            listOf(DeepSlate, RoyalNavy)
        )
    }

    val borderModifier = if (isEscrow) {
        Modifier.border(1.dp, ChampagneGold.copy(alpha = 0.35f), RoundedCornerShape(16.dp))
    } else {
        Modifier.border(1.dp, Charcoal, RoundedCornerShape(16.dp))
    }

    Column(
        modifier = Modifier
            .weight(1f)
            .fillMaxHeight()
            .then(borderModifier)
            .background(backgroundBrush, RoundedCornerShape(16.dp))
            .onGloballyPositioned { coordinates ->
                onBoundsPositioned(coordinates.boundsInRoot())
            }
            .padding(10.dp)
    ) {
        // Header
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 12.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                Text(stage.emoji, fontSize = 14.sp)
                Text(
                    text = stage.displayName,
                    fontWeight = FontWeight.Black,
                    fontSize = 13.sp,
                    color = if (isEscrow) ChampagneGold else Color.White
                )
            }
            Box(
                modifier = Modifier
                    .size(20.dp)
                    .background(Charcoal, CircleShape),
                contentAlignment = Alignment.Center
            ) {
                Text(leads.size.toString(), fontSize = 10.sp, color = Color.White, fontWeight = FontWeight.Bold)
            }
        }

        Divider(color = Charcoal.copy(alpha = 0.5f), modifier = Modifier.padding(bottom = 10.dp))

        // Cards list
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            items(leads, key = { it.id }) { lead ->
                val isBeingDragged = lead.id == draggedLeadId
                KanbanLeadCard(
                    lead = lead,
                    isBeingDragged = isBeingDragged,
                    onStartDrag = { offset, rootPos -> onStartDrag(lead.id, offset, rootPos) },
                    onDrag = onDrag
                )
            }
        }
    }
}

@Composable
fun KanbanLeadCard(
    lead: CRMLead,
    isBeingDragged: Boolean,
    onStartDrag: (Offset, Offset) -> Unit,
    onDrag: (Offset, Offset) -> Unit
) {
    var cardOffset by remember { mutableStateOf(Offset.Zero) }
    var currentRootPos by remember { mutableStateOf(Offset.Zero) }

    val containerColor = if (lead.stage == KanbanStage.ESCROW_LOCKED) {
        Color(0xFF14241F)
    } else {
        Charcoal
    }

    val cardBorder = if (lead.stage == KanbanStage.ESCROW_LOCKED) {
        Modifier.border(1.dp, EmeraldGreen.copy(alpha = 0.4f), RoundedCornerShape(12.dp))
    } else {
        Modifier.border(1.dp, Color.White.copy(alpha = 0.08f), RoundedCornerShape(12.dp))
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .scale(if (isBeingDragged) 0.0f else 1f)
            .then(cardBorder)
            .pointerInput(lead.id) {
                detectDragGesturesAfterLongPress(
                    onDragStart = { offset ->
                        cardOffset = Offset.Zero
                        onStartDrag(cardOffset, currentRootPos)
                    },
                    onDragEnd = {},
                    onDragCancel = {},
                    onDrag = { change, dragAmount ->
                        change.consume()
                        cardOffset += dragAmount
                        currentRootPos = change.position
                        onDrag(dragAmount, change.position)
                    }
                )
            }
            .onGloballyPositioned { coordinates ->
                currentRootPos = coordinates.localToRoot(Offset.Zero)
            },
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = containerColor)
    ) {
        Column(
            modifier = Modifier.padding(10.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Surface(
                    color = lead.stage.color.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(4.dp)
                ) {
                    Text(
                        text = lead.category,
                        fontSize = 8.sp,
                        color = lead.stage.color,
                        fontWeight = FontWeight.Black,
                        modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                    )
                }
                if (lead.stage == KanbanStage.ESCROW_LOCKED) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(2.dp)
                    ) {
                        Icon(Icons.Default.Lock, null, tint = EmeraldGreen, modifier = Modifier.size(10.dp))
                        Text("Escrow Guard", fontSize = 8.sp, color = EmeraldGreen, fontWeight = FontWeight.Bold)
                    }
                }
            }

            Text(
                text = lead.clientName,
                fontWeight = FontWeight.Bold,
                fontSize = 12.sp,
                color = Color.White,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                Icon(Icons.Default.LocationOn, null, tint = SlateGray, modifier = Modifier.size(10.dp))
                Text(lead.location, fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Bold)
            }

            Divider(color = Color.White.copy(alpha = 0.06f))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(lead.budget, fontSize = 11.sp, color = ChampagneGold, fontWeight = FontWeight.Black)
                Text(lead.date, fontSize = 9.sp, color = SlateGray)
            }
        }
    }
}
