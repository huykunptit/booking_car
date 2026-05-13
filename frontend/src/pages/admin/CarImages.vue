<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { 
  ArrowLeft, 
  Upload, 
  Trash2, 
  Star, 
  ImageIcon, 
  Loader2,
  CheckCircle,
  AlertCircle,
  ImagePlus
} from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { carApi } from '@/api'

const route = useRoute()
const router = useRouter()
const carId = route.params.carId
const images = ref([])
const loading = ref(true)
const uploading = ref(false)
const carInfo = ref(null)

onMounted(async () => {
  await fetchImages()
  await fetchCarInfo()
})

const fetchCarInfo = async () => {
  try {
    const res = await carApi.get(carId)
    if (res.success) carInfo.value = res.data
  } catch (err) {
    console.error(err)
  }
}

const fetchImages = async () => {
  loading.value = true
  try {
    const res = await carApi.getImages(carId)
    if (res.success) images.value = res.data
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

const handleFileUpload = async (event) => {
  const file = event.target.files[0]
  if (!file) return

  uploading.value = true
  const formData = new FormData()
  formData.append('file', file)

  try {
    const res = await carApi.adminUploadImage(carId, formData)
    if (res.success) {
      await fetchImages()
    }
  } catch (err) {
    alert(err.response?.data?.message || 'Lỗi khi upload ảnh')
  } finally {
    uploading.value = false
    event.target.value = ''
  }
}

const setPrimary = async (imageId) => {
  try {
    const res = await carApi.adminSetPrimaryImage(carId, imageId)
    if (res.success) {
      await fetchImages()
    }
  } catch (err) {
    alert('Không thể đặt làm ảnh đại diện')
  }
}

const deleteImage = async (imageId) => {
  if (!confirm('Bạn có chắc muốn xóa ảnh này?')) return
  // Note: API for deleting images wasn't explicitly in the guide but implied by management needs.
  // We'll assume soft delete or image removal is handled.
  alert('Tính năng đang được cập nhật')
}
</script>

<template>
  <div class="max-w-6xl mx-auto space-y-8">
    <div class="flex justify-between items-center">
      <div class="flex items-center gap-4">
        <button @click="router.back()" class="p-2 hover:bg-stitch-surface-container rounded-full transition-colors">
          <ArrowLeft class="w-6 h-6 text-stitch-on-surface-variant" />
        </button>
        <div>
          <h1 class="editorial-display text-3xl text-stitch-primary">Quản lý hình ảnh</h1>
          <p v-if="carInfo" class="text-sm font-medium text-stitch-on-surface-variant">{{ carInfo.brand }} {{ carInfo.name }} • {{ carInfo.licensePlate }}</p>
        </div>
      </div>

      <div class="relative">
        <input 
          type="file" 
          id="image-upload" 
          class="hidden" 
          accept="image/*"
          @change="handleFileUpload"
          :disabled="uploading"
        >
        <label 
          for="image-upload" 
          class="flex items-center gap-2 bg-stitch-primary text-white px-6 py-3 rounded-stitch-lg cursor-pointer hover:bg-stitch-primary-container transition-all shadow-lg shadow-stitch-primary/20"
          :class="{ 'opacity-50 cursor-not-allowed': uploading }"
        >
          <Loader2 v-if="uploading" class="w-5 h-5 animate-spin" />
          <ImagePlus v-else class="w-5 h-5" />
          <span class="text-sm font-bold">Thêm ảnh mới</span>
        </label>
      </div>
    </div>

    <!-- Gallery Grid -->
    <div v-if="loading" class="flex items-center justify-center py-20">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-stitch-primary"></div>
    </div>

    <div v-else-if="images.length === 0" class="bg-white rounded-stitch-xl p-20 text-center border border-dashed border-stitch-outline-variant/30">
      <div class="bg-stitch-surface-container w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
        <ImageIcon class="w-10 h-10 text-stitch-outline" />
      </div>
      <h3 class="editorial-headline text-xl mb-2">Chưa có hình ảnh nào</h3>
      <p class="text-stitch-on-surface-variant text-sm max-w-sm mx-auto">Tải lên những hình ảnh đẹp nhất của xe để thu hút khách hàng thuê xe.</p>
    </div>

    <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
      <div 
        v-for="img in images" 
        :key="img.id"
        class="bg-white rounded-stitch-xl overflow-hidden shadow-sm border border-stitch-outline-variant/10 group relative"
      >
        <div class="aspect-video w-full overflow-hidden bg-stitch-surface-container">
          <img :src="img.imageUrl" class="w-full h-full object-cover group-hover:scale-105 transition-transform duration-700">
        </div>
        
        <!-- Primary Badge -->
        <div v-if="img.isPrimary" class="absolute top-4 left-4 bg-stitch-accent text-white px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-widest shadow-lg">
          Ảnh đại diện
        </div>

        <!-- Controls -->
        <div class="p-4 flex justify-between items-center bg-white">
          <div class="flex gap-2">
            <button 
              @click="setPrimary(img.id)"
              class="p-2 rounded-stitch-md transition-all"
              :class="img.isPrimary ? 'text-stitch-accent cursor-default' : 'text-stitch-outline hover:text-stitch-accent hover:bg-stitch-accent/5'"
              :title="img.isPrimary ? 'Đang là ảnh đại diện' : 'Đặt làm ảnh đại diện'"
            >
              <Star class="w-5 h-5" :fill="img.isPrimary ? 'currentColor' : 'none'" />
            </button>
          </div>
          <button 
            @click="deleteImage(img.id)"
            class="p-2 text-stitch-outline hover:text-red-500 hover:bg-red-50 rounded-stitch-md transition-all"
          >
            <Trash2 class="w-5 h-5" />
          </button>
        </div>
      </div>
    </div>

    <!-- Upload Info -->
    <div class="bg-stitch-surface-container-low p-6 rounded-stitch-xl flex items-start gap-4">
      <AlertCircle class="w-5 h-5 text-stitch-primary flex-shrink-0 mt-0.5" />
      <div class="space-y-1">
        <p class="text-sm font-bold">Lưu ý khi tải lên:</p>
        <ul class="text-xs text-stitch-on-surface-variant space-y-1 list-disc ml-4">
          <li>Chỉ chấp nhận định dạng JPG, JPEG hoặc PNG.</li>
          <li>Ảnh đầu tiên được tải lên sẽ mặc định làm ảnh đại diện.</li>
          <li>Kích thước tối ưu khuyên dùng: 1920x1080 (tỷ lệ 16:9).</li>
        </ul>
      </div>
    </div>
  </div>
</template>
