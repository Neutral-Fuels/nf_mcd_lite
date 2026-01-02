import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'
import { storeAPIService } from '@/services/api'
import { useAuthStore } from '@/stores/auth'
import { useUIStore } from '@/stores/ui'
import { useCollectionStore } from '@/stores/collection'
import type { StoreModel } from '@/types/models'

export function useStore() {
  const router = useRouter()
  const authStore = useAuthStore()
  const uiStore = useUIStore()
  const collectionStore = useCollectionStore()

  const stores = ref<StoreModel[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  const searchQuery = ref('')

  // Computed filtered list
  const filteredStores = computed(() => {
    if (!searchQuery.value) return stores.value
    const query = searchQuery.value.toLowerCase()
    return stores.value.filter(store =>
      store.storeCode?.toLowerCase().includes(query) ||
      store.storeNo?.toLowerCase().includes(query) ||
      store.storeName?.toLowerCase().includes(query) ||
      store.address?.toLowerCase().includes(query) ||
      store.city?.toLowerCase().includes(query) ||
      store.suburb?.toLowerCase().includes(query)
    )
  })

  async function fetchCustomerStores() {
    const customerId = authStore.user?.customerId
    if (!customerId) {
      error.value = 'No customer ID found'
      return
    }

    try {
      loading.value = true
      error.value = null
      stores.value = await storeAPIService.getCustomerStores(
        customerId.toString()
      )
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to load stores'
      error.value = errorMessage
      uiStore.showToast(errorMessage, 'error')
    } finally {
      loading.value = false
    }
  }

  function selectStore(store: StoreModel, routeName: string = '/home/collect') {
    // Save to both UI store and collection store
    uiStore.setSelectedStore(store)
    collectionStore.setSelectedStore(store)
    uiStore.showToast(`Store ${store.storeCode || store.storeNo} selected`, 'success')
    router.push(routeName)
  }

  function clearSelection() {
    uiStore.setSelectedStore(null)
    collectionStore.setSelectedStore(null)
  }

  return {
    // State
    stores,
    loading,
    error,
    searchQuery,
    filteredStores,

    // Actions
    fetchCustomerStores,
    selectStore,
    clearSelection,
  }
}
