<template>
  <div class="min-h-screen bg-gray-50 pb-20">
    <!-- Header -->
    <div class="bg-white shadow-sm sticky top-0 z-10 px-4 py-4 border-b border-gray-200">
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-3">
          <img src="/assets/180.png" alt="NF" class="w-10 h-10 object-contain" />
          <h1 class="text-2xl font-bold text-gray-900">New Collection</h1>
        </div>
        <button
          @click="router.push('/home/dashboard')"
          class="p-2 rounded-lg hover:bg-gray-100 transition-colors"
          aria-label="Back to dashboard"
        >
          <svg class="w-6 h-6 text-gray-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
          </svg>
        </button>
      </div>

      <!-- Truck Info -->
      <div v-if="selectedTruck" class="mt-3 flex items-center text-sm text-gray-600">
        <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M13 16V6a1 1 0 00-1-1H4a1 1 0 00-1 1v10a1 1 0 001 1h1m8-1a1 1 0 01-1 1H9m4-1V8a1 1 0 011-1h2.586a1 1 0 01.707.293l3.414 3.414a1 1 0 01.293.707V16a1 1 0 01-1 1h-1m-6-1a1 1 0 001 1h1M5 17a2 2 0 104 0m-4 0a2 2 0 114 0m6 0a2 2 0 104 0m-4 0a2 2 0 114 0" />
        </svg>
        <span class="font-medium">{{ selectedTruck.regno }}</span>
      </div>
    </div>

    <!-- Main Content -->
    <div class="px-4 py-6 space-y-4">
      <!-- Store Selection Section -->
      <div class="bg-white rounded-lg shadow-md p-4">
        <div v-if="!collectionStore.selectedStore" class="text-center py-8">
          <svg class="w-16 h-16 text-gray-400 mx-auto mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                  d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
          </svg>
          <h3 class="text-lg font-semibold text-gray-900 mb-2">Select a Store</h3>
          <p class="text-sm text-gray-600 mb-4">Choose the McDonald's store for this collection</p>
          <button
            @click="router.push('/select-store')"
            class="px-6 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors"
          >
            Select Store
          </button>
        </div>

        <!-- Selected Store Display -->
        <div v-else class="space-y-3">
          <div class="flex items-start justify-between">
            <div class="flex-1">
              <h3 class="font-semibold text-gray-900">{{ collectionStore.selectedStore.storeName }}</h3>
              <p v-if="collectionStore.selectedStore.address" class="text-sm text-gray-600 mt-1">
                {{ collectionStore.selectedStore.address }}
              </p>
              <p class="text-xs text-gray-500 mt-1">
                Store #{{ collectionStore.selectedStore.storeNo }}
              </p>
            </div>
            <button
              @click="router.push('/select-store')"
              class="text-primary hover:text-blue-700 text-sm font-medium underline"
            >
              Change
            </button>
          </div>

          <!-- GPS Location -->
          <div class="pt-3 border-t border-gray-200">
            <button
              v-if="!collectionStore.hasLocation"
              @click="handleCaptureLocation"
              :disabled="locationLoading"
              class="w-full flex items-center justify-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                      d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z" />
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
              </svg>
              <span>{{ locationLoading ? 'Capturing Location...' : 'Capture GPS Location' }}</span>
            </button>
            <div v-else class="flex items-center justify-between text-sm">
              <div class="flex items-center text-green-600">
                <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                </svg>
                <span>Location Captured</span>
              </div>
              <span class="text-gray-600">
                {{ collectionStore.latitude?.toFixed(6) }}, {{ collectionStore.longitude?.toFixed(6) }}
              </span>
            </div>
          </div>
        </div>
      </div>

      <!-- Tabs -->
      <div v-if="collectionStore.selectedStore" class="bg-white rounded-lg shadow-md overflow-hidden">
        <!-- Tab Headers -->
        <div class="flex border-b border-gray-200">
          <button
            v-for="tab in tabs"
            :key="tab.id"
            @click="activeTab = tab.id"
            :class="[
              'flex-1 px-4 py-3 text-sm font-medium transition-colors',
              activeTab === tab.id
                ? 'text-primary border-b-2 border-primary bg-blue-50'
                : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50'
            ]"
          >
            {{ tab.label }}
            <span v-if="tab.count > 0" class="ml-2 px-2 py-0.5 text-xs rounded-full bg-primary text-white">
              {{ tab.count }}
            </span>
          </button>
        </div>

        <!-- Tab Content -->
        <div class="p-4">
          <!-- Empty ROCs Tab -->
          <div v-if="activeTab === 'empty'">
            <EmptyROCsTab />
          </div>

          <!-- Full ROCs Tab -->
          <div v-else-if="activeTab === 'full'">
            <FullROCsTab />
          </div>
        </div>
      </div>

      <!-- Summary Card -->
      <div v-if="collectionStore.hasROCs" class="bg-white rounded-lg shadow-md p-4">
        <h3 class="font-semibold text-gray-900 mb-3">Collection Summary</h3>
        <div class="grid grid-cols-3 gap-4 text-center">
          <div>
            <div class="text-2xl font-bold text-primary">{{ collectionStore.totalFullROCs }}</div>
            <div class="text-xs text-gray-600">Full ROCs</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-green-600">{{ collectionStore.totalQuantity }}</div>
            <div class="text-xs text-gray-600">Total Litres</div>
          </div>
          <div>
            <div class="text-2xl font-bold text-blue-600">{{ collectionStore.totalEmptyROCs }}</div>
            <div class="text-xs text-gray-600">Empty ROCs</div>
          </div>
        </div>

        <!-- Comments Field -->
        <div class="mt-4 pt-4 border-t border-gray-200">
          <label class="block text-sm font-medium text-gray-700 mb-2">Comments</label>
          <textarea
            v-model="collectionStore.comments"
            placeholder="Enter any comments (default: none)"
            rows="2"
            class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none text-sm"
          ></textarea>
        </div>
      </div>

      <!-- Submit Button - Requires at least one empty ROC and GPS location -->
      <button
        v-if="collectionStore.totalEmptyROCs > 0 && collectionStore.hasLocation"
        @click="handleSubmit"
        :disabled="collectionStore.isLoading"
        class="w-full py-3 bg-primary text-white rounded-lg font-semibold hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed"
      >
        {{ collectionStore.isLoading ? 'Submitting...' : 'Verify & Complete Collection' }}
      </button>

      <!-- Submission Requirements Message -->
      <div v-else-if="collectionStore.selectedStore" class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
        <div class="flex items-start gap-3">
          <svg class="w-5 h-5 text-yellow-600 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
          </svg>
          <div class="text-sm text-yellow-800">
            <p class="font-medium mb-1">To complete this collection:</p>
            <ul class="list-disc list-inside space-y-1 text-yellow-700">
              <li v-if="collectionStore.totalEmptyROCs === 0">Add at least one empty ROC to deliver</li>
              <li v-if="!collectionStore.hasLocation">Capture GPS location</li>
            </ul>
          </div>
        </div>
      </div>

      <!-- Error Display -->
      <div v-if="collectionStore.error" class="bg-red-50 border border-red-200 rounded-lg p-4">
        <p class="text-red-800 text-sm">{{ collectionStore.error }}</p>
      </div>
    </div>

    <!-- Staff Verification Dialog -->
    <StaffVerificationDialog
      v-model:show="showStaffDialog"
      :mcd-staff-list="mcdStaffList"
      @verified="handleStaffVerified"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCollectionStore } from '@/stores/collection'
