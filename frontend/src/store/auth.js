import { defineStore } from 'pinia'
import { userApi, authApi } from '@/api'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: JSON.parse(localStorage.getItem('user') || 'null'),
    token: localStorage.getItem('token') || null,
    loading: false,
  }),

  getters: {
    isLoggedIn: (state) => !!state.token,
    isAdmin: (state) => state.user?.role === 'ADMIN',
    userName: (state) => state.user?.name || '',
  },

  actions: {
    setAuth({ token, refreshToken, user }) {
      this.token = token
      this.user = user
      localStorage.setItem('token', token)
      localStorage.setItem('refreshToken', refreshToken)
      localStorage.setItem('user', JSON.stringify(user))
    },

    async fetchUser() {
      if (!this.token) return
      this.loading = true
      try {
        const res = await userApi.getMe()
        if (res.success) {
          this.user = res.data
          localStorage.setItem('user', JSON.stringify(res.data))
        }
      } catch (err) {
        console.error('Failed to fetch user:', err)
      } finally {
        this.loading = false
      }
    },

    async logout() {
      try {
        await authApi.logout()
      } catch (err) {
        // Ignore logout API errors
      } finally {
        this.token = null
        this.user = null
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
        localStorage.removeItem('user')
      }
    },
  },
})
