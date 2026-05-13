<script setup>
import { ref, onMounted } from 'vue'
import { Search, CreditCard, CheckCircle, XCircle, Clock, ChevronLeft, ChevronRight, Check } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { paymentApi } from '@/api'

const payments = ref([])
const loading = ref(true)
const page = ref(0)
const totalPages = ref(0)
const totalElements = ref(0)
const filterStatus = ref('')
const confirmingId = ref(null)

const statusConfig = {
  PENDING: { label: 'Chờ xác nhận', class: 'bg-amber-100 text-amber-700', icon: Clock },
  SUCCESS: { label: 'Thành công', class: 'bg-green-100 text-green-700', icon: CheckCircle },
  FAILED: { label: 'Thất bại', class: 'bg-red-100 text-red-700', icon: XCircle },
}

const methodLabels = {
  CASH: 'Tiền mặt',
  BANK_TRANSFER: 'Chuyển khoản',
  VNPAY: 'VNPay',
  MOMO: 'MoMo',
}

const fetchPayments = async () => {
  loading.value = true
  try {
    const params = { page: page.value, size: 10 }
    if (filterStatus.value) params.paymentStatus = filterStatus.value
    const res = await paymentApi.adminList(params)
    if (res.success) {
      payments.value = res.data.content || []
      totalPages.value = res.data.totalPages || 0
      totalElements.value = res.data.totalElements || 0
    }
  } catch (err) {
    console.error('Failed to fetch payments:', err)
  } finally {
    loading.value = false
  }
}

const confirmPayment = async (invoiceId, result) => {
  const label = result === 'SUCCESS' ? 'xác nhận thanh toán thành công' : 'đánh dấu thanh toán thất bại'
  if (!confirm(`Bạn có chắc chắn muốn ${label}?`)) return
  confirmingId.value = invoiceId
  try {
    await paymentApi.adminConfirm(invoiceId, result)
    await fetchPayments()
  } catch (err) {
    alert(err.response?.data?.message || 'Không thể xác nhận thanh toán')
  } finally {
    confirmingId.value = null
  }
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'
const formatDate = (dateStr) => new Date(dateStr).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric', hour: '2-digit', minute: '2-digit' })

const onFilterChange = () => {
  page.value = 0
  fetchPayments()
}

onMounted(fetchPayments)
</script>

<template>
  <div class="space-y-8">
    <div class="flex justify-between items-center">
      <div class="space-y-1">
        <h1 class="editorial-display text-3xl text-stitch-primary">Quản lý thanh toán</h1>
        <p class="text-stitch-on-surface-variant text-sm font-medium">
          Xem và xác nhận thanh toán từ khách hàng.
          <span v-if="totalElements" class="text-stitch-primary font-bold">{{ totalElements }} giao dịch</span>
        </p>
      </div>
    </div>

    <!-- Table -->
    <div class="bg-white rounded-stitch-xl shadow-stitch-ambient overflow-hidden border border-stitch-outline-variant/10">
      <!-- Toolbar -->
      <div class="p-6 border-b border-stitch-outline-variant/10 flex flex-col md:flex-row justify-between items-start md:items-center gap-4 bg-stitch-surface-container-lowest">
        <div class="relative">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
          <input type="text" placeholder="Tìm kiếm..." class="bg-stitch-surface-container border-none rounded-stitch-md px-10 py-2 text-sm w-64 outline-none">
        </div>
        <div class="flex gap-2">
          <select v-model="filterStatus" @change="onFilterChange" class="bg-stitch-surface-container border-none rounded-stitch-md px-4 py-2 text-sm font-bold outline-none">
            <option value="">Tất cả</option>
            <option value="PENDING">Chờ xác nhận</option>
            <option value="SUCCESS">Thành công</option>
            <option value="FAILED">Thất bại</option>
          </select>
        </div>
      </div>

      <!-- Loading -->
      <div v-if="loading" class="p-12 text-center">
        <div class="animate-spin rounded-full h-10 w-10 border-b-2 border-stitch-primary mx-auto"></div>
      </div>

      <!-- Empty -->
      <div v-else-if="payments.length === 0" class="p-12 text-center text-stitch-on-surface-variant">
        <p class="font-bold">Chưa có giao dịch nào.</p>
      </div>

      <!-- Data -->
      <div v-else class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-stitch-surface-container-low">
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Mã GD</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Số tiền</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Phương thức</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Thời gian</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Trạng thái</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Hành động</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stitch-outline-variant/10">
            <tr v-for="p in payments" :key="p.paymentId" class="hover:bg-stitch-surface-container-lowest transition-colors">
              <td class="p-6">
                <div class="flex items-center gap-3">
                  <div class="bg-stitch-surface-container p-2 rounded-stitch-md">
                    <CreditCard class="w-4 h-4 text-stitch-primary" />
                  </div>
                  <div>
                    <p class="font-bold text-sm">{{ p.transactionCode || '#' + p.paymentId }}</p>
                    <p class="text-[10px] text-stitch-on-surface-variant">Invoice #{{ p.invoiceId }}</p>
                  </div>
                </div>
              </td>
              <td class="p-6 text-sm font-bold text-stitch-primary">{{ formatPrice(p.amount) }}</td>
              <td class="p-6 text-sm font-medium">{{ methodLabels[p.paymentMethod] || p.paymentMethod }}</td>
              <td class="p-6 text-sm text-stitch-on-surface-variant">{{ formatDate(p.createAt) }}</td>
              <td class="p-6">
                <div class="flex items-center gap-2 px-3 py-1 rounded-full w-fit" :class="(statusConfig[p.paymentStatus] || statusConfig.PENDING).class">
                  <component :is="(statusConfig[p.paymentStatus] || statusConfig.PENDING).icon" class="w-3.5 h-3.5" />
                  <span class="text-[10px] font-bold uppercase tracking-wider">{{ (statusConfig[p.paymentStatus] || statusConfig.PENDING).label }}</span>
                </div>
              </td>
              <td class="p-6">
                <div v-if="p.paymentStatus === 'PENDING'" class="flex gap-2">
                  <button
                    @click="confirmPayment(p.invoiceId, 'SUCCESS')"
                    :disabled="confirmingId === p.invoiceId"
                    class="p-2 bg-green-50 hover:bg-green-100 text-green-600 rounded-stitch-md transition-colors disabled:opacity-50"
                    title="Xác nhận thành công"
                  >
                    <CheckCircle class="w-4 h-4" />
                  </button>
                  <button
                    @click="confirmPayment(p.invoiceId, 'FAILED')"
                    :disabled="confirmingId === p.invoiceId"
                    class="p-2 bg-red-50 hover:bg-red-100 text-red-600 rounded-stitch-md transition-colors disabled:opacity-50"
                    title="Đánh dấu thất bại"
                  >
                    <XCircle class="w-4 h-4" />
                  </button>
                </div>
                <span v-else class="text-xs text-stitch-outline">—</span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center gap-2 p-6 border-t border-stitch-outline-variant/10">
        <button @click="page--; fetchPayments()" :disabled="page === 0" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronLeft class="w-5 h-5" />
        </button>
        <span class="px-4 py-2 text-sm font-bold text-stitch-on-surface-variant">{{ page + 1 }} / {{ totalPages }}</span>
        <button @click="page++; fetchPayments()" :disabled="page >= totalPages - 1" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronRight class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>
