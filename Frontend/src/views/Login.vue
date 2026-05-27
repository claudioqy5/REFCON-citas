<template>
  <div class="login-container">
    <div class="login-box glass-panel">
      <div class="login-header">
        <h2>Bienvenido</h2>
        <p>Inicia sesión en tu centro de salud</p>
      </div>
      
      <form @submit.prevent="handleLogin" class="login-form">
        <div class="form-group">
          <label>Email</label>
          <input type="email" v-model="email" required placeholder="tu@email.com" />
        </div>
        <div class="form-group">
          <label>Contraseña</label>
          <input type="password" v-model="password" required placeholder="••••••••" />
        </div>
        
        <div v-if="errorMsg" class="error-msg">
          {{ errorMsg }}
        </div>

        <button type="submit" class="btn btn-primary login-btn" :disabled="loading">
          <span v-if="loading">Cargando...</span>
          <span v-else>Ingresar</span>
        </button>
      </form>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const email = ref('')
const password = ref('')
const errorMsg = ref('')
const loading = ref(false)
const router = useRouter()
const authStore = useAuthStore()

const handleLogin = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
    // Port 5146 from launchSettings.json
    const response = await axios.post(`${import.meta.env.VITE_API_URL || 'http://localhost:5146/api'}/auth/login`, {
      email: email.value,
      password: password.value
    })
    
    authStore.setAuth(response.data)
    router.push('/')
  } catch (err) {
    errorMsg.value = err.response?.data?.message || 'Error al iniciar sesión'
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
}
.login-box {
  width: 100%;
  max-width: 400px;
  padding: 2.5rem;
}
.login-header {
  text-align: center;
  margin-bottom: 2rem;
}
.login-header h2 {
  font-size: 1.75rem;
  margin-bottom: 0.5rem;
  color: var(--text-main);
}
.login-header p {
  color: var(--text-muted);
}
.login-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}
.login-btn {
  width: 100%;
  margin-top: 1rem;
}
.error-msg {
  color: var(--danger-color);
  font-size: 0.875rem;
  text-align: center;
}
</style>
