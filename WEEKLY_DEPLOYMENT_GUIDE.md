# Weekly Deployment Guide - ResqLink Mobile

## Overview
This document details exactly what files and folders your colleague needs to copy from each weekly release to integrate changes into their UI-only project.

---

## **WEEK 1: Foundation + Auth + User Profile**
**Commit:** `f51a26b` (feat(user-profile): wire profile screens to AuthProvider and UserApi)

### **1. Core Infrastructure - CREATE NEW FOLDERS**

#### `lib/core/` (NEW FOLDER)
Copy entire folder structure:
```
lib/core/
├── constants/
│   └── api_constants.dart
└── errors/
    └── app_exception.dart
└── utils/
    └── date_formatter.dart
```

#### `lib/models/` (NEW FOLDER)
Copy all 6 model files:
```
lib/models/
├── user_model.dart
├── driver_profile_model.dart
├── ride_request_model.dart
├── tracking_model.dart
├── chat_message_model.dart
└── ambulance_model.dart
```

#### `lib/providers/` (NEW FOLDER)
Copy all 4 provider files:
```
lib/providers/
├── auth_provider.dart
├── chat_provider.dart
├── ride_provider.dart
└── tracking_provider.dart
```

#### `lib/services/` (NEW FOLDER)
Copy all 9 service files:
```
lib/services/
├── api_service.dart (BASE - Most Important)
├── auth_api.dart
├── user_api.dart
├── chat_api.dart
├── ride_api.dart
├── driver_api.dart
├── dispatch_api.dart
├── socket_service.dart
└── storage_service.dart
```

### **2. Update Existing Files**

#### Modified Screens:
- `lib/screens/login_screen.dart` - Connect to AuthProvider
- `lib/screens/signup_screen.dart` - Connect to AuthProvider
- `lib/screens/verify_otp_screen.dart` - Connect to AuthProvider
- `lib/screens/send_verification_screen.dart` - Connect to AuthProvider
- `lib/screens/splash_screen.dart` - Add auth check logic
- `lib/screens/welcome_screen.dart` - Minor updates
- `lib/screens/home_screen.dart` - Connect to ride_provider
- `lib/screens/user_profile_screen.dart` - Connect to user_api
- `lib/screens/edit_profile_screen.dart` - Connect to user_api

#### Modified Configuration:
- `lib/main.dart` - Add providers & API initialization
- `pubspec.yaml` - Add dependencies
- `pubspec.lock` - Dependencies lock file

#### Platform-Specific (Auto-generated):
- `linux/flutter/generated_plugin_registrant.cc`
- `linux/flutter/generated_plugins.cmake`
- `macos/Flutter/GeneratedPluginRegistrant.swift`
- `windows/flutter/generated_plugin_registrant.cc`
- `windows/flutter/generated_plugins.cmake`

### **Week 1 Summary**
- **New Folders:** 4 (core, models, providers, services)
- **New Files:** 18
- **Updated Files:** 11 (screens + config)
- **Total Files:** 29+

---

## **WEEK 2: Driver + Paramedic Modules**
**Commit:** `a314120` (feat(paramedic): wire paramedic screens to backend API)

### **1. Driver Module - NEW FOLDER**

#### `lib/screens/driver/` (NEW FOLDER)
Copy all 4 driver screen files:
```
lib/screens/driver/
├── driver_alert_screen.dart
├── driver_profile_screen.dart
├── driver_ride_screen.dart
└── edit_driver_profile_screen.dart
```

### **2. Paramedic Module - NEW FOLDER**

#### `lib/screens/paramedic/` (NEW FOLDER)
Copy all 3 paramedic screen files:
```
lib/screens/paramedic/
├── paramedic_alert_screen.dart
├── paramedic_profile_screen.dart
└── edit_para_profile_screen.dart
```

### **3. Ride Booking Related Screens**

#### New Booking Screens:
- `lib/screens/SelectVehicleScreen.dart` - Vehicle selection
- `lib/screens/booking_history_screen.dart` - View booking history
- `lib/screens/fare_selection_screen.dart` - Select ride fare
- `lib/screens/select_payment_method_screen.dart` - Choose payment
- `lib/screens/select_route_screen.dart` - Select pickup/drop route
- `lib/screens/user_ride_details_sceen.dart` - View ride details

### **Week 2 Summary**
- **New Folders:** 2 (driver, paramedic)
- **New Files:** 13
- **All Week 1 files:** INCLUDED ✅
- **Total Files to Deploy:** Week 1 + 13 new files

---

## **WEEK 3: Ride Booking + Minor Fixes**
**Commit:** `b32f17d` (fix: clean up remaining minor issues across screens)

### **1. Updates to Existing Screens**

#### Modified Files:
- `lib/screens/SelectVehicleScreen.dart` - Fix improvements
- `lib/screens/user_profile_screen.dart` - Minor refinements
- `lib/screens/vehical_edit_profile_screen.dart` - Vehicle edit screen

### **Week 3 Summary**
- **New Files:** 1 (vehical_edit_profile_screen.dart - new vehicle edit)
- **Updated Files:** 2
- **All Week 1 + Week 2 files:** INCLUDED ✅
- **Total Files to Deploy:** Week 1 + Week 2 + 3 updated files

---

## **DEPLOYMENT CHECKLIST**

