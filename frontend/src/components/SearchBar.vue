<script setup>
import { ref } from 'vue'
import { Search, MapPin, Calendar, Clock, Car, UserCheck } from 'lucide-vue-next'
import MapPickerModal from './MapPickerModal.vue'

const isMapModalOpen = ref(false)
const selectedLocation = ref({ name: '', address: '' })
const activeTab = ref('self-drive') // 'self-drive' or 'with-driver'

const handleLocationSelect = (loc) => {
  selectedLocation.value = loc
}

const pickupDate = ref('')
const returnDate = ref('')
const pickupTime = ref('09:00')
const returnTime = ref('20:00')
</script>

<template>
  <div class="flex flex-col gap-4">
    <!-- Service Tabs -->
    <div class="flex gap-2 p-1 bg-white/20 backdrop-blur-md rounded-full w-fit mx-auto border border-white/30">
      <button 
        @click="activeTab = 'self-drive'"
        :class="[
          'flex items-center gap-2 px-6 py-2 rounded-full text-xs font-bold transition-all duration-300',
          activeTab === 'self-drive' ? 'bg-white text-stitch-primary shadow-lg' : 'text-white hover:bg-white/10'
        ]"
      >
        <Car class="w-4 h-4" />
        XE TỰ LÁI
      </button>
      <button 
        @click="activeTab = 'with-driver'"
        :class="[
          'flex items-center gap-2 px-6 py-2 rounded-full text-xs font-bold transition-all duration-300',
          activeTab === 'with-driver' ? 'bg-white text-stitch-primary shadow-lg' : 'text-white hover:bg-white/10'
        ]"
      >
        <UserCheck class="w-4 h-4" />
        XE CÓ TÀI XẾ
      </button>
    </div>

    <!-- Search Main Card -->
    <div class="no-line-card !p-2 flex flex-col md:flex-row items-stretch bg-white shadow-2xl rounded-stitch-2xl border border-stitch-outline-variant/20 overflow-hidden">
      <!-- Location Section -->
      <div 
        class="flex-[1.5] flex items-center gap-4 px-6 py-4 border-b md:border-b-0 md:border-r border-stitch-outline-variant/30 cursor-pointer hover:bg-stitch-surface-container-low transition-colors group"
        @click="isMapModalOpen = true"
      >
        <div class="bg-stitch-primary/10 p-3 rounded-stitch-lg group-hover:bg-stitch-primary group-hover:text-white transition-all">
          <MapPin class="w-5 h-5" />
        </div>
        <div class="flex flex-col">
          <span class="text-[10px] font-bold text-stitch-on-surface-variant uppercase tracking-widest mb-1">Địa điểm</span>
          <span v-if="selectedLocation.name" class="text-sm font-bold text-stitch-primary">{{ selectedLocation.name }}</span>
          <span v-else class="text-sm font-medium text-stitch-outline">Bạn muốn đi đâu?</span>
        </div>
      </div>

      <!-- Time Section -->
      <div class="flex-[2] flex flex-col md:flex-row divide-y md:divide-y-0 md:divide-x divide-stitch-outline-variant/30">
        <!-- Pickup -->
        <div class="flex-1 flex items-center gap-4 px-6 py-4 hover:bg-stitch-surface-container-low transition-colors group relative">
          <Calendar class="w-5 h-5 text-stitch-primary group-hover:scale-110 transition-transform" />
          <div class="flex flex-col flex-1">
            <span class="text-[10px] font-bold text-stitch-on-surface-variant uppercase tracking-widest mb-1">Bắt đầu</span>
            <div class="flex items-center gap-2">
              <input type="date" v-model="pickupDate" class="text-sm font-bold bg-transparent outline-none cursor-pointer w-24">
              <span class="text-stitch-outline">|</span>
              <select v-model="pickupTime" class="text-sm font-bold bg-transparent outline-none cursor-pointer">
                <option v-for="h in 24" :key="h" :value="`${(h-1).toString().padStart(2,'0')}:00`">{{ (h-1).toString().padStart(2,'0') }}:00</option>
              </select>
            </div>
          </div>
        </div>

        <!-- Return -->
        <div class="flex-1 flex items-center gap-4 px-6 py-4 hover:bg-stitch-surface-container-low transition-colors group">
          <Calendar class="w-5 h-5 text-stitch-primary group-hover:scale-110 transition-transform" />
          <div class="flex flex-col flex-1">
            <span class="text-[10px] font-bold text-stitch-on-surface-variant uppercase tracking-widest mb-1">Kết thúc</span>
            <div class="flex items-center gap-2">
              <input type="date" v-model="returnDate" class="text-sm font-bold bg-transparent outline-none cursor-pointer w-24">
              <span class="text-stitch-outline">|</span>
              <select v-model="returnTime" class="text-sm font-bold bg-transparent outline-none cursor-pointer">
                <option v-for="h in 24" :key="h" :value="`${(h-1).toString().padStart(2,'0')}:00`">{{ (h-1).toString().padStart(2,'0') }}:00</option>
              </select>
            </div>
          </div>
        </div>
      </div>

      <!-- Search Button -->
      <div class="p-2 flex items-center">
        <button class="w-full md:w-16 h-16 bg-stitch-primary text-white rounded-stitch-xl hover:bg-stitch-primary-container transition-all flex items-center justify-center shadow-xl shadow-stitch-primary/30 group">
          <Search class="w-6 h-6 group-hover:scale-110 transition-transform" />
        </button>
      </div>
    </div>
  </div>

  <!-- Map Modal -->
  <MapPickerModal 
    :is-open="isMapModalOpen" 
    @close="isMapModalOpen = false" 
    @select="handleLocationSelect"
  />
</template>
