# ResqLink Mobile - Screens Audit Report

**Date:** 2026-06-15  
**Branch:** audit-screens  
**Status:** 29 Screens Audited

---

## EXECUTIVE SUMMARY

| Status | Count | Screens |
|--------|-------|---------|
| ✅ Fully Integrated | 16 | Authentication, User Profile, Ride Booking, Driver/Paramedic |
| ⚠️ Partially Integrated | 5 | Home, Route Selection, Payment Methods, Language |
| ❌ Not Integrated | 5 | Payment Cards, Chat, Notifications, Password, Vehicle Edit |
| ✅ UI Only (By Design) | 2 | Welcome, Vehicle Selection |
| **TOTAL** | **29** | |

---

## DETAILED AUDIT BY CATEGORY

### 1. AUTHENTICATION & ONBOARDING (6 screens)

#### ✅ login_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `AuthProvider.login()` → `AuthApi.login()`
- **Features:** Email/Phone + Password authentication
- **Actions:** Calls backend API, stores token, navigates by role
- **Health:** ✅ PRODUCTION READY

#### ✅ signup_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `AuthProvider.register()` → `AuthApi.register()`
- **Features:** Name, Email/Phone, Password, Role selection
- **Actions:** Creates user account, auto-login, navigates to profile setup
- **Health:** ✅ PRODUCTION READY

#### ✅ verify_otp_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `AuthApi.verifyOtp()` with resend via `AuthApi.sendOtp()`
- **Features:** OTP input, resend with countdown, auto-validation
- **Actions:** Verifies OTP, shows errors, sets token
- **Health:** ✅ PRODUCTION READY

#### ✅ send_verification_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `AuthApi.sendOtp()`
- **Features:** Email/Phone input, OTP request
- **Actions:** Triggers OTP email/SMS
- **Health:** ✅ PRODUCTION READY

#### ✅ splash_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `AuthApi.getProfile()` with auto-token retrieval
- **Features:** Session validation on app startup
- **Actions:** Checks stored token, loads user, routes to home/login
- **Health:** ✅ PRODUCTION READY

#### ✅ welcome_screen.dart
- **Status:** UI ONLY (CORRECT BY DESIGN)
- **Purpose:** Role selection gateway
- **Health:** ✅ WORKS AS INTENDED

---

### 2. USER PROFILE & SETTINGS (5 screens)

#### ⚠️ home_screen.dart
- **Status:** PARTIALLY INTEGRATED
- **Implemented:**
  - ✅ Displays user name from `AuthProvider`
  - ✅ Drawer with navigation links
  - ✅ Logout functionality
  - ✅ Bottom navigation (Home/Profile)
  
- **Missing:**
  - ❌ Location list is hardcoded (3 static hospitals)
  - ❌ Search bar is non-functional
  - ❌ No API call to load recent locations
  - ❌ No real ride booking shortcuts
  
- **Priority:** 🟡 IMPORTANT
- **Fix Required:** Add location API integration

#### ✅ user_profile_screen.dart
- **Status:** FULLY INTEGRATED (Read-Only)
- **API:** Reads from `AuthProvider.currentUser`
- **Features:** View profile, edit link, notifications, language, logout
- **Health:** ✅ PRODUCTION READY

#### ✅ edit_profile_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `UserApi.updateUser()`
- **Features:** Update name, email, phone
- **Actions:** Calls backend, updates provider, shows success
- **Health:** ✅ PRODUCTION READY

#### ✅ booking_history_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `RideProvider.loadMyRides()` → `RideApi.getMyRides()`
- **Features:** Shows all past rides, ratings, costs, status badges
- **Actions:** Displays real ride history, rebook button (for completed rides)
- **Health:** ✅ PRODUCTION READY

#### ⚠️ language_selection_screen.dart
- **Status:** PARTIALLY INTEGRATED
- **Implemented:**
  - ✅ UI responds to language selection dynamically
  - ✅ Visual feedback on selected language
  
