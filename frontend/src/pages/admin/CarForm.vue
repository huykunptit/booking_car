<script setup>
import { ref, onMounted } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  ArrowLeft, 
  Save, 
  Car, 
  MapPin, 
  DollarSign, 
  Info, 
  Settings, 
  Users,
  CheckCircle,
  AlertCircle
} from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { carApi } from '@/api'

const router = useRouter()
const route = useRoute()
const isEdit = ref(!!route.params.id)
const loading = ref(false)
const saving = ref(false)
const error = ref('')
const success = ref(false)

const form = ref({
  name: '',
  brand: '',
  model: '',
  licensePlate: '',
  pricePerDay: 0,
  carStatus: 'AVAILABLE',
  seats: 5,
  transmission: 'Automatic',
  fuelType: 'Gasoline',
  location: 'Hà Nội'
})

onMounted(async () => {
  if (isEdit.value) {
    loading.value = true
    try {
      const res = await carApi.get(route.params.id)
      if (res.success) {
        form.value = { ...res.data }
      }
    } catch (err) {
      error.value = 'Không thể tải thông tin xe'
    } finally {
      loading.value = false
    }
  }
})

const handleSubmit = async () => {
  saving.value = true
  error.value = ''
  try {
    let res
    if (isEdit.value) {
      res = await carApi.adminUpdate(route.params.id, form.value)
    } else {
      res = await carApi.adminCreate(form.value)
    }

    if (res.success) {
      success.value = true
      setTimeout(() => {
        router.push('/admin/cars')
      }, 2000)
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Có lỗi xảy ra khi lưu thông tin'
  } finally {
    saving.value = false
  }
}
</script>

<template>
  <div class="max-w-4xl mx-auto space-y-8">
    <div class="flex justify-between items-center">
      <div class="flex items-center gap-4">
        <button @click="router.back()" class="p-2 hover:bg-stitch-surface-container rounded-full transition-colors">
          <ArrowLeft class="w-6 h-6 text-stitch-on-surface-variant" />
        </button>
        <h1 class="editorial-display text-3xl text-stitch-primary">
          {{ isEdit ? 'Cập nhật thông tin xe' : 'Thêm xe mới' }}
        </h1>
      </div>
    </div>

    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-stitch-primary"></div>
    </div>

    <form v-else @submit.prevent="handleSubmit" class="space-y-8">
      <!-- General Info Card -->
      <div class="bg-white p-8 rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 space-y-8">
        <div class="flex items-center gap-3 border-b border-stitch-outline-variant/10 pb-4">
          <Info class="w-5 h-5 text-stitch-primary" />
          <h3 class="editorial-headline text-lg">Thông tin cơ bản</h3>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Tên xe</label>
            <input v-model="form.name" type="text" required placeholder="Ví dụ: VF8 Plus" class="input-field w-full">
          </div>
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Thương hiệu</label>
            <input v-model="form.brand" type="text" required placeholder="Ví dụ: VinFast" class="input-field w-full">
          </div>
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Biển số xe</label>
            <input v-model="form.licensePlate" type="text" required placeholder="29A-123.45" class="input-field w-full">
          </div>
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Giá thuê/Ngày (VNĐ)</label>
            <div class="relative">
              <DollarSign class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
              <input v-model.number="form.pricePerDay" type="number" required class="input-field w-full pl-12">
            </div>
          </div>
        </div>
      </div>

      <!-- Specs Card -->
      <div class="bg-white p-8 rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 space-y-8">
        <div class="flex items-center gap-3 border-b border-stitch-outline-variant/10 pb-4">
          <Settings class="w-5 h-5 text-stitch-primary" />
          <h3 class="editorial-headline text-lg">Thông số kỹ thuật</h3>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Số chỗ</label>
            <div class="relative">
              <Users class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
              <select v-model.number="form.seats" class="input-field w-full pl-12 appearance-none">
                <option :value="2">2 chỗ</option>
                <option :value="4">4 chỗ</option>
                <option :value="5">5 chỗ</option>
                <option :value="7">7 chỗ</option>
                <option :value="16">16 chỗ</option>
              </select>
            </div>
          </div>
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Truyền động</label>
            <select v-model="form.transmission" class="input-field w-full appearance-none">
              <option value="Automatic">Số tự động</option>
              <option value="Manual">Số sàn</option>
            </select>
          </div>
          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Nhiên liệu</label>
            <select v-model="form.fuelType" class="input-field w-full appearance-none">
              <option value="Gasoline">Xăng</option>
              <option value="Diesel">Dầu Diesel</option>
              <option value="Electric">Điện</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Action Footer -->
      <div class="flex items-center justify-between pt-4">
        <p v-if="error" class="text-sm text-red-500 font-medium flex items-center gap-2">
          <AlertCircle class="w-4 h-4" />
          {{ error }}
        </p>
        <p v-else-if="success" class="text-sm text-green-500 font-medium flex items-center gap-2">
          <CheckCircle class="w-4 h-4" />
          Lưu thông tin thành công! Đang quay lại danh sách...
        </p>
        <div v-else></div>

        <div class="flex gap-4">
          <BaseButton variant="outline" type="button" @click="router.back()">Hủy bỏ</BaseButton>
          <BaseButton 
            type="submit" 
            variant="primary" 
            class="flex items-center gap-2 !px-8"
            :loading="saving"
          >
            <Save class="w-4 h-4" />
            Lưu thay đổi
          </BaseButton>
        </div>
      </div>
    </form>
  </div>
</template>
