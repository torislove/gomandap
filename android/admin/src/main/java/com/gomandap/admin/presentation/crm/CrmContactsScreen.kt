package com.gomandap.admin.presentation.crm

import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.material3.TabRowDefaults.tabIndicatorOffset
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.gomandap.admin.data.vendor.VendorRepository
import com.gomandap.app.domain.model.Vendor
import com.gomandap.app.domain.model.VenueVendor
import com.gomandap.app.presentation.theme.*
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CrmContactsScreen(onBack: () -> Unit) {
    val context = LocalContext.current
    var selectedTab by remember { mutableIntStateOf(0) } // 0: Platform Vendors, 1: Platform Clients
    val view = androidx.compose.ui.platform.LocalView.current

    DisposableEffect(view) {
        val window = (view.context as? android.app.Activity)?.window
        window?.addFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
        onDispose {
            window?.clearFlags(android.view.WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    // Search & Filter State
    var searchQuery by remember { mutableStateOf("") }
    var selectedCategoryFilter by remember { mutableStateOf("All") }

    // Live Database connections
    val db = FirebaseFirestore.getInstance()
    val vendorList = VendorRepository.vendors.collectAsState().value
    
    var clientsList by remember { mutableStateOf<List<Map<String, Any>>>(emptyList()) }
    var isLoadingClients by remember { mutableStateOf(false) }

    LaunchedEffect(selectedTab) {
        if (selectedTab == 1) {
            isLoadingClients = true
            runCatching {
                val snapshot = db.collection("users")
                    .whereEqualTo("role", "CLIENT")
                    .get()
                    .await()
                clientsList = snapshot.documents.map { doc ->
                    val data = doc.data ?: emptyMap<String, Any>()
                    data + ("id" to doc.id)
                }
            }
            isLoadingClients = false
        }
    }

    // Detail modal drawer for Vendor Complete Profile specs
    var selectedVendorForDetail by remember { mutableStateOf<Vendor?>(null) }
    var showDetailBottomSheet by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Client-Vendor CRM Hub", fontWeight = FontWeight.Bold, color = RoyalNavy) },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back", tint = RoyalNavy)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color.White)
            )
        },
        containerColor = PearlWhite
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            // Dual Tab Selector
            TabRow(
                selectedTabIndex = selectedTab,
                containerColor = Color.White,
                contentColor = ChampagneGold,
                indicator = { tabPositions ->
                    TabRowDefaults.Indicator(
                        modifier = Modifier.tabIndicatorOffset(tabPositions[selectedTab]),
                        color = ChampagneGold
                    )
                }
            ) {
                Tab(
                    selected = selectedTab == 0,
                    onClick = { selectedTab = 0 },
                    text = { Text("Platform Vendors", fontWeight = FontWeight.Bold, color = if (selectedTab == 0) RoyalNavy else Color.Gray) }
                )
                Tab(
                    selected = selectedTab == 1,
                    onClick = { selectedTab = 1 },
                    text = { Text("Platform Clients", fontWeight = FontWeight.Bold, color = if (selectedTab == 1) RoyalNavy else Color.Gray) }
                )
            }

            // Search input field
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 16.dp, vertical = 12.dp)
                    .background(Color.White, RoundedCornerShape(12.dp))
                    .border(1.dp, Color.LightGray.copy(alpha = 0.3f), RoundedCornerShape(12.dp))
                    .padding(horizontal = 16.dp, vertical = 2.dp)
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.Search, contentDescription = "Search", tint = Color.Gray)
                    Spacer(modifier = Modifier.width(10.dp))
                    TextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        placeholder = { Text(if (selectedTab == 0) "Search vendors by name, suburb..." else "Search clients by name, phone...", color = Color.Gray) },
                        colors = TextFieldDefaults.colors(
                            focusedContainerColor = Color.Transparent,
                            unfocusedContainerColor = Color.Transparent,
                            focusedIndicatorColor = Color.Transparent,
                            unfocusedIndicatorColor = Color.Transparent
                        ),
                        modifier = Modifier.fillMaxWidth(),
                        singleLine = true
                    )
                }
            }

            if (selectedTab == 0) {
                // ── VENDORS CRM TAB ──
                val categories = listOf("All", "Venues", "Catering", "Photography", "Decorators", "Makeup Art")
                LazyRow(
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp),
                    modifier = Modifier.padding(bottom = 12.dp)
                ) {
                    items(categories) { cat ->
                        val isSelected = selectedCategoryFilter == cat
                        Surface(
                            onClick = { selectedCategoryFilter = cat },
                            color = if (isSelected) ChampagneGold else Color.White,
                            border = BorderStroke(1.dp, if (isSelected) ChampagneGold else Color.LightGray.copy(alpha = 0.5f)),
                            shape = RoundedCornerShape(20.dp)
                        ) {
                            Text(
                                text = cat,
                                color = if (isSelected) Color.White else RoyalNavy,
                                fontSize = 11.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier.padding(horizontal = 14.dp, vertical = 6.dp)
                            )
                        }
                    }
                }

                val filteredVendors = remember(searchQuery, selectedCategoryFilter, vendorList) {
                    vendorList.filter { vendor ->
                        val matchesSearch = vendor.name.contains(searchQuery, ignoreCase = true) ||
                                vendor.locality.contains(searchQuery, ignoreCase = true)
                        val matchesCategory = when (selectedCategoryFilter) {
                            "All" -> true
                            "Venues" -> vendor is com.gomandap.app.domain.model.VenueVendor
                            "Catering" -> vendor is com.gomandap.app.domain.model.CateringVendor
                            "Photography" -> vendor is com.gomandap.app.domain.model.PhotographyVendor
                            "Decorators" -> vendor is com.gomandap.app.domain.model.DecorMandapVendor
                            "Makeup Art" -> vendor is com.gomandap.app.domain.model.MakeupArtistVendor
                            else -> true
                        }
                        matchesSearch && matchesCategory
                    }
                }

                LazyColumn(
                    contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier.weight(1f)
                ) {
                    items(filteredVendors) { vendor ->
                        CrmVendorCard(
                            vendor = vendor,
                            onCardClick = {
                                selectedVendorForDetail = vendor
                                showDetailBottomSheet = true
                            },
                            onCallClick = { phone ->
                                runCatching {
                                    val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phone"))
                                    context.startActivity(intent)
                                }.onFailure {
                                    Toast.makeText(context, "Cannot initiate call intent", Toast.LENGTH_SHORT).show()
                                }
                            },
                            onWhatsAppClick = { waNum ->
                                runCatching {
                                    // Parse clean number
                                    val cleanNum = waNum.replace(Regex("[^0-9+]"), "")
                                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://api.whatsapp.com/send?phone=$cleanNum"))
                                    context.startActivity(intent)
                                }.onFailure {
                                    Toast.makeText(context, "Cannot launch WhatsApp intent", Toast.LENGTH_SHORT).show()
                                }
                            },
                            onEmailClick = { email ->
                                runCatching {
                                    val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$email"))
                                    context.startActivity(intent)
                                }.onFailure {
                                    Toast.makeText(context, "Cannot initiate email intent", Toast.LENGTH_SHORT).show()
                                }
                            }
                        )
                    }

                    if (filteredVendors.isEmpty()) {
                        item {
                            Box(modifier = Modifier.fillMaxWidth().padding(vertical = 40.dp), contentAlignment = Alignment.Center) {
                                Text("No platform partners found matching query.", fontSize = 12.sp, color = Color.Gray)
                            }
                        }
                    }
                }
            } else {
                // ── CLIENTS CRM TAB ──
                val filteredClients = remember(searchQuery, clientsList) {
                    clientsList.filter { client ->
                        val name = client["name"] as? String ?: ""
                        val phone = client["phone"] as? String ?: ""
                        name.contains(searchQuery, ignoreCase = true) || phone.contains(searchQuery, ignoreCase = true)
                    }
                }

                if (isLoadingClients) {
                    Box(modifier = Modifier.fillMaxWidth().weight(1f), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = ChampagneGold)
                    }
                } else {
                    LazyColumn(
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        items(filteredClients) { client ->
                            CrmClientCard(
                                client = client,
                                onCallClick = { phone ->
                                    runCatching {
                                        val intent = Intent(Intent.ACTION_DIAL, Uri.parse("tel:$phone"))
                                        context.startActivity(intent)
                                    }.onFailure {
                                        Toast.makeText(context, "Cannot initiate call intent", Toast.LENGTH_SHORT).show()
                                    }
                                },
                                onWhatsAppClick = { phone ->
                                    runCatching {
                                        val cleanNum = phone.replace(Regex("[^0-9+]"), "")
                                        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://api.whatsapp.com/send?phone=$cleanNum"))
                                        context.startActivity(intent)
                                    }.onFailure {
                                        Toast.makeText(context, "Cannot launch WhatsApp intent", Toast.LENGTH_SHORT).show()
                                    }
                                },
                                onEmailClick = { email ->
                                    runCatching {
                                        val intent = Intent(Intent.ACTION_SENDTO, Uri.parse("mailto:$email"))
                                        context.startActivity(intent)
                                    }.onFailure {
                                        Toast.makeText(context, "Cannot initiate email intent", Toast.LENGTH_SHORT).show()
                                    }
                                }
                            )
                        }

                        if (filteredClients.isEmpty()) {
                            item {
                                Box(modifier = Modifier.fillMaxWidth().padding(vertical = 40.dp), contentAlignment = Alignment.Center) {
                                    Text("No clients found matching query.", fontSize = 12.sp, color = Color.Gray)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Drawer Sheet: Vendor Complete Profile Specs
    if (showDetailBottomSheet && selectedVendorForDetail != null) {
        val vendor = selectedVendorForDetail!!
        ModalBottomSheet(
            onDismissRequest = { showDetailBottomSheet = false },
            containerColor = Color.White,
            shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
        ) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(24.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header Identity
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(vendor.name, fontWeight = FontWeight.Black, fontSize = 20.sp, color = RoyalNavy, modifier = Modifier.weight(1f))
                    if (vendor.isVerified) {
                        Box(
                            modifier = Modifier
                                .background(EmeraldGreen.copy(alpha = 0.1f), RoundedCornerShape(4.dp))
                                .border(1.dp, EmeraldGreen.copy(alpha = 0.3f), RoundedCornerShape(4.dp))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        ) {
                            Text("VERIFIED PARTNER", color = EmeraldGreen, fontSize = 8.sp, fontWeight = FontWeight.Bold)
                        }
                    }
                }

                Text("Locality: " + vendor.locality, color = Color.Gray, fontSize = 13.sp)
                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                // Location Details
                Text("Complete Location", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("Address: " + if(vendor.fullAddress.isNotBlank()) vendor.fullAddress else "Not Provided", fontSize = 13.sp)
                    Text("City / Town: " + if(vendor.city.isNotBlank()) vendor.city else "Not Provided", fontSize = 13.sp)
                    Text("State & Pincode: " + vendor.state + " - " + vendor.pincode, fontSize = 13.sp)
                    Text("Famous Landmark: " + if(vendor.landmark.isNotBlank()) vendor.landmark else "Not Provided", fontSize = 13.sp)
                }

                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                // Primary Contact Details
                Text("Verification Contacts", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("Primary Mobile: " + if(vendor.mobileNumber.isNotBlank()) vendor.mobileNumber else "Not Provided", fontSize = 13.sp)
                    Text("WhatsApp contact: " + if(vendor.whatsAppNumber.isNotBlank()) vendor.whatsAppNumber else "Not Provided", fontSize = 13.sp)
                    Text("Email ID: " + if(vendor.emailId.isNotBlank()) vendor.emailId else "Not Provided", fontSize = 13.sp)
                }

                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                // Banking & Escrow Settings
                Text("Settlement Payout Credentials (Tap to Reveal)", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    SecureDataField("Account Holder Name", vendor.bankAccountName)
                    SecureDataField("Bank Name", vendor.bankName)
                    SecureDataField("Account Number", vendor.bankAccountNumber)
                    SecureDataField("Bank IFSC Code", vendor.bankIfscCode)
                    SecureDataField("UPI ID (Settlements)", vendor.upiId)
                }

                Divider(color = Color.LightGray.copy(alpha = 0.3f))

                // Specific Sub-type (If Venues)
                if (vendor is VenueVendor) {
                    Text("Sub-Venue Classification Properties", fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text("Type: " + vendor.venueType.name, fontSize = 13.sp)
                        Text("AC Seating Capacity: " + vendor.acCapacity + " seats", fontSize = 13.sp)
                        Text("Lawn Area: " + if(vendor.totalLawnArea.isNotBlank()) vendor.totalLawnArea + " Sq. Ft." else "N/A", fontSize = 13.sp)
                        Text("Rain Water Protection: " + if(vendor.rainProtection) "Yes" else "No", fontSize = 13.sp)
                        Text("Room Configurations: " + if(vendor.roomConfigurations.isNotBlank()) vendor.roomConfigurations else "N/A", fontSize = 13.sp)
                        Text("Heritage Class: " + if(vendor.heritageCategory.isNotBlank()) vendor.heritageCategory else "N/A", fontSize = 13.sp)
                        Text("Traditional Layout suitability: " + if(vendor.traditionalLayout) "Yes" else "No", fontSize = 13.sp)
                    }
                }

                Button(
                    onClick = { showDetailBottomSheet = false },
                    colors = ButtonDefaults.buttonColors(containerColor = RoyalNavy),
                    modifier = Modifier.fillMaxWidth().padding(vertical = 12.dp)
                ) {
                    Text("Close Panel", color = Color.White)
                }
            }
        }
    }
}

@Composable
fun CrmVendorCard(
    vendor: Vendor,
    onCardClick: () -> Unit,
    onCallClick: (String) -> Unit,
    onWhatsAppClick: (String) -> Unit,
    onEmailClick: (String) -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onCardClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.Top
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = vendor.name,
                            fontWeight = FontWeight.Bold,
                            fontSize = 14.sp,
                            color = RoyalNavy,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                        if (vendor.isVerified) {
                            Spacer(modifier = Modifier.width(4.dp))
                            Box(modifier = Modifier.size(10.dp).clip(CircleShape).background(EmeraldGreen))
                        }
                    }
                    Text(
                        text = when(vendor) {
                            is VenueVendor -> "Venue: " + vendor.venueType.name
                            else -> "Category: " + vendor.javaClass.simpleName.replace("Vendor", "")
                        },
                        fontSize = 11.sp,
                        color = ChampagneGold,
                        fontWeight = FontWeight.Bold
                    )
                    Text(text = "Locality: " + vendor.locality, fontSize = 11.sp, color = Color.Gray)
                }

                // Call Action Button
                val phone = if(vendor.mobileNumber.isNotBlank()) vendor.mobileNumber else "+919876543210"
                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    IconButton(
                        onClick = { onCallClick(phone) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Phone, contentDescription = "Call", tint = RoyalNavy, modifier = Modifier.size(15.dp))
                    }
                    
                    val whatsApp = if(vendor.whatsAppNumber.isNotBlank()) vendor.whatsAppNumber else phone
                    IconButton(
                        onClick = { onWhatsAppClick(whatsApp) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Send, contentDescription = "WhatsApp", tint = EmeraldGreen, modifier = Modifier.size(15.dp))
                    }

                    val email = if(vendor.emailId.isNotBlank()) vendor.emailId else "contact@vendor.com"
                    IconButton(
                        onClick = { onEmailClick(email) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Email, contentDescription = "Email", tint = ChampagneGold, modifier = Modifier.size(15.dp))
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))
            Divider(color = Color.LightGray.copy(alpha = 0.2f))
            Spacer(modifier = Modifier.height(8.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Text("Escrow Account: " + if(vendor.upiId.isNotBlank()) vendor.upiId else "Not Connected", fontSize = 11.sp, color = SlateGray)
                Spacer(modifier = Modifier.weight(1f))
                Text("View credentials", fontSize = 11.sp, color = DarkGold, fontWeight = FontWeight.Bold)
                Icon(imageVector = Icons.Default.KeyboardArrowRight, contentDescription = null, tint = DarkGold, modifier = Modifier.size(14.dp))
            }
        }
    }
}

