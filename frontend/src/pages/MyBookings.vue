<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Calendar, Car, Clock, CheckCircle, XCircle, ChevronLeft, ChevronRight, Eye, Ban, AlertCircle } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { bookingApi } from '@/api'
import { useToast } from '@/composables/useToast'

const router = useRouter()
const route = useRoute()
const { showToast } = useToast()
const bookings = ref([])
const loading = ref(true)
const page = ref(0)
const totalPages = ref(0)
const totalElements = ref(0)
const cancellingId = ref(null)

const paymentStatus = ref('')
const paymentMessage = ref('')

const statusConfig = {
  PENDING: { label: 'Chờ xử lý', class: 'bg-amber-100 text-amber-700', icon: Clock },
  CONFIRMED: { label: 'Đã xác nhận', class: 'bg-blue-100 text-blue-700', icon: CheckCircle },
  IN_PROGRESS: { label: 'Đang thuê', class: 'bg-indigo-100 text-indigo-700', icon: Car },
  COMPLETED: { label: 'Hoàn thành', class: 'bg-green-100 text-green-700', icon: CheckCircle },
  CANCELLED: { label: 'Đã hủy', class: 'bg-red-100 text-red-700', icon: XCircle },
}

const fetchBookings = async () => {
  loading.value = true
  try {
    const res = await bookingApi.listMy({ page: page.value, size: 10 })
    if (res.success) {
      bookings.value = res.data.content || []
      totalPages.value = res.data.totalPages || 0
      totalElements.value = res.data.totalElements || 0
    }
  } catch (err) {
    console.error('Failed to fetch bookings:', err)
  } finally {
    loading.value = false
  }
}

const cancelBooking = async (id) => {
  if (!confirm('Bạn có chắc chắn muốn hủy đơn đặt xe này?')) return
  cancellingId.value = id
  try {
    const res = await bookingApi.cancel(id)
    if (res.success) {
      showToast('Hủy đơn đặt xe thành công', 'success')
      await fetchBookings()
    }
  } catch (err) {
    showToast(err.response?.data?.message || 'Không thể hủy đơn đặt xe', 'error')
  } finally {
    cancellingId.value = null
  }
}

const formatPrice = (price) => {
  return new Intl.NumberFormat('vi-VN').format(price) + 'đ'
}

const formatDate = (dateStr) => {
  return new Date(dateStr).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })
}

onMounted(() => {
  if (route.query.payment === 'success') {
    paymentStatus.value = 'success'
    paymentMessage.value = 'Thanh toán thành công. Đơn hàng của bạn đã được xác nhận!'
    // Clear query
    router.replace({ query: null })
  } else if (route.query.payment === 'failed') {
    paymentStatus.value = 'error'
    paymentMessage.value = 'Thanh toán thất bại hoặc đã bị hủy.'
    router.replace({ query: null })
  } else if (route.query.payment === 'error') {
    paymentStatus.value = 'error'
    paymentMessage.value = 'Lỗi chữ ký thanh toán không hợp lệ.'
    router.replace({ query: null })
  }
  
  fetchBookings()
})
</script>

