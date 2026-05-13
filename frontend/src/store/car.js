import { defineStore } from 'pinia'
import { carApi } from '@/api'

export const useCarStore = defineStore('car', {
  state: () => ({
    cars: [],
    loading: false,
    error: null,
    filters: {
      onlyAvailable: true,
      minPrice: 0,
      maxPrice: 5000000,
      search: '',
      page: 0,
      size: 12
    }
  }),
  actions: {
    async fetchCars() {
      this.loading = true
      try {
        const res = await carApi.list(this.filters)
        if (res.success) {
          // data is PageResponse<T>
          this.cars = res.data.content || []
        }
      } catch (err) {
        this.error = err.message
      } finally {
        this.loading = false
      }
    }
  }
})
