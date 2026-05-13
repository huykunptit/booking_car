<script setup>
import { ref } from 'vue'
import { Plus, Search, Filter, MoreHorizontal, Edit, Trash2, Image as ImageIcon } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'

const cars = ref([
  { id: 1, brand: 'VinFast', name: 'VF8 Plus', status: 'AVAILABLE', price: 1200000, location: 'Hà Nội', image: 'https://images.unsplash.com/photo-1617788138017-80ad40651399?w=100' },
  { id: 2, brand: 'Toyota', name: 'Vios 2023', status: 'BOOKED', price: 800000, location: 'TP. HCM', image: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=100' },
  { id: 3, brand: 'Hyundai', name: 'SantaFe', status: 'MAINTENANCE', price: 1500000, location: 'Đà Nẵng', image: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=100' },
])

const getStatusClass = (status) => {
  switch (status) {
    case 'AVAILABLE': return 'bg-green-100 text-green-700'
    case 'BOOKED': return 'bg-blue-100 text-blue-700'
    case 'MAINTENANCE': return 'bg-amber-100 text-amber-700'
    case 'PENDING': return 'bg-purple-100 text-purple-700'
    default: return 'bg-gray-100 text-gray-700'
  }
}
</script>

<template>
  <div class="space-y-8">
    <div class="flex justify-between items-center">
      <div class="space-y-1">
        <h1 class="editorial-display text-3xl text-stitch-primary">Quản lý xe</h1>
        <p class="text-stitch-on-surface-variant text-sm font-medium">Danh sách toàn bộ xe trong hệ thống của bạn.</p>
      </div>
      <router-link to="/admin/cars/new">
        <BaseButton variant="primary" class="flex items-center gap-2">
          <Plus class="w-5 h-5" />
          Thêm xe mới
        </BaseButton>
      </router-link>
    </div>

    <!-- Stats -->
    <div class="grid grid-cols-1 md:grid-cols-4 gap-6">
      <div v-for="i in 4" :key="i" class="bg-white p-6 rounded-stitch-lg shadow-sm border border-stitch-outline-variant/10">
        <p class="text-xs font-bold uppercase tracking-widest text-stitch-on-surface-variant mb-2">Tổng số xe</p>
        <div class="flex justify-between items-end">
          <span class="editorial-display text-3xl text-stitch-primary">124</span>
          <span class="text-xs text-green-500 font-bold">+12%</span>
        </div>
      </div>
    </div>

    <!-- Table Section -->
    <div class="bg-white rounded-stitch-xl shadow-stitch-ambient overflow-hidden border border-stitch-outline-variant/10">
      <div class="p-6 border-b border-stitch-outline-variant/10 flex justify-between items-center bg-stitch-surface-container-lowest">
        <div class="relative">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
          <input type="text" placeholder="Tìm theo tên xe, thương hiệu..." class="bg-stitch-surface-container border-none rounded-stitch-md px-10 py-2 text-sm w-80 outline-none focus:ring-2 focus:ring-stitch-primary/10">
        </div>
        <button class="flex items-center gap-2 text-sm font-bold text-stitch-on-surface-variant hover:text-stitch-primary transition-colors">
          <Filter class="w-4 h-4" />
          Lọc nâng cao
        </button>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-stitch-surface-container-low">
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Xe</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Thông tin</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Trạng thái</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Giá/Ngày</th>
              <th class="p-6 text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant"></th>
            </tr>
          </thead>
          <tbody class="divide-y divide-stitch-outline-variant/10">
            <tr v-for="car in cars" :key="car.id" class="hover:bg-stitch-surface-container-lowest transition-colors group">
              <td class="p-6">
                <div class="flex items-center gap-4">
                  <div class="w-16 h-12 rounded-stitch-md overflow-hidden bg-stitch-surface-container flex-shrink-0">
                    <img :src="car.image" class="w-full h-full object-cover">
                  </div>
                  <div>
                    <p class="font-bold text-sm">{{ car.brand }}</p>
                    <p class="text-xs text-stitch-on-surface-variant">{{ car.name }}</p>
                  </div>
                </div>
              </td>
              <td class="p-6">
                <p class="text-sm font-medium">{{ car.location }}</p>
                <p class="text-xs text-stitch-on-surface-variant">ID: #CAR-00{{ car.id }}</p>
              </td>
              <td class="p-6">
                <span class="px-3 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider" :class="getStatusClass(car.status)">
                  {{ car.status }}
                </span>
              </td>
              <td class="p-6">
                <p class="font-bold text-sm text-stitch-primary">{{ car.price.toLocaleString() }}đ</p>
              </td>
              <td class="p-6">
                <div class="flex justify-end gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                  <router-link :to="`/admin/cars/${car.id}/images`" class="p-2 hover:bg-stitch-surface-container rounded-stitch-md text-stitch-on-surface-variant transition-colors">
                    <ImageIcon class="w-4 h-4" />
                  </router-link>
                  <router-link :to="`/admin/cars/edit/${car.id}`" class="p-2 hover:bg-stitch-surface-container rounded-stitch-md text-stitch-on-surface-variant transition-colors">
                    <Edit class="w-4 h-4" />
                  </router-link>
                  <button class="p-2 hover:bg-red-50 rounded-stitch-md text-red-500 transition-colors">
                    <Trash2 class="w-4 h-4" />
                  </button>
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <div class="p-6 bg-stitch-surface-container-low border-t border-stitch-outline-variant/10 flex justify-between items-center">
        <span class="text-xs font-medium text-stitch-on-surface-variant">Hiển thị 1-10 trong số 124 xe</span>
        <div class="flex gap-2">
          <button class="p-2 bg-white border border-stitch-outline-variant/30 rounded-stitch-md hover:bg-stitch-surface-container transition-colors disabled:opacity-50" disabled>
            <ChevronLeft class="w-4 h-4" />
          </button>
          <button class="p-2 bg-white border border-stitch-outline-variant/30 rounded-stitch-md hover:bg-stitch-surface-container transition-colors">
            <ChevronLeft class="w-4 h-4 rotate-180" />
          </button>
        </div>
      </div>
    </div>
  </div>
</template>
