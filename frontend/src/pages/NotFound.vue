<script setup>
import { useRouter } from 'vue-router'
import { Home, ArrowLeft } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'

const router = useRouter()
</script>

<template>
  <div class="min-h-screen flex items-center justify-center px-6">
    <div class="text-center max-w-md">
      <h1 class="editorial-display text-[120px] text-stitch-primary leading-none mb-4">404</h1>
      <h2 class="editorial-headline text-2xl mb-4">Trang không tồn tại</h2>
      <p class="text-stitch-on-surface-variant text-sm mb-10 leading-relaxed">
        Xin lỗi, trang bạn đang tìm kiếm không tồn tại hoặc đã bị di chuyển.
      </p>
      <div class="flex gap-4 justify-center">
        <BaseButton variant="outline" @click="router.back()">
          <ArrowLeft class="w-4 h-4 mr-2" /> Quay lại
        </BaseButton>
        <BaseButton variant="primary" @click="router.push('/')">
          <Home class="w-4 h-4 mr-2" /> Trang chủ
        </BaseButton>
      </div>
    </div>
  </div>
</template>
