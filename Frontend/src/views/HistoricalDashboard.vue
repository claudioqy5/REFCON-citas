<template>
  <div class="dashboard-container">
    <!-- WELCOME HEADER (Historical Control) -->
    <div class="welcome-header glass-panel">
      <div class="welcome-text-container">
        <h1>Hola, {{ authStore.user?.nombreCompleto || 'Usuario' }} 👋</h1>
        <p class="welcome-subtitle">
          Panel de Control Histórico y Reporte General de <strong>{{ establishmentNombre || authStore.user?.establecimientoNombre || 'Establecimiento de Salud' }}</strong>
        </p>
        <div class="welcome-meta-row">
          <div class="welcome-date">
            <span class="calendar-icon">📊</span> Resumen Histórico Consolidado
          </div>
        </div>
      </div>

      <!-- Prominent Action Indicator -->
      <div class="header-action-container">
        <div class="status-pill status-success">
          <span class="status-dot"></span>
          <span class="status-text">Datos en Tiempo Real</span>
        </div>
      </div>
    </div>

    <!-- 1. METRICS GRID (All-Time General Analytics) -->
    <div class="metrics-grid">
      <div class="metric-card glass-panel">
        <div class="metric-icon bg-indigo-light">👥</div>
        <div class="metric-info">
          <span class="metric-label">Total Pacientes Registrados</span>
          <span class="metric-value">{{ totalPatients }}</span>
        </div>
      </div>
      
      <div class="metric-card glass-panel">
        <div class="metric-icon bg-blue-light">💬</div>
        <div class="metric-info">
          <span class="metric-label">Total Mensajes Enviados</span>
          <span class="metric-value">{{ totalMessages }}</span>
        </div>
      </div>

      <div class="metric-card glass-panel">
        <div class="metric-icon bg-green-light">✅</div>
        <div class="metric-info">
          <span class="metric-label">Total Envíos Exitosos</span>
          <span class="metric-value">{{ successfulMessages }}</span>
        </div>
      </div>

      <div class="metric-card glass-panel">
        <div class="metric-icon bg-red-light">❌</div>
        <div class="metric-info">
          <span class="metric-label">Total Envíos Fallidos</span>
          <span class="metric-value">{{ failedMessages }}</span>
        </div>
      </div>
    </div>

    <!-- 3. CHARTS SECTION -->
    <div class="charts-grid">
      <!-- Weekly Aggregate Chart -->
      <div class="glass-panel chart-card">
        <div class="chart-header-row">
          <div class="chart-title-col">
            <h3>Envíos por Día (Acumulado)</h3>
            <p class="chart-subtitle">Resumen histórico de envíos de Lunes a Domingo</p>
          </div>
        </div>
        <div class="bar-chart">
          <div v-for="(day, index) in daysOfWeek" :key="day" class="bar-wrapper">
            <div 
              class="bar" 
              v-if="weeklyCounts[index] > 0"
              :style="{ 
                height: getBarHeight(weeklyCounts[index]),
                backgroundColor: barColors[index]
              }"
            >
              <div class="bar-tooltip">{{ weeklyCounts[index] }} mensajes</div>
            </div>
            <span class="bar-label">{{ day.substring(0, 3) }}</span>
          </div>
        </div>
      </div>

      <!-- Specialties Chart (All-Time Donut) -->
      <div class="glass-panel chart-card">
        <div class="chart-header-row">
          <div class="chart-title-col">
            <h3>Distribución Histórica</h3>
            <p class="chart-subtitle">Todas las especialidades registradas en el historial</p>
          </div>
        </div>
        
        <div class="specialty-horizontal-chart-container" v-if="allSpecialties.length > 0">
          <div class="specialty-list-scrollable">
            <div 
              v-for="(spec, index) in allSpecialties" 
              :key="spec.name" 
              class="horizontal-bar-row"
            >
              <div class="bar-info">
                <span class="bar-spec-name">{{ spec.name }}</span>
                <span class="bar-spec-count">
                  <strong>{{ spec.count }}</strong> {{ spec.count === 1 ? 'envío' : 'envíos' }}
                </span>
              </div>
              <div class="bar-track">
                <div 
                  class="bar-fill" 
                  :style="{ 
                    width: (spec.count / maxSpecialtyCount * 100) + '%',
                    background: getSpecialtyBarColor(index)
                  }"
                ></div>
              </div>
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
const history = ref([])
const patients = ref([])
const establishmentNombre = ref('')
let pollInterval = null

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

