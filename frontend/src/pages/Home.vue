<script setup>
import { onMounted } from 'vue'
import { useCarStore } from '@/store/car'
import SearchBar from '@/components/SearchBar.vue'
import CarCard from '@/components/CarCard.vue'
import BaseButton from '@/components/BaseButton.vue'
import { ShieldCheck, Zap, Clock, Star, ArrowRight, CheckCircle } from 'lucide-vue-next'

const carStore = useCarStore()

onMounted(() => {
  carStore.fetchCars()
})

const mockCars = [
  { id: 1, brand: 'VinFast', name: 'VF8 Plus', fuelType: 'Điện', seats: 5, transmission: 'AUTOMATIC', location: 'Hà Nội', pricePerDay: 1200000 },
  { id: 2, brand: 'Toyota', name: 'Vios 2023', fuelType: 'Xăng', seats: 5, transmission: 'AUTOMATIC', location: 'TP. HCM', pricePerDay: 800000 },
  { id: 3, brand: 'Hyundai', name: 'SantaFe', fuelType: 'Dầu', seats: 7, transmission: 'AUTOMATIC', location: 'Đà Nẵng', pricePerDay: 1500000 },
  { id: 4, brand: 'Tesla', name: 'Model 3', fuelType: 'Điện', seats: 5, transmission: 'AUTOMATIC', location: 'Hà Nội', pricePerDay: 2500000 },
]

const features = [
  { icon: ShieldCheck, title: 'Bảo hiểm 100%', desc: 'Mọi chuyến đi đều được bảo vệ toàn diện bởi các đối tác bảo hiểm uy tín.' },
  { icon: Zap, title: 'Thủ tục nhanh gọn', desc: 'Đặt xe chỉ trong 5 phút với quy trình xác thực tự động thông minh.' },
  { icon: Clock, title: 'Hỗ trợ 24/7', desc: 'Đội ngũ chăm sóc khách hàng luôn sẵn sàng hỗ trợ bạn trên mọi cung đường.' },
]
</script>

