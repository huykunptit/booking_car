<script setup>
defineProps({
  variant: {
    type: String,
    default: 'primary',
    validator: (value) => ['primary', 'accent', 'ghost', 'outline'].includes(value)
  },
  loading: Boolean,
  disabled: Boolean
})
</script>

<template>
  <button 
    class="relative inline-flex items-center justify-center font-semibold transition-all active:scale-[0.98] disabled:opacity-50 disabled:cursor-not-allowed overflow-hidden"
    :class="[
      variant === 'primary' ? 'btn-primary' : '',
      variant === 'accent' ? 'btn-accent' : '',
      variant === 'ghost' ? 'text-stitch-primary hover:bg-stitch-primary/5 px-6 py-3 rounded-full' : '',
      variant === 'outline' ? 'border border-stitch-outline-variant text-stitch-on-surface hover:bg-stitch-surface-container px-6 py-3 rounded-full' : '',
      { 'pointer-events-none': loading }
    ]"
    :disabled="disabled || loading"
  >
    <span v-if="loading" class="absolute inset-0 flex items-center justify-center bg-inherit">
      <svg class="animate-spin h-5 w-5 text-current" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
      </svg>
    </span>
    <span :class="{ 'opacity-0': loading }">
      <slot />
    </span>
  </button>
</template>
