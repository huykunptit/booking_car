<script setup>
import { CheckCircle, Car, DollarSign, ShieldCheck, Zap, ArrowRight, Star } from 'lucide-vue-next'
import BaseButton from '@/components/BaseButton.vue'

const benefits = [
  { 
    icon: DollarSign, 
    title: 'Thu nhập thụ động', 
    desc: 'Kiếm thêm 10-20 triệu mỗi tháng bằng cách cho thuê chiếc xe nhàn rỗi của bạn.' 
  },
  { 
    icon: ShieldCheck, 
    title: 'Bảo hiểm toàn diện', 
    desc: 'Mọi chuyến đi đều được bảo hiểm bởi các đối tác uy tín, bảo vệ tài sản của bạn 24/7.' 
  },
  { 
    icon: Zap, 
    title: 'Quản lý thông minh', 
    desc: 'Ứng dụng quản lý chuyến đi, doanh thu và lịch xe một cách tự động, minh bạch.' 
  }
]

const steps = [
  { title: 'Đăng ký thông tin', desc: 'Cung cấp thông tin xe, hình ảnh và giấy tờ liên quan.' },
  { title: 'Duyệt hồ sơ', desc: 'Đội ngũ AutoRent sẽ kiểm tra và kích hoạt xe của bạn trong 24h.' },
  { title: 'Bắt đầu kiếm tiền', desc: 'Nhận yêu cầu thuê xe và tận hưởng nguồn thu nhập mới.' }
]
</script>

