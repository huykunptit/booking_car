<script setup>
import { ref, onMounted } from 'vue'
import { Search, Car, CheckCircle, XCircle, Clock, ChevronLeft, ChevronRight, Ban, Play, PackageCheck, UserCheck, MoreVertical } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { bookingApi } from '@/api'

const bookings = ref([])
const loading = ref(true)
const page = ref(0)
const totalPages = ref(0)
const totalElements = ref(0)
const searchQuery = ref('')
const actionLoading = ref(null)
const openMenuId = ref(null)

const statusConfig = {
  PENDING: { label: 'Chờ xử lý', class: 'bg-amber-100 text-amber-700', icon: Clock },
  CONFIRMED: { label: 'Đã xác nhận', class: 'bg-blue-100 text-blue-700', icon: CheckCircle },
  IN_PROGRESS: { label: 'Đang thuê', class: 'bg-indigo-100 text-indigo-700', icon: Car },
  COMPLETED: { label: 'Hoàn thành', class: 'bg-green-100 text-green-700', icon: CheckCircle },
  CANCELLED: { label: 'Đã hủy', class: 'bg-red-100 text-red-700', icon: XCircle },
}

// Actions available for each status
const getActions = (status) => {
  switch (status) {
    case 'PENDING':
      return [
        { label: 'Xác nhận đơn', action: 'confirm', icon: UserCheck, class: 'text-blue-600 hover:bg-blue-50' },
        { label: 'Hủy đơn', action: 'cancel', icon: Ban, class: 'text-red-600 hover:bg-red-50' },
      ]
    case 'CONFIRMED':
      return [
        { label: 'Bàn giao xe', action: 'handover', icon: Play, class: 'text-indigo-600 hover:bg-indigo-50' },
        { label: 'Hủy đơn', action: 'cancel', icon: Ban, class: 'text-red-600 hover:bg-red-50' },
      ]
    case 'IN_PROGRESS':
      return [
        { label: 'Hoàn thành', action: 'complete', icon: PackageCheck, class: 'text-green-600 hover:bg-green-50' },
      ]
    default:
      return []
  }
}

