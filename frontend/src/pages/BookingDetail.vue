<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { Car, Calendar, MapPin, CreditCard, Clock, CheckCircle, XCircle, ChevronLeft, FileText, Star, Banknote } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { bookingApi, reviewApi, paymentApi } from '@/api'
import { useToast } from '@/composables/useToast'

const route = useRoute()
const router = useRouter()
const { showToast } = useToast()
const booking = ref(null)
const loading = ref(true)
const error = ref('')

const review = ref(null)
const reviewForm = ref({ rating: 5, comment: '' })
const submittingReview = ref(false)
const processingPayment = ref(false)

const statusConfig = {
  PENDING: { label: 'Chờ xử lý', class: 'bg-amber-100 text-amber-700', icon: Clock },
  CONFIRMED: { label: 'Đã xác nhận', class: 'bg-blue-100 text-blue-700', icon: CheckCircle },
  IN_PROGRESS: { label: 'Đang thuê', class: 'bg-indigo-100 text-indigo-700', icon: Car },
  COMPLETED: { label: 'Hoàn thành', class: 'bg-green-100 text-green-700', icon: CheckCircle },
  CANCELLED: { label: 'Đã hủy', class: 'bg-red-100 text-red-700', icon: XCircle },
}

const timelineSteps = [
  { status: 'PENDING', label: 'Đặt xe' },
  { status: 'CONFIRMED', label: 'Xác nhận' },
  { status: 'IN_PROGRESS', label: 'Đang thuê' },
  { status: 'COMPLETED', label: 'Hoàn thành' },
]

const getStepState = (stepStatus) => {
  if (!booking.value) return 'inactive'
  if (booking.value.status === 'CANCELLED') return stepStatus === 'PENDING' ? 'cancelled' : 'inactive'
  const order = ['PENDING', 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED']
  const currentIdx = order.indexOf(booking.value.status)
  const stepIdx = order.indexOf(stepStatus)
  if (stepIdx < currentIdx) return 'done'
  if (stepIdx === currentIdx) return 'active'
  return 'inactive'
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'
const formatDate = (dateStr) => new Date(dateStr).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })

const cancelBooking = async () => {
  if (!confirm('Bạn có chắc chắn muốn hủy đơn đặt xe này?')) return
  try {
    const res = await bookingApi.cancel(route.params.id)
    if (res.success) {
      booking.value = res.data
      showToast('Hủy đơn thành công', 'success')
    }
  } catch (err) {
    showToast(err.response?.data?.message || 'Không thể hủy đơn', 'error')
  }
}

