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
            <h3 class="text-xl font-semibold text-gray-900">Delivery Authorization</h3>
            <button
              @click="handleCancel"
              class="p-2 text-gray-400 hover:text-gray-600 hover:bg-gray-100 rounded-lg transition-colors"
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
              To be filled by an authorized Neutral Fuels Staff Member
            </p>

            <!-- Employee ID Input (PIN-style) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Employee ID *
              </label>
              <input
                v-model="employeeId"
                type="password"
                inputmode="numeric"
                required
                :disabled="isVerified"
                placeholder="Enter your Employee ID"
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
                  <p class="text-lg font-semibold text-green-900">
                    {{ verifiedStaff.firstname }} {{ verifiedStaff.lastname }}
                  </p>
                </div>
              </div>
            </div>

            <!-- Comments (required) -->
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">
                Comments *
              </label>
              <textarea
                v-model="comments"
                required
                rows="3"
                placeholder="Enter any comments about this delivery"
                class="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-primary focus:border-transparent resize-none"
                :class="{ 'border-red-500': commentsError }"
              ></textarea>
              <p v-if="commentsError" class="text-sm text-red-600 mt-1">{{ commentsError }}</p>
            </div>

            <!-- Info Box -->
            <div v-if="!isVerified" class="bg-blue-50 border border-blue-200 rounded-lg p-3">
              <div class="flex items-start gap-2">
                <svg class="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M13 16h-1v-4h-1m1-4h.01M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
                <p class="text-xs text-blue-800">
                  Please enter your Neutral Fuels Employee ID to authorize this delivery. Your ID will be verified against the system.
                </p>
              </div>
            </div>

            <!-- Staff List Warning -->
            <div v-if="nfStaffList.length === 0" class="bg-yellow-50 border border-yellow-200 rounded-lg p-3">
              <div class="flex items-start gap-2">
                <svg class="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                        d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                </svg>
                <p class="text-xs text-yellow-800">
                  Staff list not loaded. Please ensure you have an internet connection and try again.
                </p>
              </div>
            </div>

            <!-- Actions -->
            <div class="flex gap-3 pt-4">
              <button
                type="button"
                @click="handleCancel"
                class="flex-1 px-4 py-2 border border-gray-300 text-gray-700 rounded-lg hover:bg-gray-50 transition-colors font-medium"
              >
                Cancel
              </button>
              <button
                v-if="!isVerified"
                type="submit"
                :disabled="!employeeId || nfStaffList.length === 0"
                class="flex-1 px-4 py-2 bg-primary text-white rounded-lg hover:bg-blue-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
              >
                Verify
              </button>
              <button
                v-else
                type="button"
                @click="handleSubmit"
                :disabled="!comments.trim()"
                class="flex-1 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
              >
                Confirm Delivery
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
import type { NFStaffApiResponse } from '@/types/models'

interface Props {
  show: boolean
  nfStaffList: NFStaffApiResponse[]
}

interface VerificationData {
  staffId: number
  comments: string
}

const props = defineProps<Props>()
const emit = defineEmits<{
  'update:show': [value: boolean]
  'verified': [data: VerificationData]
}>()

const employeeId = ref('')
const comments = ref('')
const isVerified = ref(false)
const error = ref('')
const commentsError = ref('')
const verifiedStaff = ref<NFStaffApiResponse | null>(null)

// Reset form when dialog is opened
watch(() => props.show, (newShow) => {
  if (newShow) {
    employeeId.value = ''
    comments.value = ''
    isVerified.value = false
    error.value = ''
    commentsError.value = ''
    verifiedStaff.value = null
  }
})

function handleVerify() {
  if (!employeeId.value) {
    error.value = 'Please enter your Employee ID'
    return
  }

  error.value = ''

  // Search for matching employee ID in the pre-fetched staff list
  const matchedStaff = props.nfStaffList.find(
    staff => staff.employeeid?.toString() === employeeId.value
  )

  if (matchedStaff) {
    verifiedStaff.value = matchedStaff
    isVerified.value = true
    error.value = ''
  } else {
    error.value = 'Invalid Staff ID. Please check and try again.'
    isVerified.value = false
    verifiedStaff.value = null
  }
}

function handleSubmit() {
  if (!isVerified.value || !verifiedStaff.value) {
    return
  }

  // Validate comments
  if (!comments.value.trim()) {
    commentsError.value = 'Comments are required'
    return
  }

  commentsError.value = ''

  // Emit the verified data
  emit('verified', {
    staffId: verifiedStaff.value.staffid,
    comments: comments.value.trim()
  })

  emit('update:show', false)
}

function handleCancel() {
  emit('update:show', false)
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
