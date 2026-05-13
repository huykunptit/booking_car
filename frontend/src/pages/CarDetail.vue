<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ChevronLeft, Share2, Heart, Fuel, ShieldCheck, MapPin, Calendar, CheckCircle, Users, Cog, Star } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { carApi, bookingApi, reviewApi } from '@/api'
import AvailabilityCalendar from '@/components/AvailabilityCalendar.vue'

const route = useRoute()
const router = useRouter()
const car = ref(null)
const bookedDates = ref([])
const loading = ref(true)
const bookingLoading = ref(false)
const bookingSuccess = ref(false)
const bookingError = ref('')

const reviews = ref([])
const totalReviews = ref(0)
const loadingReviews = ref(true)

// Date selection
const startDate = ref('')
const endDate = ref('')

const today = computed(() => new Date().toISOString().split('T')[0])

const totalDays = computed(() => {
  if (!startDate.value || !endDate.value) return 0
  const start = new Date(startDate.value)
  const end = new Date(endDate.value)
  const diff = Math.ceil((end - start) / (1000 * 60 * 60 * 24))
  return diff > 0 ? diff : 0
})

const totalPrice = computed(() => {
  if (!car.value || !totalDays.value) return 0
  return car.value.pricePerDay * totalDays.value
})

const canBook = computed(() => totalDays.value > 0 && !bookingLoading.value)

const handleBooking = async () => {
  if (!localStorage.getItem('token')) {
    router.push({ name: 'Login', query: { redirect: route.fullPath } })
    return
  }

  if (!canBook.value) {
    bookingError.value = 'Vui lòng chọn ngày bắt đầu và kết thúc hợp lệ'
    return
  }

  bookingLoading.value = true
  bookingError.value = ''
  try {
    const res = await bookingApi.create({
      carId: Number(route.params.id),
      startDate: startDate.value,
      endDate: endDate.value,
    })
    if (res.success) {
      bookingSuccess.value = true
    }
  } catch (err) {
    bookingError.value = err.response?.data?.message || 'Đặt xe thất bại. Vui lòng thử lại.'
  } finally {
    bookingLoading.value = false
  }
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price)

