<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { User, LogOut, LayoutDashboard, Car, Calendar, Menu, X } from 'lucide-vue-next'
import BaseButton from './BaseButton.vue'

const router = useRouter()
const isScrolled = ref(false)
const isMobileMenuOpen = ref(false)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

const user = ref(null)

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
  const userData = localStorage.getItem('user')
  if (userData) user.value = JSON.parse(userData)
})

onUnmounted(() => window.removeEventListener('scroll', handleScroll))

const navLinks = [
  { name: 'Trang chủ', path: '/' },
  { name: 'Tìm xe', path: '/browse' },
  { name: 'Trở thành chủ xe', path: '/become-owner' },
  { name: 'Đơn của tôi', path: '/my-bookings' },
]

const handleLogout = () => {
  localStorage.clear()
  user.value = null
  router.push('/auth/login')
}
</script>

<template>
  <header 
    class="fixed top-0 left-0 right-0 z-50 transition-all duration-500"
    :class="[
      isScrolled ? 'bg-white/80 backdrop-blur-xl border-b border-stitch-outline-variant/20 py-4 shadow-sm' : 'bg-transparent py-6'
    ]"
  >
    <div class="max-w-7xl mx-auto px-6 flex justify-between items-center">
      <!-- Logo -->
      <router-link to="/" class="flex items-center gap-2 group">
        <div class="bg-stitch-primary p-2 rounded-stitch-md group-hover:scale-105 transition-transform">
          <Car class="text-white w-6 h-6" />
        </div>
        <span class="editorial-display text-2xl tracking-tighter transition-colors" :class="isScrolled ? 'text-stitch-primary' : 'text-white'">
          AutoRent
        </span>
      </router-link>

      <!-- Desktop Nav -->
      <nav class="hidden md:flex items-center gap-8">
        <router-link 
          v-for="link in navLinks" 
          :key="link.path"
          :to="link.path"
          class="text-sm font-bold uppercase tracking-widest transition-colors"
          :class="isScrolled ? 'text-stitch-on-surface-variant hover:text-stitch-primary' : 'text-white/90 hover:text-white'"
        >
          {{ link.name }}
        </router-link>
      </nav>

      <!-- User Actions -->
      <div class="hidden md:flex items-center gap-4">
        <template v-if="user">
          <router-link to="/admin" v-if="user.role === 'ADMIN'" class="p-2 text-stitch-on-surface-variant hover:text-stitch-primary transition-colors">
            <LayoutDashboard class="w-5 h-5" />
          </router-link>
          <router-link to="/profile" class="flex items-center gap-3 bg-stitch-surface-container hover:bg-stitch-surface-container-high transition-colors px-4 py-2 rounded-full">
            <span class="text-sm font-bold">{{ user.name }}</span>
            <div class="bg-stitch-primary-container p-1 rounded-full">
              <User class="text-white w-4 h-4" />
            </div>
          </router-link>
        </template>
        <template v-else>
          <button 
            @click="router.push('/auth/login')" 
            class="text-sm font-bold uppercase tracking-widest px-4 py-2 transition-colors"
            :class="isScrolled ? 'text-stitch-on-surface-variant' : 'text-white'"
          >
            Đăng nhập
          </button>
          <BaseButton variant="primary" @click="router.push('/auth/register')">Đăng ký</BaseButton>
        </template>
      </div>

      <!-- Mobile Menu Toggle -->
      <button class="md:hidden p-2 text-stitch-primary" @click="isMobileMenuOpen = !isMobileMenuOpen">
        <component :is="isMobileMenuOpen ? X : Menu" class="w-6 h-6" />
      </button>
    </div>

    <!-- Mobile Menu Overlay -->
    <transition name="fade">
      <div v-if="isMobileMenuOpen" class="fixed inset-0 top-[72px] bg-white z-40 md:hidden p-6">
        <nav class="flex flex-col gap-6">
          <router-link 
            v-for="link in navLinks" 
            :key="link.path"
            :to="link.path"
            class="text-2xl editorial-headline"
            @click="isMobileMenuOpen = false"
          >
            {{ link.name }}
          </router-link>
          <hr class="border-stitch-outline-variant/30">
          <div class="flex flex-col gap-4">
            <BaseButton variant="primary" class="w-full">Đăng nhập</BaseButton>
            <BaseButton variant="outline" class="w-full">Đăng ký</BaseButton>
          </div>
        </nav>
      </div>
    </transition>
  </header>
</template>

<style scoped>
.fade-enter-active, .fade-leave-active { transition: opacity 0.3s ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }
</style>
