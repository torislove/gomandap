# 🚀 GoMandap Launch Script - Quick Reference Card

## ⚡ Quick Start (30 seconds)

### **Chrome Web - All Apps**
```powershell
cd C:\Users\manoj\OneDrive\Desktop\Gomandap
.\launch_all.ps1
```
✅ Chrome opens automatically  
✅ All 3 apps run on localhost:8081, 8082, 8083  
✅ No login needed (mock auth ON)

---

### **Android Mobile - All Apps**
```powershell
cd C:\Users\manoj\OneDrive\Desktop\Gomandap
.\launch_all.ps1 -Device android
```
✅ Deploys to Android device or emulator  
✅ First build: 1-3 minutes  
✅ Hot-reload ready

---

## 📚 All Commands

| Command | Purpose |
|---------|---------|
| `.\launch_all.ps1` | All 3 apps in Chrome |
| `.\launch_all.ps1 -Device android` | All 3 apps on Android |
| `.\launch_all.ps1 -ClientOnly` | Client app only (Chrome) |
| `.\launch_all.ps1 -Device android -VendorOnly` | Vendor app only (Android) |
| `.\launch_all.ps1 -Device auto` | Auto-detect device |
| `.\launch_all.ps1 -Help` | Show full help |

---

## 🔑 Terminal Shortcuts (While App Running)

| Key | Action |
|-----|--------|
| **r** | Hot reload (fast refresh) |
| **R** | Hot restart (full rebuild) |
| **q** | Quit app |
| **d** | Detach |
| **p** | Performance overlay |

---

## ✅ Prerequisites Checklist

- [ ] **Flutter SDK** installed and in PATH  
  `flutter doctor` should pass
- [ ] **Chrome** installed (for web mode)  
  Auto-detected, no setup needed
- [ ] **Android SDK** (for Android mode)  
  Set `ANDROID_SDK_ROOT` environment variable
- [ ] **Android Device or Emulator** (for Android mode)  
  Connected and USB debugging enabled

---

## 🔧 Fix Common Issues

### Chrome not opening?
→ Manually visit `http://localhost:8081`

### Android device not found?
→ Run `adb devices` to check connection

### Port already in use?
→ Script auto-cleans, wait 2-3 seconds and retry

### "Permission denied" error?
→ Run: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`

---

## 📍 Port Mapping (Chrome Mode)

| App | Port | URL |
|-----|------|-----|
| Client Panel | 8081 | http://localhost:8081 |
| Vendor Suite | 8082 | http://localhost:8082 |
| Admin Portal | 8083 | http://localhost:8083 |

---

## 🎯 Mock Auth Info

All apps come with mock authentication enabled:

- **Auto-login:** No real login needed
- **OTP code:** 123456 (if visiting /login manually)
- **Bypass:** MOCK_AUTH=true (Dart define)
- **Works on:** Both Chrome and Android

---

## 💡 Pro Tips

1. **Faster builds:** Use `-ClientOnly` flag if testing just one app
2. **Network issues:** Add `--enable-impeller` for better Chrome performance
3. **Debugging:** Use Flutter DevTools (link shown in terminal)
4. **Logs on Android:** Run `adb logcat` in separate terminal
5. **Kill stuck process:** `taskkill /IM flutter.bat /F`

---

## 📖 Full Documentation

See `LAUNCH_USAGE_GUIDE.md` for:
- Detailed setup instructions
- Troubleshooting guide
- Environment variables configuration
- Manual Flutter commands
- Device setup instructions

---

## 🔗 File Locations

```
c:\Users\manoj\OneDrive\Desktop\Gomandap\
├── launch_all.ps1              ← Main script
├── LAUNCH_USAGE_GUIDE.md        ← Full guide (you are here)
├── LAUNCH_PLAN.md              ← Implementation details
├── flutter_app/
│   ├── apps/
│   │   ├── client/
│   │   ├── vendor/
│   │   └── admin/
```

---

**Version:** 2.0 | **Updated:** May 28, 2026  
**Tested on:** Windows 10/11 with Flutter 3.x, Android SDK 30+
