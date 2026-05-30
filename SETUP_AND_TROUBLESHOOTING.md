# GoMandap Launch Script - Setup & Troubleshooting Guide

## 🔧 Pre-Launch Setup

### Step 1: Verify Flutter Installation

```powershell
# Open PowerShell and run:
flutter doctor

# Output should show:
# [✓] Flutter (Channel stable)
# [✓] Android toolchain
# [✓] Chrome
# [✓] Windows Version
```

If Flutter is not found:
1. Download from https://flutter.dev/docs/get-started/install/windows
2. Add Flutter to PATH
3. Run `flutter pub get` in each app directory

---

### Step 2: Ensure Chrome is Installed

```powershell
# Check Chrome installation:
Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe"

# If not found, download from: https://www.google.com/chrome/
```

---

### Step 3: Setup Android Support (Android Mode Only)

#### 3a. Set Android SDK Environment Variable

1. **Find your Android SDK location:**
   - Usually: `C:\Users\<YourName>\AppData\Local\Android\Sdk`
   - Or from Android Studio: Tools → SDK Manager → SDK Location

2. **Add Environment Variable (Windows):**
   ```
   • Settings → System → About → Advanced system settings
   • Environment Variables → New (User variables)
   • Variable name: ANDROID_SDK_ROOT
   • Variable value: C:\Users\<YourName>\AppData\Local\Android\Sdk
   • Click OK
   • Restart PowerShell
   ```

3. **Verify it's set:**
   ```powershell
   echo $env:ANDROID_SDK_ROOT
   # Should show your SDK path
   ```

#### 3b. Enable USB Debugging (Physical Device)

1. Enable Developer Mode:
   - Settings → About phone
   - Tap "Build number" 7 times
   - Tap "System" → Developer options

2. Enable USB Debugging:
   - Settings → System → Developer options
   - Enable "USB Debugging"

3. Connect via USB and allow permission on device

#### 3c. Setup Android Emulator (Virtual Device)

1. Open Android Studio
2. Tools → AVD Manager → Create Virtual Device
3. Select device (e.g., Pixel 5)
4. Select Android version (API 30+)
5. Click "Finish" to create
6. Before running script, start emulator:
   - AVD Manager → Select device → Press Play (green arrow)

---

## 🚀 First-Time Launch

### Chrome Mode (Easiest)

```powershell
cd C:\Users\manoj\OneDrive\Desktop\Gomandap
.\launch_all.ps1
```

**Expected output:**
```
  -------------------------------------------------------
   GoMandap  ---  Multi-App Dev Launcher v2.0
   Target Device: CHROME
  -------------------------------------------------------

  > Checking prerequisites...
  [OK] Flutter: C:\flutter\bin\flutter.bat
  [OK] Chrome: C:\Program Files\Google\Chrome\Application\chrome.exe
  [OK] All app directories confirmed

  -------------------------------------------------------
  Clearing ports 8081, 8082, 8083...
  [OK] Ports cleared
  
  [... apps launching ...]
  
  ========================================================
  GoMandap Dev Suite -- All Systems Live!
  [C] Client Panel  -->  http://localhost:8081
  [V] Vendor Suite  -->  http://localhost:8082
  [A] Admin Portal  -->  http://localhost:8083
  ========================================================
```

---

### Android Mode (Advanced)

```powershell
# First, verify setup:
adb devices
# Should show your device listed

# Then launch:
cd C:\Users\manoj\OneDrive\Desktop\Gomandap
.\launch_all.ps1 -Device android
```

**Expected output:**
```
  -------------------------------------------------------
  Target Device: ANDROID
  [OK] Found Android device(s): emulator-5554
  -------------------------------------------------------
  
  [... building and deploying ...]
  
  ========================================================
  GoMandap Dev Suite -- All Systems Live!
  [C] Client Panel  -->  Android Mobile (Debug)
  [V] Vendor Suite  -->  Android Mobile (Debug)
  [A] Admin Portal  -->  Android Mobile (Debug)
  ========================================================
```

---

## ❌ Troubleshooting

### Issue 1: "Chrome not found" error

**Error message:**
```
[XX] Chrome not found in standard paths.
     Install Chrome or use -Device android
```

**Fixes:**
1. **Install Chrome** from https://www.google.com/chrome/
2. **Update script path** if Chrome is in custom location:
   ```powershell
   # Edit launch_all.ps1, find CHROME_PATHS section
   # Add your custom path if not listed
   ```
3. **Use Android mode instead:**
   ```powershell
   .\launch_all.ps1 -Device android
   ```

---

### Issue 2: "Flutter not found" error

**Error message:**
```
[XX] Flutter not found at: C:\flutter\bin\flutter.bat
```

**Fixes:**
1. **Verify Flutter is installed:**
   ```powershell
   which flutter
   flutter --version
   ```

2. **Add Flutter to PATH:**
   - Download Flutter: https://flutter.dev/docs/get-started/install/windows
   - Extract to `C:\flutter` (or your preferred location)
   - Add to PATH or update script

3. **Update script** if Flutter is in different location:
   ```powershell
   # Edit launch_all.ps1, line ~25
   $FLUTTER = "C:\path\to\your\flutter\bin\flutter.bat"
   ```

---

### Issue 3: "Port already in use" error

**Symptoms:**
- Script hangs or shows error about ports
- Previous app processes still running

**Fixes:**
1. **Script should auto-clean, but if stuck:**
   ```powershell
   # Find process on port 8081:
   netstat -ano | findstr :8081
   
   # Kill by PID (from above output):
   taskkill /PID 12345 /F
   ```

2. **Alternatively, use different ports:**
   - Edit `launch_all.ps1` and change:
     ```powershell
     $CLIENT_PORT = 9001  # Changed from 8081
     $VENDOR_PORT = 9002  # Changed from 8082
     $ADMIN_PORT  = 9003  # Changed from 8083
     ```

