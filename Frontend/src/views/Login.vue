<template>
  <div class="login-page-wrapper">
    <div class="login-card-container">
      <!-- Left Pane: Info & Spheres -->
      <div class="login-left-pane">
        <div class="sphere sphere-1"></div>
        <div class="sphere sphere-2"></div>
        <div class="sphere sphere-3"></div>
        
        <div class="brand-info">
          <span class="brand-tag">REFCON Citas v2.0</span>
          <h1 class="brand-headline">BIENVENIDO A TU GESTOR DE CITAS</h1>
          <p class="brand-description">
            Plataforma avanzada para la gestión de pacientes y envío automático de recordatorios de citas por WhatsApp.
          </p>
        </div>
      </div>
      
      <!-- Right Pane: Form -->
      <div class="login-right-pane">
        <div class="login-header">
          <h2>Iniciar Sesión</h2>
          <p>Ingresa tus credenciales de acceso</p>
        </div>
        
        <form @submit.prevent="handleLogin" class="login-form">
          <div class="input-field-wrapper">
            <span class="input-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M3 14s-1 0-1-1 1-4 6-4 6 3 6 4-1 1-1 1zm5-6a3 3 0 1 0 0-6 3 3 0 0 0 0 6"/>
              </svg>
            </span>
            <input 
              type="email" 
              v-model="email" 
              required 
              placeholder="Correo Electrónico" 
              class="custom-input"
            />
          </div>
          
          <div class="input-field-wrapper">
            <span class="input-icon">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                <path d="M8 1a2 2 0 0 1 2 2v4H6V3a2 2 0 0 1 2-2m3 6V3a3 3 0 0 0-6 0v4a2 2 0 0 0-2 2v5a2 2 0 0 0 2 2h6a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2"/>
              </svg>
            </span>
            <input 
              :type="showPassword ? 'text' : 'password'" 
              v-model="password" 
              required 
              placeholder="Contraseña" 
              class="custom-input"
            />
            <button 
              type="button" 
              class="btn-toggle-password" 
              @click="showPassword = !showPassword"
            >
              {{ showPassword ? 'OCULTAR' : 'MOSTRAR' }}
            </button>
          </div>

          <div class="form-options-row">
            <label class="remember-me-label">
              <input type="checkbox" v-model="rememberMe" />
              <span>Recordarme</span>
            </label>
            <a href="#" class="forgot-password-link">¿Olvidaste tu contraseña?</a>
          </div>
          
          <div v-if="errorMsg" class="error-msg-banner">
            ⚠️ {{ errorMsg }}
          </div>

          <button type="submit" class="btn-submit-login" :disabled="loading">
            <span v-if="loading" class="spinner-small"></span>
            <span>{{ loading ? 'Ingresando...' : 'Iniciar Sesión' }}</span>
          </button>
        </form>

        <div class="or-separator">
          <span class="line"></span>
          <span class="text">INFORMACIÓN</span>
          <span class="line"></span>
        </div>

        <div class="notice-footer">
          <p>Acceso exclusivo para personal de salud autorizado del establecimiento.</p>
        </div>
      </div>
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
const showPassword = ref(false)
const rememberMe = ref(false)
const router = useRouter()
const authStore = useAuthStore()