const fetchBookings = async () => {
  loading.value = true
  try {
    const res = await bookingApi.adminList({ page: page.value, size: 10 })
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

const executeAction = async (bookingId, action) => {
  const messages = {
    confirm: 'Xác nhận đơn đặt xe này?',
    handover: 'Xác nhận bàn giao xe cho khách?',
    complete: 'Xác nhận khách đã trả xe và hoàn thành đơn?',
    cancel: 'Bạn có chắc chắn muốn hủy đơn đặt xe này?',
  }
  if (!confirm(messages[action])) return

  actionLoading.value = bookingId
  openMenuId.value = null
  try {
    switch (action) {
      case 'confirm': await bookingApi.adminConfirm(bookingId); break
      case 'handover': await bookingApi.adminHandover(bookingId); break
      case 'complete': await bookingApi.adminComplete(bookingId); break
      case 'cancel': await bookingApi.adminCancel(bookingId); break
    }
    await fetchBookings()
  } catch (err) {
    alert(err.response?.data?.message || 'Thao tác thất bại')
  } finally {
    actionLoading.value = null
  }
}

const toggleMenu = (id) => {
  openMenuId.value = openMenuId.value === id ? null : id
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'
const formatDate = (dateStr) => new Date(dateStr).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })

const countByStatus = (status) => bookings.value.filter(b => b.status === status).length

onMounted(fetchBookings)
</script>

<template>
  <div class="space-y-8" @click="openMenuId = null">
    <div class="flex justify-between items-center">
      <div class="space-y-1">
        <h1 class="editorial-display text-3xl text-stitch-primary">Quản lý đặt xe</h1>
        <p class="text-stitch-on-surface-variant text-sm font-medium">
          Theo dõi và quản lý toàn bộ đơn đặt xe trong hệ thống.
          <span v-if="totalElements" class="text-stitch-primary font-bold">{{ totalElements }} đơn</span>
        </p>
      </div>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-2 md:grid-cols-5 gap-4">
      <div class="bg-white p-5 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">Chờ xử lý</p>
        <p class="editorial-display text-2xl text-amber-600">{{ countByStatus('PENDING') }}</p>
      </div>
      <div class="bg-white p-5 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">Đã xác nhận</p>
        <p class="editorial-display text-2xl text-blue-600">{{ countByStatus('CONFIRMED') }}</p>
      </div>
      <div class="bg-white p-5 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">Đang thuê</p>
        <p class="editorial-display text-2xl text-indigo-600">{{ countByStatus('IN_PROGRESS') }}</p>
      </div>
      <div class="bg-white p-5 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">Hoàn thành</p>
        <p class="editorial-display text-2xl text-green-600">{{ countByStatus('COMPLETED') }}</p>
      </div>
      <div class="bg-white p-5 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-1">Đã hủy</p>
        <p class="editorial-display text-2xl text-red-600">{{ countByStatus('CANCELLED') }}</p>
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-stitch-xl shadow-stitch-ambient overflow-hidden border border-stitch-outline-variant/10">
      <div class="p-6 border-b border-stitch-outline-variant/10 flex justify-between items-center bg-stitch-surface-container-lowest">
        <div class="relative">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
          <input v-model="searchQuery" type="text" placeholder="Tìm theo mã đơn, khách hàng..." class="bg-stitch-surface-container border-none rounded-stitch-md px-10 py-2 text-sm w-80 outline-none">
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="p-12 text-center">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-stitch-primary mx-auto"></div>
        <p class="text-sm text-stitch-on-surface-variant mt-4">Đang tải dữ liệu...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="bookings.length === 0" class="p-12 text-center text-stitch-on-surface-variant">
        <p class="font-bold">Chưa có đơn đặt xe nào.</p>
      </div>

      <!-- Data Table -->
      <div v-else class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-stitch-surface-container-low">
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Đơn hàng</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Khách hàng</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Lịch trình</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Tổng tiền</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Trạng thái</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant text-right">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stitch-outline-variant/10">
            <tr v-for="booking in bookings" :key="booking.bookingId" class="hover:bg-stitch-surface-container-lowest transition-colors group"
                :class="{ 'opacity-50 pointer-events-none': actionLoading === booking.bookingId }"
            >
              <td class="p-5">
                <div class="flex items-center gap-3">
                  <div class="bg-stitch-surface-container p-2 rounded-stitch-md">
                    <Car class="w-4 h-4 text-stitch-primary" />
                  </div>
                  <div>
                    <p class="font-bold text-sm">#{{ booking.bookingId }}</p>
                    <p class="text-[10px] text-stitch-on-surface-variant font-bold uppercase tracking-tight">{{ booking.carName || 'Xe #' + booking.carId }}</p>
                  </div>
                </div>
              </td>
              <td class="p-5">
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-full bg-stitch-primary-container text-white text-[10px] flex items-center justify-center font-bold">
                    {{ (booking.userName || 'U').charAt(0) }}
                  </div>
                  <span class="text-sm font-medium">{{ booking.userName || 'User #' + booking.userId }}</span>
                </div>
              </td>
              <td class="p-5">
                <div class="flex items-center gap-2 text-xs font-medium">
                  <span>{{ formatDate(booking.startDate) }}</span>
                  <span class="text-stitch-outline">→</span>
                  <span>{{ formatDate(booking.endDate) }}</span>
                </div>
              </td>
              <td class="p-5 text-sm font-bold text-stitch-primary">
                {{ formatPrice(booking.totalPrice) }}
              </td>
              <td class="p-5">
                <div class="flex items-center gap-2 px-3 py-1 rounded-full w-fit" :class="(statusConfig[booking.status] || statusConfig.PENDING).class">
                  <component :is="(statusConfig[booking.status] || statusConfig.PENDING).icon" class="w-3.5 h-3.5" />
                  <span class="text-[10px] font-bold uppercase tracking-wider">
                    {{ (statusConfig[booking.status] || statusConfig.PENDING).label }}
                  </span>
                </div>
              </td>
              <td class="p-5 text-right">
                <!-- Action Menu -->
                <div v-if="getActions(booking.status).length" class="relative inline-block">
                  <button
                    @click.stop="toggleMenu(booking.bookingId)"
                    class="p-2 hover:bg-stitch-surface-container rounded-stitch-md text-stitch-on-surface-variant transition-colors"
                  >
                    <MoreVertical class="w-5 h-5" />
                  </button>

                  <!-- Dropdown -->
                  <transition name="fade">
                    <div
                      v-if="openMenuId === booking.bookingId"
                      class="absolute right-0 top-full mt-1 bg-white rounded-stitch-lg shadow-xl border border-stitch-outline-variant/20 py-1 z-50 min-w-[180px]"
                      @click.stop
                    >
                      <button
                        v-for="act in getActions(booking.status)"
                        :key="act.action"
                        @click="executeAction(booking.bookingId, act.action)"
                        class="w-full flex items-center gap-3 px-4 py-2.5 text-sm font-medium transition-colors"
                        :class="act.class"
                      >
                        <component :is="act.icon" class="w-4 h-4" />
                        {{ act.label }}
                      </button>
                    </div>
                  </transition>
                </div>
                <span v-else class="text-xs text-stitch-outline">—</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center gap-2 p-6 border-t border-stitch-outline-variant/10">
        <button @click="page--; fetchBookings()" :disabled="page === 0" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronLeft class="w-5 h-5" />
        </button>
        <span class="px-4 py-2 text-sm font-bold text-stitch-on-surface-variant">{{ page + 1 }} / {{ totalPages }}</span>
        <button @click="page++; fetchBookings()" :disabled="page >= totalPages - 1" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronRight class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.15s ease, transform 0.15s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; transform: translateY(-4px); }
</style>