<template>
  <div class="bg-white">
    <!-- Cinematic Hero Section -->
    <section class="relative h-[90vh] min-h-[700px] flex items-center justify-center overflow-hidden bg-stitch-primary">
      <div class="absolute inset-0 z-0">
        <img 
          src="https://images.unsplash.com/photo-1503376780353-7e6692767b70?auto=format&fit=crop&q=80&w=2000" 
          class="w-full h-full object-cover opacity-40 scale-105 animate-slow-zoom"
          alt="Luxury Car Hero"
        >
        <div class="absolute inset-0 bg-gradient-to-t from-stitch-primary via-transparent to-transparent"></div>
      </div>

      <div class="relative z-10 max-w-5xl mx-auto px-6 text-center text-white">
        <div class="inline-flex items-center gap-2 bg-white/10 backdrop-blur-md px-4 py-2 rounded-full mb-8 animate-fade-up">
          <Star class="w-4 h-4 text-stitch-accent fill-stitch-accent" />
          <span class="text-xs font-bold uppercase tracking-widest">Nền tảng thuê xe số 1 Việt Nam</span>
        </div>
        <h1 class="editorial-display text-5xl md:text-7xl lg:text-8xl mb-8 leading-[1.1] animate-fade-up [animation-delay:200ms]">
          Khám phá hành trình <br> <span class="text-stitch-accent italic">tự do</span> của bạn
        </h1>
        
        <!-- Search Engine -->
        <div class="max-w-4xl mx-auto -mb-20 animate-fade-up [animation-delay:400ms]">
          <SearchBar class="!rounded-stitch-xl !p-4 shadow-2xl" />
        </div>
      </div>
    </section>

    <!-- Features Section -->
    <section class="pt-32 pb-20 px-6 max-w-7xl mx-auto">
      <div class="grid grid-cols-1 md:grid-cols-3 gap-12">
        <div v-for="feature in features" :key="feature.title" class="group">
          <div class="bg-stitch-surface-container w-14 h-14 rounded-stitch-lg flex items-center justify-center mb-6 group-hover:bg-stitch-primary group-hover:text-white transition-all duration-300">
            <component :is="feature.icon" class="w-7 h-7" />
          </div>
          <h3 class="editorial-headline text-xl mb-3">{{ feature.title }}</h3>
          <p class="text-stitch-on-surface-variant text-sm leading-relaxed">
            {{ feature.desc }}
          </p>
        </div>
      </div>
    </section>

    <!-- Vehicle Showcase -->
    <section class="py-20 bg-stitch-surface-container-low px-6">
      <div class="max-w-7xl mx-auto">
        <div class="flex flex-col md:flex-row justify-between items-end gap-6 mb-12">
          <div class="space-y-4">
            <h2 class="editorial-display text-4xl text-stitch-primary">Xe nổi bật dành cho bạn</h2>
            <p class="text-stitch-on-surface-variant font-medium">Những mẫu xe được yêu thích nhất trong tuần qua.</p>
          </div>
          <BaseButton variant="outline" class="group">
            Xem tất cả xe 
            <ArrowRight class="w-4 h-4 ml-2 group-hover:translate-x-1 transition-transform" />
          </BaseButton>
        </div>

        <div v-if="carStore.loading" class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <div v-for="i in 4" :key="i" class="no-line-card !p-0 h-[450px] animate-pulse bg-stitch-surface-container"></div>
        </div>

        <div v-else class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <CarCard 
            v-for="car in (carStore.cars.length ? carStore.cars : mockCars)" 
            :key="car.id" 
            :car="car" 
          />
        </div>
      </div>
    </section>

    <!-- CTA Section -->
    <section class="py-20 px-6">
      <div class="max-w-7xl mx-auto bg-stitch-primary rounded-stitch-xl overflow-hidden relative p-12 md:p-24 text-center">
        <div class="absolute inset-0 z-0">
          <img src="https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?auto=format&fit=crop&q=80&w=2000" class="w-full h-full object-cover opacity-20" alt="CTA Background">
        </div>
        <div class="relative z-10 space-y-8">
          <h2 class="editorial-display text-4xl md:text-6xl text-white">Sẵn sàng đồng hành cùng <br> AutoRent?</h2>
          <p class="text-stitch-on-primary-container max-w-2xl mx-auto text-lg">
            Đăng ký ngay để nhận ưu đãi lên đến 20% cho lần thuê đầu tiên và trải nghiệm dịch vụ đẳng cấp quốc tế.
          </p>
          <div class="flex flex-col md:flex-row gap-4 justify-center">
            <BaseButton variant="accent" class="!px-12 !py-5 text-lg shadow-xl shadow-stitch-accent/20" @click="router.push('/browse')">Bắt đầu ngay</BaseButton>
            <BaseButton variant="outline" class="!border-white !text-white hover:!bg-white hover:!text-stitch-primary !px-12 !py-5 text-lg">Liên hệ tư vấn</BaseButton>
          </div>
        </div>
      </div>
    </section>

    <!-- Become Owner Showcase -->
    <section class="py-32 px-6 bg-stitch-surface-container-lowest">
      <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-center gap-16">
        <div class="flex-1 order-2 md:order-1">
          <div class="relative rounded-stitch-2xl overflow-hidden shadow-2xl group">
            <img 
              src="https://images.unsplash.com/photo-1552519507-da3b142c6e3d?auto=format&fit=crop&q=80&w=1000" 
              class="w-full h-full object-cover transition-transform duration-700 group-hover:scale-110"
              alt="Luxury Car Owner"
            >
            <div class="absolute inset-0 bg-gradient-to-t from-stitch-primary/80 via-transparent to-transparent"></div>
          </div>
        </div>
        <div class="flex-1 order-1 md:order-2 space-y-8">
          <h2 class="editorial-display text-5xl text-stitch-primary leading-tight">Bạn có xe nhàn rỗi? <br> Hãy để nó <span class="text-stitch-accent">kiếm tiền</span> cho bạn</h2>
          <p class="text-stitch-on-surface-variant text-lg leading-relaxed font-medium">
            Gia nhập cộng đồng chủ xe AutoRent để tăng thu nhập hàng tháng lên đến 20 triệu đồng. Chúng tôi lo liệu bảo hiểm và vận hành, bạn chỉ việc nhận tiền.
          </p>
          <ul class="space-y-4">
            <li v-for="item in ['Bảo hiểm chuyến đi 24/7', 'Quy trình xét duyệt nhanh gọn', 'Quản lý doanh thu minh bạch']" :key="item" class="flex items-center gap-3 font-bold text-stitch-primary">
              <CheckCircle class="w-5 h-5 text-stitch-accent" />
              {{ item }}
            </li>
          </ul>
          <BaseButton variant="primary" class="!px-12 !py-5 shadow-lg" @click="router.push('/become-owner')">Tìm hiểu thêm</BaseButton>
        </div>
      </div>
    </section>
  </div>
</template>

<style scoped>
@keyframes slow-zoom {
  0% { transform: scale(1.05); }
  100% { transform: scale(1.15); }
}

.animate-slow-zoom {
  animation: slow-zoom 20s infinite alternate linear;
}

@keyframes fade-up {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}

.animate-fade-up {
  animation: fade-up 1s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
  opacity: 0;
}
</style>
