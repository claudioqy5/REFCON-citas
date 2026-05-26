<template>
  <div class="dashboard-container">
    <div class="glass-panel main-panel">
      <h1>Panel de Control</h1>
      <p class="subtitle">Bienvenido, {{ authStore.user?.nombreCompleto }}</p>
      
      <div class="status-card" :class="statusClass">
        <div class="status-icon">
          <span v-if="currentStatus === 'Pendiente'">⏳</span>
          <span v-else-if="currentStatus === 'Procesando'">⚙️</span>
          <span v-else-if="currentStatus === 'Completado'">✅</span>
          <span v-else-if="currentStatus === 'Fallido'">❌</span>
          <span v-else>💡</span>
        </div>
        <div class="status-info">
          <h3>Estado del Envío</h3>
          <p>{{ statusText }}</p>
        </div>
      </div>

      <div class="action-section">
        <button 
          @click="triggerReminders" 
          class="btn btn-primary trigger-btn"
          :disabled="isProcessing"
        >
          {{ isProcessing ? 'Enviando recordatorios...' : 'Iniciar Envío de Recordatorios' }}
        </button>
        <p v-if="errorMsg" class="error-msg">{{ errorMsg }}</p>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()
const currentStatus = ref('Ninguno')
const errorMsg = ref('')
let pollInterval = null

const api = axios.create({
  baseURL: 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

const isProcessing = computed(() => {
  return currentStatus.value === 'Pendiente' || currentStatus.value === 'Procesando'
})

const statusClass = computed(() => {
  if (isProcessing.value) return 'status-processing'
  if (currentStatus.value === 'Completado') return 'status-success'
  if (currentStatus.value === 'Fallido') return 'status-error'
  return 'status-idle'
})

const statusText = computed(() => {
  if (currentStatus.value === 'Ninguno') return 'Listo para iniciar envíos'
  return currentStatus.value
})

const fetchStatus = async () => {
  try {
    const res = await api.get('/reminders/status')
    currentStatus.value = res.data.estado
  } catch (err) {
    console.error('Error fetching status', err)
  }
}

const triggerReminders = async () => {
  errorMsg.value = ''
  try {
    await api.post('/reminders/trigger')
    await fetchStatus()
  } catch (err) {
    errorMsg.value = err.response?.data?.message || 'Error al iniciar envíos'
  }
}

onMounted(() => {
  fetchStatus()
  pollInterval = setInterval(fetchStatus, 5000)
})

onUnmounted(() => {
  if (pollInterval) clearInterval(pollInterval)
})
</script>

<style scoped>
.dashboard-container {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  padding-top: 2rem;
}
.main-panel {
  width: 100%;
  max-width: 600px;
  padding: 2.5rem;
  text-align: center;
}
.subtitle {
  color: var(--text-muted);
  margin-bottom: 2.5rem;
}
.status-card {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1.5rem;
  border-radius: 12px;
  background: var(--primary-light);
  margin-bottom: 2.5rem;
  border: 1px solid transparent;
  transition: all 0.3s ease;
}
.status-idle { border-color: var(--border-color); }
.status-processing { 
  border-color: var(--warning-color);
  animation: pulse-border 2s infinite;
}
.status-success { border-color: var(--success-color); }
.status-error { border-color: var(--danger-color); }

@keyframes pulse-border {
  0% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.4); }
  70% { box-shadow: 0 0 0 10px rgba(245, 158, 11, 0); }
  100% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0); }
}

.status-icon {
  font-size: 2.5rem;
}
.status-info {
  text-align: left;
}
.status-info h3 {
  margin-bottom: 0.25rem;
  font-size: 1.1rem;
}
.status-info p {
  color: var(--text-muted);
  font-size: 0.95rem;
}
.trigger-btn {
  font-size: 1.1rem;
  padding: 1rem 2rem;
  width: 100%;
}
.error-msg {
  color: var(--danger-color);
  margin-top: 1rem;
}
</style>
