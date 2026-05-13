<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { KeyRound, Lock, CheckCircle, ArrowLeft } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { authApi } from '@/api'

const router = useRouter()
const route = useRoute()
const email = ref(route.query.email || '')
const otp = ref('')
const newPassword = ref('')
const confirmPassword = ref('')
const loading = ref(false)
const success = ref(false)
const error = ref('')

const handleSubmit = async () => {
  if (newPassword.value !== confirmPassword.value) {
    error.value = 'Mật khẩu xác nhận không khớp'
    return
  }

  loading.value = true
  error.value = ''
  try {
    const res = await authApi.resetPassword({
      email: email.value,
      otp: otp.value,
      newPassword: newPassword.value,
      confirmPassword: confirmPassword.value
    })
    if (res.success) {
      success.value = true
    } else {
      error.value = res.message || 'Có lỗi xảy ra'
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Mã OTP không hợp lệ hoặc đã hết hạn'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-stitch-surface-container-lowest flex items-center justify-center p-6">
    <div class="max-w-md w-full">
      <div class="bg-white p-10 rounded-stitch-xl shadow-stitch-ambient border border-stitch-outline-variant/10">
        <div v-if="!success">
          <h1 class="editorial-display text-3xl mb-4">Đặt lại mật khẩu</h1>
          <p class="text-stitch-on-surface-variant text-sm mb-8 leading-relaxed">
            Vui lòng nhập mã OTP đã nhận và mật khẩu mới của bạn.
          </p>

          <form @submit.prevent="handleSubmit" class="space-y-6">
            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Mã xác thực (OTP)</label>
              <div class="relative">
                <KeyRound class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
                <input 
                  v-model="otp"
                  type="text" 
                  required
                  placeholder="123456"
                  class="w-full bg-stitch-surface-container-highest border-none rounded-stitch-md pl-12 pr-4 py-4 focus:ring-2 focus:ring-stitch-primary/20 outline-none transition-all tracking-[0.5em] text-center font-bold"
                >
              </div>
            </div>

            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Mật khẩu mới</label>
              <div class="relative">
                <Lock class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
                <input 
                  v-model="newPassword"
                  type="password" 
                  required
                  placeholder="••••••••"
                  class="w-full bg-stitch-surface-container-highest border-none rounded-stitch-md pl-12 pr-4 py-4 focus:ring-2 focus:ring-stitch-primary/20 outline-none transition-all"
                >
              </div>
            </div>

            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Xác nhận mật khẩu</label>
              <div class="relative">
                <Lock class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
                <input 
                  v-model="confirmPassword"
                  type="password" 
                  required
                  placeholder="••••••••"
                  class="w-full bg-stitch-surface-container-highest border-none rounded-stitch-md pl-12 pr-4 py-4 focus:ring-2 focus:ring-stitch-primary/20 outline-none transition-all"
                >
              </div>
              <p v-if="error" class="text-xs text-red-500 font-medium ml-1">{{ error }}</p>
            </div>

            <BaseButton 
              type="submit" 
              variant="primary" 
              class="w-full !py-4"
              :loading="loading"
            >
              Đặt lại mật khẩu
            </BaseButton>
          </form>
        </div>

        <div v-else class="text-center">
          <div class="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle class="w-8 h-8" />
          </div>
          <h2 class="editorial-display text-2xl mb-4">Thành công!</h2>
          <p class="text-stitch-on-surface-variant text-sm mb-8 leading-relaxed">
            Mật khẩu của bạn đã được thay đổi thành công. Bây giờ bạn có thể đăng nhập bằng mật khẩu mới.
          </p>
          <BaseButton 
            variant="primary" 
            class="w-full" 
            @click="router.push('/auth/login')"
          >
            Đăng nhập ngay
          </BaseButton>
        </div>
      </div>
    </div>
  </div>
</template>