- **Missing:**
  - ❌ No API to save preference
  - ❌ No app-wide localization (all hardcoded in English)
  - ❌ Preference lost on app restart
  
- **Priority:** 🟡 IMPORTANT
- **Fix Required:** Add language preference API + localization

---

### 3. RIDE BOOKING FLOW (5 screens)

#### ✅ SelectVehicleScreen.dart
- **Status:** UI ONLY (CORRECT BY DESIGN)
- **Features:** Select ambulance type (BASIC / WITH_DOCTOR)
- **Pricing:** Hardcoded (PKR 500 base + PKR 100/km)
- **Purpose:** Selection before route/fare
- **Health:** ✅ WORKS AS INTENDED
- **Optional Enhancement:** Fetch vehicle types from API

#### ⚠️ select_route_screen.dart
- **Status:** PARTIALLY INTEGRATED
- **Implemented:**
  - ✅ Gets user real location via Geolocator
  - ✅ Shows current location on map
  - ✅ Navigates to fare selection on confirm
  
- **Missing:**
  - ❌ Destination list is hardcoded (3 hospitals)
  - ❌ No location search API
  - ❌ Can't add custom destinations
  - ❌ No maps integration for dynamic selection
  
- **Priority:** 🟡 IMPORTANT
- **Fix Required:** Integrate location search API

#### ✅ fare_selection_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `DispatchApi.findNearest()` to locate ambulances
- **Features:** Shows available ambulances with ETA, driver rating, cost
- **Actions:** Selects ambulance, proceeds to payment
- **Health:** ✅ PRODUCTION READY

#### ⚠️ select_payment_method_screen.dart
- **Status:** PARTIALLY INTEGRATED
- **Implemented:**
  - ✅ Shows payment options (Visa, MasterCard, Bank Transfer, PayPak)
  - ✅ Calls `RideProvider.createRide()` on confirm
  - ✅ Navigates to ride details
  
- **Missing:**
  - ❌ Payment methods are hardcoded (not fetched from API)
  - ❌ No payment method validation
  - ❌ No API to fetch user's saved cards
  
- **Priority:** 🟡 IMPORTANT
- **Fix Required:** Fetch available payment methods from API

#### ❌ payment/card_flow_screen.dart
- **Status:** NOT INTEGRATED
- **Current State:**
  - 3-step flow: Form → Scanner → Preview
  - Form submission: `onPressed: () { // Logic to save manual entry }`
  - Scanner button: navigates to mock scanner view
  
- **Missing:**
  - ❌ Card validation (no expiry, CVV check)
  - ❌ No API to save card details
  - ❌ No tokenization for security
  - ❌ No actual payment processing
  
- **Priority:** 🔴 CRITICAL
- **Fix Required:** Implement payment API integration

#### ❌ payment/add_card_screen.dart
- **Status:** NOT INTEGRATED
- **Current State:**
  - Empty form fields with placeholders
  - All buttons have empty handlers: `onTap: () {}`
  - Suggests card scanning & Face ID (not implemented)
  
- **Missing:**
  - ❌ Card validation
  - ❌ No API to save card
  - ❌ No card scanning implementation
  - ❌ No biometric support
  
- **Priority:** 🔴 CRITICAL
- **Fix Required:** Implement card saving API

---

### 4. RIDE TRACKING & DETAILS (1 screen)

#### ✅ user_ride_details_sceen.dart
- **Status:** FULLY INTEGRATED
- **API:** Polls `RideApi.getRide()` every 10 seconds for live updates
- **Features:** Real-time ETA, driver info, cost, route
- **Actions:** Allows rating when trip completes via `RideApi.rateRide()`
- **Health:** ✅ PRODUCTION READY

---

### 5. CHAT & MESSAGING (1 screen)

#### ❌ chat_screen.dart
- **Status:** NOT INTEGRATED
- **Current State:**
  - Hardcoded demo messages
  - Paramedic name hardcoded
  - Send button is non-functional: `onPressed: () {}`
  - Uses `ChatProvider` but no API calls
  
