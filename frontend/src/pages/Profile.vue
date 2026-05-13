<script setup>
import { ref, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { 
  User, 
  Settings, 
  Lock, 
  Calendar, 
  CreditCard, 
  LogOut, 
  CheckCircle,
  AlertCircle,
  Save,
  Camera
} from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'
import { userApi, authApi } from '@/api'

const router = useRouter()
const activeTab = ref('profile')
const loading = ref(true)
const saving = ref(false)
const error = ref('')
const success = ref('')

const profile = ref({
  name: '',
  email: '',
  phone: '',
  driveLicense: '',
})

const passwords = ref({
  oldPassword: '',
  newPassword: '',
  confirmPassword: ''
})

onMounted(async () => {
  await fetchProfile()
})

const fetchProfile = async () => {
  loading.value = true
  try {
    const res = await userApi.getMe()
    if (res.success) profile.value = res.data
  } catch (err) {
    console.error(err)
  } finally {
    loading.value = false
  }
}

const handleUpdateProfile = async () => {
  saving.value = true
  error.value = ''
  success.value = ''
  try {
    const res = await userApi.updateMe(profile.value)
    if (res.success) {
      success.value = 'Cập nhật thông tin thành công'
      await fetchProfile()
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Không thể cập nhật thông tin'
  } finally {
    saving.value = false
  }
}

const handleChangePassword = async () => {
  if (passwords.value.newPassword !== passwords.value.confirmPassword) {
    error.value = 'Mật khẩu xác nhận không khớp'
    return
  }

  saving.value = true
  error.value = ''
  success.value = ''
  try {
    const res = await userApi.changePassword(passwords.value)
    if (res.success) {
      success.value = 'Đổi mật khẩu thành công'
      passwords.value = { oldPassword: '', newPassword: '', confirmPassword: '' }
    }
  } catch (err) {
    error.value = err.response?.data?.message || 'Mật khẩu cũ không chính xác'
  } finally {
    saving.value = false
  }
}

const handleLogout = async () => {
  try {
    await authApi.logout()
  } finally {
    localStorage.clear()
    router.push('/auth/login')
  }
}
</script>

<template>
  <div class="pt-32 pb-20 px-6 max-w-6xl mx-auto min-h-screen">
    <div class="flex flex-col lg:grid lg:grid-cols-12 gap-10">
      <!-- Sidebar Nav -->
      <aside class="lg:col-span-3 space-y-4">
        <div class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8 text-center mb-6">
          <div class="relative w-24 h-24 mx-auto mb-4 group">
            <div class="w-full h-full rounded-full bg-stitch-surface-container flex items-center justify-center text-stitch-primary text-3xl font-bold">
              {{ profile.name?.charAt(0) }}
            </div>
            <button class="absolute bottom-0 right-0 p-2 bg-stitch-primary text-white rounded-full shadow-lg opacity-0 group-hover:opacity-100 transition-opacity">
              <Camera class="w-4 h-4" />
            </button>
          </div>
          <h2 class="font-bold text-lg">{{ profile.name }}</h2>
          <p class="text-xs text-stitch-on-surface-variant font-medium">{{ profile.email }}</p>
        </div>

        <nav class="space-y-1">
          <button 
            @click="activeTab = 'profile'"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg transition-all font-bold text-sm"
            :class="activeTab === 'profile' ? 'bg-stitch-primary text-white shadow-lg shadow-stitch-primary/20' : 'text-stitch-on-surface-variant hover:bg-stitch-surface-container'"
          >
            <User class="w-4 h-4" />
            Thông tin cá nhân
          </button>
          <button 
            @click="activeTab = 'security'"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg transition-all font-bold text-sm"
            :class="activeTab === 'security' ? 'bg-stitch-primary text-white shadow-lg shadow-stitch-primary/20' : 'text-stitch-on-surface-variant hover:bg-stitch-surface-container'"
          >
            <Lock class="w-4 h-4" />
            Mật khẩu & Bảo mật
          </button>
          <hr class="my-4 border-stitch-outline-variant/20">
          <router-link 
            to="/my-bookings"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg transition-all font-bold text-sm text-stitch-on-surface-variant hover:bg-stitch-surface-container"
          >
            <Calendar class="w-4 h-4" />
            Đơn đặt xe
          </router-link>
          <router-link 
            to="/my-invoices"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg transition-all font-bold text-sm text-stitch-on-surface-variant hover:bg-stitch-surface-container"
          >
            <CreditCard class="w-4 h-4" />
            Hóa đơn
          </router-link>
          <router-link 
            to="/my-payments"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg transition-all font-bold text-sm text-stitch-on-surface-variant hover:bg-stitch-surface-container"
          >
            <CreditCard class="w-4 h-4" />
            Thanh toán
          </router-link>
          <hr class="my-4 border-stitch-outline-variant/20">
          <button 
            @click="handleLogout"
            class="w-full flex items-center gap-3 px-4 py-3 rounded-stitch-lg text-red-500 hover:bg-red-50 transition-all font-bold text-sm"
          >
            <LogOut class="w-4 h-4" />
            Đăng xuất
          </button>
        </nav>
      </aside>

      <!-- Main Content Area -->
      <main class="lg:col-span-9">
        <div v-if="loading" class="flex items-center justify-center py-20">
          <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-stitch-primary"></div>
        </div>

        <div v-else class="bg-white rounded-stitch-xl shadow-sm border border-stitch-outline-variant/10 p-8 md:p-12 animate-fade-up">
          
          <!-- Profile Tab -->
          <div v-if="activeTab === 'profile'" class="space-y-8">
            <div class="space-y-1">
              <h1 class="editorial-display text-3xl">Thông tin cá nhân</h1>
              <p class="text-stitch-on-surface-variant text-sm font-medium">Cập nhật thông tin để chúng tôi phục vụ bạn tốt hơn.</p>
            </div>

            <form @submit.prevent="handleUpdateProfile" class="space-y-6">
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div class="space-y-2">
                  <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Họ và tên</label>
                  <input v-model="profile.name" type="text" required class="input-field w-full">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Email</label>
                  <input v-model="profile.email" type="email" required class="input-field w-full opacity-60 cursor-not-allowed" disabled title="Email không thể thay đổi">
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Số điện thoại</label>
                  <input v-model="profile.phone" type="text" required class="input-field w-full opacity-60 cursor-not-allowed" disabled>
                </div>
                <div class="space-y-2">
                  <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Bằng lái xe</label>
                  <input v-model="profile.driveLicense" type="text" required class="input-field w-full">
                </div>
              </div>

              <div class="flex items-center justify-between pt-6">
                <p v-if="success" class="text-sm text-green-500 font-bold flex items-center gap-2">
                  <CheckCircle class="w-4 h-4" />
                  {{ success }}
                </p>
                <p v-if="error" class="text-sm text-red-500 font-bold flex items-center gap-2">
                  <AlertCircle class="w-4 h-4" />
                  {{ error }}
                </p>
                <div v-else></div>

                <BaseButton type="submit" variant="primary" class="!px-10 flex items-center gap-2" :loading="saving">
                  <Save class="w-4 h-4" />
                  Lưu thay đổi
                </BaseButton>
              </div>
            </form>
          </div>

          <!-- Security Tab -->
          <div v-if="activeTab === 'security'" class="space-y-8">
            <div class="space-y-1">
              <h1 class="editorial-display text-3xl">Mật khẩu & Bảo mật</h1>
              <p class="text-stitch-on-surface-variant text-sm font-medium">Thay đổi mật khẩu thường xuyên để bảo vệ tài khoản.</p>
            </div>

            <form @submit.prevent="handleChangePassword" class="space-y-6 max-w-md">
              <div class="space-y-2">
                <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Mật khẩu hiện tại</label>
                <input v-model="passwords.oldPassword" type="password" required class="input-field w-full">
              </div>
              <div class="space-y-2">
                <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Mật khẩu mới</label>
                <input v-model="passwords.newPassword" type="password" required class="input-field w-full">
              </div>
              <div class="space-y-2">
                <label class="text-[10px] font-bold uppercase tracking-widest text-stitch-on-surface-variant ml-1">Xác nhận mật khẩu mới</label>
                <input v-model="passwords.confirmPassword" type="password" required class="input-field w-full">
              </div>

              <div class="pt-6">
                <BaseButton type="submit" variant="primary" class="w-full !py-4" :loading="saving">
                  Đổi mật khẩu
                </BaseButton>
              </div>
            </form>
          </div>

        </div>
      </main>
    </div>
  </div>
</template>
