<script setup>
import { ref, onMounted } from 'vue'
import { Search, Users, UserCheck, UserX, Mail, Phone, ChevronLeft, ChevronRight, CreditCard, Shield } from 'lucide-vue-next'
import { adminUserApi } from '@/api'

const users = ref([])
const loading = ref(true)
const page = ref(0)
const totalPages = ref(0)
const totalElements = ref(0)
const searchQuery = ref('')
const togglingId = ref(null)
let searchTimeout = null

const fetchUsers = async () => {
  loading.value = true
  try {
    const res = await adminUserApi.list({ search: searchQuery.value, page: page.value, size: 10 })
    if (res.success) {
      users.value = res.data.content || []
      totalPages.value = res.data.totalPages || 0
      totalElements.value = res.data.totalElements || 0
    }
  } catch (err) {
    console.error('Failed to fetch users:', err)
  } finally {
    loading.value = false
  }
}

const onSearch = () => {
  clearTimeout(searchTimeout)
  searchTimeout = setTimeout(() => {
    page.value = 0
    fetchUsers()
  }, 400)
}

const toggleUser = async (user) => {
  const isDisabling = user.role !== 'DISABLED'
  const label = isDisabling ? 'vô hiệu hóa' : 'kích hoạt lại'
  if (!confirm(`Bạn có chắc chắn muốn ${label} tài khoản "${user.name}"?`)) return

  togglingId.value = user.userId
  try {
    await adminUserApi.toggle(user.userId, !isDisabling)
    await fetchUsers()
  } catch (err) {
    alert(err.response?.data?.message || 'Thao tác thất bại')
  } finally {
    togglingId.value = null
  }
}

const getRoleBadge = (role) => {
  switch (role) {
    case 'ADMIN': return { label: 'Admin', class: 'bg-purple-100 text-purple-700' }
    case 'USER': return { label: 'Khách hàng', class: 'bg-blue-100 text-blue-700' }
    case 'DISABLED': return { label: 'Đã khóa', class: 'bg-red-100 text-red-700' }
    default: return { label: role, class: 'bg-gray-100 text-gray-700' }
  }
}

onMounted(fetchUsers)
</script>

<template>
  <div class="space-y-8">
    <div class="flex justify-between items-center">
      <div class="space-y-1">
        <h1 class="editorial-display text-3xl text-stitch-primary">Quản lý khách hàng</h1>
        <p class="text-stitch-on-surface-variant text-sm font-medium">
          Danh sách tất cả người dùng trong hệ thống.
          <span v-if="totalElements" class="text-stitch-primary font-bold">{{ totalElements }} người dùng</span>
        </p>
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-stitch-xl shadow-stitch-ambient overflow-hidden border border-stitch-outline-variant/10">
      <!-- Search Toolbar -->
      <div class="p-6 border-b border-stitch-outline-variant/10 bg-stitch-surface-container-lowest">
        <div class="relative max-w-md">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
          <input
            v-model="searchQuery"
            @input="onSearch"
            type="text"
            placeholder="Tìm theo tên, email, SĐT..."
            class="bg-stitch-surface-container border-none rounded-stitch-md px-10 py-2.5 text-sm w-full outline-none"
          >
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="p-12 text-center">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-stitch-primary mx-auto"></div>
        <p class="text-sm text-stitch-on-surface-variant mt-4">Đang tải...</p>
      </div>

      <!-- Empty -->
      <div v-else-if="users.length === 0" class="p-12 text-center">
        <div class="w-16 h-16 bg-stitch-surface-container rounded-full flex items-center justify-center mx-auto mb-4">
          <Users class="w-8 h-8 text-stitch-outline" />
        </div>
        <p class="font-bold text-stitch-on-surface-variant">Không tìm thấy người dùng nào.</p>
      </div>

      <!-- Data -->
      <div v-else class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-stitch-surface-container-low">
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Người dùng</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Liên hệ</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">GPLX</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Đơn đặt</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Vai trò</th>
              <th class="p-5 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant text-right">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stitch-outline-variant/10">
            <tr
              v-for="user in users"
              :key="user.userId"
              class="hover:bg-stitch-surface-container-lowest transition-colors"
              :class="{ 'opacity-50': user.role === 'DISABLED' }"
            >
              <td class="p-5">
                <div class="flex items-center gap-3">
                  <div class="w-10 h-10 rounded-full flex items-center justify-center font-bold text-sm text-white"
                    :class="user.role === 'ADMIN' ? 'bg-purple-500' : user.role === 'DISABLED' ? 'bg-gray-400' : 'bg-stitch-primary-container'"
                  >
                    {{ (user.name || 'U').charAt(0).toUpperCase() }}
                  </div>
                  <div>
                    <p class="font-bold text-sm">{{ user.name }}</p>
                    <p class="text-[10px] text-stitch-on-surface-variant font-medium">#{{ user.userId }}</p>
                  </div>
                </div>
              </td>
              <td class="p-5">
                <div class="space-y-1">
                  <div class="flex items-center gap-1.5 text-xs text-stitch-on-surface-variant">
                    <Mail class="w-3 h-3" />
                    <span>{{ user.email || '—' }}</span>
                  </div>
                  <div class="flex items-center gap-1.5 text-xs text-stitch-on-surface-variant">
                    <Phone class="w-3 h-3" />
                    <span>{{ user.phone || '—' }}</span>
                  </div>
                </div>
              </td>
              <td class="p-5">
                <div class="flex items-center gap-1.5">
                  <CreditCard class="w-3.5 h-3.5 text-stitch-on-surface-variant" />
                  <span class="text-xs font-medium" :class="user.driveLicense ? 'text-green-600' : 'text-stitch-outline'">
                    {{ user.driveLicense || 'Chưa cập nhật' }}
                  </span>
                </div>
              </td>
              <td class="p-5">
                <span class="text-sm font-bold text-stitch-primary">{{ user.totalBookings }}</span>
              </td>
              <td class="p-5">
                <span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider" :class="getRoleBadge(user.role).class">
                  {{ getRoleBadge(user.role).label }}
                </span>
              </td>
              <td class="p-5 text-right">
                <button
                  v-if="user.role !== 'ADMIN'"
                  @click="toggleUser(user)"
                  :disabled="togglingId === user.userId"
                  class="p-2 rounded-stitch-md transition-colors disabled:opacity-50"
                  :class="user.role === 'DISABLED'
                    ? 'text-green-600 hover:bg-green-50'
                    : 'text-red-500 hover:bg-red-50'"
                  :title="user.role === 'DISABLED' ? 'Kích hoạt lại' : 'Vô hiệu hóa'"
                >
                  <UserCheck v-if="user.role === 'DISABLED'" class="w-5 h-5" />
                  <UserX v-else class="w-5 h-5" />
                </button>
                <span v-else class="inline-flex items-center gap-1 text-xs text-purple-500 font-bold">
                  <Shield class="w-3.5 h-3.5" /> Admin
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center gap-2 p-6 border-t border-stitch-outline-variant/10">
        <button @click="page--; fetchUsers()" :disabled="page === 0" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronLeft class="w-5 h-5" />
        </button>
        <span class="px-4 py-2 text-sm font-bold text-stitch-on-surface-variant">{{ page + 1 }} / {{ totalPages }}</span>
        <button @click="page++; fetchUsers()" :disabled="page >= totalPages - 1" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronRight class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>
