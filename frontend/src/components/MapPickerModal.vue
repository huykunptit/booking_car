<script setup>
import { ref, onMounted } from 'vue'
import { MapPin, Search, X, Navigation, LocateFixed } from 'lucide-vue-next'
import BaseButton from './BaseButton.vue'

const props = defineProps({
  isOpen: Boolean
})

const emit = defineEmits(['close', 'select'])

const searchQuery = ref('')
const popularLocations = [
  { name: 'Hà Nội', address: 'Thủ đô Hà Nội, Việt Nam' },
  { name: 'TP. Hồ Chí Minh', address: 'Quận 1, TP. Hồ Chí Minh' },
  { name: 'Đà Nẵng', address: 'Quận Hải Châu, Đà Nẵng' },
  { name: 'Nha Trang', address: 'Khánh Hòa, Việt Nam' },
  { name: 'Phú Quốc', address: 'Kiên Giang, Việt Nam' },
]

const selectLocation = (loc) => {
  emit('select', loc)
  emit('close')
}
</script>

<template>
  <transition name="fade">
    <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center p-4 md:p-10 bg-stitch-primary/40 backdrop-blur-md">
      <div class="bg-white w-full max-w-5xl h-[80vh] rounded-stitch-xl shadow-2xl flex flex-col md:flex-row overflow-hidden animate-fade-up">
        
        <!-- Sidebar Selection -->
        <div class="w-full md:w-80 border-r border-stitch-outline-variant/20 p-6 flex flex-col bg-stitch-surface-container-low">
          <div class="flex justify-between items-center mb-8">
            <h3 class="editorial-headline text-xl">Chọn địa điểm</h3>
            <button @click="emit('close')" class="md:hidden p-2"><X class="w-6 h-6" /></button>
          </div>

          <div class="relative mb-6">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
            <input 
              v-model="searchQuery"
              type="text" 
              placeholder="Tìm địa điểm..." 
              class="w-full bg-white border border-stitch-outline-variant/30 rounded-stitch-md pl-10 pr-4 py-3 text-sm focus:ring-2 focus:ring-stitch-primary/10 transition-all outline-none"
            >
          </div>

          <div class="flex-grow overflow-y-auto space-y-2">
            <p class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-4">Địa điểm phổ biến</p>
            <button 
              v-for="loc in popularLocations" 
              :key="loc.name"
              @click="selectLocation(loc)"
              class="w-full flex items-start gap-3 p-3 rounded-stitch-lg hover:bg-white hover:shadow-sm transition-all group text-left"
            >
              <div class="bg-stitch-surface-container p-2 rounded-full group-hover:bg-stitch-primary group-hover:text-white transition-colors">
                <MapPin class="w-4 h-4" />
              </div>
              <div>
                <p class="text-sm font-bold">{{ loc.name }}</p>
                <p class="text-[10px] text-stitch-on-surface-variant line-clamp-1">{{ loc.address }}</p>
              </div>
            </button>
          </div>

          <div class="pt-6 border-t border-stitch-outline-variant/10">
            <BaseButton variant="outline" class="w-full flex items-center justify-center gap-2">
              <LocateFixed class="w-4 h-4" />
              Vị trí hiện tại
            </BaseButton>
          </div>
        </div>

        <!-- Map Area -->
        <div class="flex-grow relative bg-stitch-surface-container overflow-hidden">
          <!-- Placeholder for Real Map (Google Maps / Mapbox / Goong) -->
          <div class="absolute inset-0 flex flex-col items-center justify-center text-center p-10">
            <div class="w-20 h-20 bg-stitch-primary/5 rounded-full flex items-center justify-center mb-6 animate-pulse">
              <Navigation class="w-10 h-10 text-stitch-primary" />
            </div>
            <h4 class="editorial-headline text-xl mb-4">Bản đồ tương tác</h4>
            <p class="text-stitch-on-surface-variant text-sm max-w-sm mb-8 leading-relaxed">
              Tích hợp <b>Goong Maps</b> hoặc <b>Mapbox</b> để cung cấp trải nghiệm chọn vị trí trực quan trên bản đồ Việt Nam.
            </p>
            <div class="bg-white p-4 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/20 max-w-xs text-left">
              <p class="text-[10px] font-bold text-stitch-primary uppercase tracking-widest mb-1">Gợi ý cho bạn</p>
              <p class="text-xs text-stitch-on-surface-variant">Sử dụng API của Goong.io để tối ưu hóa địa chỉ tại Việt Nam.</p>
            </div>
          </div>

          <!-- Close button (Desktop) -->
          <button @click="emit('close')" class="absolute top-6 right-6 hidden md:flex p-3 bg-white/80 backdrop-blur-md rounded-full shadow-lg hover:bg-white transition-all text-stitch-primary">
            <X class="w-6 h-6" />
          </button>
        </div>
      </div>
    </div>
  </transition>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.4s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