- **Missing:**
  - ❌ No message send API call
  - ❌ No message fetch from backend
  - ❌ No real-time updates
  - ❌ No message storage
  
- **Impact:** BLOCKS paramedic workflow (chat required after accept ride)
- **Priority:** 🔴 CRITICAL
- **Fix Required:** Implement `ChatApi` integration

---

### 6. DRIVER FEATURES (4 screens)

#### ✅ driver/driver_profile_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `DriverApi.getProfileByUserId()` + `RideApi.getDriverRides()`
- **Features:** Shows driver profile, license, experience, earnings
- **Polling:** Refreshes available rides every 30 seconds
- **Health:** ✅ PRODUCTION READY

#### ✅ driver/edit_driver_profile_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `UserApi.updateUser()`
- **Features:** Update driver profile (name, email, phone)
- **Health:** ✅ PRODUCTION READY

#### ✅ driver/driver_alert_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `RideApi.acceptRide()` / `RideApi.rejectRide()`
- **Features:** Shows incoming ride request, accept/reject buttons
- **Health:** ✅ PRODUCTION READY

#### ✅ driver/driver_ride_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** Updates ride status, calls `RideApi.updateStatus()`
- **Features:** Live tracking, ETA, cost, end trip button
- **Health:** ✅ PRODUCTION READY

#### ✅ driver/rider_notifications_screen.dart
- **Status:** FULLY INTEGRATED
- **Features:** Shows driver-specific notifications
- **Health:** ✅ PRODUCTION READY

---

### 7. PARAMEDIC FEATURES (4 screens)

#### ✅ paramedic/paramedic_profile_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `ParamedicApi.getProfileByUserId()` (uses `DriverProfileModel`)
- **Features:** Shows paramedic profile, qualifications
- **Polling:** Refreshes available calls every 30 seconds
- **Note:** Reuses driver model - could be optimized
- **Health:** ✅ PRODUCTION READY

#### ✅ paramedic/edit_para_profile_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `UserApi.updateUser()`
- **Features:** Update paramedic profile
- **Health:** ✅ PRODUCTION READY

#### ✅ paramedic/paramedic_alert_screen.dart
- **Status:** FULLY INTEGRATED
- **API:** `RideApi.acceptRide()` / `RideApi.rejectRide()`
- **Features:** Shows emergency request, accept/reject
- **Caveat:** Navigates to `chat_screen` on accept (which is non-functional)
- **Health:** ⚠️ WORKS BUT BLOCKED BY CHAT

#### ✅ paramedic/paramedi_notifications_screen.dart
- **Status:** FULLY INTEGRATED
- **Features:** Paramedic-specific notifications
- **Health:** ✅ PRODUCTION READY

---

### 8. SETTINGS & CONFIGURATION (3 screens)

#### ❌ notifications_screen.dart
- **Status:** NOT INTEGRATED
- **Current State:**
  - Toggles stored in local state only
  - No API to persist preferences
  - Settings lost on app restart
  
- **Missing:**
  - ❌ No backend API for preferences
  - ❌ No persistent storage
  - ❌ No notification service integration
  
- **Priority:** 🟡 IMPORTANT
- **Fix Required:** Add notification preferences API

#### ❌ set_password_screen.dart
- **Status:** NOT INTEGRATED
- **Current State:**
  - Form fields with length validation only
  - Submit button navigates directly: `onPressed: () { Navigator.pushNamed(context, AppRoutes.home); }`
  - No API call
  
- **Missing:**
  - ❌ No password strength validation
  - ❌ No password update API call
  - ❌ No backend persistence
  - ❌ No confirmation email
  
- **Priority:** 🔴 CRITICAL
- **Fix Required:** Implement password update API

#### ⚠️ privacy_policy_screen.dart
- **Status:** UI ONLY
- **Content:** Static hardcoded policy text
- **Health:** ✅ WORKS AS INTENDED

---

### 9. VEHICLE MANAGEMENT (1 screen)

