<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Mail, ArrowLeft, Loader2, CheckCircle } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { authApi } from '@/api'

const router = useRouter()
const email = ref('')
const loading = ref(false)
const success = ref(false)
const error = ref('')

const handleSubmit = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await authApi.forgotPassword(email.value)
    if (res.success) {
      success.value = true
    } else {
      error.value = res.message || 'Có lỗi xảy ra'
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Không thể gửi yêu cầu'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-stitch-surface-container-lowest flex items-center justify-center p-6">
    <div class="max-w-md w-full">
      <router-link to="/auth/login" class="inline-flex items-center gap-2 text-stitch-on-surface-variant hover:text-stitch-primary mb-8 transition-colors group">
        <ArrowLeft class="w-4 h-4 group-hover:-translate-x-1 transition-transform" />
        <span class="text-sm font-bold">Quay lại đăng nhập</span>
      </router-link>

      <div class="bg-white p-10 rounded-stitch-xl shadow-stitch-ambient border border-stitch-outline-variant/10">
        <div v-if="!success">
          <h1 class="editorial-display text-3xl mb-4">Quên mật khẩu?</h1>
          <p class="text-stitch-on-surface-variant text-sm mb-8 leading-relaxed">
            Nhập email của bạn và chúng tôi sẽ gửi mã OTP để đặt lại mật khẩu.
          </p>

          <form @submit.prevent="handleSubmit" class="space-y-6">
            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Email</label>
              <div class="relative">
                <Mail class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
                <input 
                  v-model="email"
                  type="email" 
                  required
                  placeholder="name@example.com"
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
              Gửi mã OTP
            </BaseButton>
          </form>
        </div>

        <div v-else class="text-center">
          <div class="w-16 h-16 bg-green-100 text-green-600 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle class="w-8 h-8" />
          </div>
          <h2 class="editorial-display text-2xl mb-4">Kiểm tra email của bạn</h2>
          <p class="text-stitch-on-surface-variant text-sm mb-8 leading-relaxed">
            Chúng tôi đã gửi mã xác thực đến <b>{{ email }}</b>. Vui lòng kiểm tra hộp thư.
          </p>
          <BaseButton 
            variant="primary" 
            class="w-full" 
            @click="router.push({ name: 'ResetPassword', query: { email } })"
          >
            Nhập mã OTP
          </BaseButton>
        </div>
      </div>
    </div>
  </div>
</template>
