import { defineStore } from 'pinia'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    token: localStorage.getItem('token') || null,
    user: JSON.parse(localStorage.getItem('user')) || null
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
    isAdmin: (state) => state.user?.rol === 'Admin'
  },
  actions: {
    setAuth(data) {
      this.token = data.token
      this.user = {
        usuarioID: data.usuarioID,
        establecimientoID: data.establecimientoID,
        nombreCompleto: data.nombreCompleto,
        rol: data.rol
      }
      localStorage.setItem('token', data.token)
      localStorage.setItem('user', JSON.stringify(this.user))
    },
    logout() {
      this.token = null
      this.user = null
      localStorage.removeItem('token')
      localStorage.removeItem('user')
    }
  }
})
