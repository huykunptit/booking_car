<script setup>
import { Car, Facebook, Instagram, Twitter, Mail, MapPin, Phone } from 'lucide-vue-next'
</script>

<template>
  <footer class="bg-stitch-primary text-white pt-20 pb-10">
    <div class="max-w-7xl mx-auto px-6">
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-12 mb-20">
        <!-- Brand -->
        <div class="space-y-6">
          <div class="flex items-center gap-2">
            <div class="bg-white p-2 rounded-stitch-md">
              <Car class="text-stitch-primary w-6 h-6" />
            </div>
            <span class="editorial-display text-2xl tracking-tighter">AutoRent</span>
          </div>
          <p class="text-stitch-on-primary-container text-sm leading-relaxed max-w-xs">
            Trải nghiệm thuê xe tự lái cao cấp, an toàn và minh bạch. Khám phá hành trình tiếp theo của bạn cùng AutoRent.
          </p>
          <div class="flex gap-4">
            <button class="p-2 bg-stitch-primary-container rounded-full hover:bg-stitch-accent transition-colors"><Facebook class="w-5 h-5" /></button>
            <button class="p-2 bg-stitch-primary-container rounded-full hover:bg-stitch-accent transition-colors"><Instagram class="w-5 h-5" /></button>
            <button class="p-2 bg-stitch-primary-container rounded-full hover:bg-stitch-accent transition-colors"><Twitter class="w-5 h-5" /></button>
          </div>
        </div>

        <!-- Links -->
        <div>
          <h4 class="font-bold uppercase tracking-widest text-xs mb-8">Công ty</h4>
          <ul class="space-y-4 text-sm text-stitch-on-primary-container">
            <li><router-link to="/about" class="hover:text-white transition-colors">Về chúng tôi</router-link></li>
            <li><router-link to="/cars" class="hover:text-white transition-colors">Danh sách xe</router-link></li>
            <li><router-link to="/blog" class="hover:text-white transition-colors">Blog</router-link></li>
            <li><router-link to="/careers" class="hover:text-white transition-colors">Tuyển dụng</router-link></li>
          </ul>
        </div>

        <!-- Support -->
        <div>
          <h4 class="font-bold uppercase tracking-widest text-xs mb-8">Hỗ trợ</h4>
          <ul class="space-y-4 text-sm text-stitch-on-primary-container">
            <li><router-link to="/help" class="hover:text-white transition-colors">Trung tâm hỗ trợ</router-link></li>
            <li><router-link to="/terms" class="hover:text-white transition-colors">Điều khoản dịch vụ</router-link></li>
            <li><router-link to="/privacy" class="hover:text-white transition-colors">Chính sách bảo mật</router-link></li>
            <li><router-link to="/faq" class="hover:text-white transition-colors">Câu hỏi thường gặp</router-link></li>
          </ul>
        </div>

        <!-- Contact -->
        <div>
          <h4 class="font-bold uppercase tracking-widest text-xs mb-8">Liên hệ</h4>
          <ul class="space-y-6 text-sm text-stitch-on-primary-container">
            <li class="flex gap-3">
              <MapPin class="w-5 h-5 text-stitch-accent flex-shrink-0" />
              <span>123 Đường Láng, Quận Đống Đa, Hà Nội, Việt Nam</span>
            </li>
            <li class="flex gap-3">
              <Phone class="w-5 h-5 text-stitch-accent flex-shrink-0" />
              <span>+84 123 456 789</span>
            </li>
            <li class="flex gap-3">
              <Mail class="w-5 h-5 text-stitch-accent flex-shrink-0" />
              <span>support@autorent.vn</span>
            </li>
          </ul>
        </div>
      </div>

      <div class="pt-10 border-t border-stitch-primary-container flex flex-col md:flex-row justify-between items-center gap-6">
        <p class="text-xs text-stitch-on-primary-container">
          © 2026 AutoRent System. Tất cả quyền được bảo lưu.
        </p>
        <div class="flex gap-6">
          <img src="https://www.svgrepo.com/show/508408/visa.svg" class="h-6 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" alt="Visa">
          <img src="https://www.svgrepo.com/show/508401/mastercard.svg" class="h-6 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" alt="Mastercard">
          <img src="https://www.svgrepo.com/show/508719/nap.svg" class="h-6 opacity-50 grayscale hover:grayscale-0 transition-all cursor-pointer" alt="Napas">
        </div>
      </div>
    </div>
  </footer>
</template>