onMounted(async () => {
  try {
    const res = await bookingApi.get(route.params.id)
    if (res.success) {
      booking.value = res.data
      if (booking.value.status === 'COMPLETED') {
        const reviewRes = await reviewApi.getForBooking(route.params.id)
        if (reviewRes.success && reviewRes.data) {
          review.value = reviewRes.data
        }
      }
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Không thể tải thông tin đơn đặt xe'
  } finally {
    loading.value = false
  }
})

const submitReview = async () => {
  if (!reviewForm.value.rating) return showToast('Vui lòng chọn số sao đánh giá.', 'error')
  submittingReview.value = true
  try {
    const res = await reviewApi.create(booking.value.bookingId, reviewForm.value)
    if (res.success) {
      review.value = res.data
      showToast('Cảm ơn bạn đã đánh giá!', 'success')
    }
  } catch (err) {
    showToast(err.response?.data?.message || 'Lỗi khi gửi đánh giá', 'error')
  } finally {
    submittingReview.value = false
  }
}

const handlePayment = async () => {
  processingPayment.value = true
  try {
    const res = await paymentApi.createVNPayUrl(booking.value.bookingId)
    if (res.success && res.data) {
      window.location.href = res.data // Redirect to VNPay
    }
  } catch (err) {
    showToast(err.response?.data?.message || 'Không thể tạo phiên thanh toán', 'error')
  } finally {
    processingPayment.value = false
  }
}
</script>

<template>
  <div class="pt-32 pb-20 px-6 max-w-4xl mx-auto min-h-screen">
    <!-- Back Button -->
    <button @click="router.push('/my-bookings')" class="flex items-center gap-2 text-stitch-on-surface-variant hover:text-stitch-primary transition-colors mb-8 font-bold text-sm">
      <ChevronLeft class="w-4 h-4" /> Quay lại đơn của tôi
    </button>

    <!-- Loading -->
    <div v-if="loading" class="space-y-6">
      <div class="bg-white rounded-stitch-xl h-48 animate-pulse shadow-sm"></div>
      <div class="bg-white rounded-stitch-xl h-64 animate-pulse shadow-sm"></div>
    </div>

    <!-- Error -->
    <div v-else-if="error" class="bg-red-50 text-red-600 rounded-stitch-xl p-8 text-center">
      <p class="font-bold">{{ error }}</p>
    </div>

    <!-- Content -->
    <div v-else-if="booking" class="space-y-8">
      <!-- Header Card -->
      <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
        <div class="flex flex-col md:flex-row justify-between items-start gap-6 mb-8">
          <div>
            <h1 class="editorial-display text-3xl mb-2">Đơn đặt xe #{{ booking.bookingId }}</h1>
            <p class="text-stitch-on-surface-variant text-sm font-medium">Tạo lúc {{ formatDate(booking.createdAt) }}</p>
          </div>
          <div
            class="flex items-center gap-2 px-4 py-2 rounded-full"
            :class="(statusConfig[booking.status] || statusConfig.PENDING).class"
          >
            <component :is="(statusConfig[booking.status] || statusConfig.PENDING).icon" class="w-4 h-4" />
            <span class="text-xs font-bold uppercase tracking-wider">
              {{ (statusConfig[booking.status] || statusConfig.PENDING).label }}
            </span>
          </div>
        </div>

        <!-- Status Timeline -->
        <div v-if="booking.status !== 'CANCELLED'" class="flex items-center justify-between mb-2">
          <div v-for="(step, idx) in timelineSteps" :key="step.status" class="flex items-center flex-1">
            <div class="flex flex-col items-center gap-2 flex-shrink-0">
              <div
                class="w-10 h-10 rounded-full flex items-center justify-center transition-all"
                :class="{
                  'bg-green-500 text-white': getStepState(step.status) === 'done',
                  'bg-stitch-primary text-white shadow-lg shadow-stitch-primary/30 scale-110': getStepState(step.status) === 'active',
                  'bg-stitch-surface-container text-stitch-outline': getStepState(step.status) === 'inactive',
                }"
              >
                <CheckCircle v-if="getStepState(step.status) === 'done'" class="w-5 h-5" />
                <span v-else class="text-xs font-bold">{{ idx + 1 }}</span>
              </div>
              <span class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">{{ step.label }}</span>
            </div>
            <div v-if="idx < timelineSteps.length - 1" class="flex-grow h-0.5 mx-2 -mt-6"
              :class="getStepState(timelineSteps[idx + 1].status) !== 'inactive' ? 'bg-green-400' : 'bg-stitch-surface-container'"
            ></div>
          </div>
        </div>
      </div>

      <!-- Details Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
        <!-- Car Info -->
        <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
          <h3 class="editorial-headline text-lg mb-6 flex items-center gap-2">
            <Car class="w-5 h-5 text-stitch-primary" /> Thông tin xe
          </h3>
          <div class="space-y-4">
            <div class="flex justify-between">
              <span class="text-sm text-stitch-on-surface-variant">Tên xe</span>
              <span class="text-sm font-bold">{{ booking.carName || 'Xe #' + booking.carId }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-sm text-stitch-on-surface-variant">Biển số</span>
              <span class="text-sm font-bold">{{ booking.licensePlate || '—' }}</span>
            </div>
          </div>
        </div>

        <!-- Schedule Info -->
        <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
          <h3 class="editorial-headline text-lg mb-6 flex items-center gap-2">
            <Calendar class="w-5 h-5 text-stitch-primary" /> Lịch trình
          </h3>
          <div class="space-y-4">
            <div class="flex justify-between">
              <span class="text-sm text-stitch-on-surface-variant">Ngày bắt đầu</span>
              <span class="text-sm font-bold">{{ formatDate(booking.startDate) }}</span>
            </div>
            <div class="flex justify-between">
              <span class="text-sm text-stitch-on-surface-variant">Ngày kết thúc</span>
              <span class="text-sm font-bold">{{ formatDate(booking.endDate) }}</span>
            </div>
          </div>
        </div>
      </div>

      <!-- Payment Summary -->
      <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
        <h3 class="editorial-headline text-lg mb-6 flex items-center gap-2">
          <CreditCard class="w-5 h-5 text-stitch-primary" /> Thanh toán
        </h3>
        <div class="flex justify-between items-center py-4 border-t border-stitch-outline-variant/10">
          <span class="font-bold text-lg">Tổng cộng</span>
          <span class="editorial-display text-2xl text-stitch-primary">{{ formatPrice(booking.totalPrice) }}</span>
        </div>
      </div>

      <!-- Review Section (Only for COMPLETED bookings) -->
      <div v-if="booking.status === 'COMPLETED'" class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
        <h3 class="editorial-headline text-lg mb-6 flex items-center gap-2">
          <Star class="w-5 h-5 text-stitch-primary" /> Đánh giá chuyến đi
        </h3>

        <!-- Display Review if already submitted -->
        <div v-if="review" class="space-y-4 bg-stitch-surface-container-lowest p-6 rounded-stitch-lg">
          <div class="flex items-center gap-1">
            <Star v-for="i in 5" :key="i" class="w-5 h-5" :class="i <= review.rating ? 'text-amber-400 fill-amber-400' : 'text-stitch-outline'" />
          </div>
          <p class="text-sm text-stitch-on-surface-variant italic">"{{ review.comment || 'Không có bình luận' }}"</p>
          <p class="text-[10px] font-bold text-stitch-outline uppercase tracking-widest mt-2">
            Đánh giá lúc {{ formatDate(review.createdAt) }}
          </p>
        </div>

        <!-- Submit Review Form -->
        <div v-else class="space-y-6">
          <p class="text-sm text-stitch-on-surface-variant">Bạn thấy chuyến đi thế nào? Đánh giá của bạn sẽ giúp người khác chọn xe tốt hơn.</p>
          <div class="flex items-center gap-2">
            <button v-for="i in 5" :key="i" @click="reviewForm.rating = i" class="p-1 hover:scale-110 transition-transform">
              <Star class="w-8 h-8" :class="i <= reviewForm.rating ? 'text-amber-400 fill-amber-400' : 'text-stitch-outline'" />
            </button>
          </div>
          <textarea
            v-model="reviewForm.comment"
            rows="3"
            placeholder="Chia sẻ trải nghiệm của bạn (tùy chọn)..."
            class="w-full bg-stitch-surface-container border-none rounded-stitch-md p-4 text-sm outline-none resize-none"
          ></textarea>
          <BaseButton @click="submitReview" :loading="submittingReview">Gửi đánh giá</BaseButton>
        </div>
      </div>

      <!-- Action Buttons -->
      <div class="flex gap-4 justify-end">
        <BaseButton v-if="booking.status === 'PENDING'" variant="outline" class="!text-red-500 !border-red-300 hover:!bg-red-50" @click="cancelBooking">
          <XCircle class="w-4 h-4 mr-2" /> Hủy đơn
        </BaseButton>
        <BaseButton v-if="booking.status === 'PENDING'" variant="primary" @click="handlePayment" :loading="processingPayment">
          <Banknote class="w-4 h-4 mr-2" /> Thanh toán qua VNPay
        </BaseButton>
      </div>
    </div>
  </div>
</template>
