<script setup>
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import { 
  TrendingUp, 
  Users, 
  Car, 
  CalendarCheck, 
  Clock,
  CheckCircle,
  Play,
  XCircle,
  CreditCard,
  ArrowRight
} from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { adminDashboardApi } from '@/api'

const router = useRouter()
const stats = ref(null)
const loading = ref(true)

const formatPrice = (price) => {
  if (!price) return '0đ'
  if (price >= 1000000) return (price / 1000000).toFixed(1) + 'M'
  if (price >= 1000) return (price / 1000).toFixed(0) + 'K'
  return new Intl.NumberFormat('vi-VN').format(price) + 'đ'
}

const statCards = computed(() => {
  if (!stats.value) return []
  return [
    { 
      label: 'Tổng doanh thu', 
      value: formatPrice(stats.value.totalRevenue), 
      icon: TrendingUp, 
      color: 'text-emerald-600', 
      bg: 'bg-emerald-50',
      sub: `${stats.value.completedBookings} đơn hoàn thành`
    },
    { 
      label: 'Tổng khách hàng', 
      value: stats.value.totalUsers, 
      icon: Users, 
      color: 'text-blue-600', 
      bg: 'bg-blue-50',
      sub: 'Đã đăng ký'
    },
    { 
      label: 'Xe đang hoạt động', 
      value: `${stats.value.availableCars}/${stats.value.totalCars}`, 
      icon: Car, 
      color: 'text-orange-600', 
      bg: 'bg-orange-50',
      sub: `${stats.value.bookedCars} xe đang cho thuê`
    },
    { 
      label: 'Đơn chờ xử lý', 
      value: stats.value.pendingBookings, 
      icon: Clock, 
      color: 'text-amber-600', 
      bg: 'bg-amber-50',
      sub: 'Cần duyệt ngay'
    },
  ]
})

const bookingBreakdown = computed(() => {
  if (!stats.value) return []
  return [
    { label: 'Chờ xử lý', count: stats.value.pendingBookings, icon: Clock, color: 'text-amber-600', bg: 'bg-amber-50' },
    { label: 'Đã xác nhận', count: stats.value.confirmedBookings, icon: CheckCircle, color: 'text-blue-600', bg: 'bg-blue-50' },
    { label: 'Đang thuê', count: stats.value.inProgressBookings, icon: Play, color: 'text-indigo-600', bg: 'bg-indigo-50' },
    { label: 'Hoàn thành', count: stats.value.completedBookings, icon: CheckCircle, color: 'text-green-600', bg: 'bg-green-50' },
    { label: 'Đã hủy', count: stats.value.cancelledBookings, icon: XCircle, color: 'text-red-600', bg: 'bg-red-50' },
  ]
})

onMounted(async () => {
  try {
    const res = await adminDashboardApi.getStats()
    if (res.success) stats.value = res.data
  } catch (err) {
    console.error('Failed to fetch dashboard stats:', err)
  } finally {
    loading.value = false
  }
})
</script>