@Composable
fun CrmClientCard(
    client: Map<String, Any>,
    onCallClick: (String) -> Unit,
    onWhatsAppClick: (String) -> Unit,
    onEmailClick: (String) -> Unit
) {
    val name = client["name"] as? String ?: "Client Manoj"
    val phone = client["phone"] as? String ?: "+91 99999 88888"
    val email = client["email"] as? String ?: "manoj@gmail.com"

    Card(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color.White),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column(modifier = Modifier.weight(1f)) {
                    Text(text = name, fontWeight = FontWeight.Bold, fontSize = 14.sp, color = RoyalNavy)
                    Text(text = "Primary mobile: $phone", fontSize = 11.sp, color = Color.Gray)
                    Text(text = "Email ID: $email", fontSize = 11.sp, color = Color.Gray)
                }

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    IconButton(
                        onClick = { onCallClick(phone) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Phone, contentDescription = "Call", tint = RoyalNavy, modifier = Modifier.size(15.dp))
                    }
                    
                    IconButton(
                        onClick = { onWhatsAppClick(phone) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Send, contentDescription = "WhatsApp", tint = EmeraldGreen, modifier = Modifier.size(15.dp))
                    }

                    IconButton(
                        onClick = { onEmailClick(email) },
                        modifier = Modifier.size(32.dp).background(PearlWhite, CircleShape)
                    ) {
                        Icon(imageVector = Icons.Default.Email, contentDescription = "Email", tint = ChampagneGold, modifier = Modifier.size(15.dp))
                    }
                }
            }
        }
    }
}

@Composable
fun SecureDataField(label: String, value: String) {
    var revealed by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    var timerJob by remember { mutableStateOf<kotlinx.coroutines.Job?>(null) }

    val maskedValue = remember(value, revealed) {
        if (revealed || value.length < 4) {
            value
        } else {
            "•••• •••• " + value.takeLast(4)
        }
    }

    Row(
        horizontalArrangement = Arrangement.SpaceBetween,
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                if (!revealed) {
                    revealed = true
                    timerJob?.cancel()
                    timerJob = scope.launch {
                        kotlinx.coroutines.delay(30000)
                        revealed = false
                    }
                } else {
                    revealed = false
                    timerJob?.cancel()
                }
            }
            .padding(vertical = 4.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(text = label, fontSize = 13.sp, color = SlateGray, fontWeight = FontWeight.Medium)
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = maskedValue,
                fontSize = 13.sp,
                color = if (revealed) EmeraldGreen else RoyalNavy,
                fontWeight = FontWeight.Black
            )
            Spacer(Modifier.width(6.dp))
            Icon(
                imageVector = if (revealed) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                contentDescription = if (revealed) "Hide" else "Reveal",
                tint = ChampagneGold,
                modifier = Modifier.size(16.dp)
            )
        }
    }
}
