# McDonald's Neutral Fuels UCO Collection Web Application
## Full-Stack Development Plan: Flutter to Vue 3 Migration

**Document Version:** 1.0
**Date:** December 24, 2025
**Project:** McDonald's NF UCO Collection Web App
**Current Mobile Version:** 1.3.1
**Target Web Version:** 2.0.0

---

## Executive Summary

This document outlines the complete migration of the McDonald's Neutral Fuels Used Cooking Oil (UCO) collection mobile application from Flutter to a modern Vue 3 web application with Progressive Web App (PWA) capabilities, offline support, and real-time updates.

### Current State
- Flutter mobile app (iOS/Android) - Version 1.3.1
- 10 screens with OAuth2 authentication
- GPS tracking and staff verification
- REST API integration with Neutral Fuels UCO API
- Local state management with SharedPreferences

### Target Architecture
- **Frontend:** Vue 3 (Composition API) + TypeScript + Tailwind CSS
- **Backend:** Node.js + Express (Mediatory API for CORS handling)
- **Features:** All mobile features + PWA + Real-time updates + Offline support
- **Deployment:** Docker containers with runtime environment switching
- **Timeline:** 18 weeks (4.5 months)

---

## Table of Contents
1. [Application Overview](#1-application-overview)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure](#3-project-structure)
4. [API Architecture](#4-api-architecture)
5. [Frontend Architecture](#5-frontend-architecture)
6. [Backend Architecture](#6-backend-architecture)
7. [Feature Implementation](#7-feature-implementation)
8. [Development Phases](#8-development-phases)
9. [Docker Deployment](#9-docker-deployment)
10. [Testing Strategy](#10-testing-strategy)
11. [Security Considerations](#11-security-considerations)
12. [Critical Reference Files](#12-critical-reference-files)

---

## 1. Application Overview

### Purpose
Specialized logistics application for managing the collection, delivery, and tracking of Used Cooking Oil (UCO) from McDonald's restaurants by Neutral Fuels drivers.

### User Base
- McDonald's drivers (first-party)
- Third-party logistics (3PL) drivers
- Requires McDonald's/Neutral Fuels staff verification for transactions

### Core Functionality

#### Collection Flow
- Search and select McDonald's store
- Record full ROCs (containers) collected from store
- Record empty ROCs delivered to store
- Capture GPS location
- Verify with McDonald's staff ID
- Submit collection record

#### Delivery Flow (4 Types)
1. **From Another Truck** - Transfer ROCs between trucks
2. **From Stores** - Deliver collections from current truck
3. **Bulk Delivery** - Large-scale multi-store deliveries
4. **Collect Empty ROCs** - Pick up empty containers from Neutral Fuels site

#### Dashboard
- Daily statistics (oil collected, collections count, ROCs count)
- Collection history
- User profile with truck and location info

### Screens Overview (10 Total)
1. **Login** - OAuth2 authentication
2. **Home** - Tab-based navigation hub
3. **Dashboard** - Statistics and history (2 tabs: Summary/Collections)
4. **Collect** - Record collections (2 tabs: Empty ROCs/Full ROCs)
5. **Deliver** - Delivery operations (4 delivery types)
6. **SelectTruck** - Standard driver truck selection
7. **SelectTruck3PL** - 3PL driver truck selection
8. **SelectNewTruck** - Source truck for delivery
9. **SelectNewTruck3PL** - 3PL source truck for delivery
10. **SelectStore** - Store search and selection

---

## 2. Technology Stack

### Frontend
- **Framework:** Vue 3.4+ with Composition API
- **Language:** TypeScript 5+
- **Build Tool:** Vite 5+
- **Styling:** Tailwind CSS 3+
- **State Management:** Pinia 2+
- **Routing:** Vue Router 4+
- **HTTP Client:** Axios
- **WebSocket:** Socket.IO Client
- **Form Validation:** VeeValidate
- **Maps:** Leaflet or Google Maps API
- **Progress Indicators:** vue3-progress-bar
- **Loading Animations:** vue-spinner

### Backend
- **Runtime:** Node.js 18+
- **Framework:** Express 4+
- **Language:** TypeScript 5+
- **WebSocket:** Socket.IO
- **HTTP Client:** Axios (for UCO API proxy)
- **Logging:** Winston
- **Caching:** Redis
- **Security:** Helmet.js, CORS

### DevOps & Deployment
- **Containerization:** Docker & Docker Compose
- **Reverse Proxy:** Nginx
- **CI/CD:** GitHub Actions
- **SSL:** Let's Encrypt
- **Container Registry:** Docker Hub or AWS ECR

### Testing & Quality
- **Unit Testing:** Vitest
- **E2E Testing:** Playwright
- **Performance:** Lighthouse CI
- **Code Quality:** ESLint, Prettier
- **Type Checking:** TypeScript strict mode

---

## 3. Project Structure

### Monorepo Organization

```
mcd-nf-uco-web/
├── frontend/                          # Vue 3 Application
│   ├── public/
│   │   ├── manifest.json             # PWA manifest
│   │   ├── service-worker.js         # Offline support
│   │   └── icons/                    # App icons
│   ├── src/
│   │   ├── components/               # Reusable components
│   │   │   ├── common/              # AppButton, AppCard, LoadingSpinner
│   │   │   ├── layout/              # AppHeader, BottomNavigation, TabBar
│   │   │   └── forms/               # ROCInput, StaffVerification, StoreSearch
│   │   ├── composables/             # Composition functions
│   │   │   ├── useAuth.ts           # Authentication logic
│   │   │   ├── useGeolocation.ts    # GPS functionality
│   │   │   ├── useApi.ts            # API client wrapper
│   │   │   ├── useWebSocket.ts      # WebSocket connection
│   │   │   ├── useOffline.ts        # Offline detection & sync
│   │   │   └── useValidation.ts     # Form validation
│   │   ├── stores/                  # Pinia state management
│   │   │   ├── auth.ts              # User & token state
│   │   │   ├── collection.ts        # Collection operations
│   │   │   ├── delivery.ts          # Delivery operations
│   │   │   ├── dashboard.ts         # Statistics
│   │   │   ├── offline.ts           # Offline queue
│   │   │   └── ui.ts                # UI state
│   │   ├── views/                   # Page components
│   │   │   ├── LoginView.vue
│   │   │   ├── HomeView.vue
│   │   │   ├── DashboardView.vue
│   │   │   ├── CollectView.vue
│   │   │   ├── DeliverView.vue
│   │   │   └── Select*.vue
│   │   ├── services/                # API & business logic
│   │   │   ├── api/                 # API service classes
│   │   │   ├── storage/             # localStorage, IndexedDB
│   │   │   └── websocket/           # WebSocket service
│   │   ├── types/                   # TypeScript definitions
│   │   │   ├── models/              # User, Collection, Delivery, ROC
│   │   │   └── api/                 # Request/response types
│   │   ├── utils/                   # Utilities
│   │   │   ├── constants.ts         # App constants
│   │   │   ├── validators.ts        # Validation helpers
│   │   │   └── logger.ts            # Logging
│   │   ├── router/                  # Vue Router
│   │   └── styles/                  # Global styles
│   ├── tests/
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── package.json
│
├── backend/                          # Node.js/Express API
│   ├── src/
│   │   ├── config/                  # Configuration
│   │   │   ├── environment.ts       # Environment variables
│   │   │   ├── cors.ts              # CORS setup
│   │   │   └── logger.ts            # Winston logger
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts   # JWT validation
│   │   │   ├── error.middleware.ts  # Error handling
│   │   │   └── logging.middleware.ts
│   │   ├── routes/                  # Express routes
│   │   │   ├── auth.routes.ts       # /api/auth/*
│   │   │   ├── collection.routes.ts # /api/collection/*
│   │   │   ├── delivery.routes.ts   # /api/delivery/*
│   │   │   ├── truck.routes.ts      # /api/truck/*
│   │   │   ├── store.routes.ts      # /api/store/*
│   │   │   └── staff.routes.ts      # /api/staff/*
│   │   ├── services/
│   │   │   ├── proxy.service.ts     # UCO API proxy
│   │   │   ├── cache.service.ts     # Redis caching
│   │   │   └── websocket.service.ts # WebSocket manager
│   │   ├── websocket/
│   │   │   ├── server.ts            # Socket.IO server
│   │   │   └── handlers.ts          # Event handlers
│   │   ├── app.ts                   # Express setup
│   │   └── server.ts                # Entry point
│   ├── tests/
│   ├── tsconfig.json
│   └── package.json
│
├── docker/
│   ├── frontend.Dockerfile
│   ├── backend.Dockerfile
│   ├── nginx.conf
│   └── nginx-ssl.conf
├── docker-compose.yml               # Development
├── docker-compose.prod.yml          # Production
├── .github/workflows/               # CI/CD
└── docs/                            # Documentation
```

---

## 4. API Architecture

### Existing UCO API Endpoints

**Base URLs:**
- Test: `https://nf-test-ucoapi.neutralfuels.net`
- Production: `https://ucoapi.neutralfuels.net`
- Path Prefix: `/api/v1/`

**Authentication:**
```
POST /api/v1/Token
Body: { grant_type: "password", username: string, password: string }
Response: NFUserModel with access_token

POST /api/v1/Users/Logout
Headers: { Authorization: "Bearer <token>" }
```

**Customer & Resources:**
```
GET /api/v1/Customer/Trucks?customerid={id}
GET /api/v1/Customer/ThirdPartyTrucks?customerid={id}
GET /api/v1/Customer/Stores?customerid={id}
GET /api/v1/Customer/VerificationMethods?customerid={id}
GET /api/v1/Customer/VerificationRequest?customerid={id}&verifytypecode={code}&...
```

**Staff:**
```
GET /api/v1/McdStaff/StaffByStore?storeId={id}
GET /api/v1/McdStaff/StaffByCountry?countryid={id}
GET /api/v1/McdStaff/StaffMemberByEmployeeId?employeeid={id}
GET /api/v1/NFStaff/StaffBySite?siteId={id}
```

**Collections:**
```
GET /api/v1/ROCCollection/CollectionsPendingByTruckRego?truckrego={rego}&isallclientcollections={bool}
GET /api/v1/ROCCollection/EmptyRocsAtStore?storeid={id}
POST /api/v1/ROCCollection/newCollection
Body: RocCollectionModel (JSON)
```

**Deliveries & Despatch:**
```
POST /api/v1/ROCDelivery/newDelivery
Body: RcoDeliveryModel (JSON)

POST /api/v1/Despatch/newDepatchedEmpty
Body: EmptyDespatchRecordModel (JSON)
```

**System:**
```
GET /api/v1/System/MobileApps
Response: Version information
```

### Mediatory Backend API Design

**Purpose:** Handle CORS, relay requests to UCO API, add WebSocket support

**Endpoint Mapping:**

| Frontend Request | Backend Route | UCO API Endpoint |
|-----------------|---------------|------------------|
| POST /api/auth/login | /api/auth/login | POST /api/v1/Token |
| POST /api/auth/logout | /api/auth/logout | POST /api/v1/Users/Logout |
| GET /api/trucks | /api/trucks | GET /api/v1/Customer/Trucks |
| GET /api/trucks/3pl | /api/trucks/3pl | GET /api/v1/Customer/ThirdPartyTrucks |
| GET /api/stores | /api/stores | GET /api/v1/Customer/Stores |
| GET /api/staff/mcd/store/:id | /api/staff/mcd/store/:id | GET /api/v1/McdStaff/StaffByStore |
| GET /api/staff/mcd/employee | /api/staff/mcd/employee | GET /api/v1/McdStaff/StaffMemberByEmployeeId |
| GET /api/staff/nf/site/:id | /api/staff/nf/site/:id | GET /api/v1/NFStaff/StaffBySite |
| GET /api/collection/pending | /api/collection/pending | GET /api/v1/ROCCollection/CollectionsPendingByTruckRego |
| GET /api/collection/empty-rocs/:storeId | /api/collection/empty-rocs/:storeId | GET /api/v1/ROCCollection/EmptyRocsAtStore |
| POST /api/collection/new | /api/collection/new | POST /api/v1/ROCCollection/newCollection |
| POST /api/delivery/new | /api/delivery/new | POST /api/v1/ROCDelivery/newDelivery |
| POST /api/despatch/new | /api/despatch/new | POST /api/v1/Despatch/newDepatchedEmpty |
| GET /api/system/version | /api/system/version | GET /api/v1/System/MobileApps |

---

## 5. Frontend Architecture

### State Management (Pinia Stores)

**auth.ts** - Authentication State
```typescript
interface AuthState {
  user: NFUserModel | null
  token: string | null
  loginTime: string | null
  isAuthenticated: boolean
}

Actions:
- login(username, password)
- logout()
- loadFromStorage()
- validateToken()
- checkTokenExpiry()
```

**collection.ts** - Collection State
```typescript
interface CollectionState {
  selectedStore: Store | null
  emptyROCsAtStore: string[]
  fullROCs: CollectRocModel[]
  emptyROCs: CollectionEmptyRocModel[]
  pendingCollections: RocCollectionModel[]
}

Actions:
- fetchEmptyROCsAtStore(storeId)
- submitCollection(data)
- addFullROC(roc)
- addEmptyROC(roc)
- removeROC(index)
- checkDuplicateROC(rocNumber)
```

**delivery.ts** - Delivery State
```typescript
interface DeliveryState {
  selectedDeliveryType: string
  selectedTruck: Truck | null
  pendingROCs: DeliveryRocModel[]
}

Actions:
- fetchPendingDeliveries(truckRego)
- submitDelivery(data)
- markROCStatus(rocId, status)
```

**offline.ts** - Offline Queue
```typescript
interface OfflineState {
  queue: QueuedRequest[]
  isSyncing: boolean
}

Actions:
- queueRequest(request)
- syncQueue()
- removeFromQueue(id)
```

### Key Composables

**useAuth.ts**
```typescript
export function useAuth() {
  const authStore = useAuthStore()
  const router = useRouter()

  const login = async (username: string, password: string)
  const logout = async ()
  const checkTokenExpiry = ()
  const autoLogin = async ()

  return { login, logout, checkTokenExpiry, autoLogin, isAuthenticated }
}
```

**useGeolocation.ts**
```typescript
export function useGeolocation() {
  const getCurrentPosition = async (): Promise<{ latitude: number, longitude: number }>
  const watchPosition = (callback: Function)

  return { getCurrentPosition, watchPosition }
}
```

**useOffline.ts**
```typescript
export function useOffline() {
  const isOnline = ref(navigator.onLine)
  const queueRequest = (request: QueuedRequest)
  const syncQueue = async ()

  return { isOnline, queueRequest, syncQueue }
}
```

### Routing Configuration

```typescript
const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: LoginView,
    meta: { requiresAuth: false }
  },
  {
    path: '/home',
    name: 'Home',
    component: HomeView,
    meta: { requiresAuth: true },
    children: [
      { path: 'deliver', name: 'Deliver', component: DeliverView },
      { path: 'dashboard', name: 'Dashboard', component: DashboardView },
      { path: 'collect', name: 'Collect', component: CollectView }
    ]
  },
  {
    path: '/trucks',
    name: 'SelectTruck',
    component: SelectTruckView,
    meta: { requiresAuth: true }
  }
]

// Route Guard
router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    next('/home/dashboard')
  } else {
    next()
  }
})
```

### Component Design Pattern

```vue
<!-- Example: CollectView.vue -->
<template>
  <div class="min-h-screen bg-app-bg bg-cover p-4">
    <!-- Store Search -->
    <StoreSearchBar @store-selected="handleStoreSelected" />

    <!-- Tab Navigation -->
    <TabBar
      :tabs="['Empty ROCs', 'Full ROCs']"
      v-model="activeTab"
    />

    <!-- Empty ROCs Tab -->
    <div v-show="activeTab === 0">
      <EmptyROCsList :rocs="emptyROCs" @remove="removeEmptyROC" />
      <AppButton @click="showAddEmptyROC = true">Add Empty ROC</AppButton>
    </div>

    <!-- Full ROCs Tab -->
    <div v-show="activeTab === 1">
      <FullROCsList :rocs="fullROCs" @remove="removeFullROC" />
      <AppButton @click="showAddFullROC = true">Add Full ROC</AppButton>
    </div>

    <!-- Verify Button -->
    <AppButton
      color="primary"
      @click="verifyCollection"
      :disabled="!hasROCs"
    >
      Verify Collection
    </AppButton>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useCollectionStore } from '@/stores/collection'
import { useGeolocation } from '@/composables/useGeolocation'

const collectionStore = useCollectionStore()
const { getCurrentPosition } = useGeolocation()

const activeTab = ref(0)
const fullROCs = computed(() => collectionStore.fullROCs)
const emptyROCs = computed(() => collectionStore.emptyROCs)
const hasROCs = computed(() => fullROCs.value.length > 0 || emptyROCs.value.length > 0)

const handleStoreSelected = (store) => {
  collectionStore.selectedStore = store
  collectionStore.fetchEmptyROCsAtStore(store.storeid)
}

const verifyCollection = async () => {
  const position = await getCurrentPosition()
  // Show staff verification dialog
  // Submit collection with GPS coordinates
}
</script>
```

---

## 6. Backend Architecture

### Express Server Setup

**app.ts**
```typescript
import express from 'express'
import cors from 'cors'
import helmet from 'helmet'
import routes from './routes'
import { errorMiddleware } from './middleware/error.middleware'
import { loggingMiddleware } from './middleware/logging.middleware'

const app = express()

// Security
app.use(helmet())
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true
}))

// Parsing
app.use(express.json())
app.use(express.urlencoded({ extended: true }))

// Logging
app.use(loggingMiddleware)

// Routes
app.use('/api', routes)

// Error handling
app.use(errorMiddleware)

export default app
```

### Proxy Service

**services/proxy.service.ts**
```typescript
import axios from 'axios'

export class ProxyService {
  private baseURL: string

  constructor(environment: 'test' | 'production') {
    this.baseURL = environment === 'test'
      ? 'https://nf-test-ucoapi.neutralfuels.net'
      : 'https://ucoapi.neutralfuels.net'
  }

  async proxyRequest(method: string, endpoint: string, token: string, data?: any) {
    try {
      const response = await axios({
        method,
        url: `${this.baseURL}${endpoint}`,
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        data
      })
      return response.data
    } catch (error) {
      throw this.transformError(error)
    }
  }
}
```

### WebSocket Server

**websocket/server.ts**
```typescript
import { Server as SocketIOServer } from 'socket.io'

export function setupWebSocket(httpServer) {
  const io = new SocketIOServer(httpServer, {
    cors: {
      origin: process.env.FRONTEND_URL,
      methods: ['GET', 'POST']
    }
  })

  io.on('connection', (socket) => {
    console.log('Client connected:', socket.id)

    // Join truck room
    socket.on('join:truck', (truckRego) => {
      socket.join(`truck:${truckRego}`)
    })

    // Disconnect
    socket.on('disconnect', () => {
      console.log('Client disconnected:', socket.id)
    })
  })

  return io
}
```

### Route Example

**routes/collection.routes.ts**
```typescript
import { Router } from 'express'
import { authMiddleware } from '../middleware/auth.middleware'
import { ProxyService } from '../services/proxy.service'

const router = Router()
const proxy = new ProxyService(process.env.ENVIRONMENT)

// POST /api/collection/new
router.post('/new', authMiddleware, async (req, res, next) => {
  try {
    const data = await proxy.proxyRequest(
      'POST',
      '/api/v1/ROCCollection/newCollection',
      req.token,
      req.body
    )

    // Emit WebSocket event
    req.app.get('io').emit('collection:created', data)

    res.json(data)
  } catch (error) {
    next(error)
  }
})

export default router
```

---

## 7. Feature Implementation

### Authentication Flow

**Login Process:**
1. User enters username/password
2. Frontend calls `/api/auth/login`
3. Backend proxies to UCO API `/api/v1/Token`
4. Validate `isMcDUser === 'True'`
5. Save token to localStorage
6. Save encrypted credentials to IndexedDB (for offline auto-login)
7. Save login time for token expiry calculation
8. Navigate to home/dashboard

**Logout Process:**
1. Call `/api/auth/logout`
2. Clear localStorage
3. Clear IndexedDB
4. Clear Pinia stores
5. Navigate to login

**Token Expiry:**
- Calculate: `loginTime + expiresIn > currentTime`
- Check on route navigation
- Auto-logout if expired

### GPS Location Capture

```typescript
// composables/useGeolocation.ts
export function useGeolocation() {
  const getCurrentPosition = async () => {
    return new Promise((resolve, reject) => {
      if (!navigator.geolocation) {
        reject('Geolocation not supported')
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          resolve({
            latitude: position.coords.latitude,
            longitude: position.coords.longitude
          })
        },
        (error) => reject(error),
        { enableHighAccuracy: true, timeout: 5000, maximumAge: 0 }
      )
    })
  }

  return { getCurrentPosition }
}
```

### Form Validation

**ROC Number Validation:**
- Required field
- Numeric only
- Max 4 digits
- No duplicates in current collection

**Quantity Validation:**
- Required field
- Numeric with decimals
- Max 5 characters (edit) or 3 characters (new)
- Greater than 0

**Staff ID Validation:**
- Required for collection submission
- Must exist in system (API verification)

**Implementation with VeeValidate:**
```typescript
import { useForm, useField } from 'vee-validate'
import * as yup from 'yup'

const schema = yup.object({
  rocNumber: yup.string()
    .required('ROC number is required')
    .matches(/^\d{1,4}$/, 'ROC number must be 1-4 digits')
    .test('unique', 'ROC already added', (value) => !isDuplicateROC(value)),
  quantity: yup.number()
    .required('Quantity is required')
    .positive('Quantity must be greater than 0')
    .max(99999, 'Quantity too large'),
  state: yup.string().required('State is required')
})

const { handleSubmit, errors } = useForm({ validationSchema: schema })
```

### Offline Support

**Request Queue Strategy:**
1. Detect offline state: `!navigator.onLine`
2. Queue failed requests in IndexedDB
3. Listen for online event
4. Sync queue when connection restored
5. Handle conflicts (timestamp-based)

**Caching Strategy:**
- **API Responses:** Network First, Cache Fallback (24hr expiry)
- **Static Assets:** Cache First (30 day expiry)
- **Service Worker:** No cache (always fresh)

### Real-time Updates

**Events to Emit:**
- `collection:created` - New collection submitted
- `delivery:created` - New delivery submitted
- `dashboard:update` - Statistics changed

**Frontend Listener:**
```typescript
// In DashboardView.vue
const { socket } = useWebSocket()

watch(socket, (newSocket) => {
  if (newSocket) {
    newSocket.on('collection:created', (data) => {
      dashboardStore.fetchPendingCollections()
    })
  }
})
```

---

## 8. Development Phases

### Phase 1: Foundation (Week 1-2)
**Goal:** Project setup and core infrastructure

**Tasks:**
- Create monorepo structure
- Initialize Vue 3 + Vite + TypeScript
- Initialize Express + TypeScript
- Configure Tailwind CSS
- Set up Pinia and Vue Router
- Configure ESLint, Prettier
- Set up Docker Compose for local dev
- Configure environment variables (.env files)

**Deliverable:** Running dev environment with hot reload

---

### Phase 2: Authentication (Week 3)
**Goal:** Complete authentication flow

**Backend Tasks:**
- Implement `/api/auth/login` route
- Implement `/api/auth/logout` route
- Create auth middleware for JWT validation
- Proxy OAuth2 flow to UCO API

**Frontend Tasks:**
- Build LoginView.vue
- Create auth store (Pinia)
- Create useAuth composable
- Implement route guards
- Set up secure storage (IndexedDB)
- Handle token expiry

**Testing:**
- Unit tests for auth services
- E2E test for login/logout flow

**Deliverable:** Working login/logout with persistent sessions

---

### Phase 3: Core API Integration (Week 4-5)
**Goal:** Proxy all UCO API endpoints

**Backend Tasks:**
- Create proxy service
- Implement all route files:
  - auth.routes.ts
  - truck.routes.ts
  - store.routes.ts
  - staff.routes.ts
  - collection.routes.ts
  - delivery.routes.ts
  - despatch.routes.ts
  - system.routes.ts
- Add error handling middleware
- Add logging middleware

**Frontend Tasks:**
- Create API client (Axios instance)
- Create service classes for each domain
- Define TypeScript types for all models
- Implement error handling

**Testing:**
- Mock API responses
- Unit tests for each service
- Integration tests with test environment

**Deliverable:** All API endpoints accessible from frontend

---

### Phase 4: Dashboard Screen (Week 6)
**Goal:** First complete screen with data

**Components:**
- DashboardView.vue
- UserProfileCard.vue
- OilCollectedCard.vue (with progress indicator)
- CollectionsTodayCard.vue
- ROCsCollectedCard.vue
- CollectionsList.vue

**State Management:**
- Dashboard store
- Fetch pending collections
- Calculate statistics (oil collected, collections count, ROCs count)

**Styling:**
- Mobile-first responsive design
- Match Flutter colors and design language
- Tailwind CSS implementation

**Deliverable:** Functional dashboard screen matching mobile app

---

### Phase 5: Collection Screen (Week 7-8)
**Goal:** Most complex screen with forms and validation

**Components:**
- CollectView.vue
- StoreSearchBar.vue
- StoreInfoCard.vue
- TabBar.vue (Empty ROCs / Full ROCs tabs)
- ROCForm.vue
- StaffVerificationDialog.vue

**Business Logic:**
- Store selection flow
- ROC number validation (4 digits max, no duplicates)
- GPS location capture
- Staff ID verification
- Form submission with all data

**State Management:**
- Collection store
- Form state management
- Validation rules

**Testing:**
- Unit tests for validation
- E2E test for complete collection flow

**Deliverable:** Complete collection flow from store selection to submission

---

### Phase 6: Delivery Screen (Week 9-10)
**Goal:** Delivery screen with 4 delivery types

**Components:**
- DeliverView.vue
- DeliveryTypeSelector.vue
- FromAnotherTruck.vue
- FromStores.vue
- BulkDelivery.vue
- CollectEmptyROCs.vue

**Business Logic:**
- Delivery type selection
- Pending ROCs display
- ROC verification (Confirmed/Missing/Disputed)
- NF staff verification
- Despatch logic for empty ROCs

**State Management:**
- Delivery store
- Form validations

**Deliverable:** All 4 delivery types functional

---

### Phase 7: Truck & Store Selection (Week 11)
**Goal:** Support screens for truck and store selection

**Components:**
- SelectTruckView.vue
- SelectTruck3PLView.vue
- SelectStoreView.vue

**Features:**
- Search and filter functionality
- List display with scrolling
- Truck selection (standard vs 3PL based on user type)
- Store selection with search
- Save selection to localStorage

**Deliverable:** Working truck/store selection screens

---

### Phase 8: Home & Navigation (Week 12)
**Goal:** Tab-based navigation

**Components:**
- HomeView.vue
- BottomNavigation.vue
- TabContainer.vue

**Features:**
- Tab switching (Deliver / Dashboard / Collect)
- Persistent active tab state
- Environment indicator (test = red, prod = green)
- Version display

**Deliverable:** Complete navigation flow between all screens

---

### Phase 9: Real-time & WebSocket (Week 13)
**Goal:** Live updates across users

**Backend Tasks:**
- Set up Socket.IO server
- Implement room management (per truck)
- Create event emitters for collection/delivery creation

**Frontend Tasks:**
- Create useWebSocket composable
- Add WebSocket connection to App.vue
- Implement listeners in Dashboard and other views
- Add connection status indicator

**Events:**
- `collection:created`
- `delivery:created`
- `dashboard:update`

**Deliverable:** Real-time dashboard updates when collections/deliveries are created

---

### Phase 10: Offline Support & PWA (Week 14-15)
**Goal:** Full offline capability

**PWA Tasks:**
- Create service worker with caching strategies
- Create manifest.json
- Generate app icons (multiple sizes)
- Implement install prompts

**Offline Queue:**
- Set up IndexedDB for offline storage
- Implement request queuing
- Create background sync
- Handle conflict resolution

**Caching Strategy:**
- API responses: Network First (24hr cache)
- Static assets: Cache First (30 day cache)
- Service worker: No cache (always fresh)

**Testing:**
- Test offline collection submission
- Test sync when back online
- Test PWA installation

**Deliverable:** Installable PWA with full offline support

---

### Phase 11: Testing & Quality Assurance (Week 16-17)
**Goal:** Comprehensive testing

**Unit Tests:**
- All composables (useAuth, useGeolocation, etc.)
- All Pinia stores
- All API services
- Utility functions

**Integration Tests:**
- API integration with backend
- Authentication flow
- Data submission flows

**E2E Tests (Playwright):**
- Complete user journeys
- Login → Select Truck → Collect → Submit
- Login → Select Truck → Deliver → Submit
- Offline scenarios

**Performance Testing:**
- Lighthouse audit (target: 90+ scores)
- Bundle size optimization
- Load time optimization
- Mobile performance testing

**Deliverable:** 80%+ test coverage, passing E2E tests, Lighthouse score 90+

---

### Phase 12: Deployment & DevOps (Week 18)
**Goal:** Production deployment

**Docker Tasks:**
- Create multi-stage Dockerfiles
- Optimize image sizes
- Create docker-compose files (dev & prod)
- Configure Nginx reverse proxy

**CI/CD Tasks:**
- Set up GitHub Actions workflows
- Automated testing on PR
- Docker image builds
- Automated deployment

**Monitoring:**
- Set up error tracking (Sentry or similar)
- Set up logging aggregation
- Configure analytics

**Security:**
- SSL certificates (Let's Encrypt)
- Environment variable management
- Security headers (Helmet.js)

**Deliverable:** Production-ready deployment with CI/CD

---

## 9. Docker Deployment

### Frontend Dockerfile

```dockerfile
# Multi-stage build
FROM node:18-alpine AS build

WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
ARG VITE_BACKEND_URL
ENV VITE_BACKEND_URL=$VITE_BACKEND_URL
RUN npm run build

# Production
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Backend Dockerfile

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY backend/package*.json ./
RUN npm ci --only=production
COPY backend/dist ./dist

ENV NODE_ENV=production
ENV PORT=3000

EXPOSE 3000
CMD ["node", "dist/server.js"]
```

### Docker Compose (Production)

```yaml
version: '3.8'

services:
  frontend:
    build:
      context: .
      dockerfile: docker/frontend.Dockerfile
      args:
        VITE_BACKEND_URL: https://api.yourdomain.com/api
    ports:
      - "80:80"
    restart: unless-stopped

  backend:
    build:
      context: .
      dockerfile: docker/backend.Dockerfile
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - ENVIRONMENT=production
      - UCO_API_URL=https://ucoapi.neutralfuels.net
      - FRONTEND_URL=https://yourdomain.com
    restart: unless-stopped
    depends_on:
      - redis

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    volumes:
      - redis-data:/data

volumes:
  redis-data:
```

### Deployment Commands

```bash
# Build images
docker-compose -f docker-compose.prod.yml build

# Start services
docker-compose -f docker-compose.prod.yml up -d

# View logs
docker-compose -f docker-compose.prod.yml logs -f

# Stop services
docker-compose -f docker-compose.prod.yml down
```

---

## 10. Testing Strategy

### Unit Testing (Vitest)

**Test Coverage Goals:**
- Composables: 90%+
- Stores: 90%+
- Services: 85%+
- Components: 70%+

**Example Test:**
```typescript
// tests/unit/composables/useAuth.spec.ts
import { describe, it, expect, vi } from 'vitest'
import { useAuth } from '@/composables/useAuth'

describe('useAuth', () => {
  it('should login successfully', async () => {
    const { login } = useAuth()
    await login('testuser', 'password123')
    expect(localStorage.getItem('token')).toBeTruthy()
  })

  it('should reject non-McDonald users', async () => {
    const { login } = useAuth()
    await expect(login('invaliduser', 'pass'))
      .rejects.toThrow('Invalid User')
  })
})
```

### Integration Testing

**Focus Areas:**
- API integration with backend
- Authentication flow
- Collection submission
- Delivery submission
- Offline sync

### E2E Testing (Playwright)

**Critical User Journeys:**
1. Login → Select Truck → Dashboard
2. Collection: Login → Truck → Collect → Store → Add ROCs → Verify → Submit
3. Delivery: Login → Truck → Deliver → Type Selection → Verify → Submit
4. Offline: Collection while offline → Come online → Auto-sync

**Example E2E Test:**
```typescript
import { test, expect } from '@playwright/test'

test('complete collection flow', async ({ page }) => {
  // Login
  await page.goto('/login')
  await page.fill('[data-test="username"]', 'testuser')
  await page.fill('[data-test="password"]', 'testpass')
  await page.click('[data-test="login-btn"]')

  // Select truck
  await page.click('[data-test="truck-item-0"]')

  // Navigate to collect
  await page.click('[data-test="nav-collect"]')

  // Select store
  await page.click('[data-test="search-store"]')
  await page.fill('[data-test="store-search"]', 'Store 123')
  await page.click('[data-test="store-result-0"]')

  // Add ROC
  await page.click('[data-test="add-roc"]')
  await page.selectOption('[data-test="roc-number"]', '1234')
  await page.fill('[data-test="quantity"]', '50')
  await page.click('[data-test="confirm"]')

  // Verify and submit
  await page.click('[data-test="verify"]')
  await page.fill('[data-test="staff-id"]', '12345')
  await page.click('[data-test="submit"]')

  // Assert success
  await expect(page).toHaveURL('/home/dashboard')
})
```

### Performance Testing

**Lighthouse CI Configuration:**
- Performance: 90+
- Accessibility: 90+
- Best Practices: 90+
- SEO: 90+
- PWA: 80+

---

## 11. Security Considerations

### Frontend Security

**XSS Prevention:**
- Vue's built-in HTML escaping
- Avoid `v-html` with user input
- Content Security Policy headers

**Secure Storage:**
- Encrypt credentials in IndexedDB using Web Crypto API
- Never store tokens in cookies (use localStorage)
- Clear all storage on logout

**Input Validation:**
- Client-side validation with VeeValidate
- Sanitize all user inputs
- Validate ROC numbers, quantities, staff IDs

### Backend Security

**CORS Configuration:**
```typescript
app.use(cors({
  origin: process.env.FRONTEND_URL,
  credentials: true,
  optionsSuccessStatus: 200
}))
```

**Security Headers (Helmet.js):**
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- X-XSS-Protection: 1; mode=block
- Strict-Transport-Security

**Rate Limiting:**
```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per window
})

app.use('/api/', limiter)
```

**Environment Variables:**
- Never commit `.env` files
- Use environment variable validation
- Use secrets management in production (AWS Secrets Manager, etc.)

---

## 12. Critical Reference Files

During implementation, reference these files from the Flutter codebase:

### 1. Authentication Flow
**File:** `lib/services/authentication.dart`
**Why:** Contains OAuth2 flow, token management, credential storage pattern

### 2. Collection Screen Logic
**File:** `lib/screens/collect/collect.dart`
**Why:** Most complex screen with GPS, forms, validation, and API integration

### 3. API Endpoints
**File:** `lib/services/list_provider.dart`
**Why:** Complete endpoint mapping and request handling patterns

### 4. Data Models
**File:** `lib/models/new_collection_record_model.dart`
**Why:** Critical data structure for collection submission

### 5. Constants & Configuration
**File:** `lib/screens/components/constants.dart`
**Why:** Environment config, version management, theming

### 6. Delivery Logic
**File:** `lib/screens/deliver/deliver.dart`
**Why:** 4 delivery types implementation

### 7. Data Provider Patterns
**File:** `lib/services/record_creators.dart`
**Why:** POST request patterns for creating records

---

## Appendix A: Data Models Reference

### NFUserModel (TypeScript)
```typescript
interface NFUserModel {
  accessToken: string
  tokenType: string
  expiresIn: number
  id: string
  username: string
  email: string
  licenseNo: string
  firstName: string
  lastName: string
  isMcDUser: 'True' | 'False'
  customerId: string
  customerName: string
  countryId: string
  countryIso: string
  siteId: string
  timeZoneName: string
  customerHasTruck: 'True' | 'False'
  isthirdpartyuser: 'True' | 'False'
}
```

### RocCollectionModel
```typescript
interface RocCollectionModel {
  containers: CollectRocModel[]
  emptyROCsSupplied: CollectionEmptyRocModel[]
  truckrego: string
  storeid: string
  supervisorname: string
  supervisorid: number
  ucoreceiptnumber: number
  datetimeofcollection: string  // ISO8601
  latitude: number
  longitude: number
  verifycode: string
}

interface CollectRocModel {
  rocNumber: string
  quantity: number
  state: string
  containerTypeId: number
}

interface CollectionEmptyRocModel {
  rocNumber: string
}
```

### RcoDeliveryModel
```typescript
interface RcoDeliveryModel {
  containers: DeliveryRocModel[]
  userid: string
  datetimeofdelivery: string  // ISO8601
  truckrego: string
  staffid: number
  comments: string
}

interface DeliveryRocModel {
  ucocollectionid: number
  rocnumber: string
  quantity: number
  state: string
  containertypeid: number
  ismissing: boolean
}
```

---

## Appendix B: Tailwind Configuration

```javascript
// tailwind.config.js
module.exports = {
  content: ['./index.html', './src/**/*.{vue,js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: '#258AFF',        // Flutter primaryColor
        secondary: '#52CB00',      // Flutter secondaryColor
        'widget-orange': 'rgba(244, 152, 35, 0.7)',
        'widget-pink': 'rgba(212, 97, 210, 0.7)',
        'widget-blue': 'rgba(36, 200, 248, 0.7)',
        'widget-grey': 'rgba(133, 155, 144, 0.3)',
      },
      borderRadius: {
        '15': '15px',
        '30': '30px',
        '100': '100px',
      },
      backgroundImage: {
        'app-bg': "url('/assets/bg.jpg')",
      },
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
  ],
}
```

---

## Appendix C: Environment Variables

### Frontend (.env)
```bash
VITE_BACKEND_URL=http://localhost:3000/api
VITE_APP_VERSION=2.0.0
VITE_APP_CODE=MCDUCOWEB
```

### Backend (.env)
```bash
NODE_ENV=development
PORT=3000
ENVIRONMENT=test

# UCO API URLs
UCO_API_TEST_URL=https://nf-test-ucoapi.neutralfuels.net
UCO_API_PROD_URL=https://ucoapi.neutralfuels.net

# CORS
FRONTEND_URL=http://localhost:5173

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# Logging
LOG_LEVEL=debug
```

---

## Success Criteria

### Feature Parity
- ✅ All 10 screens implemented
- ✅ OAuth2 authentication working
- ✅ GPS location capture
- ✅ Staff verification
- ✅ Collection submission
- ✅ Delivery submission (all 4 types)
- ✅ Dashboard statistics
- ✅ Environment switching (test/prod)

### New Features
- ✅ PWA with offline support
- ✅ Real-time updates via WebSocket
- ✅ Installable on mobile devices
- ✅ Background sync for offline requests

### Performance
- ✅ Lighthouse score 90+ (all categories)
- ✅ First Contentful Paint < 1.5s
- ✅ Time to Interactive < 3s
- ✅ Bundle size < 500KB (gzipped)

### Quality
- ✅ 80%+ test coverage
- ✅ All E2E tests passing
- ✅ No critical accessibility violations
- ✅ No security vulnerabilities

### Deployment
- ✅ Docker containerization
- ✅ CI/CD pipeline
- ✅ Production deployment
- ✅ Monitoring and logging

---

## Timeline Summary

| Phase | Duration | Description |
|-------|----------|-------------|
| Phase 1 | Week 1-2 | Foundation & Setup |
| Phase 2 | Week 3 | Authentication |
| Phase 3 | Week 4-5 | API Integration |
| Phase 4 | Week 6 | Dashboard Screen |
| Phase 5 | Week 7-8 | Collection Screen |
| Phase 6 | Week 9-10 | Delivery Screen |
| Phase 7 | Week 11 | Truck/Store Selection |
| Phase 8 | Week 12 | Navigation |
| Phase 9 | Week 13 | Real-time Features |
| Phase 10 | Week 14-15 | Offline & PWA |
| Phase 11 | Week 16-17 | Testing & QA |
| Phase 12 | Week 18 | Deployment |
| **Total** | **18 weeks** | **4.5 months** |

---

## Contact & Support

For questions or clarifications during implementation:
- Review the Flutter codebase reference files listed in Section 12
- Check the API documentation at the UCO API endpoints
- Refer to this plan for architectural decisions

---

**End of Document**
