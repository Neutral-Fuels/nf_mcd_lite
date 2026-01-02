# Critical Reference Files from Flutter App

This directory contains the 7 most important files from the Flutter mobile app that your team should reference during the Vue 3 web application development.

## Files Overview

### 1. `authentication.dart` (3.4 KB)
**Purpose:** OAuth2 authentication flow, token management, and credential storage

**Key Implementation Details:**
- OAuth2 password grant flow to UCO API
- Token storage in SharedPreferences
- Encrypted credential storage in FlutterSecureStorage
- User validation (isMcDUser check)
- Login time tracking for token expiry

**Use This For:**
- Implementing the login flow in Vue 3
- Understanding token management patterns
- Setting up secure credential storage with IndexedDB
- Auth store (Pinia) implementation
- useAuth composable logic

---

### 2. `collect.dart` (67 KB)
**Purpose:** Most complex screen - oil collection from stores

**Key Implementation Details:**
- Store selection flow
- Two-tab interface (Empty ROCs / Full ROCs)
- ROC number validation (4 digits max, no duplicates)
- GPS location capture
- Staff verification workflow
- Form submission with all data
- Duplicate ROC checking logic
- State management patterns

**Use This For:**
- CollectView.vue implementation (Phase 5: Week 7-8)
- Form validation rules with VeeValidate
- GPS integration with useGeolocation composable
- Collection store (Pinia) implementation
- Understanding the complete collection workflow

**Important Patterns:**
- `checkROCNumber()` - Duplicate detection
- `verifyAndSubmit()` - Staff verification flow
- State structure for managing ROC lists

---

### 3. `list_provider.dart` (6.6 KB)
**Purpose:** Complete API endpoint mapping and GET request patterns

**Key Implementation Details:**
- All GET request handlers
- Token injection in headers
- Error handling (401 auto-logout)
- Endpoint URLs and query parameters
- Response parsing

**API Endpoints Covered:**
- `getTruckList()` → GET /api/v1/Customer/Trucks
- `get3plTruckList()` → GET /api/v1/Customer/ThirdPartyTrucks
- `getStoreList()` → GET /api/v1/Customer/Stores
- `getClientStaffList()` → GET /api/v1/McdStaff/StaffByStore
- `getNfStaffListBySite()` → GET /api/v1/NFStaff/StaffBySite
- `getCollectionListPendingForCleint()` → GET /api/v1/ROCCollection/CollectionsPendingByTruckRego
- `getEmptyROCList()` → GET /api/v1/ROCCollection/EmptyRocsAtStore
- `getCurrentMobileVersionInPROD()` → GET /api/v1/System/MobileApps

**Use This For:**
- Backend route implementation (Phase 3: Week 4-5)
- Frontend API service classes
- Understanding request/response patterns
- Error handling strategies
- Query parameter mapping

---

### 4. `new_collection_record_model.dart` (1.0 KB)
**Purpose:** Critical data structure for collection submission

**Key Implementation Details:**
- RocCollectionModel structure
- CollectRocModel (full ROCs)
- CollectionEmptyRocModel (empty ROCs)
- JSON serialization (toJson/fromJson)

**Data Model:**
```dart
RocCollectionModel {
  containers: List<CollectRocModel>
  emptyROCsSupplied: List<CollectionEmptyRocModel>
  truckrego: String
  storeid: String
  supervisorname: String
  supervisorid: int
  ucoreceiptnumber: int
  datetimeofcollection: String (ISO8601)
  latitude: double
  longitude: double
  verifycode: String
}
```

**Use This For:**
- TypeScript interface definitions (types/models/Collection.ts)
- API request payload structure
- Understanding field names and types
- Form data structure in collection store

---

### 5. `constants.dart` (901 B)
**Purpose:** Environment configuration, version management, and theming

**Key Implementation Details:**
- API URLs (test/prod environments)
- App version and build numbers
- Mobile app code
- Color scheme (primary blue, secondary green)
- Environment switching flag

**Important Constants:**
```dart
mobileAppCode: 'MCDUCO'
mobileAppVersion: '1.3.1'
isTestEnv: true/false
testEnv: 'https://nf-test-ucoapi.neutralfuels.net'
prodEnv: 'https://ucoapi.neutralfuels.net'
primaryColor: #258AFF
secondaryColor: #52CB00
```

**Use This For:**
- utils/constants.ts implementation
- Tailwind CSS color configuration
- Environment variable setup (.env files)
- Version management
- Runtime environment switching logic

---