// Metrics computation (All-time aggregates)
const totalPatients = computed(() => patients.value.length)
const totalMessages = computed(() => history.value.length)
const successfulMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Enviado').length)
const failedMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Error').length)

// Vibrant distinct colors for bar chart days of week
const barColors = [
  '#6366f1', // Lunes (Indigo)
  '#3b82f6', // Martes (Blue)
  '#10b981', // Miércoles (Emerald)
  '#f59e0b', // Jueves (Amber)
  '#ec4899', // Viernes (Pink)
  '#8b5cf6', // Sábado (Purple)
  '#14b8a6'  // Domingo (Teal)
]

// Weekly Chart computations (All-Time)
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
  const percentage = (count / max) * 90 
  return `${Math.max(percentage, 5)}%`
}

// Specialty Chart computations (All Specialties Horizontal Bars)
const allSpecialties = computed(() => {
  const specMap = {}
  history.value.forEach(item => {
    if (item.especialidad) {
      const spec = item.especialidad.trim() || 'General'
      specMap[spec] = (specMap[spec] || 0) + 1
    }
  })
  return Object.keys(specMap).map(name => ({
    name,
    count: specMap[name]
  })).sort((a, b) => b.count - a.count)
})

const maxSpecialtyCount = computed(() => {
  const max = Math.max(...allSpecialties.value.map(s => s.count), 0)
  return max === 0 ? 1 : max
})

const getSpecialtyBarColor = (index) => {
  const colors = [
    'linear-gradient(90deg, #6366f1 0%, #a5b4fc 100%)', // Indigo
    'linear-gradient(90deg, #10b981 0%, #6ee7b7 100%)', // Emerald
    'linear-gradient(90deg, #3b82f6 0%, #93c5fd 100%)', // Blue
    'linear-gradient(90deg, #f59e0b 0%, #fde68a 100%)', // Amber
    'linear-gradient(90deg, #ec4899 0%, #fbcfe8 100%)', // Pink
    'linear-gradient(90deg, #8b5cf6 0%, #c7d2fe 100%)', // Purple
    'linear-gradient(90deg, #14b8a6 0%, #99f6e4 100%)'  // Teal
  ]
  return colors[index % colors.length]
}

const fetchData = async () => {
  try {
    const [resHistory, resPatients, resEst] = await Promise.all([
      api.get('/reminders/history'),
      api.get('/reminders/patients'),
      api.get('/reminders/establishment')
    ])
    history.value = resHistory.data
    patients.value = resPatients.data
    if (resEst.data && resEst.data.name) {
      establishmentNombre.value = resEst.data.name
    }
  } catch (err) {
    console.error('Error fetching historical dashboard data', err)
  }
}

onMounted(() => {
  fetchData()
  pollInterval = setInterval(fetchData, 8000) // Slightly longer poll for historical view
})

onUnmounted(() => {
  if (pollInterval) clearInterval(pollInterval)
})
</script>

<style scoped>
.dashboard-container {
  display: flex;
  flex-direction: column;
  gap: 2vh;  
  margin: 0 auto;
  width: 100%;
  height: calc(100vh - 2.5rem);
  box-sizing: border-box;
}

/* Welcome Header Style */
.welcome-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5vh 2.5rem;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.7) 0%, rgba(255, 255, 255, 0.4) 100%);
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.02);
  gap: 2rem;
  box-sizing: border-box;
}

.welcome-header h1 {
  font-size: 1.75rem;
  font-weight: 700;
  margin: 0 0 0.35rem 0;
  color: var(--text-h);
}

.welcome-subtitle {
  font-size: 0.95rem;
  color: var(--text-muted);
  margin: 0 0 1rem 0;
}

.welcome-meta-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-wrap: wrap;
}

.welcome-date {
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--primary-color);
  background: var(--primary-light);
  padding: 0.45rem 1rem;
  border-radius: 9999px;
  display: flex;
  align-items: center;
  gap: 0.4rem;
  box-shadow: 0 2px 10px rgba(99, 102, 241, 0.05);
}

.calendar-icon {
  font-size: 0.95rem;
}

.header-action-container {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.5rem;
  flex-shrink: 0;
}

/* Premium Status Pill */
.status-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.45rem 1rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.75px;
  border: 1px solid transparent;
  transition: all 0.3s ease;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.02);
}

.status-pill .status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
}

.status-success {
  background: #d1fae5;
  color: #059669;
  border-color: #6ee7b7;
}
.status-success .status-dot {
  background: #059669;
}