onMounted(async () => {
  try {
    const carRes = await carApi.get(route.params.id)
    if (carRes.success) car.value = carRes.data

    const availRes = await carApi.getAvailability(route.params.id)
    if (availRes.success) {
      bookedDates.value = availRes.data.bookedDates || []
    }

    try {
      const reviewRes = await reviewApi.getForCar(route.params.id, { page: 0, size: 5 })
      if (reviewRes.success) {
        reviews.value = reviewRes.data.content || []
        totalReviews.value = reviewRes.data.totalElements || 0
      }
    } catch (err) {
      console.error('Failed to load reviews', err)
    }
  } catch (err) {
    console.error(err)
    car.value = {
      id: route.params.id,
      brand: 'VinFast',
      name: 'VF8 Plus 2023',
      description: 'VinFast VF8 là mẫu SUV điện thông minh, mang đến trải nghiệm lái êm ái, công nghệ an toàn vượt trội và nội thất sang trọng.',
      fuelType: 'Điện',
      seats: 5,
      transmission: 'AUTOMATIC',
      location: 'Nam Từ Liêm, Hà Nội',
      pricePerDay: 1200000,
      rating: 4.9,
      trips: 124,
      images: [
        'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=800',
      ]
    }
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div v-if="loading" class="flex items-center justify-center min-h-screen">
    <div class="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-stitch-primary"></div>
  </div>

  <div v-else-if="car" class="pb-32 bg-white min-h-screen">
    <!-- Header Controls -->
    <div class="fixed top-0 left-0 right-0 p-6 flex justify-between items-center z-40">
      <button @click="router.back()" class="bg-white/90 backdrop-blur p-2.5 rounded-full shadow-lg text-stitch-primary">
        <ChevronLeft class="w-6 h-6" />
      </button>
      <div class="flex gap-3">
        <button class="bg-white/90 backdrop-blur p-2.5 rounded-full shadow-lg text-stitch-primary">
          <Share2 class="w-5 h-5" />
        </button>
        <button class="bg-white/90 backdrop-blur p-2.5 rounded-full shadow-lg text-stitch-primary">
          <Heart class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- Gallery -->
    <div class="aspect-[4/3] relative bg-stitch-surface-container-low">
      <img :src="car.images?.[0] || car.primaryImage || 'https://images.unsplash.com/photo-1617788138017-80ad40651399?auto=format&fit=crop&q=80&w=800'" class="w-full h-full object-cover">
    </div>

    <!-- Content -->
    <div class="px-6 -mt-8 relative z-10">
      <div class="bg-white rounded-t-stitch-xl p-6 shadow-[0_-8px_24px_rgba(0,0,0,0.04)]">
        <div class="flex justify-between items-start mb-4">
          <div>
            <h1 class="editorial-display text-3xl mb-1">{{ car.brand }} {{ car.name }}</h1>
            <div class="flex items-center gap-2 text-sm text-stitch-on-surface-variant font-medium">
              <span class="flex items-center gap-1"><Star class="w-4 h-4 text-amber-400 fill-amber-400" /> {{ car.averageRating ? car.averageRating.toFixed(1) : 'Chưa có' }}</span>
              <span>•</span>
              <span>{{ car.reviewCount || 0 }} đánh giá</span>
            </div>
          </div>
          <div class="flex items-center gap-1 text-stitch-tertiary">
            <ShieldCheck class="w-5 h-5" />
            <span class="text-xs font-bold uppercase tracking-widest">Verified</span>
          </div>
        </div>

        <!-- Quick Specs -->
        <div class="grid grid-cols-3 gap-3 mb-8">
          <div class="bg-stitch-surface-container-lowest border border-stitch-outline-variant/30 p-4 rounded-stitch-lg flex flex-col items-center gap-2">
            <Fuel class="w-5 h-5 text-stitch-primary" />
            <span class="text-[10px] font-bold uppercase tracking-wider text-stitch-on-surface-variant">Nhiên liệu</span>
            <span class="text-xs font-bold">{{ car.fuelType }}</span>
          </div>
          <div class="bg-stitch-surface-container-lowest border border-stitch-outline-variant/30 p-4 rounded-stitch-lg flex flex-col items-center gap-2">
            <Cog class="w-5 h-5 text-stitch-primary" />
            <span class="text-[10px] font-bold uppercase tracking-wider text-stitch-on-surface-variant">Hộp số</span>
            <span class="text-xs font-bold">{{ car.transmission === 'AUTOMATIC' ? 'Tự động' : 'Số sàn' }}</span>
          </div>
          <div class="bg-stitch-surface-container-lowest border border-stitch-outline-variant/30 p-4 rounded-stitch-lg flex flex-col items-center gap-2">
            <Users class="w-5 h-5 text-stitch-primary" />
            <span class="text-[10px] font-bold uppercase tracking-wider text-stitch-on-surface-variant">Chỗ ngồi</span>
            <span class="text-xs font-bold">{{ car.seats }} Chỗ</span>
          </div>
        </div>

        <!-- Description -->
        <div v-if="car.description" class="mb-8">
          <h3 class="editorial-headline text-lg mb-3">Đặc điểm nổi bật</h3>
          <p class="text-stitch-on-surface-variant leading-relaxed text-sm">{{ car.description }}</p>
        </div>

        <!-- Location -->
        <div class="mb-8 p-4 bg-stitch-surface-container rounded-stitch-lg flex items-center gap-4">
          <div class="bg-white p-2.5 rounded-full shadow-sm">
            <MapPin class="w-5 h-5 text-stitch-primary" />
          </div>
          <div>
            <h4 class="font-bold text-sm">Vị trí xe</h4>
            <p class="text-xs text-stitch-on-surface-variant">{{ car.location }}</p>
          </div>
        </div>

        <!-- Booking Form -->
        <div class="mb-8 bg-stitch-surface-container-low border border-stitch-outline-variant/20 rounded-stitch-xl p-6">
          <h3 class="editorial-headline text-lg mb-6 flex items-center gap-2">
            <Calendar class="w-5 h-5 text-stitch-primary" /> Chọn ngày thuê
          </h3>
          <div class="grid grid-cols-2 gap-4 mb-6">
            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Ngày bắt đầu</label>
              <input v-model="startDate" type="date" :min="today" class="input-field w-full" />
            </div>
            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Ngày kết thúc</label>
              <input v-model="endDate" type="date" :min="startDate || today" class="input-field w-full" />
            </div>
          </div>

          <!-- Price Summary -->
          <div v-if="totalDays > 0" class="space-y-3 pt-4 border-t border-stitch-outline-variant/20">
            <div class="flex justify-between text-sm">
              <span class="text-stitch-on-surface-variant">{{ formatPrice(car.pricePerDay) }}đ × {{ totalDays }} ngày</span>
              <span class="font-bold">{{ formatPrice(totalPrice) }}đ</span>
            </div>
            <div class="flex justify-between text-lg pt-2 border-t border-stitch-outline-variant/20">
              <span class="font-bold">Tổng cộng</span>
              <span class="editorial-display text-stitch-primary">{{ formatPrice(totalPrice) }}đ</span>
            </div>
          </div>

          <!-- Error -->
          <p v-if="bookingError" class="text-red-500 text-sm font-bold mt-4">{{ bookingError }}</p>
        </div>

        <!-- Availability Calendar -->
        <div class="mb-8">
          <h3 class="editorial-headline text-lg mb-4">Lịch xe trống</h3>
          <p class="text-xs text-stitch-on-surface-variant mb-6">Tham khảo lịch dưới đây để chọn ngày thuê phù hợp.</p>
          <AvailabilityCalendar :booked-dates="bookedDates" />
        </div>

        <!-- Reviews -->
        <div class="mb-8 border-t border-stitch-outline-variant/20 pt-8">
          <div class="flex items-center justify-between mb-6">
            <h3 class="editorial-headline text-lg flex items-center gap-2">
              <Star class="w-5 h-5 text-stitch-primary" /> Đánh giá ({{ totalReviews }})
            </h3>
            <div class="flex items-center gap-1">
              <span class="editorial-display text-2xl">{{ car.averageRating ? car.averageRating.toFixed(1) : '0' }}</span>
              <Star class="w-5 h-5 text-amber-400 fill-amber-400" />
            </div>
          </div>
          
          <div v-if="reviews.length > 0" class="space-y-6">
            <div v-for="review in reviews" :key="review.reviewId" class="border-b border-stitch-outline-variant/10 pb-6 last:border-0">
              <div class="flex justify-between items-start mb-2">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-full bg-stitch-surface-container flex items-center justify-center font-bold text-xs">
                    {{ (review.userName || 'U').charAt(0).toUpperCase() }}
                  </div>
                  <div>
                    <p class="font-bold text-sm">{{ review.userName }}</p>
                    <p class="text-[10px] text-stitch-on-surface-variant uppercase tracking-widest">{{ new Date(review.createdAt).toLocaleDateString('vi-VN') }}</p>
                  </div>
                </div>
                <div class="flex gap-0.5">
                  <Star v-for="i in 5" :key="i" class="w-3.5 h-3.5" :class="i <= review.rating ? 'text-amber-400 fill-amber-400' : 'text-stitch-outline'" />
                </div>
              </div>
              <p class="text-sm text-stitch-on-surface-variant italic mt-3">{{ review.comment || 'Không có bình luận.' }}</p>
            </div>
            
            <button v-if="totalReviews > 5" class="w-full py-3 text-sm font-bold text-stitch-primary hover:bg-stitch-surface-container rounded-stitch-md transition-colors border border-stitch-outline-variant/20">
              Xem tất cả đánh giá
            </button>
          </div>
          <div v-else class="text-center py-8 bg-stitch-surface-container-lowest rounded-stitch-lg border border-stitch-outline-variant/10">
            <p class="text-sm text-stitch-on-surface-variant font-medium">Xe này chưa có đánh giá nào.</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Booking Sticky Bar -->
    <div class="fixed bottom-0 left-0 right-0 p-6 glass-effect border-t border-stitch-outline-variant/20 flex justify-between items-center z-50">
      <div>
        <p class="text-xs text-stitch-on-surface-variant font-medium">Giá thuê 1 ngày</p>
        <div class="flex items-baseline gap-1">
          <span class="editorial-display text-2xl text-stitch-primary">{{ Math.floor(car.pricePerDay / 1000) }}k</span>
          <span class="text-xs text-stitch-on-surface-variant font-bold">VNĐ</span>
        </div>
      </div>
      <BaseButton 
        variant="accent" 
        class="!px-10 !py-4 shadow-xl shadow-stitch-accent/30"
        :loading="bookingLoading"
        :disabled="!canBook"
        @click="handleBooking"
      >
        {{ totalDays > 0 ? `Đặt ${totalDays} ngày` : 'Chọn ngày trước' }}
      </BaseButton>
    </div>

    <!-- Success Modal -->
    <transition name="fade">
      <div v-if="bookingSuccess" class="fixed inset-0 z-[100] flex items-center justify-center p-6 bg-stitch-primary/40 backdrop-blur-sm">
        <div class="bg-white rounded-stitch-xl p-10 max-w-sm w-full text-center shadow-2xl animate-fade-up">
          <div class="w-20 h-20 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle class="w-12 h-12" />
          </div>
          <h2 class="editorial-display text-2xl mb-4">Đặt xe thành công!</h2>
          <p class="text-stitch-on-surface-variant text-sm mb-8 leading-relaxed">
            Yêu cầu đặt xe của bạn đã được gửi đi. Vui lòng theo dõi trạng thái đơn trong mục "Đơn đặt xe".
          </p>
          <div class="space-y-3">
            <BaseButton variant="primary" class="w-full" @click="router.push('/my-bookings')">Xem đơn hàng</BaseButton>
            <BaseButton variant="ghost" class="w-full" @click="bookingSuccess = false">Đóng</BaseButton>
          </div>
        </div>
      </div>
    </transition>
  </div>
</template>

<style scoped>
@keyframes fade-up {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-up {
  animation: fade-up 0.5s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
}
</style>