### 6. `deliver.dart` (114 KB)
**Purpose:** Delivery screen with 4 delivery types implementation

**Key Implementation Details:**
- 4 delivery type workflows:
  1. From Another Truck (truck-to-truck transfer)
  2. From Stores (deliver collections)
  3. Bulk Delivery (multi-store)
  4. Collect Empty ROCs (pick up empties)
- ROC verification (Confirmed/Missing/Disputed)
- NF staff verification
- Pending ROC display logic
- State management for each delivery type

**Use This For:**
- DeliverView.vue implementation (Phase 6: Week 9-10)
- Understanding the 4 delivery type components
- Delivery store (Pinia) implementation
- ROC status management
- Despatch logic for empty ROCs

**Important Patterns:**
- Delivery type selection logic
- ROC status tracking
- Staff verification for deliveries

---

### 7. `record_creators.dart` (3.1 KB)
**Purpose:** POST request patterns for creating records

**Key Implementation Details:**
- POST request handlers
- Collection submission
- Delivery submission
- Despatch submission
- Error handling and navigation

**API Endpoints:**
- `newCollection()` → POST /api/v1/ROCCollection/newCollection
- `newDelivery()` → POST /api/v1/ROCDelivery/newDelivery
- `newDespatch()` → POST /api/v1/Despatch/newDepatchedEmpty

**Use This For:**
- Backend POST route implementation
- Frontend service classes (collection.service.ts, delivery.service.ts)
- Understanding request body structure
- Success/error handling patterns
- Navigation after successful submission

---

## How to Use These Files

### During Backend Development (Phase 3)
1. Reference **list_provider.dart** for GET endpoints
2. Reference **record_creators.dart** for POST endpoints
3. Use the patterns for:
   - Token injection in headers
   - Error handling (especially 401 responses)
   - Query parameter formatting
   - Response structure

### During Frontend Development (Phase 4-10)
1. Reference **authentication.dart** for auth flow (Phase 2)
2. Reference **constants.dart** for environment setup (Phase 1)
3. Reference **collect.dart** for collection screen (Phase 5)
4. Reference **deliver.dart** for delivery screen (Phase 6)
5. Reference **new_collection_record_model.dart** for TypeScript interfaces (Phase 3)

### Key Patterns to Replicate

#### Error Handling
```dart
// Flutter pattern
if (response.statusCode == 200) {
  // Success
} else if (response.statusCode == 401) {
  // Clear storage and logout
} else {
  // Log error and return null
}
```

#### Token Management
```dart
// Flutter pattern
String token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
String _head = "Bearer $token";
headers: { HttpHeaders.authorizationHeader: _head }
```

#### State Management
```dart
// Flutter pattern
setState(() {
  // Update state
})
```
**→ Vue 3:** Use Pinia actions and reactive state

---

## File Size Reference
- **Largest:** `deliver.dart` (114 KB) - Most complex screen with 4 delivery types
- **Second Largest:** `collect.dart` (67 KB) - Complex form with validation
- **Smallest:** `constants.dart` (901 B) - Configuration values

---

## Development Phase Reference

| Phase | Files to Reference |
|-------|-------------------|
| Phase 1: Foundation | constants.dart |
| Phase 2: Authentication | authentication.dart |
| Phase 3: API Integration | list_provider.dart, record_creators.dart |
| Phase 4: Dashboard | list_provider.dart |
| Phase 5: Collection Screen | collect.dart, new_collection_record_model.dart |
| Phase 6: Delivery Screen | deliver.dart, record_creators.dart |
| Phase 7-12: All Others | All files as needed |

---

## Important Notes

1. **Do NOT Copy Dart Code Directly** - These files are for reference only. Translate the logic to Vue 3/TypeScript patterns.

2. **Focus on Business Logic** - Pay attention to:
   - Validation rules
   - API call sequences
   - State management patterns
   - Error handling strategies
   - Navigation flows

3. **TypeScript Types** - Use the Dart models to create accurate TypeScript interfaces in `frontend/src/types/models/`

4. **API Endpoint Mapping** - The exact endpoint URLs, query parameters, and request bodies are all in these files.

5. **Environment Variables** - The constants file shows you exactly what configuration values need to be environment-aware.

---

## Questions?

If you're unsure how to translate a Flutter pattern to Vue 3:
1. Check the main development plan (MIGRATION_PLAN.md)
2. Look at the code examples in the plan
3. Focus on the business logic, not the framework-specific syntax

---

**Happy Coding! 🚀**
