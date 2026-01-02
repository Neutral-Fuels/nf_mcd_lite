import { createRouter, createWebHistory, type RouteRecordRaw } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: () => import('@/views/LoginView.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/home',
    name: 'Home',
    component: () => import('@/views/HomeView.vue'),
    meta: { requiresAuth: true },
    redirect: '/home/dashboard',
    children: [
      {
        path: 'dashboard',
        name: 'Dashboard',
        component: () => import('@/views/DashboardView.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'collect',
        name: 'Collect',
        component: () => import('@/views/CollectView.vue'),
        meta: { requiresAuth: true }
      },
      {
        path: 'deliver',
        name: 'Deliver',
        component: () => import('@/views/DeliverView.vue'),
        meta: { requiresAuth: true }
      }
    ]
  },
  {
    path: '/select-truck',
    name: 'SelectTruck',
    component: () => import('@/views/SelectTruckView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/select-truck-3pl',
    name: 'SelectTruck3PL',
    component: () => import('@/views/SelectTruck3PLView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/select-new-truck',
    name: 'SelectNewTruck',
    component: () => import('@/views/SelectNewTruckView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/select-new-truck-3pl',
    name: 'SelectNewTruck3PL',
    component: () => import('@/views/SelectNewTruck3PLView.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/select-store',
    name: 'SelectStore',
    component: () => import('@/views/SelectStoreView.vue'),
    meta: { requiresAuth: true }
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// Route Guard
router.beforeEach((to, _from, next) => {
  const authStore = useAuthStore()

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    // User needs to be authenticated
    next('/login')
  } else if (to.path === '/login' && authStore.isAuthenticated) {
    // Already logged in, redirect to dashboard
    next('/home/dashboard')
  } else if (authStore.isAuthenticated && !authStore.checkTokenExpiry()) {
    // Token expired, clear and redirect to login
    authStore.clearStorage()
    next('/login')
  } else {
    // Allow navigation
    next()
  }
})

export default router
