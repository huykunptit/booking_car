import { createRouter, createWebHistory } from 'vue-router'
import Home from '@/pages/Home.vue'

const routes = [
  {
    path: '/',
    name: 'Home',
    component: Home
  },
  {
    path: '/browse',
    name: 'Browse',
    component: () => import('@/pages/Browse.vue')
  },
  {
    path: '/become-owner',
    name: 'BecomeOwner',
    component: () => import('@/pages/BecomeOwner.vue')
  },
  {
    path: '/car/:id',
    name: 'CarDetail',
    component: () => import('@/pages/CarDetail.vue')
  },
  {
    path: '/auth/login',
    name: 'Login',
    component: () => import('@/pages/Login.vue'),
    meta: { guestOnly: true }
  },
  {
    path: '/auth/register',
    name: 'Register',
    component: () => import('@/pages/Register.vue'),
    meta: { guestOnly: true }
  },
  {
    path: '/auth/forgot-password',
    name: 'ForgotPassword',
    component: () => import('@/pages/ForgotPassword.vue'),
    meta: { guestOnly: true }
  },
  {
    path: '/auth/reset-password',
    name: 'ResetPassword',
    component: () => import('@/pages/ResetPassword.vue'),
    meta: { guestOnly: true }
  },
  {
    path: '/profile',
    name: 'Profile',
    component: () => import('@/pages/Profile.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/my-bookings',
    name: 'MyBookings',
    component: () => import('@/pages/MyBookings.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/my-bookings/:id',
    name: 'BookingDetail',
    component: () => import('@/pages/BookingDetail.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/my-invoices',
    name: 'MyInvoices',
    component: () => import('@/pages/MyInvoices.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/my-payments',
    name: 'MyPayments',
    component: () => import('@/pages/MyPayments.vue'),
    meta: { requiresAuth: true }
  },
  {
    path: '/admin',
    component: () => import('@/layouts/AdminLayout.vue'),
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: '',
        name: 'AdminDashboard',
        component: () => import('@/pages/admin/Dashboard.vue')
      },
      {
        path: 'cars',
        name: 'AdminCars',
        component: () => import('@/pages/admin/CarManagement.vue')
      },
      {
        path: 'cars/new',
        name: 'AdminCarCreate',
        component: () => import('@/pages/admin/CarForm.vue')
      },
      {
        path: 'cars/edit/:id',
        name: 'AdminCarEdit',
        component: () => import('@/pages/admin/CarForm.vue')
      },
      {
        path: 'cars/:carId/images',
        name: 'AdminCarImages',
        component: () => import('@/pages/admin/CarImages.vue')
      },
      {
        path: 'bookings',
        name: 'AdminBookings',
        component: () => import('@/pages/admin/BookingManagement.vue')
      },
      {
        path: 'payments',
        name: 'AdminPayments',
        component: () => import('@/pages/admin/PaymentManagement.vue')
      },
      {
        path: 'users',
        name: 'AdminUsers',
        component: () => import('@/pages/admin/UserManagement.vue')
      }
    ]
  },
  {
    path: '/:pathMatch(.*)*',
    name: 'NotFound',
    component: () => import('@/pages/NotFound.vue')
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior() {
    return { top: 0 }
  }
})

// Route guards
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  const user = JSON.parse(localStorage.getItem('user') || 'null')

  // Block authenticated users from guest-only pages (login/register)
  if (to.meta.guestOnly && token) {
    return next({ name: 'Home' })
  }

  // Redirect to login if auth required
  if (to.meta.requiresAuth && !token) {
    return next({ name: 'Login', query: { redirect: to.fullPath } })
  }

  // Redirect non-admin from admin pages
  if (to.meta.requiresAdmin && user?.role !== 'ADMIN') {
    return next({ name: 'Home' })
  }

  next()
})

export default router
