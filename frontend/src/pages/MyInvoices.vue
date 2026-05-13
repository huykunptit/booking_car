<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { FileText, ChevronLeft, ChevronRight, CheckCircle, Clock, XCircle } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { invoiceApi } from '@/api'

const router = useRouter()
const invoices = ref([])
const loading = ref(true)
const page = ref(0)
const totalPages = ref(0)
const totalElements = ref(0)

const statusConfig = {
  UNPAID: { label: 'Chưa thanh toán', class: 'bg-amber-100 text-amber-700', icon: Clock },
  PAID: { label: 'Đã thanh toán', class: 'bg-green-100 text-green-700', icon: CheckCircle },
  FAILED: { label: 'Thất bại', class: 'bg-red-100 text-red-700', icon: XCircle },
}

const fetchInvoices = async () => {
  loading.value = true
  try {
    const res = await invoiceApi.listMy({ page: page.value, size: 10 })
    if (res.success) {
      invoices.value = res.data.content || []
      totalPages.value = res.data.totalPages || 0
      totalElements.value = res.data.totalElements || 0
    }
  } catch (err) {
    console.error('Failed to fetch invoices:', err)
  } finally {
    loading.value = false
  }
}

const formatPrice = (price) => new Intl.NumberFormat('vi-VN').format(price) + 'đ'
const formatDate = (dateStr) => new Date(dateStr).toLocaleDateString('vi-VN', { day: '2-digit', month: '2-digit', year: 'numeric' })

onMounted(fetchInvoices)
</script>

<template>
  <div class="pt-32 pb-20 px-6 max-w-6xl mx-auto min-h-screen">
    <div class="space-y-1 mb-10">
      <h1 class="editorial-display text-4xl text-stitch-primary">Hóa đơn của tôi</h1>
      <p class="text-stitch-on-surface-variant text-sm font-medium">
        Danh sách tất cả hóa đơn cho các đơn đặt xe.
        <span v-if="totalElements" class="text-stitch-primary font-bold">{{ totalElements }} hóa đơn</span>
      </p>
    </div>

    <!-- Loading -->
    <div v-if="loading" class="space-y-4">
      <div v-for="i in 3" :key="i" class="bg-white rounded-stitch-xl h-24 animate-pulse shadow-sm"></div>
    </div>

    <!-- Empty -->
    <div v-else-if="invoices.length === 0" class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-16 text-center">
      <div class="w-20 h-20 bg-stitch-surface-container rounded-full flex items-center justify-center mx-auto mb-6">
        <FileText class="w-10 h-10 text-stitch-outline" />
      </div>
      <h3 class="editorial-headline text-xl mb-2">Chưa có hóa đơn nào</h3>
      <p class="text-stitch-on-surface-variant text-sm">Hóa đơn sẽ xuất hiện khi bạn đặt xe.</p>
    </div>

    <!-- Invoice Table -->
    <div v-else class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-stitch-surface-container-low">
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Mã hóa đơn</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Mã đơn</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Số tiền</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Ngày tạo</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Trạng thái</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stitch-outline-variant/10">
            <tr v-for="inv in invoices" :key="inv.invoiceId" class="hover:bg-stitch-surface-container-lowest transition-colors">
              <td class="p-6">
                <div class="flex items-center gap-3">
                  <div class="bg-stitch-surface-container p-2 rounded-stitch-md">
                    <FileText class="w-4 h-4 text-stitch-primary" />
                  </div>
                  <span class="font-bold text-sm">{{ inv.invoiceNumber }}</span>
                </div>
              </td>
              <td class="p-6 text-sm font-medium text-stitch-on-surface-variant">#{{ inv.bookingId }}</td>
              <td class="p-6 text-sm font-bold text-stitch-primary">{{ formatPrice(inv.totalAmount) }}</td>
              <td class="p-6 text-sm text-stitch-on-surface-variant">{{ formatDate(inv.createAt) }}</td>
              <td class="p-6">
                <div class="flex items-center gap-2 px-3 py-1 rounded-full w-fit" :class="(statusConfig[inv.status] || statusConfig.UNPAID).class">
                  <component :is="(statusConfig[inv.status] || statusConfig.UNPAID).icon" class="w-3.5 h-3.5" />
                  <span class="text-[10px] font-bold uppercase tracking-wider">{{ (statusConfig[inv.status] || statusConfig.UNPAID).label }}</span>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Pagination -->
      <div v-if="totalPages > 1" class="flex justify-center gap-2 p-6 border-t border-stitch-outline-variant/10">
        <button @click="page--; fetchInvoices()" :disabled="page === 0" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronLeft class="w-5 h-5" />
        </button>
        <span class="px-4 py-2 text-sm font-bold text-stitch-on-surface-variant">{{ page + 1 }} / {{ totalPages }}</span>
        <button @click="page++; fetchInvoices()" :disabled="page >= totalPages - 1" class="p-2 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-30">
          <ChevronRight class="w-5 h-5" />
        </button>
      </div>
    </div>
  </div>
</template>
