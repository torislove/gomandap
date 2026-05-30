# GoMandap Launch Script v2.0 - Complete Setup & Usage Guide

## 🎯 Overview
The updated `launch_all.ps1` script now supports:
- ✅ **Chrome Web Mode** (existing - now fixed)
- ✅ **Android Mobile Debug Mode** (new)
- ✅ Better error handling and validation
- ✅ Proper device auto-detection
- ✅ Streamlined startup process

---

## 📋 Prerequisites

### 1. **Flutter SDK** (Required for both modes)
```powershell
# Check Flutter installation
flutter doctor
```
- Should show `flutter` in PATH
- Ensure Android SDK is also installed for Android mode

### 2. **Chrome** (Required for Chrome Web mode)
- Should be automatically detected at:
  - `C:\Program Files\Google\Chrome\Application\chrome.exe`
  - `C:\Program Files (x86)\Google\Chrome\Application\chrome.exe`
  - `%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe`

### 3. **Android SDK** (Required for Android Mobile mode)
```powershell
# Set environment variable (add to Windows Environment Variables):
# ANDROID_SDK_ROOT = C:\Users\<YourUsername>\AppData\Local\Android\Sdk
# Or wherever your Android SDK is installed

# Verify:
echo $env:ANDROID_SDK_ROOT
```

### 4. **Android Device or Emulator** (Required for Android Mobile mode)
- **Option A: Android Emulator**
  - Install Android Studio
  - Create a virtual device (AVD)
  - Start the emulator before running the script

- **Option B: Physical Android Device**
  - Enable Developer Mode: Settings → About phone → Tap Build Number 7 times
  - Enable USB Debugging: Settings → Developer options → USB Debugging
  - Connect via USB to computer
  - Allow USB debugging permission on device

---

## 🚀 Usage Examples

### **Mode 1: Chrome Web (Default)**
```powershell
# Launch all 3 apps in Chrome
.\launch_all.ps1

# Launch only Client Panel
.\launch_all.ps1 -ClientOnly

# Launch only Vendor Suite
.\launch_all.ps1 -VendorOnly

# Launch only Admin Portal
.\launch_all.ps1 -AdminOnly
```

**What happens:**
- Chrome opens automatically
- Apps run on localhost:8081, localhost:8082, localhost:8083
- Mock auth is enabled (no real login needed)
- Can use hot-reload with `r` key in Flutter terminal

---

### **Mode 2: Android Mobile Debug**
```powershell
# Launch all 3 apps on Android device
.\launch_all.ps1 -Device android

# Launch only Client on Android
.\launch_all.ps1 -Device android -ClientOnly

# Launch Vendor on Android
.\launch_all.ps1 -Device android -VendorOnly
```

**What happens:**
- Apps are compiled and deployed to Android device/emulator
- First build: 1-3 minutes (subsequent builds are faster)
- Apps run in debug mode
- Hot-reload available with `r` key
- Mock auth works on Android too

---

### **Mode 3: Auto-Detect**
```powershell
# Automatically select Chrome or Android
.\launch_all.ps1 -Device auto

# If Android device connected → uses Android
# If no Android device → falls back to Chrome
```

---

### **Other Options**
```powershell
# Skip waiting for server startup
.\launch_all.ps1 -NoWait

# Show help and available options
.\launch_all.ps1 -Help
```

---

## ✅ Troubleshooting

### **Problem: Chrome not opening automatically**
**Solution:**
1. Ensure Chrome is installed at standard location
2. Run `flutter doctor` to confirm Chrome detection
3. Manually navigate to http://localhost:8081 (for Client)
4. Check if port is already in use: `netstat -ano | findstr :8081`

### **Problem: Android device not detected**
**Solution:**
1. Run `adb devices` to verify device connection
2. Ensure `ANDROID_SDK_ROOT` environment variable is set correctly
3. For physical device: Enable USB Debugging and grant permission
4. For emulator: Ensure it's running (check Android Studio)

### **Problem: Port already in use**
**Solution:**
```powershell
# The script auto-cleans ports, but if still failing:
netstat -ano | findstr :8081  # Find process using port
taskkill /PID <pid> /F         # Kill process by PID
```

### **Problem: "Flutter not found"**
**Solution:**
1. Ensure Flutter is installed
2. Run `flutter doctor` to verify installation
3. Add Flutter to PATH if needed
4. Update `FLUTTER` variable in script if custom path: `C:\path\to\flutter\bin\flutter.bat`

### **Problem: Script shows as "cannot be loaded" in PowerShell**
**Solution:**
```powershell
# Run this command once:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then try again:
.\launch_all.ps1
```

---

## 🔍 How to Check if Everything Works

### **Chrome Web Mode**
```
✅ Chrome opens automatically
✅ Apps load at localhost:8081, 8082, 8083
✅ Mock auth: login page shows "MOCK_AUTH_ON"
✅ Can press 'r' in terminal for hot-reload
```

### **Android Mobile Mode**
```
✅ Script shows "Building and deploying to Android..."
✅ App installs on device/emulator
✅ App opens and shows GoMandap branding
✅ Mock auth works (no login needed)
✅ Can press 'r' in terminal for hot-reload
```

---

## 📝 Configuration

### **Environment Variables** (Optional)
The script automatically loads from `.env.local` if it exists:
```
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY=your-key
R2_ENDPOINT=https://your-account.r2.cloudflarestorage.com
R2_ACCESS_KEY_ID=your-access-key
R2_SECRET_ACCESS_KEY=your-secret-key
```

### **Port Configuration**
Edit the script if you need different ports:
```powershell
$CLIENT_PORT = 8081  # Default
$VENDOR_PORT = 8082  # Default
$ADMIN_PORT  = 8083  # Default
```

---

## 🎮 After Launch

### **Terminal Controls**
Once an app is running in the Flutter terminal:
- **`r`** - Hot reload (fast refresh)
- **`R`** - Hot restart (full rebuild)
- **`q`** - Quit/close the app
- **`p`** - Toggle performance overlay
- **`d`** - Detach from running app

### **For Chrome Web**
- Open browser DevTools: F12
- Use Flutter DevTools for debugging (shown in terminal output)

### **For Android Mobile**
- Use Android Studio Logcat for debugging
- Use `adb logcat` command for logs

---

## 🛠️ Manual Flutter Commands

If you prefer to run commands manually:

```powershell
# Chrome web - all 3 apps
cd C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app\apps\client
flutter run -d chrome --web-port 8081 --dart-define=MOCK_AUTH=true

# Android mobile - Client app
cd C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app\apps\client
flutter run -d android --dart-define=MOCK_AUTH=true
```

---

## 📞 Support

### **Common Commands**
```powershell
# Check Flutter setup
flutter doctor -v

# List connected devices
flutter devices

# Clear Flutter cache if issues persist
flutter clean

# Check Android devices
adb devices

# Restart adb server
adb kill-server
adb start-server
```

---

## ✨ What's New in v2.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| Chrome Web Support | ✅ | ✅ Improved |
| Android Mobile Support | ❌ | ✅ New |
| Auto Device Detection | ❌ | ✅ New |
| Error Handling | Basic | ✅ Enhanced |
| Port Cleanup | ✅ | ✅ Improved |
| Device Validation | ❌ | ✅ New |
| Help Command | ✅ | ✅ Expanded |

---

Generated: May 28, 2026  
Version: 2.0
