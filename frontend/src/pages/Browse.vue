<script setup>
import { ref, onMounted } from 'vue'
import { useCarStore } from '@/store/car'
import CarCard from '@/components/CarCard.vue'
import SearchBar from '@/components/SearchBar.vue'
import { SlidersHorizontal, ChevronDown, Grid, List as ListIcon } from 'lucide-vue-next'

const carStore = useCarStore()
const brands = ['VinFast', 'Toyota', 'Hyundai', 'Tesla', 'Mercedes', 'BMW']
const viewMode = ref('grid')

onMounted(() => {
  carStore.fetchCars()
})

const mockCars = [
  { id: 1, brand: 'VinFast', name: 'VF8 Plus', fuelType: 'Điện', seats: 5, transmission: 'AUTOMATIC', location: 'Hà Nội', pricePerDay: 1200000 },
  { id: 2, brand: 'Toyota', name: 'Vios 2023', fuelType: 'Xăng', seats: 5, transmission: 'AUTOMATIC', location: 'TP. HCM', pricePerDay: 800000 },
  { id: 3, brand: 'Hyundai', name: 'SantaFe', fuelType: 'Dầu', seats: 7, transmission: 'AUTOMATIC', location: 'Đà Nẵng', pricePerDay: 1500000 },
  { id: 4, brand: 'Tesla', name: 'Model 3', fuelType: 'Điện', seats: 5, transmission: 'AUTOMATIC', location: 'Hà Nội', pricePerDay: 2500000 },
  { id: 5, brand: 'Mercedes', name: 'GLC 300', fuelType: 'Xăng', seats: 5, transmission: 'AUTOMATIC', location: 'TP. HCM', pricePerDay: 3500000 },
  { id: 6, brand: 'BMW', name: 'X5', fuelType: 'Xăng', seats: 5, transmission: 'AUTOMATIC', location: 'Hà Nội', pricePerDay: 4000000 },
]
</script>

<template>
  <div class="pt-32 pb-20 px-6 max-w-7xl mx-auto min-h-screen">
    <!-- Header Controls -->
    <div class="flex flex-col md:flex-row justify-between items-center gap-6 mb-12">
      <h1 class="editorial-display text-4xl text-stitch-primary">Khám phá dòng xe</h1>
      <div class="w-full md:w-auto">
        <SearchBar class="!rounded-full shadow-lg !p-2" />
      </div>
    </div>

    <div class="flex flex-col lg:grid lg:grid-cols-12 gap-10">
      <!-- Sidebar Filters -->
      <aside class="lg:col-span-3 space-y-10">
        <!-- Brand Filter -->
        <div>
          <h4 class="font-bold uppercase tracking-widest text-xs mb-6 text-stitch-on-surface-variant">Thương hiệu</h4>
          <div class="space-y-3">
            <label v-for="brand in brands" :key="brand" class="flex items-center gap-3 cursor-pointer group">
              <input type="checkbox" class="w-5 h-5 rounded-stitch-md border-stitch-outline-variant text-stitch-primary focus:ring-stitch-primary/20">
              <span class="text-sm font-medium group-hover:text-stitch-primary transition-colors">{{ brand }}</span>
            </label>
          </div>
        </div>

        <hr class="border-stitch-outline-variant/30">

        <!-- Price Range -->
        <div>
          <h4 class="font-bold uppercase tracking-widest text-xs mb-6 text-stitch-on-surface-variant">Giá thuê (VNĐ)</h4>
          <div class="space-y-4">
            <input type="range" min="0" max="5000000" step="100000" class="w-full h-1.5 bg-stitch-surface-container rounded-lg appearance-none cursor-pointer accent-stitch-primary">
            <div class="flex justify-between text-xs font-bold">
              <span>0đ</span>
              <span>5.000k+</span>
            </div>
          </div>
        </div>

        <hr class="border-stitch-outline-variant/30">

        <!-- Other Filters -->
        <div class="space-y-6">
          <div class="flex justify-between items-center cursor-pointer hover:text-stitch-primary transition-colors">
            <span class="font-bold text-sm">Loại nhiên liệu</span>
            <ChevronDown class="w-4 h-4" />
          </div>
          <div class="flex justify-between items-center cursor-pointer hover:text-stitch-primary transition-colors">
            <span class="font-bold text-sm">Truyền động</span>
            <ChevronDown class="w-4 h-4" />
          </div>
        </div>
      </aside>

      <!-- Main Results -->
      <main class="lg:col-span-9">
        <div class="flex justify-between items-center mb-8 bg-stitch-surface-container-low p-4 rounded-stitch-lg">
          <p class="text-sm font-bold text-stitch-on-surface-variant">
            Tìm thấy <span class="text-stitch-primary">{{ carStore.cars.length || mockCars.length }}</span> kết quả
          </p>
          <div class="flex gap-2">
            <button 
              @click="viewMode = 'grid'" 
              class="p-2 rounded-stitch-md transition-all"
              :class="viewMode === 'grid' ? 'bg-white shadow-sm text-stitch-primary' : 'text-stitch-outline hover:text-stitch-primary'"
            >
              <Grid class="w-5 h-5" />
            </button>
            <button 
              @click="viewMode = 'list'" 
              class="p-2 rounded-stitch-md transition-all"
              :class="viewMode === 'list' ? 'bg-white shadow-sm text-stitch-primary' : 'text-stitch-outline hover:text-stitch-primary'"
            >
              <ListIcon class="w-5 h-5" />
            </button>
          </div>
        </div>

        <div v-if="carStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div v-for="i in 6" :key="i" class="no-line-card !p-0 h-[400px] animate-pulse bg-stitch-surface-container"></div>
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
          <CarCard 
            v-for="car in (carStore.cars.length ? carStore.cars : mockCars)" 
            :key="car.id" 
            :car="car" 
          />
        </div>
      </main>
    </div>
  </div>
</template>
