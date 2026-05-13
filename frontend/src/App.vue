<script setup>
import MainHeader from '@/components/MainHeader.vue'
import MainFooter from '@/components/MainFooter.vue'
import Toast from '@/components/Toast.vue'
</script>

<template>
  <div class="min-h-screen bg-stitch-background flex flex-col">
    <!-- Global Toast -->
    <Toast />

    <!-- Desktop Header -->
    <MainHeader />

    <!-- Main Content Area -->
    <main class="flex-grow pt-0">
      <router-view v-slot="{ Component }">
        <transition 
          name="page" 
          mode="out-in"
        >
          <component :is="Component" />
        </transition>
      </router-view>
    </main>

    <!-- Desktop Footer -->
    <MainFooter />
  </div>
</template>

<style>
.page-enter-active,
.page-leave-active {
  transition: opacity 0.4s cubic-bezier(0.4, 0, 0.2, 1), transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
}

.page-enter-from {
  opacity: 0;
  transform: translateY(20px);
}

.page-leave-to {
  opacity: 0;
  transform: translateY(-20px);
}

/* Global transitions and scroll behavior */
html {
  scroll-behavior: smooth;
}

body {
  overflow-x: hidden;
}
</style>
