<script setup>
import { Fuel, ShieldCheck, MapPin, Star, Zap, Map, CreditCard } from 'lucide-vue-next'
import BaseButton from './BaseButton.vue'
import { useRouter } from 'vue-router'

const props = defineProps({
  car: {
    type: Object,
    required: true
  }
})

const router = useRouter()

const navigateToDetail = () => {
  router.push(`/car/${props.car.id}`)
}
</script>

<template>
  <div 
    class="no-line-card overflow-hidden !p-0 group cursor-pointer hover:shadow-2xl transition-all duration-500 rounded-stitch-2xl border border-stitch-outline-variant/10 bg-white"
    @click="navigateToDetail"
  >
    <!-- Image Area -->
    <div class="aspect-[16/10] bg-gray-100 relative overflow-hidden">
      <img 
        :src="car.primaryImage || car.images?.[0] || 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?auto=format&fit=crop&q=80&w=800'" 
        :alt="car.name" 
        class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
      >
      
      <!-- Feature Badges -->
      <div class="absolute top-3 left-3 flex flex-col gap-1.5">
        <div class="bg-stitch-primary text-white px-2.5 py-1 rounded-full text-[9px] font-black uppercase tracking-wider flex items-center gap-1 shadow-lg">
          <Zap class="w-3 h-3 fill-white" /> ĐẶT NHANH
        </div>
        <div v-if="car.delivery" class="bg-amber-400 text-white px-2.5 py-1 rounded-full text-[9px] font-black uppercase tracking-wider flex items-center gap-1 shadow-lg">
          <Map class="w-3 h-3" /> GIAO TẬN NƠI
        </div>
      </div>

      <div class="absolute top-3 right-3 bg-white/90 backdrop-blur-md px-3 py-1 rounded-full text-[10px] font-bold shadow-sm uppercase tracking-wider text-stitch-primary">
        {{ car.transmission === 'AUTOMATIC' ? 'Tự động' : 'Số sàn' }}
      </div>
      
      <!-- Price Badge -->
      <div class="absolute bottom-3 left-3 glass-effect text-white px-4 py-2 rounded-stitch-xl shadow-lg border border-white/20">
        <div class="flex items-baseline gap-0.5">
          <span class="font-bold text-lg tracking-tighter">{{ Math.floor(car.pricePerDay / 1000) }}k</span>
          <span class="text-[10px] font-medium opacity-80 uppercase">/ ngày</span>
        </div>
      </div>
    </div>

    <!-- Content Area -->
    <div class="p-6">
      <div class="flex justify-between items-start mb-4">
        <div>
          <h3 class="editorial-headline text-lg font-bold text-stitch-on-surface truncate pr-2 group-hover:text-stitch-primary transition-colors">
            {{ car.brand }} {{ car.name }}
          </h3>
          <div class="flex items-center gap-1.5 text-stitch-on-surface-variant text-[11px] mt-1">
            <MapPin class="w-3.5 h-3.5 text-stitch-primary" />
            <span class="font-medium">{{ car.location }}</span>
          </div>
        </div>
        <div class="flex flex-col items-end">
          <div v-if="car.averageRating > 0" class="flex items-center gap-1 text-[11px] font-black text-stitch-on-surface">
            <Star class="w-4 h-4 text-amber-400 fill-amber-400" />
            <span>{{ car.averageRating.toFixed(1) }}</span>
          </div>
          <div class="text-[9px] font-bold text-stitch-outline uppercase tracking-widest mt-0.5">
            {{ car.reviewCount || 0 }} chuyến
          </div>
        </div>
      </div>

      <!-- Quick Specs -->
      <div class="grid grid-cols-2 gap-3 mb-6">
        <div class="flex items-center gap-2 text-stitch-on-surface-variant text-[11px] bg-stitch-surface-container-low px-3 py-1.5 rounded-full">
          <Fuel class="w-3.5 h-3.5 text-stitch-primary" />
          <span class="font-bold">{{ car.fuelType }}</span>
        </div>
        <div class="flex items-center gap-2 text-stitch-on-surface-variant text-[11px] bg-stitch-surface-container-low px-3 py-1.5 rounded-full">
          <CreditCard class="w-3.5 h-3.5 text-stitch-primary" />
          <span class="font-bold">MIỄN THẾ CHẤP</span>
        </div>
      </div>

      <div class="pt-4 border-t border-stitch-outline-variant/10">
        <BaseButton variant="primary" class="w-full !py-3 text-xs font-black uppercase tracking-widest group-hover:scale-[1.02] active:scale-95 transition-transform">
          Thuê ngay
        </BaseButton>
      </div>
    </div>
  </div>
</template>