const handleLogin = async () => {
  loading.value = true
  errorMsg.value = ''
  try {
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
.login-page-wrapper {
  min-height: 100vh;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  background: linear-gradient(135deg, #0076FF 0%, #0045B5 100%);
  padding: 1.5rem;
  box-sizing: border-box;
}

.login-card-container {
  display: flex;
  width: 100%;
  max-width: 900px;
  background: #FFFFFF;
  border-radius: 24px;
  overflow: hidden;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
  min-height: 520px;
}

/* Left Pane Style (Blue Spheres Background) */
.login-left-pane {
  flex: 1;
  background: linear-gradient(135deg, #0088FF 0%, #0055D4 100%);
  padding: 3rem 2.5rem;
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  justify-content: center;
  color: #FFFFFF;
}

/* 3D Spheres */
.sphere {
  position: absolute;
  border-radius: 50%;
  background: radial-gradient(circle at 30% 30%, #00C6FF 0%, #0072FF 60%, #0052D4 100%);
  box-shadow: -10px 10px 30px rgba(0,0,0,0.15), inset -10px -10px 30px rgba(0,0,0,0.3);
}

.sphere-1 {
  width: 180px;
  height: 180px;
  right: -40px;
  top: -20px;
  background: radial-gradient(circle at 30% 30%, #00aaff 0%, #0066ee 70%, #0044cc 100%);
}

.sphere-2 {
  width: 140px;
  height: 140px;
  left: -50px;
  bottom: -30px;
}

.sphere-3 {
  width: 120px;
  height: 120px;
  bottom: 60px;
  right: 20px;
}

.brand-info {
  position: relative;
  z-index: 10;
  max-width: 320px;
}

.brand-tag {
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(5px);
  padding: 0.35rem 0.85rem;
  border-radius: 999px;
  font-size: 0.75rem;
  font-weight: 700;
  letter-spacing: 0.5px;
  display: inline-block;
  margin-bottom: 1.5rem;
}

.brand-headline {
  font-size: 2rem;
  font-weight: 800;
  line-height: 1.25;
  margin: 0 0 1rem 0;
  letter-spacing: -0.5px;
}

.brand-description {
  font-size: 0.9rem;
  line-height: 1.5;
  opacity: 0.9;
  margin: 0;
}

/* Right Pane Style (White Form) */
.login-right-pane {
  width: 460px;
  padding: 3rem 3.5rem;
  background: #FFFFFF;
  display: flex;
  flex-direction: column;
  justify-content: center;
  box-sizing: border-box;
}

.login-header {
  margin-bottom: 2rem;
}

.login-header h2 {
  font-size: 1.85rem;
  font-weight: 800;
  color: #0F172A;
  margin: 0 0 0.4rem 0;
}

.login-header p {
  font-size: 0.85rem;
  color: #64748B;
  margin: 0;
}

.login-form {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.input-field-wrapper {
  position: relative;
  display: flex;
  align-items: center;
  background: #F1F5F9;
  border-radius: 12px;
  transition: all 0.2s ease;
}

.input-field-wrapper:focus-within {
  background: #E2E8F0;
  box-shadow: 0 0 0 2px #0076FF;
}

.input-icon {
  position: absolute;
  left: 1rem;
  color: #64748B;
  display: flex;
  align-items: center;
  justify-content: center;
}

.custom-input {
  width: 100%;
  border: none;
  background: transparent;
  padding: 0.9rem 1rem 0.9rem 2.75rem;
  font-size: 0.9rem;
  color: #0F172A;
  font-weight: 600;
  outline: none;
  box-sizing: border-box;
}

.custom-input::placeholder {
  color: #94A3B8;
  font-weight: 500;
}

.btn-toggle-password {
  position: absolute;
  right: 1rem;
  background: transparent;
  border: none;
  font-size: 0.7rem;
  font-weight: 800;
  color: #0055D4;
  cursor: pointer;
  outline: none;
}

.form-options-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.8rem;
  margin: 0.25rem 0;
}

.remember-me-label {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  color: #64748B;
  cursor: pointer;
  font-weight: 600;
}

.forgot-password-link {
  color: #0055D4;
  text-decoration: none;
  font-weight: 700;
}

.forgot-password-link:hover {
  text-decoration: underline;
}

.error-msg-banner {
  background: #FEF2F2;
  border: 1px solid #FCA5A5;
  border-radius: 10px;
  color: #991B1B;
  padding: 0.75rem;
  font-size: 0.8rem;
  font-weight: 600;
  text-align: center;
}

.btn-submit-login {
  background: #0045B5;
  color: #FFFFFF;
  border: none;
  padding: 0.9rem;
  border-radius: 12px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(0, 69, 181, 0.2);
}

.btn-submit-login:hover:not(:disabled) {
  background: #003691;
  box-shadow: 0 6px 16px rgba(0, 69, 181, 0.35);
  transform: translateY(-1px);
}

.btn-submit-login:active:not(:disabled) {
  transform: translateY(0);
}

.btn-submit-login:disabled {
  background: #94A3B8;
  box-shadow: none;
  cursor: not-allowed;
}

.or-separator {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  margin: 1.5rem 0;
}

.or-separator .line {
  flex: 1;
  height: 1px;
  background: #E2E8F0;
}

.or-separator .text {
  font-size: 0.7rem;
  font-weight: 800;
  color: #94A3B8;
  letter-spacing: 1px;
}

.notice-footer {
  text-align: center;
}

.notice-footer p {
  font-size: 0.75rem;
  color: #94A3B8;
  line-height: 1.4;
  margin: 0;
  font-weight: 500;
}

.spinner-small {
  width: 14px;
  height: 14px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top-color: #FFFFFF;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}

@keyframes spin {
  to { transform: rotate(360deg); }
}

/* Responsive adjustments */
@media (max-width: 768px) {
  .login-card-container {
    flex-direction: column;
    max-width: 420px;
  }
  .login-left-pane {
    padding: 2.5rem 2rem;
  }
  .login-right-pane {
    width: 100%;
    padding: 2.5rem 2rem;
  }
  .brand-headline {
    font-size: 1.5rem;
  }
}
</style>
