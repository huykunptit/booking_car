<script setup>
import { useToast } from '@/composables/useToast'
import { CheckCircle, AlertCircle, Info, X } from 'lucide-vue-next'

const { toasts, removeToast } = useToast()

const getIcon = (type) => {
  switch (type) {
    case 'success': return CheckCircle
    case 'error': return AlertCircle
    default: return Info
  }
}

const getToastClass = (type) => {
  switch (type) {
    case 'success': return 'bg-green-50 border-green-200 text-green-800'
    case 'error': return 'bg-red-50 border-red-200 text-red-800'
    default: return 'bg-blue-50 border-blue-200 text-blue-800'
  }
}

const getIconClass = (type) => {
  switch (type) {
    case 'success': return 'text-green-500'
    case 'error': return 'text-red-500'
    default: return 'text-blue-500'
  }
}
</script>

<template>
  <div class="fixed top-24 right-6 z-[100] flex flex-col gap-3 pointer-events-none w-full max-w-sm">
    <transition-group name="toast">
      <div
        v-for="toast in toasts"
        :key="toast.id"
        class="pointer-events-auto flex items-start gap-3 p-4 rounded-stitch-lg border shadow-lg backdrop-blur-md"
        :class="getToastClass(toast.type)"
      >
        <component :is="getIcon(toast.type)" class="w-5 h-5 flex-shrink-0 mt-0.5" :class="getIconClass(toast.type)" />
        <p class="text-sm font-bold flex-grow">{{ toast.message }}</p>
        <button @click="removeToast(toast.id)" class="opacity-50 hover:opacity-100 transition-opacity">
          <X class="w-4 h-4" />
        </button>
      </div>
    </transition-group>
  </div>
</template>

<style scoped>
.toast-enter-active,
.toast-leave-active {
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
}
.toast-enter-from {
  opacity: 0;
  transform: translateX(50px) scale(0.9);
}
.toast-leave-to {
  opacity: 0;
  transform: translateY(-20px) scale(0.9);
}
</style>
