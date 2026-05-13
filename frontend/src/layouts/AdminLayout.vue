<script setup>
import { ref } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { 
  LayoutDashboard, 
  Car, 
  CalendarCheck, 
  CreditCard, 
  Users, 
  Settings, 
  LogOut,
  ChevronLeft,
  Bell,
  Search
} from 'lucide-vue-next'

const router = useRouter()
const route = useRoute()
const isSidebarCollapsed = ref(false)

const menuItems = [
  { name: 'Tổng quan', path: '/admin', icon: LayoutDashboard },
  { name: 'Quản lý xe', path: '/admin/cars', icon: Car },
  { name: 'Đơn đặt xe', path: '/admin/bookings', icon: CalendarCheck },
  { name: 'Thanh toán', path: '/admin/payments', icon: CreditCard },
  { name: 'Khách hàng', path: '/admin/users', icon: Users },
]
</script>

<template>
  <div class="flex min-h-screen bg-stitch-surface-container-low">
    <!-- Admin Sidebar -->
    <aside 
      class="bg-stitch-primary text-white transition-all duration-500 flex flex-col z-50 fixed inset-y-0"
      :class="isSidebarCollapsed ? 'w-20' : 'w-72'"
    >
      <!-- Brand -->
      <div class="p-6 flex items-center gap-4 mb-10">
        <div class="bg-white p-2 rounded-stitch-md flex-shrink-0">
          <Car class="text-stitch-primary w-6 h-6" />
        </div>
        <span v-if="!isSidebarCollapsed" class="editorial-display text-2xl tracking-tighter transition-all duration-300">Admin</span>
      </div>

      <!-- Nav Links -->
      <nav class="flex-grow px-4 space-y-2">
        <router-link 
          v-for="item in menuItems" 
          :key="item.path"
          :to="item.path"
          class="flex items-center gap-4 px-4 py-4 rounded-stitch-lg transition-all group"
          :class="route.path === item.path ? 'bg-white text-stitch-primary shadow-lg shadow-black/20' : 'text-stitch-on-primary-container hover:bg-white/10 hover:text-white'"
        >
          <component :is="item.icon" class="w-5 h-5 flex-shrink-0" />
          <span v-if="!isSidebarCollapsed" class="text-sm font-bold tracking-wide transition-all duration-300">{{ item.name }}</span>
        </router-link>
      </nav>

      <!-- Footer Actions -->
      <div class="p-4 space-y-2 border-t border-white/10">
        <button class="flex items-center gap-4 w-full px-4 py-4 rounded-stitch-lg text-stitch-on-primary-container hover:bg-white/10 hover:text-white transition-all group">
          <Settings class="w-5 h-5 flex-shrink-0" />
          <span v-if="!isSidebarCollapsed" class="text-sm font-bold tracking-wide">Cài đặt</span>
        </button>
        <button @click="router.push('/')" class="flex items-center gap-4 w-full px-4 py-4 rounded-stitch-lg text-red-400 hover:bg-red-500/10 hover:text-red-300 transition-all group">
          <LogOut class="w-5 h-5 flex-shrink-0" />
          <span v-if="!isSidebarCollapsed" class="text-sm font-bold tracking-wide">Thoát Admin</span>
        </button>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div 
      class="flex-grow transition-all duration-500"
      :class="isSidebarCollapsed ? 'pl-20' : 'pl-72'"
    >
      <!-- Top Bar -->
      <header class="h-20 bg-white border-b border-stitch-outline-variant/20 flex items-center justify-between px-8 sticky top-0 z-40">
        <div class="flex items-center gap-4">
          <button @click="isSidebarCollapsed = !isSidebarCollapsed" class="p-2 text-stitch-on-surface-variant hover:bg-stitch-surface-container rounded-full transition-colors">
            <ChevronLeft class="w-5 h-5 transition-transform duration-500" :class="{ 'rotate-180': isSidebarCollapsed }" />
          </button>
          <div class="relative hidden md:block">
            <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-stitch-outline" />
            <input type="text" placeholder="Tìm kiếm nhanh..." class="bg-stitch-surface-container border-none rounded-full px-10 py-2 text-sm w-64 focus:ring-2 focus:ring-stitch-primary/10 transition-all outline-none">
          </div>
        </div>

        <div class="flex items-center gap-6">
          <button class="relative p-2 text-stitch-on-surface-variant hover:bg-stitch-surface-container rounded-full transition-colors">
            <Bell class="w-5 h-5" />
            <span class="absolute top-1.5 right-1.5 w-2 h-2 bg-stitch-accent rounded-full border-2 border-white"></span>
          </button>
          <div class="h-8 w-px bg-stitch-outline-variant/30"></div>
          <div class="flex items-center gap-3">
            <div class="text-right">
              <p class="text-sm font-bold">Quản trị viên</p>
              <p class="text-[10px] text-stitch-on-surface-variant uppercase font-bold tracking-widest">Admin Huy</p>
            </div>
            <div class="w-10 h-10 rounded-full bg-stitch-primary-container flex items-center justify-center text-white font-bold">
              A
            </div>
          </div>
        </div>
      </header>

      <!-- Page Content -->
      <main class="p-8">
        <router-view />
      </main>
    </div>
  </div>
</template>