import { useUIStore } from '@/stores/ui'
import { useAuthStore } from '@/stores/auth'
import { staffAPIService } from '@/services/api/staff.service'
import EmptyROCsTab from '@/components/collect/EmptyROCsTab.vue'
import FullROCsTab from '@/components/collect/FullROCsTab.vue'
import StaffVerificationDialog from '@/components/collect/StaffVerificationDialog.vue'
import type { McdStaffModel } from '@/types/models'

const router = useRouter()
const collectionStore = useCollectionStore()
const uiStore = useUIStore()
const authStore = useAuthStore()

// MCD staff list fetched by country ID
const mcdStaffList = ref<McdStaffModel[]>([])

const activeTab = ref<'empty' | 'full'>('full')
const locationLoading = ref(false)
const showStaffDialog = ref(false)

const selectedTruck = computed(() => uiStore.selectedTruck)

const tabs = computed(() => [
  {
    id: 'full' as const,
    label: 'Full ROCs',
    count: collectionStore.totalFullROCs
  },
  {
    id: 'empty' as const,
    label: 'Empty ROCs',
    count: collectionStore.totalEmptyROCs
  }
])

async function handleCaptureLocation() {
  locationLoading.value = true
  const success = await collectionStore.captureLocation()
  if (success) {
    uiStore.showToast('Location captured successfully', 'success')
  } else {
    uiStore.showToast(collectionStore.error || 'Failed to capture location', 'error')
  }
  locationLoading.value = false
}

function handleSubmit() {
  // Show staff verification dialog
  showStaffDialog.value = true
}

async function handleStaffVerified(data: { staffId: number, staffName: string, verifyCode: string }) {
  collectionStore.setStaffVerification(data.staffId, data.staffName, data.verifyCode)

  const success = await collectionStore.submitCollection()
  if (success) {
    // Navigate back to dashboard
    router.push('/home/dashboard')
  }
}

// Fetch MCD staff list by country ID on mount
onMounted(async () => {
  const countryId = authStore.user?.countryId
  if (countryId) {
    try {
      console.log('[CollectView] Fetching MCD staff for country:', countryId)
      const response = await staffAPIService.getMcdStaffByCountry(String(countryId))

      console.log('[CollectView] Raw response:', response)

      // Handle different response formats from API
      // API returns: { staff: [{ mcdstaffid, employeeid (number), employeename, ... }] }
      let rawStaff: any[] = []

      if (response && typeof response === 'object') {
        if ('staff' in response && Array.isArray((response as any).staff)) {
          rawStaff = (response as any).staff
        } else if (Array.isArray(response)) {
          rawStaff = response
        }
      }

      // Map API response to McdStaffModel format
      mcdStaffList.value = rawStaff.map((item: any) => ({
        staffId: item.mcdstaffid,
        employeeId: String(item.employeeid), // Convert number to string for comparison
        firstName: '',
        lastName: '',
        fullName: item.employeename,
        storeId: item.storeid || '',
        isActive: item.isactive ?? true
      }))

      console.log('[CollectView] Loaded', mcdStaffList.value.length, 'MCD staff members')
    } catch (error) {
      console.error('[CollectView] Failed to fetch MCD staff:', error)
      uiStore.showToast('Failed to load staff list', 'error')
    }
  }
})
</script>