<template>
  <div class="bg-white">
    <!-- Hero Section -->
    <section class="relative py-24 md:py-32 overflow-hidden bg-stitch-primary">
      <div class="absolute inset-0 z-0">
        <img 
          src="https://images.unsplash.com/photo-1560179707-f14e90ef3623?auto=format&fit=crop&q=80&w=2000" 
          class="w-full h-full object-cover opacity-30"
          alt="Business Meeting"
        >
        <div class="absolute inset-0 bg-gradient-to-r from-stitch-primary via-stitch-primary/80 to-transparent"></div>
      </div>

      <div class="relative z-10 max-w-7xl mx-auto px-6 grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
        <div class="space-y-8">
          <div class="inline-flex items-center gap-2 bg-stitch-accent/20 border border-stitch-accent/30 px-4 py-2 rounded-full">
            <Star class="w-4 h-4 text-stitch-accent fill-stitch-accent" />
            <span class="text-[10px] font-black text-stitch-accent uppercase tracking-widest">Chương trình đối tác AutoRent</span>
          </div>
          <h1 class="editorial-display text-5xl md:text-7xl text-white leading-tight">
            Biến xe nhàn rỗi <br> thành <span class="italic text-stitch-accent">lợi nhuận</span>
          </h1>
          <p class="text-stitch-on-primary-container text-lg max-w-lg leading-relaxed">
            Gia nhập cộng đồng 5000+ chủ xe tại Việt Nam. Chúng tôi giúp bạn tối ưu hóa tài sản và quản lý rủi ro tuyệt đối.
          </p>
          <div class="flex flex-col sm:flex-row gap-4">
            <BaseButton variant="accent" class="!px-10 !py-4 text-sm font-black shadow-xl shadow-stitch-accent/30">
              ĐĂNG KÝ NGAY
            </BaseButton>
            <BaseButton variant="outline" class="!border-white !text-white hover:!bg-white hover:!text-stitch-primary !px-10 !py-4 text-sm font-black">
              TÌM HIỂU THÊM
            </BaseButton>
          </div>
        </div>
        
        <!-- Trust Card -->
        <div class="hidden md:block bg-white/10 backdrop-blur-xl border border-white/20 p-8 rounded-stitch-2xl shadow-2xl animate-fade-up">
          <div class="flex items-center gap-4 mb-8">
            <div class="w-12 h-12 bg-stitch-accent rounded-full flex items-center justify-center">
              <CheckCircle class="w-6 h-6 text-stitch-primary" />
            </div>
            <div>
              <p class="text-white font-bold">An tâm tuyệt đối</p>
              <p class="text-stitch-on-primary-container text-xs">Mọi chuyến đi đều được bảo hiểm 100%</p>
            </div>
          </div>
          <div class="space-y-4">
            <div v-for="i in 3" :key="i" class="h-2 bg-white/10 rounded-full w-full relative overflow-hidden">
              <div class="absolute inset-y-0 left-0 bg-stitch-accent" :style="{ width: [85, 92, 78][i-1] + '%' }"></div>
            </div>
          </div>
          <div class="mt-8 flex justify-between items-end">
            <div>
              <p class="text-3xl font-bold text-white">4.9/5</p>
              <p class="text-[10px] text-stitch-on-primary-container uppercase font-bold tracking-widest">Đánh giá từ chủ xe</p>
            </div>
            <BaseButton variant="ghost" class="!text-stitch-accent p-0">Xem câu chuyện <ArrowRight class="w-4 h-4 ml-1" /></BaseButton>
          </div>
        </div>
      </div>
    </section>

    <!-- Benefits Section -->
    <section class="py-24 px-6 max-w-7xl mx-auto">
      <div class="text-center mb-20 space-y-4">
        <h2 class="editorial-display text-4xl text-stitch-primary">Tại sao nên chọn AutoRent?</h2>
        <p class="text-stitch-on-surface-variant max-w-2xl mx-auto font-medium">
          Chúng tôi không chỉ là nền tảng kết nối, chúng tôi là đối tác đồng hành cùng sự thịnh vượng của bạn.
        </p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div v-for="benefit in benefits" :key="benefit.title" class="group p-8 rounded-stitch-2xl border border-stitch-outline-variant/10 hover:border-stitch-primary/30 hover:bg-stitch-surface-container-low transition-all duration-300">
          <div class="bg-stitch-primary/10 w-16 h-16 rounded-stitch-xl flex items-center justify-center mb-8 group-hover:bg-stitch-primary group-hover:text-white transition-colors">
            <component :is="benefit.icon" class="w-8 h-8" />
          </div>
          <h3 class="editorial-headline text-xl mb-4">{{ benefit.title }}</h3>
          <p class="text-stitch-on-surface-variant text-sm leading-relaxed">
            {{ benefit.desc }}
          </p>
        </div>
      </div>
    </section>

    <!-- How it works -->
    <section class="py-24 bg-stitch-surface-container-low">
      <div class="max-w-7xl mx-auto px-6">
        <div class="flex flex-col md:flex-row gap-16 items-center">
          <div class="flex-1 space-y-8">
            <h2 class="editorial-display text-4xl text-stitch-primary">3 bước đơn giản để <br> bắt đầu</h2>
            <div class="space-y-6">
              <div v-for="(step, idx) in steps" :key="step.title" class="flex gap-6 items-start">
                <div class="flex-shrink-0 w-10 h-10 bg-stitch-primary text-white rounded-full flex items-center justify-center font-black text-sm">
                  0{{ idx + 1 }}
                </div>
                <div>
                  <h4 class="font-bold text-stitch-primary mb-1">{{ step.title }}</h4>
                  <p class="text-stitch-on-surface-variant text-sm leading-relaxed">{{ step.desc }}</p>
                </div>
              </div>
            </div>
            <BaseButton variant="primary" class="!px-12 !py-4 shadow-xl">BẮT ĐẦU NGAY</BaseButton>
          </div>
          
          <div class="flex-1 w-full aspect-square rounded-stitch-3xl overflow-hidden shadow-2xl relative group">
            <img 
              src="https://images.unsplash.com/photo-1492144534655-ae79c964c9d7?auto=format&fit=crop&q=80&w=1000" 
              class="w-full h-full object-cover transition-transform duration-1000 group-hover:scale-110"
              alt="Luxury Car"
            >
            <div class="absolute inset-0 bg-gradient-to-t from-stitch-primary/60 to-transparent"></div>
            <div class="absolute bottom-8 left-8 right-8 bg-white/10 backdrop-blur-md border border-white/20 p-6 rounded-stitch-xl">
              <p class="text-white italic text-sm">"Từ khi đưa xe lên AutoRent, tôi không còn lo lắng về chi phí bảo trì hàng tháng nữa. Doanh thu rất ổn định."</p>
              <p class="text-stitch-accent font-bold mt-4 text-xs">Anh Hoàng, Chủ xe VinFast VF8</p>
            </div>
          </div>
        </div>
      </div>
    </section>

    <!-- FAQ CTA -->
    <section class="py-24 px-6 text-center max-w-4xl mx-auto">
      <h2 class="editorial-headline text-3xl mb-6">Bạn còn thắc mắc?</h2>
      <p class="text-stitch-on-surface-variant mb-10 leading-relaxed font-medium">
        Đội ngũ tư vấn của chúng tôi luôn sẵn sàng giải đáp mọi câu hỏi về bảo hiểm, hợp đồng và quy trình vận hành.
      </p>
      <div class="flex justify-center gap-4">
        <BaseButton variant="outline" class="!px-10">Xem FAQ</BaseButton>
        <BaseButton variant="ghost" class="!text-stitch-primary font-bold underline">Liên hệ hỗ trợ</BaseButton>
      </div>
    </section>
  </div>
</template>

<style scoped>
@keyframes fade-up {
  from { opacity: 0; transform: translateY(30px); }
  to { opacity: 1; transform: translateY(0); }
}
.animate-fade-up {
  animation: fade-up 1s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
}
</style>
