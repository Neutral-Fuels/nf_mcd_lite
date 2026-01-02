# Quick Start Guide

## Project Successfully Built! ✅

The McDonald's Neutral Fuels UCO Collection Web Application has been successfully built from scratch. Phase 1 (Foundation) is complete!

## Installation Status

✅ **Frontend**: 447 packages installed
✅ **Backend**: 310 packages installed
✅ All dependencies ready

## Start Development

### Option 1: Run Locally (Recommended for Development)

**Terminal 1 - Backend:**
```bash
cd backend
npm run dev
```
The backend will start on `http://localhost:3000`

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```
The frontend will start on `http://localhost:5173`

### Option 2: Run with Docker

```bash
docker-compose up
```
This will start:
- Frontend on `http://localhost:5173`
- Backend on `http://localhost:3000`
- Redis on `localhost:6379`

## Verify Setup

### Test Backend
```bash
curl http://localhost:3000/api/health
```

Expected response:
```json
{
  "success": true,
  "message": "McDonald's UCO API is running",
  "timestamp": "2025-12-24T..."
}
```

### Test Frontend
Open your browser to `http://localhost:5173`
You should see the login page placeholder.

## Project Structure

```
nf_mcd_lite/
├── frontend/              # Vue 3 + TypeScript
│   ├── src/
│   │   ├── components/   # Reusable components
│   │   ├── composables/  # Vue composables
│   │   ├── stores/       # Pinia state management
│   │   ├── views/        # Page components (10 views)
│   │   ├── services/     # API services
│   │   ├── types/        # TypeScript interfaces
│   │   ├── utils/        # Utilities & constants
│   │   ├── router/       # Vue Router
│   │   └── styles/       # Tailwind CSS
│   └── package.json
│
├── backend/              # Node.js + Express + TypeScript
│   ├── src/
│   │   ├── config/       # Environment, logging, CORS
│   │   ├── middleware/   # Auth, error, logging
│   │   ├── routes/       # API endpoints
│   │   └── services/     # Proxy service for UCO API
│   └── package.json
│
├── docker/               # Docker configuration
├── critical_reference_files/  # Flutter reference files
├── MIGRATION_PLAN.md     # Complete development plan
└── PHASE_1_COMPLETE.md   # Phase 1 completion report
```

## What's Implemented

### ✅ Phase 1 Complete (Week 1-2)
- Monorepo structure
- Vue 3 + Vite + TypeScript frontend
- Node.js + Express + TypeScript backend
- Tailwind CSS with custom theme
- Pinia state management (6 stores)
- Vue Router with 10 routes
- TypeScript interfaces for all data models
- Docker containerization
- ESLint + Prettier
- Environment configuration

### ✅ Phase 2 Complete (Week 3)

**Goal**: Complete authentication flow - ACHIEVED!

**Backend**:

- ✅ OAuth2 password grant flow to UCO API
- ✅ `/api/auth/login` - Login endpoint
- ✅ `/api/auth/logout` - Logout endpoint
- ✅ `/api/auth/verify` - Token verification
- ✅ Auth middleware for protected routes
- ✅ User validation (McDonald's users only)

**Frontend**:

- ✅ Complete LoginView.vue with beautiful UI
- ✅ useAuth composable with login/logout
- ✅ API client with interceptors
- ✅ IndexedDB for credential storage
- ✅ Auto-login functionality
- ✅ Token expiry handling
- ✅ Toast notifications
- ✅ Environment switching (dev mode)

### 🚧 Next: Phase 3 (Week 4-5)

**Goal**: Proxy all UCO API endpoints

**Tasks**:

- Implement all API route files (trucks, stores, staff, etc.)
- Create frontend API service classes
- Add comprehensive error handling
- Unit tests for services

## Available Commands

### Frontend
```bash
npm run dev      # Start dev server
npm run build    # Build for production
npm run preview  # Preview production build
npm run lint     # Run ESLint
npm run format   # Format with Prettier
```

### Backend
```bash
npm run dev      # Start dev server (hot reload)
npm run build    # Build TypeScript
npm run start    # Start production server
npm run lint     # Run ESLint
npm run format   # Format with Prettier
```

## Environment Configuration

### Frontend (.env)
Located at: `frontend/.env`
```
VITE_BACKEND_URL=http://localhost:3000/api
VITE_APP_VERSION=2.0.0
VITE_APP_CODE=MCDUCOWEB
```

### Backend (.env)
Located at: `backend/.env`
```
NODE_ENV=development
PORT=3000
ENVIRONMENT=test
UCO_API_TEST_URL=https://nf-test-ucoapi.neutralfuels.net
UCO_API_PROD_URL=https://ucoapi.neutralfuels.net
FRONTEND_URL=http://localhost:5173
REDIS_HOST=localhost
REDIS_PORT=6379
LOG_LEVEL=debug
```

## Key Features Prepared

### State Management (Pinia Stores)
- `auth.ts` - User authentication & session
- `collection.ts` - Collection operations
- `delivery.ts` - Delivery operations
- `dashboard.ts` - Statistics & data
- `ui.ts` - UI state & notifications
- `offline.ts` - Offline queue management

### Routing (10 Views)
- LoginView - Authentication
- HomeView - Main container with tabs
- DashboardView - Statistics & history
- CollectView - Oil collection form
- DeliverView - Delivery operations (4 types)
- SelectTruckView - Standard truck selection
- SelectTruck3PLView - 3PL truck selection
- SelectNewTruckView - Source truck selection
- SelectNewTruck3PLView - 3PL source truck
- SelectStoreView - Store selection

### TypeScript Models
All data models converted from Dart:
- User models (NFUserModel, LoginRequest, etc.)
- Collection models (RocCollectionModel, etc.)
- Delivery models (RocDeliveryModel, etc.)
- Resource models (Truck, Store, Staff)

## Development Workflow

1. **Start Development Servers**
   ```bash
   # Terminal 1
   cd backend && npm run dev

   # Terminal 2
   cd frontend && npm run dev
   ```

2. **Make Changes**
   - Edit files in `frontend/src/` or `backend/src/`
   - Hot reload will automatically update

3. **Check Code Quality**
   ```bash
   npm run lint    # Check for errors
   npm run format  # Format code
   ```

4. **Build for Production**
   ```bash
   npm run build
   ```

## Documentation

- **[MIGRATION_PLAN.md](./MIGRATION_PLAN.md)** - Complete 18-week development plan
- **[PHASE_1_COMPLETE.md](./PHASE_1_COMPLETE.md)** - Phase 1 completion details
- **[README.md](./README.md)** - Project documentation
- **[critical_reference_files/README.md](./critical_reference_files/README.md)** - Flutter reference guide

## Troubleshooting

### Port Already in Use
If you get "port already in use" errors:

```bash
# Kill process on port 3000 (backend)
lsof -ti:3000 | xargs kill -9

# Kill process on port 5173 (frontend)
lsof -ti:5173 | xargs kill -9
```

### Dependencies Not Found
```bash
# Reinstall dependencies
cd frontend && npm install
cd ../backend && npm install
```

### TypeScript Errors
```bash
# Clean build and reinstall
rm -rf node_modules dist
npm install
```

## Next Steps

1. ✅ Review the project structure
2. ✅ Start the development servers
3. ✅ Test the health endpoint
4. ✅ Open the frontend in browser
5. 🚧 Begin Phase 2: Authentication implementation

## Support

For questions about the implementation:
- Check [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) for detailed phase information
- Review [critical_reference_files/README.md](./critical_reference_files/README.md) for Flutter reference patterns
- Check the Phase completion documents for implementation details

---

**Status**: Phase 2 Complete ✅
**Ready for**: Phase 3 - Core API Integration
**Updated**: December 24, 2025