---

### Issue 4: "No Android devices found"

**Error message:**
```
[XX] No Android devices found. Please:
     - Start an Android emulator, or
     - Connect an Android device with USB debugging enabled
```

**Fixes:**

1. **Check device connection:**
   ```powershell
   adb devices
   # Should list your device with "device" status
   ```

2. **For Android Emulator:**
   - Open Android Studio
   - AVD Manager → Select device → Click Play (▶)
   - Wait 30-60 seconds for emulator to boot
   - Run: `adb devices` again to verify

3. **For Physical Device:**
   - Ensure USB debugging is enabled
   - Connect via USB cable
   - Authorize connection on device (dialog appears)
   - Run: `adb devices` to verify

4. **If still not showing:**
   ```powershell
   # Restart ADB server:
   adb kill-server
   adb start-server
   adb devices
   ```

---

### Issue 5: "Android SDK not properly configured"

**Error message:**
```
[!!] ANDROID_SDK_ROOT environment variable not set
[XX] Android SDK not properly configured. Cannot launch on Android.
```

**Fixes:**

1. **Set environment variable:**
   - Find SDK location (ask Android Studio):
     ```powershell
     # Or check if you know it:
     Test-Path "C:\Users\$env:USERNAME\AppData\Local\Android\Sdk"
     ```
   
   - Add to Windows PATH:
     - Settings → System → About
     - Advanced system settings → Environment Variables
     - New → ANDROID_SDK_ROOT = `C:\Users\<Your Name>\AppData\Local\Android\Sdk`
     - Restart PowerShell

2. **Verify it worked:**
   ```powershell
   echo $env:ANDROID_SDK_ROOT
   # Should show your SDK path
   
   Test-Path "$env:ANDROID_SDK_ROOT\platform-tools\adb.exe"
   # Should return True
   ```

---

### Issue 6: Apps compile but don't open

**Chrome mode:**
- Manually open http://localhost:8081 in browser
- Check Flutter terminal for errors
- Enable DevTools: Visit http://localhost:9100 (shown in terminal)

**Android mode:**
- Check device screen - app may be installing
- View logs: `adb logcat | grep flutter`
- Ensure device has USB debugging enabled

---

### Issue 7: Hot Reload not working

**Symptoms:**
- Changes don't appear when pressing 'r'
- App still shows old code

**Fixes:**
1. **Ensure you're editing the right file:**
   - Changes in `lib/` directory only
   - Some changes require full rebuild (press 'R' instead)

2. **Check for errors:**
   - Look for red/yellow messages in terminal
   - Fix syntax errors and save

3. **Fall back to Hot Restart:**
   ```
   Press 'R' (capital R) in terminal
   This performs a full rebuild
   ```

---

### Issue 8: Script won't execute ("permission denied")

**Error message:**
```
.\launch_all.ps1 : File cannot be loaded. The file ... is not digitally signed.
```

**Fix:**
```powershell
# Run once (allows local scripts):
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Then run script:
.\launch_all.ps1
```

---

### Issue 9: PowerShell says "flutter command not found"

**Issue:**
- `flutter doctor` doesn't work in new PowerShell window

**Fix:**
```powershell
# Permanently add to PATH:
# 1. Find Flutter folder location
# 2. Settings → System → About → Advanced system settings
# 3. Environment Variables → PATH
# 4. New → C:\flutter\bin (or wherever flutter is)
# 5. Close and reopen PowerShell

# Verify:
flutter --version
```

---

## ✅ Verification Checklist

### Before Running Script

- [ ] Flutter installed: `flutter --version` works
- [ ] Chrome installed: Can open Chrome manually
- [ ] For Android: `adb devices` shows device(s)
- [ ] For Android: `$env:ANDROID_SDK_ROOT` is set
- [ ] Apps folder exists: `C:\Users\manoj\OneDrive\Desktop\Gomandap\flutter_app\apps`
- [ ] PowerShell execution policy set: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`

### After Launching Script

**Chrome Mode:**
- [ ] Chrome window opens automatically (or visit http://localhost:8081)
- [ ] App loads and shows GoMandap branding
- [ ] No red errors in Flutter terminal
- [ ] Can press 'r' to hot reload
- [ ] Mock auth is enabled (no login page)

**Android Mode:**
- [ ] Script shows "Building and deploying..."
- [ ] No build errors in terminal
- [ ] App installs on device/emulator
- [ ] App launches and shows GoMandap branding
- [ ] Can press 'r' to hot reload
- [ ] Mock auth works (app opens directly, no login)

---

## 📞 Getting Help

### Helpful Commands

```powershell
# Full diagnostics
flutter doctor -v

# Check all devices
flutter devices

# View Android device logs
adb logcat -s flutter

# Clear Flutter cache
flutter clean
flutter pub get

# Restart ADB
adb kill-server
adb start-server
```

### Information to Share

If asking for help, provide:
1. Full error message (copy-paste from terminal)
2. Output of `flutter doctor -v`
3. Output of `adb devices` (for Android issues)
4. Your OS version (Windows 10/11)
5. Steps you've already tried

---

## 🎓 Additional Resources

- **Flutter Official:** https://flutter.dev
- **Flutter Setup:** https://flutter.dev/docs/get-started/install/windows
- **Android Emulator:** https://developer.android.com/studio/run/emulator
- **ADB Documentation:** https://developer.android.com/studio/command-line/adb
- **Flutter DevTools:** https://flutter.dev/docs/development/tools/devtools/overview

---

**Last Updated:** May 28, 2026  
**Tested On:** Windows 10/11  
**Flutter Version:** 3.0+  
**Android SDK:** API 30+
