# 16KB Page Size Support for isar_flutter_libs

This document describes the changes made to support Android's new 16KB page size requirement for devices running Android 15+ (API level 35).

## Background

Starting November 1, 2025, Google Play requires all new app submissions and updates to support 16KB memory page size on Android 15+ 64-bit devices. This affects apps with native libraries (.so files).

## Changes Made

### 1. Rust Linker Configuration
**File:** `packages/isar_core_ffi/.cargo/config.toml`

Added `-Wl,-z,max-page-size=16384` linker flag for all Android targets:
- `aarch64-linux-android` (ARM64)
- `armv7-linux-androideabi` (ARMv7)
- `x86_64-linux-android` (x86_64)
- `i686-linux-android` (x86)

This ensures that all compiled native libraries are aligned for 16KB page size.

### 2. Android Build Configuration
**File:** `packages/isar_flutter_libs/android/build.gradle`

- Updated Android Gradle Plugin: `7.3.1` → `8.7.3`
- Updated `compileSdkVersion`: `34` → `35`
- Added NDK version specification: `27.0.12077973` (supports 16KB alignment)
- Configured NDK ABI filters for all supported architectures
- Set `useLegacyPackaging = false` for native libraries

### 3. Gradle Wrapper Update
**File:** `packages/isar_flutter_libs/android/gradle/wrapper/gradle-wrapper.properties`

- Updated Gradle: `7.4` → `8.13-all`

### 4. Gradle Properties
**File:** `packages/isar_flutter_libs/android/gradle.properties`

Added:
```properties
android.bundle.enableUncompressedNativeLibs=false
```

## Requirements

To build with 16KB page size support, ensure you have:

- **Android Gradle Plugin**: 8.5.1 or higher ✅ (using 8.7.3)
- **Gradle**: 8.5 or higher ✅ (using 8.13)
- **NDK**: r27 or higher ✅ (using r27.0.12077973)
- **Compile SDK**: 35 ✅
- **Flutter**: 3.32 or higher (for app development)

## Building Native Libraries

Rebuild the native libraries with the new configuration:

```bash
cd /path/to/isar

# Build for ARM64 (most common)
./tool/build_android.sh arm64

# Build for ARMv7
./tool/build_android.sh armv7

# Build for x86_64 (emulator)
./tool/build_android.sh x64
```

The build script will automatically use the linker flags from `.cargo/config.toml`.

## Verification

Use the provided script to verify that your built APK/AAB supports 16KB page size:

```bash
# Make script executable (first time only)
chmod +x tool/check_elf_alignment.sh

# Check your APK
./tool/check_elf_alignment.sh path/to/your-app.apk

# Or check AAB
./tool/check_elf_alignment.sh path/to/your-app.aab
```

The script will:
- Extract all `.so` files from the package
- Check ELF alignment for each library
- Report which libraries pass/fail the 16KB requirement

Expected output for success:
```
✅ All libraries are compatible with 16KB page size!
```

## Testing on Devices

To test 16KB page size support:

1. **Use a real device** with Android 15+ (Pixel 9, etc.)
2. **Or use an emulator** configured with 16KB page size:
   - Create a new AVD with Android 15 (API 35)
   - The system will automatically use 16KB pages

## Troubleshooting

### Build Errors

If you encounter build errors:

1. **Clean build cache:**
   ```bash
   cd packages/isar_flutter_libs/android
   ./gradlew clean
   ```

2. **Verify NDK installation:**
   ```bash
   ls $ANDROID_SDK_ROOT/ndk/
   # Should show version 27.0.12077973 or higher
   ```

3. **Update NDK if needed:**
   - Open Android Studio
   - Go to SDK Manager
   - Install NDK version 27.0.12077973 or higher

### Verification Failures

If `check_elf_alignment.sh` reports failures:

1. **Check that you rebuilt** all native libraries after updating the config
2. **Verify `.cargo/config.toml`** contains the correct linker flags
3. **Ensure you're using NDK r27+** for compilation

### Other Dependencies

The article mentions other common libraries that may need updates:

- **fast_rsa**: Update to version that supports 16KB or find alternative
- **sqflite**: Update to latest version (4.0.0+)
- Check all dependencies for `.so` files in your app

## Resources

- [Official Google Documentation](https://developer.android.com/guide/practices/page-sizes)
- [Medium Article: 16KB Migration Guide](https://medium.com/easy-flutter/androids-16kb-page-size-explained-flutter-migration-made-simple-c9af18d756c1)
- [Android Developer Blog](https://android-developers.googleblog.com/)

## Summary

All changes have been implemented to ensure `isar_flutter_libs` fully supports 16KB page size. The native libraries (`libisar.so`) will be built with proper alignment when compiled using the updated build scripts and configuration.

Next steps:
1. Rebuild native libraries using the build scripts
2. Run verification script on your app
3. Test on Android 15+ devices or emulators
4. Update other dependencies as needed
