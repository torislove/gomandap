# GoMandap Launch Script - Implementation Plan

## Current Issues
1. Chrome not opening automatically (manual open logic conflicts with Flutter's built-in browser launch)
2. No Android mobile debugging support
3. Script lacks error handling for missing devices/tools
4. Missing validation for Flutter SDK and Android SDK

## Solution Overview

### 1. **Device Selection Mode**
   - Add `-Device` parameter: `chrome` (web), `android` (mobile), `auto` (detect)
   - Auto-detect connected Android devices
   - Validate device availability before launching

### 2. **Chrome Web Mode Fixes**
   - Remove manual `Wait-ForPort` Chrome opening (Flutter already handles this)
   - Let Flutter's runner open Chrome automatically
   - Add `--enable-impeller` for better Chrome performance
   - Fix port conflicts with proper netstat parsing

### 3. **Android Mobile Debug Mode**
   - Use `-d android` flag for device auto-selection
   - Add Android-specific Dart defines for memory optimization
   - Include `--profile` or `--release` options
   - Add `--network-interface` for proper Android emulator networking
   - Validate Android SDK and connected devices

### 4. **Error Handling & Validation**
   - Check Flutter SDK availability
   - Check Chrome availability (for web mode)
   - Detect connected Android devices
   - Validate app directories exist
   - Proper exit codes on failure

### 5. **Parameter Structure**
   ```
   -Device chrome|android|auto
   -ClientOnly / -VendorOnly / -AdminOnly
   -NoWait (skip waiting for server startup)
   -Profile (use profile mode for Android)
   ```

## Implementation Steps

### Phase 1: Setup & Validation
- [ ] Enhance prerequisites check (Flutter, Chrome, Android tools)
- [ ] Add device detection function
- [ ] Add parameter validation

### Phase 2: Device Selection
- [ ] Add `-Device` parameter support
- [ ] Create device selector function
- [ ] Update app launcher to use selected device

### Phase 3: Platform-Specific Logic
- [ ] Chrome web: Update flutter arguments (remove manual open)
- [ ] Android: Add Android-specific flags and validation

### Phase 4: Error Handling
- [ ] Add try-catch wrappers
- [ ] Validate network connectivity for Android
- [ ] Add helpful error messages

### Phase 5: Testing & Polish
- [ ] Test Chrome web mode
- [ ] Test Android emulator mode
- [ ] Test Android physical device mode
- [ ] Clean up logging

## Expected Outcomes
✅ Script launches Chrome web apps automatically (Flask-style auto-open)
✅ Script launches Android debug apps with proper device selection
✅ Clear error messages if devices/tools are missing
✅ Works with Android emulator and physical devices
✅ Backward compatible with existing parameters