### **For Week 1 Deployment:**
- [ ] Create `lib/core/` folder with constants, errors, utils
- [ ] Create `lib/models/` folder with 6 model files
- [ ] Create `lib/providers/` folder with 4 provider files
- [ ] Create `lib/services/` folder with 9 service files
- [ ] Replace `lib/main.dart` with new version
- [ ] Update all 9 screen files (auth, home, profile)
- [ ] Update `pubspec.yaml` with dependencies
- [ ] Run `flutter pub get`
- [ ] Test auth flow (login, signup, OTP)

### **For Week 2 Deployment:**
- [ ] Copy entire first-week-work folder
- [ ] Create `lib/screens/driver/` folder with 4 files
- [ ] Create `lib/screens/paramedic/` folder with 3 files
- [ ] Copy 6 new booking-related screen files to `lib/screens/`
- [ ] Run `flutter pub get`
- [ ] Test driver profile & paramedic profile screens
- [ ] Test ride booking flow

### **For Week 3 Deployment:**
- [ ] Copy entire second-week-work folder
- [ ] Replace `SelectVehicleScreen.dart` with updated version
- [ ] Replace `user_profile_screen.dart` with updated version
- [ ] Add `vehical_edit_profile_screen.dart`
- [ ] Run `flutter pub get`
- [ ] Test all screens for minor fixes

---

## **Quick Copy Commands (PowerShell)**

### **Week 1:**
```powershell
# Copy folder
Copy-Item -Path "D:\first-week-work\lib" -Destination "D:\colleague_project\lib" -Recurse -Force

# Copy config files
Copy-Item -Path "D:\first-week-work\pubspec.yaml" -Destination "D:\colleague_project\pubspec.yaml" -Force
Copy-Item -Path "D:\first-week-work\pubspec.lock" -Destination "D:\colleague_project\pubspec.lock" -Force
```

### **Week 2:**
```powershell
# Copy folder
Copy-Item -Path "D:\second-week-work\lib" -Destination "D:\colleague_project\lib" -Recurse -Force

# Copy config files
Copy-Item -Path "D:\second-week-work\pubspec.yaml" -Destination "D:\colleague_project\pubspec.yaml" -Force
Copy-Item -Path "D:\second-week-work\pubspec.lock" -Destination "D:\colleague_project\pubspec.lock" -Force
```

### **Week 3:**
```powershell
# Copy folder
Copy-Item -Path "D:\third-week-work\lib" -Destination "D:\colleague_project\lib" -Recurse -Force

# Copy config files
Copy-Item -Path "D:\third-week-work\pubspec.yaml" -Destination "D:\colleague_project\pubspec.yaml" -Force
Copy-Item -Path "D:\third-week-work\pubspec.lock" -Destination "D:\colleague_project\pubspec.lock" -Force
```

---

## **Complete File Structure After All Weeks**

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   ├── errors/
│   │   └── app_exception.dart
│   └── utils/
│       └── date_formatter.dart
├── models/
│   ├── user_model.dart
│   ├── driver_profile_model.dart
│   ├── ride_request_model.dart
│   ├── tracking_model.dart
│   ├── chat_message_model.dart
│   └── ambulance_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   ├── ride_provider.dart
│   └── tracking_provider.dart
├── services/
│   ├── api_service.dart
│   ├── auth_api.dart
│   ├── user_api.dart
│   ├── chat_api.dart
│   ├── ride_api.dart
│   ├── driver_api.dart
│   ├── dispatch_api.dart
│   ├── socket_service.dart
│   └── storage_service.dart
├── screens/
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── verify_otp_screen.dart
│   │   ├── send_verification_screen.dart
│   │   └── ...
│   ├── driver/
│   │   ├── driver_alert_screen.dart
│   │   ├── driver_profile_screen.dart
│   │   ├── driver_ride_screen.dart
│   │   └── edit_driver_profile_screen.dart
│   ├── paramedic/
│   │   ├── paramedic_alert_screen.dart
│   │   ├── paramedic_profile_screen.dart
│   │   └── edit_para_profile_screen.dart
│   ├── SelectVehicleScreen.dart
│   ├── booking_history_screen.dart
│   ├── edit_profile_screen.dart
│   ├── fare_selection_screen.dart
│   ├── home_screen.dart
│   ├── select_payment_method_screen.dart
│   ├── select_route_screen.dart
│   ├── user_profile_screen.dart
│   ├── user_ride_details_sceen.dart
│   ├── vehical_edit_profile_screen.dart
│   └── ...
├── main.dart
├── config/
│   └── theme.dart
└── routes/
    └── app_routes.dart

pubspec.yaml
pubspec.lock
```

---

## **Important Notes**

1. **Always copy pubspec.yaml and pubspec.lock** - Dependencies need to be updated each week
2. **Run `flutter pub get`** after each deployment
3. **Test each feature** before moving to next week
4. **Backend URL** is set in `lib/core/constants/api_constants.dart` - May need adjustment for different environments
5. **Platform files** (linux, macos, windows) are auto-generated - Don't need manual copy
6. **Android/iOS folders** - Not shown in this guide, they should update automatically

---

## **Support**

If any files are missing or conflicts occur:
1. Compare with the ZIP files provided (first-week-work.zip, second-week-work.zip, third-week-work.zip)
2. Check git diff: `git diff COMMIT1 COMMIT2 --name-only`
3. Verify pubspec.yaml dependencies match

---

**Last Updated:** 2026-06-07
**Project:** ResqLink Mobile
**Branch Strategy:** Weekly feature releases with cumulative changes
