package com.gomandap.app.presentation.gallery

import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.staggeredgrid.LazyVerticalStaggeredGrid
import androidx.compose.foundation.lazy.staggeredgrid.StaggeredGridCells
import androidx.compose.foundation.lazy.staggeredgrid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

// ─── Luxury Kalamkari Brand Tokens ───────────────────────────────────────────
private val RoyalNavy     = Color(0xFF0F172A)
private val EmeraldGreen  = Color(0xFF10B981)
private val ChampagneGold = Color(0xFFDFBA73)
private val SlateGray     = Color(0xFF64748B)
private val SoftMist      = Color(0xFFF8FAFC)

data class GalleryItem(
    val id: String,
    val imageUrl: String,
    val title: String,
    val category: String,
    val designerName: String,
    val price: Double,
    val hotspotX: Float, // relative coordinates (0f to 1f)
    val hotspotY: Float
)

val galleryItems = listOf(
    GalleryItem(
        id = "gal_01",
        imageUrl = "https://images.unsplash.com/photo-1519167758481-83f550bb49b3?q=80&w=600&auto=format&fit=crop",
        title = "Elite Marigold Floral Canopy",
        category = "Decor Design",
        designerName = "Royal Decors & Florals",
        price = 85000.0,
        hotspotX = 0.5f,
        hotspotY = 0.4f
    ),
    GalleryItem(
        id = "gal_02",
        imageUrl = "https://images.unsplash.com/photo-1511285560929-80b456fea0bc?q=80&w=600&auto=format&fit=crop",
        title = "Traditional South Indian Mandap",
        category = "Decor Design",
        designerName = "Purna Kalamkari Mandapams",
        price = 120000.0,
        hotspotX = 0.35f,
        hotspotY = 0.6f
    ),
    GalleryItem(
        id = "gal_03",
        imageUrl = "https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?q=80&w=600&auto=format&fit=crop",
        title = "Royal Champagne Crystal Walkway",
        category = "Decor Design",
        designerName = "Imperial Luxury Themes",
        price = 150000.0,
        hotspotX = 0.6f,
        hotspotY = 0.5f
    ),
    GalleryItem(
        id = "gal_04",
        imageUrl = "https://images.unsplash.com/photo-1519225495810-7517c2440bce?q=80&w=600&auto=format&fit=crop",
        title = "Emerald Backdrop & Brass Lamp setups",
        category = "Decor Design",
        designerName = "Nisarga Eco Weddings",
        price = 55000.0,
        hotspotX = 0.5f,
        hotspotY = 0.7f
    )
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ShoppableGalleryScreen(
    onBackClick: () -> Unit,
    onAddToCartSuccess: () -> Unit
) {
    val context = LocalContext.current
    var selectedItem by remember { mutableStateOf<GalleryItem?>(null) }
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)
    val scope = rememberCoroutineScope()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Wedding Inspiration Gallery", fontWeight = FontWeight.Black, color = RoyalNavy, fontSize = 18.sp)
                        Text("Tap coordinates tags to shop verified design setups", fontSize = 11.sp, color = SlateGray)
                    }
                },
                navigationIcon = {
                    IconButton(onClick = onBackClick) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White),
                modifier = Modifier.shadow(2.dp)
            )
        },
        containerColor = SoftMist
    ) { paddingValues ->
        LazyVerticalStaggeredGrid(
            columns = StaggeredGridCells.Fixed(2),
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp),
            verticalItemSpacing = 12.dp
        ) {
            items(galleryItems) { item ->
                Card(
                    shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = Color.White),
                    modifier = Modifier
                        .fillMaxWidth()
                        .border(1.dp, ChampagneGold.copy(alpha = 0.15f), RoundedCornerShape(16.dp))
                ) {
                    Box(modifier = Modifier.fillMaxWidth()) {
                        // High-res Image
                        Image(
                            imageVector = Icons.Default.Info, // Fallback
                            contentDescription = item.title,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(if (item.id == "gal_01" || item.id == "gal_03") 240.dp else 180.dp)
                                .background(Color.LightGray)
                                .clickable { selectedItem = item },
                            contentScale = ContentScale.Crop
                        )

                        // Visual Overlay Tag representing coordinate hotspot
                        Box(
                            modifier = Modifier
                                .align(Alignment.Center)
                                .offset(
                                    x = if (item.id == "gal_01") (-20).dp else 10.dp,
                                    y = if (item.id == "gal_01") (-30).dp else 20.dp
                                )
                        ) {
                            Surface(
                                onClick = { selectedItem = item },
                                color = ChampagneGold,
                                shape = CircleShape,
                                border = BorderStroke(1.5.dp, Color.White),
                                modifier = Modifier
                                    .size(32.dp)
                                    .shadow(elevation = 6.dp, shape = CircleShape)
                            ) {
                                Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                                    Text("⚡", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                                }
                            }
                        }

                        // Category Label
                        Surface(
                            color = RoyalNavy.copy(alpha = 0.75f),
                            shape = RoundedCornerShape(8.dp),
                            modifier = Modifier
                                .align(Alignment.BottomStart)
                                .padding(8.dp)
                        ) {
                            Text(
                                text = item.category.uppercase(),
                                color = Color.White,
                                fontSize = 8.sp,
                                fontWeight = FontWeight.Black,
                                modifier = Modifier.padding(horizontal = 6.dp, vertical = 3.dp)
                            )
                        }
                    }
                    
                    Column(modifier = Modifier.padding(12.dp)) {
                        Text(item.title, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy, maxLines = 1)
                        Text("By ${item.designerName}", fontSize = 10.sp, color = SlateGray)
                        Spacer(Modifier.height(4.dp))
                        Text("₹${"%,.0f".format(item.price)}", fontWeight = FontWeight.Black, fontSize = 14.sp, color = ChampagneGold)
                    }
                }
            }
        }
    }

    // Hotspot Click Modal Sheet
    if (selectedItem != null) {
        ModalBottomSheet(
            onDismissRequest = { selectedItem = null },
            sheetState = sheetState,
            containerColor = Color.White,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            val item = selectedItem!!
            var addingToCart by remember { mutableStateOf(false) }

            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 24.dp)
                    .padding(bottom = 32.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Drag helper
                Box(
                    modifier = Modifier
                        .width(44.dp)
                        .height(4.dp)
                        .background(SlateGray.copy(alpha = 0.15f), RoundedCornerShape(2.dp))
                        .align(Alignment.CenterHorizontally)
                )

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text(item.title, fontWeight = FontWeight.Black, fontSize = 18.sp, color = RoyalNavy)
                        Text("Verified Shoppable Setup Bundle", fontSize = 11.sp, color = SlateGray)
                    }

                    Surface(color = EmeraldGreen.copy(alpha = 0.08f), shape = RoundedCornerShape(8.dp)) {
                        Row(modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                            Text("100% Match", color = EmeraldGreen, fontSize = 9.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Divider(color = SlateGray.copy(alpha = 0.1f))

                // Designer info
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .background(SoftMist, RoundedCornerShape(12.dp))
                        .padding(12.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Box(modifier = Modifier.size(36.dp).background(ChampagneGold, CircleShape), contentAlignment = Alignment.Center) {
                        Text("D", color = Color.White, fontWeight = FontWeight.Bold)
                    }
                    Column(modifier = Modifier.weight(1f)) {
                        Text(item.designerName, fontWeight = FontWeight.Bold, fontSize = 13.sp, color = RoyalNavy)
                        Text("Professional platform elite decorator", fontSize = 10.sp, color = SlateGray)
                    }
                    Text("Verified ✅", color = EmeraldGreen, fontSize = 11.sp, fontWeight = FontWeight.Bold)
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column {
                        Text("COMPREHENSIVE DECOR BUDGET", fontSize = 9.sp, color = SlateGray, fontWeight = FontWeight.Black)
                        Text("₹${"%,.0f".format(item.price)}", fontWeight = FontWeight.Black, fontSize = 22.sp, color = RoyalNavy)
                        Text("Includes materials, sourcing & labor", fontSize = 9.sp, color = SlateGray)
                    }

                    Button(
                        onClick = {
                            addingToCart = true
                            scope.launch {
                                delay(1200)
                                addingToCart = false
                                selectedItem = null
                                Toast.makeText(context, "🎉 Shoppable Setup added to your Multiplayer Cart!", Toast.LENGTH_LONG).show()
                                onAddToCartSuccess()
                            }
                        },
                        colors = ButtonDefaults.buttonColors(containerColor = EmeraldGreen),
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.height(48.dp)
                    ) {
                        if (addingToCart) {
                            CircularProgressIndicator(color = Color.White, modifier = Modifier.size(16.dp))
                        } else {
                            Text("Add Setup to Cart", fontWeight = FontWeight.Bold, color = Color.White)
                            Spacer(Modifier.width(6.dp))
                            Icon(Icons.Default.ShoppingCart, null, tint = Color.White, modifier = Modifier.size(16.dp))
                        }
                    }
                }
            }
        }
    }
}
