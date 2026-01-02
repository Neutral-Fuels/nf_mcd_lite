import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type {
  StoreModel,
  CollectRocModel,
  CollectionEmptyRocModel,
  PendingCollection
} from '@/types/models'
import { collectionAPIService } from '@/services/api/collection.service'
import { useUIStore } from './ui'

export const useCollectionStore = defineStore('collection', () => {
  // State
  const selectedStore = ref<StoreModel | null>(null)
  const emptyROCsAtStore = ref<string[]>([])
  const fullROCs = ref<CollectRocModel[]>([])
  const emptyROCs = ref<CollectionEmptyRocModel[]>([])
  const pendingCollections = ref<PendingCollection[]>([])
  const isLoading = ref(false)

  // GPS Location State
  const latitude = ref<number | null>(null)
  const longitude = ref<number | null>(null)

  // Staff Verification State
  const staffId = ref<number | null>(null)
  const staffName = ref<string>('')
  const verifyCode = ref<string>('')

  // Comments State (default to 'none')
  const comments = ref<string>('none')

  // Error State
  const error = ref<string | null>(null)

  // Getters
  const totalFullROCs = computed(() => fullROCs.value.length)
  const totalEmptyROCs = computed(() => emptyROCs.value.length)
  const totalQuantity = computed(() =>
    fullROCs.value.reduce((sum, roc) => sum + roc.quantity, 0)
  )
  const hasROCs = computed(() =>
    fullROCs.value.length > 0 || emptyROCs.value.length > 0
  )
  const hasLocation = computed(() =>
    latitude.value !== null && longitude.value !== null
  )
  // canSubmit: At least one empty ROC is required to deliver
  // Full ROCs are optional (can submit with just empty ROCs)
  const canSubmit = computed(() =>
    selectedStore.value !== null &&
    emptyROCs.value.length > 0 &&  // At least one empty ROC to deliver
    hasLocation.value &&
    staffId.value !== null
  )

  // Actions
  function setSelectedStore(store: StoreModel | null) {
    selectedStore.value = store
  }

  function setEmptyROCsAtStore(rocs: string[]) {
    emptyROCsAtStore.value = rocs
  }

  function addFullROC(roc: CollectRocModel) {
    fullROCs.value.push(roc)
  }

  function addEmptyROC(roc: CollectionEmptyRocModel) {
    emptyROCs.value.push(roc)
  }

  function removeFullROC(index: number) {
    fullROCs.value.splice(index, 1)
  }

  function removeEmptyROC(index: number) {
    emptyROCs.value.splice(index, 1)
  }

  function updateFullROC(index: number, roc: CollectRocModel) {
    fullROCs.value[index] = roc
  }

  function checkDuplicateROC(rocNumber: string): boolean {
    const fullROCNumbers = fullROCs.value.map(r => r.rocNumber)
    const emptyROCNumbers = emptyROCs.value.map(r => r.rocNumber)
    return fullROCNumbers.includes(rocNumber) || emptyROCNumbers.includes(rocNumber)
  }

  // Validation
  function isValidROCNumber(rocNumber: string): boolean {
    // ROC number must be numeric and max 4 digits
    return /^\d{1,4}$/.test(rocNumber)
  }

  // GPS Location Actions
  async function captureLocation(): Promise<boolean> {
    try {
      if (!navigator.geolocation) {
        error.value = 'Geolocation is not supported by this browser'
        return false
      }

      return new Promise((resolve) => {
        navigator.geolocation.getCurrentPosition(
          (position) => {
            latitude.value = position.coords.latitude
            longitude.value = position.coords.longitude
            error.value = null
            resolve(true)
          },
          (err) => {
            error.value = `GPS Error: ${err.message}`
            resolve(false)
          },
          {
            enableHighAccuracy: true,
            timeout: 10000,
            maximumAge: 0
          }
        )
      })
    } catch (err: any) {
      error.value = err.message || 'Failed to capture location'
      return false
    }
  }

  // Staff Verification Actions
  function setStaffVerification(id: number, name: string, code: string) {
    staffId.value = id
    staffName.value = name
    verifyCode.value = code
  }

  function clearStaffVerification() {
    staffId.value = null
    staffName.value = ''
    verifyCode.value = ''
  }

  function setComments(value: string) {
    comments.value = value || 'none'
  }

  // Submit Collection
  async function submitCollection(): Promise<boolean> {
    if (!canSubmit.value) {
      error.value = 'Cannot submit: Missing required fields'
      return false
    }

    const uiStore = useUIStore()
    const truckRego = uiStore.selectedTruck?.regno

    if (!truckRego) {
      error.value = 'No truck selected'
      return false
    }

    try {
      isLoading.value = true
      error.value = null

      // Transform containers to API format (lowercase field names)
      // API expects: { rocnumber, quantity, state, containertypeid }
      const apiContainers = fullROCs.value.map(roc => ({
        rocnumber: roc.rocNumber,
        quantity: roc.quantity,
        state: roc.state,
        containertypeid: 1  // Default container type ID as per Flutter reference
      }))

      // Transform empty ROCs to API format (lowercase field names)
      // API expects: { rocnumber }
      const apiEmptyROCs = emptyROCs.value.map(roc => ({
        rocnumber: roc.rocNumber
      }))

      // Format local datetime in ISO format (without timezone)
      // API expects local time, not UTC
      const now = new Date()
      const localDateTime = new Date(now.getTime() - now.getTimezoneOffset() * 60000)
        .toISOString()
        .replace('Z', '')

      // Build API payload matching working Postman request format exactly
      // Tested working format from production API
      const collectionData = {
        containers: apiContainers,
        emptyROCsSupplied: apiEmptyROCs,
        storeid: (selectedStore.value!.storeId || selectedStore.value!.id?.toString() || ''),
        ucoreceiptnumber: 0,  // Integer, not string
        datetimeofcollection: localDateTime,  // Local time, not UTC
        supervisorid: staffId.value!,
        supervisorname: staffName.value,
        truckrego: truckRego,
        latitude: latitude.value!,
        longitude: longitude.value!,
        verifycode: null  // Must be null per working Postman example
      }

      console.log('[Collection] Submitting collection:', JSON.stringify(collectionData, null, 2))

      await collectionAPIService.createCollection(collectionData)

      uiStore.showToast('Collection submitted successfully!', 'success')

      // Reset form
      clearCollection()
      clearStaffVerification()
      latitude.value = null
      longitude.value = null

      return true
    } catch (err: any) {
      const errorMessage = err.message || 'Failed to submit collection'
      error.value = errorMessage
      uiStore.showToast(errorMessage, 'error')
      return false
    } finally {
      isLoading.value = false
    }
  }

  function clearCollection() {
    selectedStore.value = null
    emptyROCsAtStore.value = []
    fullROCs.value = []
    emptyROCs.value = []
    comments.value = 'none'
  }

  function setPendingCollections(collections: PendingCollection[]) {
    pendingCollections.value = collections
  }

  return {
    // State
    selectedStore,
    emptyROCsAtStore,
    fullROCs,
    emptyROCs,
    pendingCollections,
    isLoading,
    latitude,
    longitude,
    staffId,
    staffName,
    verifyCode,
    comments,
    error,

    // Getters
    totalFullROCs,
    totalEmptyROCs,
    totalQuantity,
    hasROCs,
    hasLocation,
    canSubmit,

    // Actions
    setSelectedStore,
    setEmptyROCsAtStore,
    addFullROC,
    addEmptyROC,
    removeFullROC,
    removeEmptyROC,
    updateFullROC,
    checkDuplicateROC,
    isValidROCNumber,
    captureLocation,
    setStaffVerification,
    clearStaffVerification,
    setComments,
    submitCollection,
    clearCollection,
    setPendingCollections,
  }
})