/* 1. METRICS STYLE */
.metrics-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
  gap: 1.5rem;
  width: 100%;
  box-sizing: border-box;
}
.metric-card {
  display: flex;
  align-items: center;
  gap: 1.25rem;
  padding: 1.2vh 1.5rem;
  box-sizing: border-box;
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

/* 3. CHARTS STYLE */
.charts-grid {
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 1.5rem;
  width: 100%;
  flex-grow: 1; /* Stretch to fill remaining viewport height */
  min-height: 0; /* Prevents layout overflow */
  box-sizing: border-box;
}
.chart-card {
  padding: 2vh 2rem;
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  height: 100%;
  box-sizing: border-box;
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
  height: auto;
  flex-grow: 1;
  min-height: 250px;
  padding-top: 1vh;
  border-bottom: 1px solid var(--border-color);
  width: 100%;
}
.bar-wrapper {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-end;
  height: 100%;
  flex: 1;
  position: relative;
  cursor: pointer;
}
.bar {
  width: 28px; /* Slightly wider bar */
  border-radius: 6px 6px 0 0;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  min-height: 4px;
  position: relative;
  display: flex;
  justify-content: center;
}
.bar:hover {
  filter: brightness(1.15);
  transform: scaleY(1.05);
}
.bar-tooltip {
  position: absolute;
  top: auto;
  bottom: 100%;
  margin-bottom: 8px;
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
.bar:hover .bar-tooltip {
  opacity: 1;
}
.bar-label {
  margin-top: 0.5rem;
  font-size: 0.8rem;
  color: var(--text-muted);
  font-weight: 500;
}

/* Premium Filter Layout */
.chart-header-row {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  margin-bottom: 1.5vh;
}

.chart-title-col {
  display: flex;
  flex-direction: column;
}

.chart-title-col h3 {
  margin: 0 0 0.25rem 0 !important;
}

.chart-title-col .chart-subtitle {
  margin: 0 !important;
}

/* Premium Donut Chart Layout */
.donut-chart-container {
  display: flex;
  flex-direction: row;
  align-items: center;
  justify-content: space-around;
  gap: 1.5rem;
  flex-grow: 1;
  height: 100%;
}

.donut-svg-wrapper {
  height: 25vh; /* Fluid sizing relative to viewport height */
  width: 25vh;
  max-height: 200px;
  max-width: 200px;
  min-height: 120px;
  min-width: 120px;
  flex-shrink: 0;
  position: relative;
}

.donut-svg {
  width: 100%;
  height: 100%;
}

.donut-slice {
  transition: stroke-width 0.3s ease, filter 0.3s ease;
}

.donut-slice:hover {
  stroke-width: 13;
  filter: drop-shadow(0px 2px 4px rgba(0,0,0,0.15));
  cursor: pointer;
}

.donut-center-text {
  user-select: none;
  pointer-events: none;
}

.donut-total-num {
  font-size: 1.5rem;
  font-weight: 800;
  fill: var(--text-h);
}

.donut-total-label {
  font-size: 0.55rem;
  font-weight: 700;
  fill: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 1px;
}

/* Horizontal Bar Chart Styles */
.specialty-horizontal-chart-container {
  display: flex;
  flex-direction: column;
  flex-grow: 1;
  width: 100%;
  box-sizing: border-box;
}

.specialty-list-scrollable {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  max-height: 250px;
  overflow-y: auto;
  padding-right: 0.5rem;
  margin-top: 0.5rem;
}

.horizontal-bar-row {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  width: 100%;
}

.bar-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-size: 0.85rem;
}

.bar-spec-name {
  font-weight: 700;
  color: var(--text-h);
}

.bar-spec-count {
  color: var(--text-muted);
  font-size: 0.8rem;
}

.bar-track {
  height: 10px;
  background: rgba(0, 0, 0, 0.05);
  border-radius: 999px;
  overflow: hidden;
  width: 100%;
  position: relative;
}

.bar-fill {
  height: 100%;
  border-radius: 999px;
  transition: width 1s cubic-bezier(0.16, 1, 0.3, 1);
}

.empty-chart {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 150px;
  color: var(--text-muted);
  font-size: 0.9rem;
}

@media (max-width: 768px) {
  .welcome-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1.5rem;
    padding: 1.5rem;
  }
  .header-action-container {
    align-items: flex-start;
    width: 100%;
  }
}
</style>
