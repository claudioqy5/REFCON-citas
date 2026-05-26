import { createRouter, createWebHistory } from 'vue-router'
import Login from '../views/Login.vue'
import Dashboard from '../views/Dashboard.vue'
import History from '../views/History.vue'
import { useAuthStore } from '../stores/auth'

import AdminEstablecimientos from '../views/AdminEstablecimientos.vue'
import AdminUsuarios from '../views/AdminUsuarios.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/login',
      name: 'login',
      component: Login
    },
    {
      path: '/',
      name: 'dashboard',
      component: Dashboard,
      meta: { requiresAuth: true }
    },
    {
      path: '/history',
      name: 'history',
      component: History,
      meta: { requiresAuth: true }
    },
    {
      path: '/admin/establecimientos',
      name: 'admin-establecimientos',
      component: AdminEstablecimientos,
      meta: { requiresAuth: true, requiresAdmin: true }
    },
    {
      path: '/admin/usuarios',
      name: 'admin-usuarios',
      component: AdminUsuarios,
      meta: { requiresAuth: true, requiresAdmin: true }
    }
  ]
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else if (to.meta.requiresAdmin && !authStore.isAdmin) {
    next('/')
  } else {
    next()
  }
})

export default router