<template>
  <div class="space-y-10">
    <div class="flex justify-between items-end">
      <div class="space-y-1">
        <h1 class="editorial-display text-4xl text-stitch-primary">Tổng quan hệ thống</h1>
        <p class="text-stitch-on-surface-variant font-medium">Chào mừng trở lại, đây là những gì đang diễn ra hôm nay.</p>
      </div>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div v-for="i in 4" :key="i" class="bg-white p-6 rounded-stitch-xl h-36 animate-pulse shadow-sm"></div>
    </div>

    <template v-else-if="stats">
      <!-- Stats Grid -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div
          v-for="card in statCards"
          :key="card.label"
          class="bg-white p-6 rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 group hover:shadow-stitch-ambient transition-all duration-300"
        >
          <div class="flex justify-between items-start mb-4">
            <div :class="[card.bg, card.color]" class="p-3 rounded-stitch-lg">
              <component :is="card.icon" class="w-6 h-6" />
            </div>
          </div>
          <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">{{ card.label }}</p>
          <p class="editorial-display text-3xl text-stitch-primary mb-1">{{ card.value }}</p>
          <p class="text-[10px] font-medium text-stitch-on-surface-variant">{{ card.sub }}</p>
        </div>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Booking Breakdown -->
        <div class="lg:col-span-2 bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
          <div class="flex justify-between items-center mb-8">
            <h3 class="editorial-headline text-xl">Phân bổ đơn đặt xe</h3>
            <p class="text-sm font-bold text-stitch-primary">Tổng: {{ stats.totalBookings }}</p>
          </div>

          <div class="space-y-4">
            <div
              v-for="item in bookingBreakdown"
              :key="item.label"
              class="flex items-center justify-between p-4 rounded-stitch-lg hover:bg-stitch-surface-container-lowest transition-colors group"
            >
              <div class="flex items-center gap-4">
                <div :class="[item.bg, item.color]" class="p-2.5 rounded-stitch-md">
                  <component :is="item.icon" class="w-5 h-5" />
                </div>
                <span class="text-sm font-bold">{{ item.label }}</span>
              </div>
              <div class="flex items-center gap-4">
                <span class="editorial-display text-2xl" :class="item.color">{{ item.count }}</span>
                <!-- Progress bar relative to total -->
                <div class="w-24 h-2 bg-stitch-surface-container rounded-full overflow-hidden hidden md:block">
                  <div
                    class="h-full rounded-full transition-all duration-700"
                    :class="item.bg.replace('bg-', 'bg-').replace('-50', '-400')"
                    :style="{ width: stats.totalBookings ? (item.count / stats.totalBookings * 100) + '%' : '0%' }"
                  ></div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Actions -->
        <div class="space-y-6">
          <div class="bg-stitch-primary text-white p-8 rounded-stitch-xl shadow-xl relative overflow-hidden">
            <div class="relative z-10">
              <h3 class="editorial-headline text-xl mb-4">Truy cập nhanh</h3>
              <div class="space-y-3">
                <button
                  @click="router.push('/admin/bookings')"
                  class="w-full flex items-center justify-between bg-white/10 hover:bg-white/20 px-4 py-3 rounded-stitch-lg transition-colors text-sm font-bold"
                >
                  <span class="flex items-center gap-2">
                    <CalendarCheck class="w-4 h-4" /> Đơn đặt xe
                  </span>
                  <ArrowRight class="w-4 h-4" />
                </button>
                <button
                  @click="router.push('/admin/payments')"
                  class="w-full flex items-center justify-between bg-white/10 hover:bg-white/20 px-4 py-3 rounded-stitch-lg transition-colors text-sm font-bold"
                >
                  <span class="flex items-center gap-2">
                    <CreditCard class="w-4 h-4" /> Thanh toán
                  </span>
                  <ArrowRight class="w-4 h-4" />
                </button>
                <button
                  @click="router.push('/admin/cars')"
                  class="w-full flex items-center justify-between bg-white/10 hover:bg-white/20 px-4 py-3 rounded-stitch-lg transition-colors text-sm font-bold"
                >
                  <span class="flex items-center gap-2">
                    <Car class="w-4 h-4" /> Quản lý xe
                  </span>
                  <ArrowRight class="w-4 h-4" />
                </button>
                <button
                  @click="router.push('/admin/users')"
                  class="w-full flex items-center justify-between bg-white/10 hover:bg-white/20 px-4 py-3 rounded-stitch-lg transition-colors text-sm font-bold"
                >
                  <span class="flex items-center gap-2">
                    <Users class="w-4 h-4" /> Khách hàng
                  </span>
                  <ArrowRight class="w-4 h-4" />
                </button>
              </div>
            </div>
            <Car class="absolute -bottom-4 -right-4 w-32 h-32 text-white/5 rotate-12" />
          </div>

          <!-- System Health -->
          <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8">
            <h3 class="editorial-headline text-lg mb-6">Tóm tắt hệ thống</h3>
            <div class="space-y-4">
              <div class="flex justify-between items-center">
                <span class="text-xs font-medium text-stitch-on-surface-variant">Tổng đơn hàng</span>
                <span class="text-sm font-bold">{{ stats.totalBookings }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-xs font-medium text-stitch-on-surface-variant">Tổng xe</span>
                <span class="text-sm font-bold">{{ stats.totalCars }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-xs font-medium text-stitch-on-surface-variant">Xe trống</span>
                <span class="text-sm font-bold text-green-600">{{ stats.availableCars }}</span>
              </div>
              <div class="flex justify-between items-center">
                <span class="text-xs font-medium text-stitch-on-surface-variant">Xe đang thuê</span>
                <span class="text-sm font-bold text-orange-600">{{ stats.bookedCars }}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
