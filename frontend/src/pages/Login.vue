<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { Mail, Lock, ArrowRight, Chrome, Github, ChevronLeft } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { authApi } from '@/api'
import { useToast } from '@/composables/useToast'

const router = useRouter()
const { showToast } = useToast()
const phone = ref('')
const password = ref('')
const loading = ref(false)
const error = ref('')

const handleLogin = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await authApi.login({ phone: phone.value, password: password.value })
    if (res.success) {
      localStorage.setItem('token', res.data.token)
      localStorage.setItem('refreshToken', res.data.refreshToken)
      localStorage.setItem('user', JSON.stringify(res.data))
      showToast('Đăng nhập thành công', 'success')
      router.push('/')
    } else {
      error.value = res.message || 'Số điện thoại hoặc mật khẩu không chính xác'
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Không thể kết nối đến máy chủ'
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-white flex">
    <!-- Left Side: Cinematic Image (Hidden on Mobile) -->
    <div class="hidden lg:block w-1/2 relative overflow-hidden bg-stitch-primary">
      <img 
        src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&q=80&w=1600" 
        class="absolute inset-0 w-full h-full object-cover mix-blend-overlay opacity-60 scale-105 animate-slow-zoom"
        alt="Porsche Interior"
      >
      <div class="absolute inset-0 bg-gradient-to-t from-stitch-primary via-transparent to-transparent"></div>
      
      <div class="absolute bottom-20 left-20 right-20 space-y-6">
        <div class="bg-white/10 backdrop-blur-md p-6 rounded-stitch-xl border border-white/20 inline-block">
          <h2 class="editorial-display text-5xl text-white leading-tight">
            Chuyến hành trình<br>bắt đầu từ đây.
          </h2>
        </div>
        <p class="text-white/80 text-lg max-w-md font-medium leading-relaxed">
          Đăng nhập để truy cập vào những mẫu xe cao cấp nhất và quản lý các chuyến đi của bạn một cách dễ dàng.
        </p>
      </div>

      <router-link to="/" class="absolute top-10 left-10 flex items-center gap-2 text-white/80 hover:text-white transition-colors group">
        <ChevronLeft class="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
        <span class="text-sm font-bold uppercase tracking-widest">Quay lại trang chủ</span>
      </router-link>
    </div>

    <!-- Right Side: Login Form -->
    <div class="w-full lg:w-1/2 flex items-center justify-center p-8 md:p-16 lg:p-24 bg-stitch-surface-container-lowest">
      <div class="max-w-md w-full space-y-10 animate-fade-up">
        <div class="space-y-4">
          <h1 class="editorial-display text-4xl text-stitch-primary">Đăng nhập</h1>
          <p class="text-stitch-on-surface-variant font-medium">Vui lòng nhập thông tin tài khoản của bạn.</p>
        </div>

        <form @submit.prevent="handleLogin" class="space-y-6">
          <div v-if="error" class="bg-red-50 text-red-600 p-4 rounded-stitch-md text-xs font-bold border border-red-100 flex items-center gap-3">
            <div class="w-1.5 h-1.5 bg-red-600 rounded-full"></div>
            {{ error }}
          </div>

          <div class="space-y-2">
            <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Số điện thoại</label>
            <div class="relative group">
              <Mail class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
              <input 
                v-model="phone"
                type="text" 
                required
                placeholder="0912345678"
                class="input-field w-full pl-12 focus:ring-stitch-primary/10"
              >
            </div>
          </div>

          <div class="space-y-2">
            <div class="flex justify-between items-center px-1">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant">Mật khẩu</label>
              <router-link to="/auth/forgot-password" class="text-[10px] font-bold uppercase tracking-widest text-stitch-primary hover:underline">
                Quên mật khẩu?
              </router-link>
            </div>
            <div class="relative group">
              <Lock class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
              <input 
                v-model="password"
                type="password" 
                required
                placeholder="••••••••"
                class="input-field w-full pl-12 focus:ring-stitch-primary/10"
              >
            </div>
          </div>

          <BaseButton 
            type="submit" 
            variant="primary" 
            class="w-full !py-4 shadow-xl shadow-stitch-primary/10 flex items-center justify-center gap-2"
            :loading="loading"
          >
            Đăng nhập ngay
            <ArrowRight class="w-4 h-4" />
          </BaseButton>
        </form>

        <div class="relative py-4 flex items-center">
          <div class="flex-grow border-t border-stitch-outline-variant/30"></div>
          <span class="flex-shrink mx-4 text-[10px] font-bold text-stitch-outline uppercase tracking-widest">Hoặc đăng nhập với</span>
          <div class="flex-grow border-t border-stitch-outline-variant/30"></div>
        </div>

        <div class="grid grid-cols-2 gap-4">
          <button class="flex items-center justify-center gap-3 p-4 border border-stitch-outline-variant/30 rounded-stitch-lg hover:bg-white hover:shadow-md transition-all font-bold text-xs uppercase tracking-wider">
            <Chrome class="w-4 h-4" />
            Google
          </button>
          <button class="flex items-center justify-center gap-3 p-4 border border-stitch-outline-variant/30 rounded-stitch-lg hover:bg-white hover:shadow-md transition-all font-bold text-xs uppercase tracking-wider">
            <Github class="w-4 h-4" />
            Github
          </button>
        </div>

        <p class="text-center text-sm text-stitch-on-surface-variant font-medium pt-4">
          Chưa có tài khoản? 
          <router-link to="/auth/register" class="text-stitch-primary font-bold hover:underline ml-1">Đăng ký ngay</router-link>
        </p>
      </div>
    </div>
  </div>
</template>

<style scoped>
@keyframes slow-zoom {
  from { transform: scale(1); }
  to { transform: scale(1.1); }
}
.animate-slow-zoom {
  animation: slow-zoom 20s infinite alternate ease-in-out;
}
</style>
