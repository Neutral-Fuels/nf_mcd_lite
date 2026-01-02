<template>
  <Teleport to="body">
    <Transition name="modal">
      <div
        v-if="show"
        class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black bg-opacity-50"
        @click.self="handleCancel"
      >
        <div class="bg-white rounded-lg shadow-xl max-w-md w-full max-h-[90vh] overflow-y-auto">
          <!-- Header -->
          <div class="flex items-center justify-between p-6 border-b border-gray-200">
            <h3 class="text-xl font-semibold text-gray-900">Collection Authorization</h3>
            <button
              @click="handleCancel"
              :disabled="isLoading"
              class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors disabled:opacity-50"
              aria-label="Close"
            >
              <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          <!-- Content -->
          <form @submit.prevent="handleVerify" class="p-6 space-y-4">
            <p class="text-sm text-gray-600 mb-4">
              To be filled by an authorized McDonald's Staff Member
            </p>

            <!-- Staff ID Input (PIN-style) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Staff ID *
              </label>
              <input
                v-model="staffIdInput"
                type="password"
                inputmode="numeric"
                required
                :disabled="isLoading || isVerified"
                placeholder="Enter your Staff ID"
                class="w-full px-4 py-3 text-lg tracking-widest border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent text-center"
                :class="{ 'border-red-500': error, 'border-green-500': isVerified }"
              />
              <p v-if="error" class="text-sm text-red-600 mt-2">{{ error }}</p>
            </div>

            <!-- Verified Staff Display -->
            <div v-if="isVerified && verifiedStaff" class="bg-green-50 border border-green-200 rounded-lg p-4">
              <div class="flex items-center gap-3">
                <div class="w-10 h-10 bg-green-100 rounded-full flex items-center justify-center">
                  <svg class="w-6 h-6 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                <div>
                  <p class="text-sm font-medium text-green-800">Verified</p>
                  <p class="text-lg font-semibold text-green-900">{{ verifiedStaff.fullName }}</p>
                </div>
              </div>
            </div>

            <!-- Loading State -->
            <div v-if="isLoading" class="flex items-center justify-center py-4">
              <svg class="animate-spin h-8 w-8 text-primary" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
              </svg>
              <span class="ml-3 text-gray-600">Verifying...</span>
            </div>

            <!-- Info Box -->
            <div v-if="!isVerified" class="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <div class="flex items-start gap-2">
                <svg class="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="text-xs text-blue-800">
                  Please enter your McDonald's Staff ID to authorize this collection. Your ID will be verified against the system.
                </p>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex gap-3 pt-4">
              <button
                type="button"
                @click="handleCancel"
                :disabled="isLoading"
                class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium disabled:opacity-50"
              >
                Cancel
              </button>
              <button
                v-if="!isVerified"
                type="submit"
                :disabled="!staffIdInput || isLoading"
                class="flex-1 px-4 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
              >
                Verify
              </button>
              <button
                v-else
                type="button"
                @click="handleSubmit"
                class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors font-medium"
              >
                Submit Collection
              </button>
            </div>
          </form>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup lang="ts">
import { ref, watch } from 'vue'
import type { McdStaffModel } from '@/types/models'

interface Props {
  show: boolean
  mcdStaffList?: McdStaffModel[]
}

interface VerificationData {
  staffId: number
  staffName: string
  verifyCode: string
}

const props = withDefaults(defineProps<Props>(), {
  mcdStaffList: () => []
})
const emit = defineEmits<{
  'update:show': [value: boolean]
  'verified': [data: VerificationData]
}>()

const staffIdInput = ref('')
const isLoading = ref(false)
const isVerified = ref(false)
const error = ref('')
const verifiedStaff = ref<McdStaffModel | null>(null)

// Reset form when dialog is opened
watch(() => props.show, (newShow) => {
  if (newShow) {
    staffIdInput.value = ''
    isLoading.value = false
    isVerified.value = false
    error.value = ''
    verifiedStaff.value = null
  }
})

function handleVerify() {
  if (!staffIdInput.value) {
    error.value = 'Please enter your Staff ID'
    return
  }

  error.value = ''
  isLoading.value = true

  // Ensure we have an array to search
  const staffList = Array.isArray(props.mcdStaffList) ? props.mcdStaffList : []

  console.log('[StaffVerification] Staff list type:', typeof props.mcdStaffList, Array.isArray(props.mcdStaffList))
  console.log('[StaffVerification] Searching in list:', staffList.length, 'staff members')
  console.log('[StaffVerification] Looking for staffId:', staffIdInput.value)

  // Search for staff in pre-fetched list by mcdstaffid (staffId)
  // User enters their mcdstaffid as a number, so we compare as numbers
  const enteredId = parseInt(staffIdInput.value, 10)
  const foundStaff = staffList.find(
    staff => staff.staffId === enteredId
  )

  console.log('[StaffVerification] Found staff:', foundStaff)

  if (foundStaff) {
    // Staff found
    verifiedStaff.value = foundStaff
    isVerified.value = true
    error.value = ''
  } else {
    // No staff found
    error.value = 'Invalid Staff ID. Please check and try again.'
    isVerified.value = false
    verifiedStaff.value = null
  }

  isLoading.value = false
}

function handleSubmit() {
  if (!isVerified.value || !verifiedStaff.value) {
    return
  }

  // Emit the verified data
  emit('verified', {
    staffId: verifiedStaff.value.staffId,
    staffName: verifiedStaff.value.fullName,
    verifyCode: staffIdInput.value
  })

  emit('update:show', false)
}

function handleCancel() {
  if (!isLoading.value) {
    emit('update:show', false)
  }
}
</script>

<style scoped>
.modal-enter-active,
.modal-leave-active {
  transition: opacity 0.3s ease;
}

.modal-enter-from,
.modal-leave-to {
  opacity: 0;
}

.modal-enter-active .bg-white,
.modal-leave-active .bg-white {
  transition: transform 0.3s ease;
}

.modal-enter-from .bg-white,
.modal-leave-to .bg-white {
  transform: scale(0.95);
}
</style>