<template>
  <div class="pt-32 pb-20 px-6 max-w-6xl mx-auto min-h-screen">
    <div class="space-y-1 mb-10">
      <h1 class="editorial-display text-4xl text-stitch-primary">Đơn đặt xe của tôi</h1>
      <p class="text-stitch-on-surface-variant text-sm font-medium">
        Theo dõi tất cả các đơn đặt xe bạn đã tạo.
        <span v-if="totalElements" class="text-stitch-primary font-bold">{{ totalElements }} đơn</span>
      </p>
    </div>

    <!-- Payment Alert -->
    <div v-if="paymentStatus" class="mb-8 p-4 rounded-stitch-lg flex items-center justify-between"
      :class="paymentStatus === 'success' ? 'bg-green-50 border border-green-200' : 'bg-red-50 border border-red-200'"
    >
      <div class="flex items-center gap-3">
        <CheckCircle v-if="paymentStatus === 'success'" class="w-6 h-6 text-green-600" />
        <AlertCircle v-else class="w-6 h-6 text-red-600" />
        <p class="text-sm font-bold" :class="paymentStatus === 'success' ? 'text-green-800' : 'text-red-800'">
          {{ paymentMessage }}
        </p>
      </div>
      <button @click="paymentStatus = ''" class="text-gray-400 hover:text-gray-600">
        <XCircle class="w-5 h-5" />
      </button>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="bg-white rounded-stitch-xl h-32 animate-pulse shadow-sm"></div>
    </div>

    <!-- Empty State -->
    <div v-else-if="bookings.length === 0" class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-16 text-center">
      <div class="w-20 h-20 bg-stitch-surface-container rounded-full flex items-center justify-center mx-auto mb-6">
        <Calendar class="w-10 h-10 text-stitch-outline" />
      </div>
      <h3 class="editorial-headline text-xl mb-2">Chưa có đơn đặt xe nào</h3>
      <p class="text-stitch-on-surface-variant text-sm mb-8">Hãy khám phá các dòng xe và đặt chiếc xe đầu tiên!</p>
      <BaseButton variant="primary" @click="router.push('/browse')">Tìm xe ngay</BaseButton>
    </div>

    <!-- Booking List -->
    <div v-else class="space-y-4">
      <div
        v-for="booking in bookings"
        :key="booking.bookingId"
        class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-6 hover:shadow-stitch-ambient transition-all duration-300 group"
      >
        <div class="flex flex-col md:flex-row md:items-center gap-6">
          <!-- Car Info -->
          <div class="flex items-center gap-4 flex-grow">
            <div class="bg-stitch-surface-container p-3 rounded-stitch-lg">
              <Car class="w-6 h-6 text-stitch-primary" />
            </div>
            <div class="flex-grow">
              <h3 class="font-bold text-lg">{{ booking.carName || 'Xe #' + booking.carId }}</h3>
              <p class="text-xs text-stitch-on-surface-variant font-medium">Mã đơn: #{{ booking.bookingId }}</p>
            </div>
          </div>

          <!-- Dates -->
          <div class="flex items-center gap-3 text-sm">
            <div class="text-center">
              <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Từ ngày</p>
              <p class="font-bold">{{ formatDate(booking.startDate) }}</p>
            </div>
            <span class="text-stitch-outline">→</span>
            <div class="text-center">
              <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Đến ngày</p>
              <p class="font-bold">{{ formatDate(booking.endDate) }}</p>
            </div>
          </div>

          <!-- Price -->
          <div class="text-right">
            <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Tổng tiền</p>
            <p class="editorial-display text-xl text-stitch-primary">{{ formatPrice(booking.totalPrice) }}</p>
          </div>

          <!-- Status -->
          <div class="flex items-center gap-2">
            <div
              class="flex items-center gap-2 px-3 py-1.5 rounded-full"
              :class="(statusConfig[booking.status] || statusConfig.PENDING).class"
            >
              <component :is="(statusConfig[booking.status] || statusConfig.PENDING).icon" class="w-3.5 h-3.5" />
              <span class="text-[10px] font-bold uppercase tracking-wider">
                {{ (statusConfig[booking.status] || statusConfig.PENDING).label }}
              </span>
            </div>
          </div>

          <!-- Actions -->
          <div class="flex gap-2">
            <button
              @click="router.push(`/my-bookings/${booking.bookingId}`)"
              class="p-2 hover:bg-stitch-surface-container rounded-stitch-md transition-colors text-stitch-on-surface-variant hover:text-stitch-primary"
              title="Xem chi tiết"
            >
              <Eye class="w-5 h-5" />
            </button>
            <button
              v-if="booking.status === 'PENDING'"
              @click="cancelBooking(booking.bookingId)"
              :disabled="cancellingId === booking.bookingId"
              class="p-2 hover:bg-red-50 rounded-stitch-md transition-colors text-stitch-on-surface-variant hover:text-red-500 disabled:opacity-50"
              title="Hủy đơn"
            >
              <Ban class="w-5 h-5" :class="{ 'animate-spin': cancellingId === booking.bookingId }" />
            </button>
          </div>
        </div>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center gap-2 pt-6">
        <button
          @click="page--; fetchBookings()"
          :disabled="page === 0"
          class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30"
        >
          <ChevronLeft class="w-5 h-5" />
        </button>
        <span class="px-4 py-2 text-sm font-bold text-stitch-on-surface-variant">
          {{ page + 1 }} / {{ totalPages }}
        </span>
        <button
          @click="page++; fetchBookings()"
          :disabled="page >= totalPages - 1"
          class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30"
        >
          <ChevronRight class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>
