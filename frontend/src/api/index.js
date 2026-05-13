import axios from 'axios'

const api = axios.create({
  baseURL: '/api',
  headers: {
    'Content-Type': 'application/json',
  },
})

// Request interceptor to add JWT token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token')
  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// Response interceptor to handle token expiration
api.interceptors.response.use(
  (response) => response.data,
  async (error) => {
    const originalRequest = error.config
    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true
      try {
        const refreshToken = localStorage.getItem('refreshToken')
        const response = await axios.post('/api/auth/refresh', { refreshToken })
        
        if (response.data.success) {
          const { token, refreshToken: newRefreshToken } = response.data.data
          localStorage.setItem('token', token)
          localStorage.setItem('refreshToken', newRefreshToken)
          
          api.defaults.headers.common['Authorization'] = `Bearer ${token}`
          return api(originalRequest)
        }
      } catch (refreshError) {
        localStorage.removeItem('token')
        localStorage.removeItem('refreshToken')
        window.location.href = '/auth/login'
      }
    }
    return Promise.reject(error)
  }
)

export const authApi = {
  login: (credentials) => api.post('/auth/login', credentials),
  register: (user) => api.post('/auth/register', user),
  refresh: (data) => api.post('/auth/refresh', data),
  logout: () => api.post('/auth/logout'),
  forgotPassword: (email) => api.post('/auth/forgot-password', { email }),
  resetPassword: (data) => api.post('/auth/reset-password', data),
}

export const userApi = {
  getMe: () => api.get('/user/me'),
  updateMe: (data) => api.put('/user/me', data),
  changePassword: (data) => api.post('/user/change-password', data),
}

export const carApi = {
  list: (params) => api.get('/cars', { params }),
  get: (id) => api.get(`/cars/${id}`),
  getAvailability: (id) => api.get(`/cars/${id}/availability`),
  getImages: (id) => api.get(`/cars/${id}/images`),
  // Admin APIs
  adminCreate: (data) => api.post('/admin/cars', data),
  adminUpdate: (id, data) => api.put(`/admin/cars/${id}`, data),
  adminDelete: (id) => api.delete(`/admin/cars/${id}`),
  adminUploadImage: (carId, formData) => api.post(`/admin/cars/${carId}/images`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  }),
  adminSetPrimaryImage: (carId, imageId) => api.patch(`/admin/cars/${carId}/images/${imageId}/primary`),
}

export const bookingApi = {
  create: (booking) => api.post('/bookings', booking),
  listMy: (params) => api.get('/bookings/my-bookings', { params }),
  get: (id) => api.get(`/bookings/${id}`),
  cancel: (id) => api.put(`/bookings/${id}/cancel`),
  // Admin APIs
  adminList: (params) => api.get('/admin/bookings', { params }),
  adminGet: (id) => api.get(`/admin/bookings/${id}`),
  adminConfirm: (id) => api.put(`/admin/bookings/${id}/confirm`),
  adminHandover: (id) => api.put(`/admin/bookings/${id}/handover`),
  adminComplete: (id) => api.put(`/admin/bookings/${id}/complete`),
  adminCancel: (id) => api.put(`/admin/bookings/${id}/cancel`),
}

export const invoiceApi = {
  listMy: (params) => api.get('/invoices/my-invoices', { params }),
  get: (id) => api.get(`/invoices/${id}`),
  adminList: (params) => api.get('/admin/invoices', { params }),
}

export const paymentApi = {
  listMy: (params) => api.get('/payments/my-payments', { params }),
  get: (id) => api.get(`/payments/${id}`),
  adminList: (params) => api.get('/admin/payments', { params }),
  adminConfirm: (invoiceId, result) => api.put(`/admin/payments/confirm/${invoiceId}`, null, {
    params: { result }
  }),
  createVNPayUrl: (bookingId) => api.post(`/payments/vnpay/create/${bookingId}`)
}

export const adminUserApi = {
  list: (params) => api.get('/admin/users', { params }),
  get: (id) => api.get(`/admin/users/${id}`),
  toggle: (id, enabled) => api.put(`/admin/users/${id}/toggle`, null, { params: { enabled } }),
}

export const adminDashboardApi = {
  getStats: () => api.get('/admin/dashboard/stats'),
}

export const reviewApi = {
  create: (bookingId, data) => api.post(`/reviews/booking/${bookingId}`, data),
  getForCar: (carId, params) => api.get(`/reviews/car/${carId}`, { params }),
  getForBooking: (bookingId) => api.get(`/reviews/booking/${bookingId}`),
}



export default api
