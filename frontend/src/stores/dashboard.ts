import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { collectionAPIService } from '@/services/api'
import { useUIStore } from './ui'
import type { PendingCollection } from '@/types/models'

export const useDashboardStore = defineStore('dashboard', () => {
  // State
  const collections = ref<PendingCollection[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)
  const lastFetched = ref<Date | null>(null)

  // Getters - Calculate statistics from collections
  const totalOilCollected = computed(() => {
    return collections.value.reduce((sum, collection) => sum + (collection.quantity || 0), 0)
  })

  const totalCollections = computed(() => {
    return collections.value.length
  })

  const totalROCs = computed(() => {
    return collections.value.reduce((sum, collection) => sum + (collection.roccount || 0), 0)
  })

  const collectionsByDate = computed(() => {
    return collections.value.sort((a, b) => {
      const dateA = new Date(a.collectiondate).getTime()
      const dateB = new Date(b.collectiondate).getTime()
      return dateB - dateA // Most recent first
    })
  })

  const todaysCollections = computed(() => {
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    return collections.value.filter(collection => {
      const collectionDate = new Date(collection.collectiondate)
      collectionDate.setHours(0, 0, 0, 0)
      return collectionDate.getTime() === today.getTime()
    })
  })

  const todaysCollectionCount = computed(() => {
    return todaysCollections.value.length
  })

  // Statistics summary
  const statistics = computed(() => ({
    totalOilCollected: totalOilCollected.value,
    totalCollections: totalCollections.value,
    totalROCs: totalROCs.value,
    todaysCollectionCount: todaysCollectionCount.value,
  }))

  // Actions
  async function fetchPendingCollections(forceRefresh = false) {
    const uiStore = useUIStore()

    const truckRego = uiStore.selectedTruck?.regno
    if (!truckRego) {
      error.value = 'No truck selected'
      return
    }

    // Skip if recently fetched (within 30 seconds) unless force refresh
    if (!forceRefresh && lastFetched.value) {
      const timeSinceLastFetch = Date.now() - lastFetched.value.getTime()
      if (timeSinceLastFetch < 30000) {
        return
      }
    }

    try {
      loading.value = true
      error.value = null

      // Note: getPendingCollections returns data based on truck registration
      // The type might need to be updated to PendingCollection[] instead of RocCollectionModel[]
      const data = await collectionAPIService.getPendingCollections(truckRego, false)

      // Type assertion since the service might have incorrect return type
      collections.value = data as any as PendingCollection[]
      lastFetched.value = new Date()
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to load pending collections'
      error.value = errorMessage
      console.error('Dashboard fetch error:', err)
    } finally {
      loading.value = false
    }
  }

  function clearCollections() {
    collections.value = []
    lastFetched.value = null
    error.value = null
  }

  function refreshCollections() {
    return fetchPendingCollections(true)
  }

  return {
    // State
    collections,
    loading,
    error,
    lastFetched,

    // Getters
    totalOilCollected,
    totalCollections,
    totalROCs,
    todaysCollections,
    todaysCollectionCount,
    collectionsByDate,
    statistics,

    // Actions
    fetchPendingCollections,
    clearCollections,
    refreshCollections,
  }
})
