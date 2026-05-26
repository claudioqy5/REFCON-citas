<template>
  <div class="dashboard-container">
    <!-- 1. METRICS GRID -->
    <div class="metrics-grid">
      <div class="metric-card glass-panel">
        <div class="metric-icon bg-indigo-light">👥</div>
        <div class="metric-info">
          <span class="metric-label">Total Pacientes</span>
          <span class="metric-value">{{ totalPatients }}</span>
        </div>
      </div>
      
      <div class="metric-card glass-panel">
        <div class="metric-icon bg-blue-light">💬</div>
        <div class="metric-info">
          <span class="metric-label">Mensajes Enviados</span>
          <span class="metric-value">{{ totalMessages }}</span>
        </div>
      </div>

      <div class="metric-card glass-panel">
        <div class="metric-icon bg-green-light">✅</div>
        <div class="metric-info">
          <span class="metric-label">Envíos Exitosos</span>
          <span class="metric-value">{{ successfulMessages }}</span>
        </div>
      </div>

      <div class="metric-card glass-panel">
        <div class="metric-icon bg-red-light">❌</div>
        <div class="metric-info">
          <span class="metric-label">Envíos Fallidos</span>
          <span class="metric-value">{{ failedMessages }}</span>
        </div>
      </div>
    </div>

    <!-- 2. QUICK ACTIONS & STATUS -->
    <div class="action-grid">
      <div class="glass-panel main-panel">
        <h2>Envío Automático</h2>
        <p class="subtitle">Inicia el flujo de envío de recordatorios mediante n8n</p>
        
        <div class="status-card" :class="statusClass">
          <div class="status-icon">
            <span v-if="currentStatus === 'Pendiente'">⏳</span>
            <span v-else-if="currentStatus === 'Procesando'">⚙️</span>
            <span v-else-if="currentStatus === 'Completado'">✅</span>
            <span v-else-if="currentStatus === 'Fallido'">❌</span>
            <span v-else>💡</span>
          </div>
          <div class="status-info">
            <h3>Estado del Proceso</h3>
            <p>{{ statusText }}</p>
          </div>
        </div>

        <div class="action-section">
          <button 
            @click="triggerReminders" 
            class="btn btn-primary trigger-btn"
            :disabled="isProcessing"
          >
            {{ isProcessing ? 'Procesando recordatorios...' : 'Iniciar Envío por WhatsApp' }}
          </button>
          <p v-if="errorMsg" class="error-msg">{{ errorMsg }}</p>
        </div>
      </div>
    </div>

    <!-- 3. CHARTS SECTION -->
    <div class="charts-grid">
      <!-- Weekly Chart -->
      <div class="glass-panel chart-card">
        <h3>Mensajes de la Semana</h3>
        <p class="chart-subtitle">Mensajes enviados de Lunes a Domingo</p>
        <div class="bar-chart">
          <div v-for="(day, index) in daysOfWeek" :key="day" class="bar-wrapper">
            <div class="bar-tooltip">{{ weeklyCounts[index] }} mensajes</div>
            <div 
              class="bar" 
              :style="{ height: getBarHeight(weeklyCounts[index]) }"
            ></div>
            <span class="bar-label">{{ day.substring(0, 3) }}</span>
          </div>
        </div>
      </div>

      <!-- Specialties Chart -->
      <div class="glass-panel chart-card">
        <h3>Distribución por Especialidad</h3>
        <p class="chart-subtitle">Especialidades con mayor número de envíos</p>
        <div class="specialty-list" v-if="topSpecialties.length > 0">
          <div v-for="spec in topSpecialties" :key="spec.name" class="specialty-row">
            <div class="specialty-info">
              <span class="spec-name">{{ spec.name }}</span>
              <span class="spec-count">{{ spec.count }} envíos</span>
            </div>
            <div class="progress-bar-bg">
              <div class="progress-bar" :style="{ width: getProgressWidth(spec.count) }"></div>
            </div>
          </div>
        </div>
        <div v-else class="empty-chart">
          Sin registros en el historial médico.
        </div>
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
const history = ref([])
const patients = ref([])
let pollInterval = null

