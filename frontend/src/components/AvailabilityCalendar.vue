<script setup>
import { ref, computed } from 'vue'
import { ChevronLeft, ChevronRight, Calendar as CalendarIcon } from 'lucide-vue-next'

const props = defineProps({
  bookedDates: {
    type: Array,
    default: () => [] // Format: ['2026-04-20', '2026-04-21']
  }
})

const currentMonth = ref(new Date())

const daysInMonth = computed(() => {
  const year = currentMonth.value.getFullYear()
  const month = currentMonth.value.getMonth()
  const date = new Date(year, month, 1)
  const days = []
  
  // Fill leading empty days
  const firstDay = date.getDay()
  for (let i = 0; i < firstDay; i++) {
    days.push({ day: null })
  }
  
  // Fill actual days
  while (date.getMonth() === month) {
    const dateStr = date.toISOString().split('T')[0]
    days.push({
      day: date.getDate(),
      dateStr,
      isBooked: props.bookedDates.includes(dateStr),
      isToday: new Date().toISOString().split('T')[0] === dateStr
    })
    date.setDate(date.getDate() + 1)
  }
  
  return days
})

const monthYearString = computed(() => {
  return currentMonth.value.toLocaleString('vi-VN', { month: 'long', year: 'numeric' })
})

const changeMonth = (delta) => {
  currentMonth.value = new Date(currentMonth.value.getFullYear(), currentMonth.value.getMonth() + delta, 1)
}
</script>

<template>
  <div class="bg-white rounded-stitch-xl border border-stitch-outline-variant/10 overflow-hidden">
    <div class="p-6 bg-stitch-surface-container-low flex justify-between items-center border-b border-stitch-outline-variant/10">
      <div class="flex items-center gap-3">
        <div class="bg-stitch-primary p-2 rounded-stitch-md text-white">
          <CalendarIcon class="w-4 h-4" />
        </div>
        <h3 class="font-bold text-sm uppercase tracking-widest text-stitch-primary">{{ monthYearString }}</h3>
      </div>
      <div class="flex gap-2">
        <button @click="changeMonth(-1)" class="p-2 hover:bg-white rounded-full transition-colors">
          <ChevronLeft class="w-4 h-4" />
        </button>
        <button @click="changeMonth(1)" class="p-2 hover:bg-white rounded-full transition-colors">
          <ChevronRight class="w-4 h-4" />
        </button>
      </div>
    </div>

    <div class="p-6">
      <div class="grid grid-cols-7 mb-4">
        <div v-for="d in ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7']" :key="d" class="text-center text-[10px] font-bold text-stitch-outline uppercase tracking-widest">
          {{ d }}
        </div>
      </div>

      <div class="grid grid-cols-7 gap-1">
        <div v-for="(dayObj, idx) in daysInMonth" :key="idx" class="aspect-square flex items-center justify-center relative">
          <template v-if="dayObj.day">
            <!-- Background for Booked -->
            <div 
              v-if="dayObj.isBooked" 
              class="absolute inset-0.5 bg-red-50 rounded-stitch-md flex items-center justify-center"
            >
              <div class="w-1.5 h-1.5 bg-red-400 rounded-full absolute top-1 right-1"></div>
            </div>

            <span 
              class="relative z-10 text-xs font-bold transition-colors"
              :class="[
                dayObj.isBooked ? 'text-red-600' : 'text-stitch-on-surface',
                dayObj.isToday ? 'text-stitch-accent underline underline-offset-4 decoration-2' : ''
              ]"
            >
              {{ dayObj.day }}
            </span>
          </template>
        </div>
      </div>

      <!-- Legend -->
      <div class="mt-8 pt-6 border-t border-stitch-outline-variant/10 flex gap-6">
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 bg-red-100 rounded-sm"></div>
          <span class="text-[10px] font-bold text-stitch-on-surface-variant uppercase tracking-tight">Đã có người đặt</span>
        </div>
        <div class="flex items-center gap-2">
          <div class="w-3 h-3 bg-stitch-surface-container rounded-sm"></div>
          <span class="text-[10px] font-bold text-stitch-on-surface-variant uppercase tracking-tight">Còn trống</span>
        </div>
      </div>
    </div>
  </div>
</template>
