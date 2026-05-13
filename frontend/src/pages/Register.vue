<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { User, Mail, Phone, Lock, FileText, ArrowRight, ChevronLeft } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { authApi } from '@/api'
import { useToast } from '@/composables/useToast'

const router = useRouter()
const { showToast } = useToast()
const loading = ref(false)
const error = ref('')

const form = ref({
  name: '',
  email: '',
  password: '',
  phone: '',
  driveLicense: '',
  role: 'USER'
})

const handleRegister = async () => {
  loading.value = true
  error.value = ''
  try {
    const res = await authApi.register(form.value)
    if (res.success) {
      localStorage.setItem('token', res.data.token)
      localStorage.setItem('refreshToken', res.data.refreshToken)
      localStorage.setItem('user', JSON.stringify(res.data))
      showToast('Đăng ký thành công', 'success')
      router.push('/')
    } else {
      error.value = res.message || 'Đăng ký thất bại'
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Có lỗi xảy ra khi đăng ký'
    showToast(error.value, 'error')
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="min-h-screen bg-white flex">
    <!-- Left Side: Cinematic Image -->
    <div class="hidden lg:block w-5/12 relative overflow-hidden bg-stitch-primary">
      <img 
        src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=1600" 
        class="absolute inset-0 w-full h-full object-cover mix-blend-overlay opacity-60 animate-slow-zoom"
        alt="Classic Car"
      >
      <div class="absolute inset-0 bg-gradient-to-r from-stitch-primary via-transparent to-transparent"></div>
      
      <div class="absolute inset-0 flex flex-col justify-center px-20 space-y-8">
        <h2 class="editorial-display text-5xl text-white leading-tight">
          Tham gia vào<br>cộng đồng AutoRent.
        </h2>
        <p class="text-white/80 text-lg max-w-sm font-medium leading-relaxed">
          Tạo tài khoản ngay để tận hưởng những ưu đãi đặc biệt và trải nghiệm dịch vụ thuê xe chuẩn 5 sao.
        </p>
        <div class="flex flex-col gap-4">
          <div v-for="benefit in ['Đa dạng dòng xe cao cấp', 'Thủ tục nhanh gọn 5 phút', 'Bảo hiểm trọn gói', 'Hỗ trợ 24/7']" :key="benefit" class="flex items-center gap-3 text-white/90 font-bold text-sm">
            <div class="w-1.5 h-1.5 bg-stitch-accent rounded-full"></div>
            {{ benefit }}
          </div>
        </div>
      </div>

      <router-link to="/" class="absolute top-10 left-10 flex items-center gap-2 text-white/80 hover:text-white transition-colors group">
        <ChevronLeft class="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
        <span class="text-sm font-bold uppercase tracking-widest">Quay lại trang chủ</span>
      </router-link>
    </div>

    <!-- Right Side: Registration Form -->
    <div class="w-full lg:w-7/12 flex items-center justify-center p-8 md:p-16 lg:p-20 bg-stitch-surface-container-lowest overflow-y-auto">
      <div class="max-w-2xl w-full space-y-10 animate-fade-up">
        <div class="space-y-4">
          <h1 class="editorial-display text-4xl text-stitch-primary">Tạo tài khoản</h1>
          <p class="text-stitch-on-surface-variant font-medium">Bắt đầu hành trình của bạn với những trải nghiệm tuyệt vời nhất.</p>
        </div>

        <form @submit.prevent="handleRegister" class="space-y-8">
          <div v-if="error" class="bg-red-50 text-red-600 p-4 rounded-stitch-md text-xs font-bold border border-red-100 flex items-center gap-3">
            <div class="w-1.5 h-1.5 bg-red-600 rounded-full"></div>
            {{ error }}
          </div>

          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Họ và tên</label>
              <div class="relative group">
                <User class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
                <input v-model="form.name" type="text" required placeholder="Nguyễn Văn A" class="input-field w-full pl-12">
              </div>
            </div>

            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Email</label>
              <div class="relative group">
                <Mail class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
                <input v-model="form.email" type="email" required placeholder="a@gmail.com" class="input-field w-full pl-12">
              </div>
            </div>

            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Số điện thoại</label>
              <div class="relative group">
                <Phone class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
                <input v-model="form.phone" type="text" required placeholder="0912345678" class="input-field w-full pl-12">
              </div>
            </div>

            <div class="space-y-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Bằng lái xe</label>
              <div class="relative group">
                <FileText class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
                <input v-model="form.driveLicense" type="text" required placeholder="B2-123456" class="input-field w-full pl-12">
              </div>
            </div>

            <div class="space-y-2 md:col-span-2">
              <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Mật khẩu</label>
              <div class="relative group">
                <Lock class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-stitch-outline group-focus-within:text-stitch-primary transition-colors" />
                <input v-model="form.password" type="password" required placeholder="••••••••" class="input-field w-full pl-12">
              </div>
            </div>
          </div>

          <BaseButton 
            type="submit" 
            variant="primary" 
            class="w-full !py-4 shadow-xl shadow-stitch-primary/10 flex items-center justify-center gap-2"
            :loading="loading"
          >
            Đăng ký ngay
            <ArrowRight class="w-4 h-4" />
          </BaseButton>
        </form>

        <p class="text-center text-sm text-stitch-on-surface-variant font-medium pt-4">
          Đã có tài khoản? 
          <router-link to="/auth/login" class="text-stitch-primary font-bold hover:underline ml-1">Đăng nhập ngay</router-link>
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
