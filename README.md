# McDonald's Neutral Fuels UCO Collection Web Application

A modern Progressive Web App (PWA) for managing Used Cooking Oil (UCO) collection, delivery, and tracking from McDonald's restaurants by Neutral Fuels drivers.

## Project Overview

This is a full-stack web application migrated from a Flutter mobile app, featuring:

- **Frontend**: Vue 3 (Composition API) + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + TypeScript (Mediatory API)
- **Features**: PWA capabilities, offline support, real-time updates via WebSocket
- **Deployment**: Docker containers with runtime environment switching

## Project Structure

```
nf_mcd_lite/
├── frontend/              # Vue 3 application
├── backend/               # Node.js/Express API
├── docker/                # Docker configuration files
├── critical_reference_files/  # Flutter app reference files
├── MIGRATION_PLAN.md      # Detailed development plan
└── README.md              # This file
```

## Quick Start

### Prerequisites

- Node.js 18+
- npm or yarn
- Docker & Docker Compose (optional)

### Development Setup

#### Frontend

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:5173`

#### Backend

```bash
cd backend
npm install
npm run dev
```

The backend will be available at `http://localhost:3000`

### Docker Setup

```bash
# Development
docker-compose up

# Production
docker-compose -f docker-compose.prod.yml up
```

## Development Phases

The project is being developed in 12 phases over 18 weeks:

- **Phase 1** (Week 1-2): ✅ Foundation & Setup - COMPLETE
- **Phase 2** (Week 3): ✅ Authentication - COMPLETE
- **Phase 3** (Week 4-5): API Integration
- **Phase 4** (Week 6): Dashboard Screen
- **Phase 5** (Week 7-8): Collection Screen
- **Phase 6** (Week 9-10): Delivery Screen
- **Phase 7** (Week 11): Truck & Store Selection
- **Phase 8** (Week 12): Home & Navigation
- **Phase 9** (Week 13): Real-time & WebSocket
- **Phase 10** (Week 14-15): Offline Support & PWA
- **Phase 11** (Week 16-17): Testing & QA
- **Phase 12** (Week 18): Deployment & DevOps

## Environment Configuration

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
ENVIRONMENT=test  # or production
UCO_API_TEST_URL=https://nf-test-ucoapi.neutralfuels.net
UCO_API_PROD_URL=https://ucoapi.neutralfuels.net
FRONTEND_URL=http://localhost:5173
```

## Key Features

### Collection Flow
- Store selection and search
- Full ROC (containers) recording
- Empty ROC tracking
- GPS location capture
- Staff verification
- Offline submission queue

### Delivery Flow (4 Types)
1. From Another Truck - Transfer ROCs between trucks
2. From Stores - Deliver collections from current truck
3. Bulk Delivery - Large-scale multi-store deliveries
4. Collect Empty ROCs - Pick up empty containers

### Dashboard
- Daily statistics (oil collected, collections count, ROCs count)
- Collection history
- User profile with truck and location info

## Technology Stack

### Frontend
- Vue 3.4+ with Composition API
- TypeScript 5+
- Vite 5+
- Tailwind CSS 3+
- Pinia 2+ (State Management)
- Vue Router 4+
- Axios (HTTP Client)
- VeeValidate (Form Validation)

### Backend
- Node.js 18+
- Express 4+
- TypeScript 5+
- Socket.IO (WebSocket)
- Winston (Logging)
- Redis (Caching)
- Helmet.js (Security)

## Available Scripts

### Frontend
- `npm run dev` - Start development server
- `npm run build` - Build for production
- `npm run preview` - Preview production build
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

### Backend
- `npm run dev` - Start development server with hot reload
- `npm run build` - Build TypeScript
- `npm run start` - Start production server
- `npm run lint` - Run ESLint
- `npm run format` - Format code with Prettier

## Documentation

- [MIGRATION_PLAN.md](./MIGRATION_PLAN.md) - Complete development plan
- [critical_reference_files/README.md](./critical_reference_files/README.md) - Flutter reference files guide

## API Endpoints

All backend endpoints are prefixed with `/api`:

- `/api/health` - Health check
- `/api/auth/*` - Authentication endpoints (Phase 2)
- `/api/trucks/*` - Truck management (Phase 3)
- `/api/stores/*` - Store management (Phase 3)
- `/api/staff/*` - Staff management (Phase 3)
- `/api/collection/*` - Collection operations (Phase 3)
- `/api/delivery/*` - Delivery operations (Phase 3)
- `/api/despatch/*` - Despatch operations (Phase 3)
- `/api/system/*` - System information (Phase 3)

## Security

- OAuth2 password grant flow
- Bearer token authentication
- Encrypted credential storage (IndexedDB)
- CORS configuration
- Helmet.js security headers
- Rate limiting (100 req/15min)
- XSS prevention
- Input validation

## Contributing

This is an internal project for Neutral Fuels. Please refer to the migration plan for development guidelines.

## License

Proprietary - Neutral Fuels & McDonald's

## Version

**Current Version**: 2.0.0
**Mobile Version**: 1.3.1
**Target Version**: 2.0.0 (Web)

---

**Status**: Phase 2 Complete ✅
**Next Phase**: Phase 3 - Core API Integration
**Updated**: December 24, 2025