#### ❌ vehical_edit_profile_screen.dart
- **Status:** NOT INTEGRATED (BY DESIGN)
- **Current State:**
  - All fields read-only mockup
  - Submit shows: "Vehicle details are managed by admin"
  - No API integration
  
- **Design:** This is intentional - vehicles managed by admin panel
- **Priority:** 🟢 NICE TO HAVE
- **Health:** ✅ CORRECT BY DESIGN

---

## API INTEGRATION STATUS SUMMARY

### Services Created ✅
- ✅ `api_service.dart` - Base HTTP layer with Dio
- ✅ `auth_api.dart` - Authentication (login, register, OTP)
- ✅ `user_api.dart` - User profile updates
- ✅ `ride_api.dart` - Ride operations (create, accept, cancel, rate)
- ✅ `driver_api.dart` - Driver profile
- ✅ `dispatch_api.dart` - Find nearest ambulances
- ⚠️ `chat_api.dart` - EXISTS BUT NOT USED
- ⚠️ `socket_service.dart` - EXISTS BUT NOT IMPLEMENTED
- ✅ `storage_service.dart` - Token/user storage

### Providers Created ✅
- ✅ `auth_provider.dart` - Authentication state
- ✅ `ride_provider.dart` - Ride booking state
- ⚠️ `chat_provider.dart` - EXISTS BUT NOT CONNECTED
- ⚠️ `tracking_provider.dart` - EXISTS BUT NOT FULLY USED

---

## CRITICAL BLOCKERS

### 🔴 MUST FIX BEFORE PRODUCTION

1. **CORS Issue on Backend**
   - Impact: ALL API calls fail from web
   - Status: Needs backend fix
   - Timeline: URGENT

2. **Chat Not Functional**
   - Impact: Paramedic workflow broken
   - Status: Needs `ChatApi` integration
   - Timeline: CRITICAL

3. **Payment Not Complete**
   - Impact: Can't complete ride booking
   - Status: Card saving & payment API needed
   - Timeline: CRITICAL

4. **Password Update Missing**
   - Impact: Users can't change password
   - Status: Needs API endpoint
   - Timeline: CRITICAL

---

## RECOMMENDATIONS

### Phase 1 (Urgent - Before Beta)
- [ ] Fix CORS on backend
- [ ] Implement ChatApi integration
- [ ] Implement payment card saving API
- [ ] Implement password update API
- [ ] Test full ride booking flow end-to-end

### Phase 2 (High Priority - Before Release)
- [ ] Integrate location search API (home, route selection)
- [ ] Fetch payment methods from API
- [ ] Add notification preferences persistence
- [ ] Implement language preference persistence
- [ ] Add error boundaries to all screens

### Phase 3 (Nice to Have - Polish)
- [ ] Fetch vehicle types dynamically
- [ ] Real-time chat with WebSocket
- [ ] Push notifications
- [ ] Offline mode support
- [ ] Advanced tracking features

---

## FILES TO UPDATE

### Need API Integration:
```
lib/screens/chat_screen.dart ← CRITICAL
lib/screens/payment/add_card_screen.dart ← CRITICAL
lib/screens/payment/card_flow_screen.dart ← CRITICAL
lib/screens/set_password_screen.dart ← CRITICAL
lib/screens/home_screen.dart ← IMPORTANT
lib/screens/select_route_screen.dart ← IMPORTANT
lib/screens/select_payment_method_screen.dart ← IMPORTANT
lib/screens/notifications_screen.dart ← IMPORTANT
lib/screens/language_selection_screen.dart ← IMPORTANT
```

### API Services to Create/Update:
```
lib/services/chat_api.dart ← CRITICAL (exists, needs wiring)
lib/services/payment_api.dart ← CRITICAL (create new)
lib/services/location_api.dart ← IMPORTANT (create new)
lib/services/notification_api.dart ← IMPORTANT (create new)
```

---

**Report Generated:** 2026-06-15  
**Auditor:** Claude Code  
**Branch:** audit-screens
