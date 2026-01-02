import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { truckAPIService } from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import type { TruckModel, ThirdPartyTruckModel } from '@/types/models'

export function useTruck() {
  const router = useRouter()
  const authStore = useAuthStore()
  const uiStore = useUIStore()

  const trucks = ref<TruckModel[]>([])
  const thirdPartyTrucks = ref<ThirdPartyTruckModel[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const searchQuery = ref('')

  // Computed filtered lists
  const filteredTrucks = computed(() => {
    if (!searchQuery.value) return trucks.value
    const query = searchQuery.value.toLowerCase()
    return trucks.value.filter(truck =>
      truck.regno?.toLowerCase().includes(query) ||
      truck.description?.toLowerCase().includes(query)
    )
  })

  const filteredThirdPartyTrucks = computed(() => {
    if (!searchQuery.value) return thirdPartyTrucks.value
    const query = searchQuery.value.toLowerCase()
    return thirdPartyTrucks.value.filter(truck =>
      truck.regno?.toLowerCase().includes(query) ||
      truck.description?.toLowerCase().includes(query) ||
      truck.supplierName?.toLowerCase().includes(query)
    )
  })

  async function fetchCustomerTrucks() {
    const customerId = authStore.user?.customerId
    if (!customerId) {
      error.value = 'No customer ID found'
      return
    }

    try {
      loading.value = true
      error.value = null
      const trucksData = await truckAPIService.getCustomerTrucks(
        customerId.toString()
      )

      trucks.value = trucksData
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to load trucks'
      error.value = errorMessage
      uiStore.showToast(errorMessage, 'error')
    } finally {
      loading.value = false
    }
  }

  async function fetchThirdPartyTrucks() {
    const customerId = authStore.user?.customerId
    if (!customerId) {
      error.value = 'No customer ID found'
      return
    }

    try {
      loading.value = true
      error.value = null
      thirdPartyTrucks.value = await truckAPIService.getThirdPartyTrucks(
        customerId.toString()
      )
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to load third-party trucks'
      error.value = errorMessage
      uiStore.showToast(errorMessage, 'error')
    } finally {
      loading.value = false
    }
  }

  function selectTruck(truck: TruckModel | ThirdPartyTruckModel, routeName: string = '/home/dashboard') {
    // Convert ThirdPartyTruckModel to TruckModel format if needed
    const truckIdValue = 'truckId' in truck ? truck.truckId : ('thirdPartyTruckId' in truck ? truck.thirdPartyTruckId : undefined)

    const truckData: TruckModel = {
      id: truck.id || truckIdValue,
      truckId: truckIdValue,
      regno: truck.regno,
      description: truck.description,
      customerId: authStore.user?.customerId || '',
      isActive: truck.isActive,
      // Add third-party specific fields if available
      ...(('supplierName' in truck) && {
        thirdParty: true,
        supplierName: truck.supplierName,
        supplierId: truck.supplierId
      })
    }

    uiStore.setSelectedTruck(truckData)
    uiStore.showToast(`Truck ${truck.regno} selected`, 'success')
    router.push(routeName)
  }

  function clearSelection() {
    uiStore.setSelectedTruck(null)
  }

  return {
    // State
    trucks,
    thirdPartyTrucks,
    loading,
    error,
    searchQuery,
    filteredTrucks,
    filteredThirdPartyTrucks,

    // Actions
    fetchCustomerTrucks,
    fetchThirdPartyTrucks,
    selectTruck,
    clearSelection,
  }
}