const api = axios.create({
  baseURL: 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

// Metrics computation
const totalPatients = computed(() => patients.value.length)
const totalMessages = computed(() => history.value.length)
const successfulMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Enviado').length)
const failedMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Error').length)

// Weekly Chart computations
const daysOfWeek = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
const weeklyCounts = computed(() => {
  const counts = [0, 0, 0, 0, 0, 0, 0]
  history.value.forEach(item => {
    if (item.fechaHoraEnvio) {
      const day = new Date(item.fechaHoraEnvio).getDay() // 0 = Sun, 1 = Mon...
      const index = day === 0 ? 6 : day - 1
      counts[index]++
    }
  })
  return counts
})

const getBarHeight = (count) => {
  const max = Math.max(...weeklyCounts.value, 1)
  const percentage = (count / max) * 150 // max height 150px
  return `${Math.max(percentage, 6)}px`
}

// Specialty Chart computations
const topSpecialties = computed(() => {
  const specMap = {}
  history.value.forEach(item => {
    if (item.especialidad) {
      specMap[item.especialidad] = (specMap[item.especialidad] || 0) + 1
    }
  })
  return Object.keys(specMap).map(name => ({
    name,
    count: specMap[name]
  })).sort((a, b) => b.count - a.count).slice(0, 4)
})

const getProgressWidth = (count) => {
  if (topSpecialties.value.length === 0) return '0%'
  const max = topSpecialties.value[0].count
  const percentage = (count / max) * 100
  return `${percentage}%`
}

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

const fetchData = async () => {
  try {
    const [resStatus, resHistory, resPatients] = await Promise.all([
      api.get('/reminders/status'),
      api.get('/reminders/history'),
      api.get('/reminders/patients')
    ])
    currentStatus.value = resStatus.data.estado
    history.value = resHistory.data
    patients.value = resPatients.data
  } catch (err) {
    console.error('Error fetching dashboard data', err)
  }
}

const triggerReminders = async () => {
  errorMsg.value = ''
  try {
    await api.post('/reminders/trigger')
    await fetchData()
  } catch (err) {
    errorMsg.value = err.response?.data?.message || 'Error al iniciar envíos'
  }
}

onMounted(() => {
  fetchData()
  pollInterval = setInterval(fetchData, 5000)
})

onUnmounted(() => {
  if (pollInterval) clearInterval(pollInterval)
})
</script>

<style scoped>
.dashboard-container {
  display: flex;
  flex-direction: column;
  gap: 2rem;
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
}

/* 1. METRICS STYLE */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.5rem;
  width: 100%;
}
.metric-card {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 1.5rem;
}
.metric-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.5rem;
}
.bg-indigo-light { background: rgba(99, 102, 241, 0.1); color: var(--primary-color); }
.bg-blue-light { background: rgba(59, 130, 246, 0.1); color: #3B82F6; }
.bg-green-light { background: rgba(16, 185, 129, 0.1); color: #10B981; }
.bg-red-light { background: rgba(239, 68, 68, 0.1); color: #EF4444; }

.metric-info {
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}
.metric-label {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--text-muted);
}
.metric-value {
  font-size: 1.6rem;
  font-weight: 700;
  color: var(--text-main);
  line-height: 1;
}

/* 2. ACTION & STATUS PANELS */
.action-grid {
  width: 100%;
}
.main-panel {
  padding: 2.5rem;
  text-align: center;
}
.subtitle {
  color: var(--text-muted);
  margin-bottom: 2rem;
  font-size: 0.95rem;
}
.status-card {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 1.25rem 1.5rem;
  border-radius: 12px;
  background: var(--bg-color);
  margin-bottom: 2rem;
  border: 1px solid var(--border-color);
  transition: all 0.3s ease;
  max-width: 450px;
  margin-left: auto;
  margin-right: auto;
}
.status-processing { 
  border-color: var(--warning-color);
  animation: pulse-border 2s infinite;
}
.status-success { border-color: var(--success-color); }
.status-error { border-color: var(--danger-color); }

@keyframes pulse-border {
  0% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0.2); }
  70% { box-shadow: 0 0 0 10px rgba(245, 158, 11, 0); }
  100% { box-shadow: 0 0 0 0 rgba(245, 158, 11, 0); }
}

.status-icon {
  font-size: 2rem;
}
.status-info {
  text-align: left;
}
.status-info h3 {
  margin-bottom: 0.2rem;
  font-size: 1.05rem;
}
.status-info p {
  color: var(--text-muted);
  font-size: 0.9rem;
}
.trigger-btn {
  font-size: 1.05rem;
  padding: 0.85rem 2.5rem;
  max-width: 320px;
  width: 100%;
}
.error-msg {
  color: var(--danger-color);
  margin-top: 1rem;
  font-size: 0.9rem;
}

/* 3. CHARTS STYLE */
.charts-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
  gap: 1.5rem;
  width: 100%;
}
.chart-card {
  padding: 2rem;
  display: flex;
  flex-direction: column;
}
.chart-card h3 {
  font-size: 1.15rem;
  color: #0F172A;
  margin-bottom: 0.25rem;
}
.chart-subtitle {
  font-size: 0.85rem;
  color: var(--text-muted);
  margin-bottom: 1.5rem;
}

/* Weekly Chart Layout */
.bar-chart {
  display: flex;
  justify-content: space-between;
  align-items: flex-end;
  height: 180px;
  padding-top: 1rem;
  border-bottom: 1px solid var(--border-color);
}
.bar-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  flex: 1;
  position: relative;
  cursor: pointer;
}
.bar {
  width: 22px;
  background: var(--primary-color);
  border-radius: 6px 6px 0 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 4px;
}
.bar:hover {
  background: var(--primary-hover);
  transform: translateY(-2px);
}
.bar-tooltip {
  position: absolute;
  top: -35px;
  background: #1E293B;
  color: #FFFFFF;
  padding: 0.35rem 0.6rem;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  opacity: 0;
  pointer-events: none;
  transition: opacity 0.2s ease;
  white-space: nowrap;
  box-shadow: 0 4px 10px rgba(0,0,0,0.1);
  z-index: 10;
}
.bar-wrapper:hover .bar-tooltip {
  opacity: 1;
}
.bar-label {
  margin-top: 0.5rem;
  font-size: 0.8rem;
  color: var(--text-muted);
  font-weight: 500;
}

/* Specialty list layout */
.specialty-list {
  display: flex;
  flex-direction: column;
  gap: 1.1rem;
  justify-content: center;
  height: 100%;
}
.specialty-row {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}
.specialty-info {
  display: flex;
  justify-content: space-between;
  font-size: 0.85rem;
  font-weight: 500;
}
.spec-name {
  color: var(--text-main);
}
.spec-count {
  color: var(--text-muted);
}
.progress-bar-bg {
  width: 100%;
  height: 8px;
  background: #E2E8F0;
  border-radius: 9999px;
  overflow: hidden;
}
.progress-bar {
  height: 100%;
  background: var(--primary-color);
  border-radius: 9999px;
  transition: width 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}
.empty-chart {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 150px;
  color: var(--text-muted);
  font-size: 0.9rem;
}
</style>
