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
        <div class="panel-header-row">
          <div>
            <h2>Envío Automático</h2>
            <p class="subtitle">Inicia el flujo de envío de recordatorios de citas vía WhatsApp</p>
          </div>
          <button 
            @click="triggerReminders" 
            class="btn btn-primary trigger-btn"
            :disabled="isProcessing"
          >
            <span v-if="isProcessing" class="spinner"></span>
            {{ isProcessing ? 'Procesando...' : '▶ Iniciar Envío' }}
          </button>
        </div>

        <!-- CONFIGURACIÓN DE ENVÍO AUTOMÁTICO -->
        <div class="auto-send-settings">
          <div class="settings-row">
            <label class="switch">
              <input type="checkbox" v-model="envioAutomatico" @change="saveSettings" :disabled="isUpdatingSettings">
              <span class="slider round"></span>
            </label>
            <div class="settings-text">
              <span class="settings-label">Activar envío automático diario (8:00 AM)</span>
              <span class="settings-desc">El sistema consultará citas en REFCON y enviará los mensajes de forma autónoma cada mañana.</span>
            </div>
          </div>
        </div>

        <!-- Estado de la última ejecución -->
        <div class="exec-status-card" :class="statusClass">
          <!-- Ícono + título -->
          <div class="exec-header">
            <div class="exec-icon">
              <span v-if="currentStatus === 'Pendiente'">⏳</span>
              <span v-else-if="currentStatus === 'Procesando'">⚙️</span>
              <span v-else-if="currentStatus === 'Completado'">✅</span>
              <span v-else-if="currentStatus === 'SinPacientes'">📭</span>
              <span v-else-if="currentStatus === 'Error'">❌</span>
              <span v-else>💡</span>
            </div>
            <div>
              <h3 class="exec-title">{{ statusTitle }}</h3>
              <p class="exec-subtitle">{{ statusText }}</p>
            </div>
            <span class="exec-badge" :class="statusClass">{{ currentStatus === 'Ninguno' ? 'Sin ejecuciones' : currentStatus }}</span>
          </div>

          <!-- Barra de progreso (solo en Procesando) -->
          <div v-if="currentStatus === 'Procesando'" class="progress-section">
            <div class="progress-track">
              <div class="progress-fill" :style="{ width: progressPercent + '%' }"></div>
            </div>
            <span class="progress-label">{{ lastPeticion?.totalEnviados ?? 0 }} de {{ lastPeticion?.totalPacientesNuevos ?? '?' }} mensajes</span>
          </div>

          <!-- Contadores de resultado (Completado o Error parcial) -->
          <div v-if="lastPeticion && (currentStatus === 'Completado' || currentStatus === 'Error')" class="exec-counters">
            <div class="counter-chip chip-sent">
              <span>✅</span> {{ lastPeticion.totalEnviados ?? 0 }} enviados
            </div>
            <div class="counter-chip chip-error" v-if="(lastPeticion.totalErrores ?? 0) > 0">
              <span>❌</span> {{ lastPeticion.totalErrores }} errores
            </div>
            <div class="counter-chip chip-total">
              <span>📋</span> {{ lastPeticion.totalPacientesNuevos ?? 0 }} pacientes
            </div>
          </div>

          <!-- Detalle del error crítico -->
          <div v-if="currentStatus === 'Error' && lastPeticion?.mensajeError" class="error-detail">
            <strong>📍 Etapa: {{ etapaLabel }}</strong>
            <p>{{ lastPeticion.mensajeError }}</p>
          </div>

          <!-- Fecha de la última ejecución -->
          <div v-if="lastPeticion?.fechaFinalizacion" class="exec-footer">
            Última ejecución: {{ formatDate(lastPeticion.fechaFinalizacion) }}
          </div>
        </div>

        <p v-if="errorMsg" class="error-msg">⚠️ {{ errorMsg }}</p>
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
const lastPeticion = ref(null)
const envioAutomatico = ref(false)
const isUpdatingSettings = ref(false)
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

// ── Métricas ─────────────────────────────────────────────────────────────────
const totalPatients = computed(() => patients.value.length)
const totalMessages = computed(() => history.value.length)
const successfulMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Enviado').length)
const failedMessages = computed(() => history.value.filter(m => m.estadoEnvio === 'Error').length)

// ── Gráfica semanal ───────────────────────────────────────────────────────────
const daysOfWeek = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']
const weeklyCounts = computed(() => {
  const counts = [0, 0, 0, 0, 0, 0, 0]
  history.value.forEach(item => {
    if (item.fechaHoraEnvio) {
      const day = new Date(item.fechaHoraEnvio).getDay()
      const index = day === 0 ? 6 : day - 1
      counts[index]++
    }
  })
  return counts
})
const getBarHeight = (count) => {
  const max = Math.max(...weeklyCounts.value, 1)
  return `${Math.max((count / max) * 150, 6)}px`
}

// ── Gráfica especialidades ────────────────────────────────────────────────────
const topSpecialties = computed(() => {
  const specMap = {}
  history.value.forEach(item => {
    if (item.especialidad) specMap[item.especialidad] = (specMap[item.especialidad] || 0) + 1
  })
  return Object.keys(specMap).map(name => ({ name, count: specMap[name] }))
    .sort((a, b) => b.count - a.count).slice(0, 4)
})
const getProgressWidth = (count) => {
  if (!topSpecialties.value.length) return '0%'
  return `${(count / topSpecialties.value[0].count) * 100}%`
}

// ── Estado de ejecución ───────────────────────────────────────────────────────
const isProcessing = computed(() =>
  currentStatus.value === 'Pendiente' || currentStatus.value === 'Procesando'
)

const statusClass = computed(() => ({
  'status-processing': isProcessing.value,
  'status-success':    currentStatus.value === 'Completado',
  'status-warning':    currentStatus.value === 'SinPacientes',
  'status-error':      currentStatus.value === 'Error',
  'status-idle':       currentStatus.value === 'Ninguno'
}))

const statusTitle = computed(() => {
  const map = {
    Ninguno:      'Sin ejecuciones recientes',
    Pendiente:    'Iniciando flujo...',
    Procesando:   'Enviando recordatorios',
    Completado:   'Proceso completado',
    SinPacientes: 'Sin pacientes nuevos',
    Error:        'Error en el flujo'
  }
  return map[currentStatus.value] ?? currentStatus.value
})

const statusText = computed(() => {
  const p = lastPeticion.value
  if (!p) return 'Presiona "Iniciar Envío" para ejecutar el proceso'
  if (currentStatus.value === 'Procesando') {
    const sent = p.totalEnviados ?? 0
    const total = p.totalPacientesNuevos ?? '?'
    return `Enviando mensaje ${sent + 1} de ${total}...`
  }
  if (currentStatus.value === 'Completado') {
    const errors = p.totalErrores ?? 0
    return errors > 0
      ? `✅ ${p.totalEnviados} enviados, ❌ ${errors} con error`
      : `Todos los mensajes enviados correctamente`
  }
  if (currentStatus.value === 'SinPacientes')
    return 'No se encontraron pacientes nuevos. Todos ya recibieron su recordatorio.'
  if (currentStatus.value === 'Error')
    return 'El flujo encontró un error. Ver detalles abajo.'
  return 'Listo para iniciar'
})

const progressPercent = computed(() => {
  const p = lastPeticion.value
  if (!p || !p.totalPacientesNuevos) return 0
  return Math.min(((p.totalEnviados ?? 0) / p.totalPacientesNuevos) * 100, 100)
})

const etapaLabel = computed(() => {
  const map = {
    RefconLogin:      'Inicio de sesión en REFCON',
    ObtenerPacientes: 'Consulta de pacientes en REFCON',
    SinPacientes:     'Filtrado de pacientes nuevos',
    EnviarWhatsApp:   'Envío de mensajes WhatsApp'
  }
  return map[lastPeticion.value?.etapaError] ?? lastPeticion.value?.etapaError ?? 'Desconocida'
})

const formatDate = (iso) => {
  if (!iso) return ''
  return new Date(iso).toLocaleString('es-PE', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

// ── Fetch de datos ────────────────────────────────────────────────────────────
const fetchData = async () => {
  try {
    const [resStatus, resHistory, resPatients] = await Promise.all([
      api.get('/reminders/status'),
      api.get('/reminders/history'),
      api.get('/reminders/patients')
    ])
    currentStatus.value = resStatus.data.estado
    lastPeticion.value  = resStatus.data.ultimaPeticion ?? null
    history.value       = resHistory.data
    patients.value      = resPatients.data
  } catch (err) {
    console.error('Error fetching dashboard data', err)
  }
}

// Cargar configuraciones del establecimiento (envío automático)
const loadSettings = async () => {
  try {
    const res = await api.get('/reminders/settings')
    envioAutomatico.value = res.data.envioAutomatico
  } catch (err) {
    console.error('Error loading settings', err)
  }
}

// Guardar configuraciones del establecimiento
const saveSettings = async () => {
  isUpdatingSettings.value = true
  errorMsg.value = ''
  try {
    await api.post('/reminders/settings', {
      envioAutomatico: envioAutomatico.value
    })
  } catch (err) {
    console.error('Error saving settings', err)
    errorMsg.value = 'Error al actualizar el envío automático diario.'
    // Revertir el estado si falla
    envioAutomatico.value = !envioAutomatico.value
  } finally {
    isUpdatingSettings.value = false
  }
}

// Polling inteligente: activo solo cuando está en proceso
const smartPoll = async () => {
  await Promise.all([fetchData(), loadSettings()])
  if (isProcessing.value) {
    pollInterval = setInterval(fetchData, 4000)
  }
}

const triggerReminders = async () => {
  errorMsg.value = ''
  try {
    await api.post('/reminders/trigger')
    await fetchData()
    // Activar polling mientras procesa
    if (!pollInterval) {
      pollInterval = setInterval(async () => {
        await fetchData()
        if (!isProcessing.value) {
          clearInterval(pollInterval)
          pollInterval = null
        }
      }, 4000)
    }
  } catch (err) {
    errorMsg.value = err.response?.data?.message || 'Error al iniciar envíos'
  }
}

onMounted(smartPoll)
onUnmounted(() => { if (pollInterval) clearInterval(pollInterval) })
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
.action-grid { width: 100%; }
.main-panel { padding: 2rem 2.5rem; }

.panel-header-row {
  display: flex;
  align-items: flex-start;
  justify-content: space-between;
  gap: 1rem;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}
.subtitle {
  color: var(--text-muted);
  font-size: 0.9rem;
  margin-top: 0.25rem;
}

/* Execution status card */
.exec-status-card {
  border: 1.5px solid var(--border-color);
  border-radius: 14px;
  padding: 1.5rem;
  background: var(--bg-color);
  display: flex;
  flex-direction: column;
  gap: 1rem;
  transition: border-color 0.3s, box-shadow 0.3s;
}
.exec-status-card.status-processing {
  border-color: var(--warning-color);
  box-shadow: 0 0 0 4px rgba(245,158,11,0.08);
  animation: pulse-border 2.5s infinite;
}
.exec-status-card.status-success { border-color: var(--success-color); }
.exec-status-card.status-error { border-color: var(--danger-color); }
.exec-status-card.status-warning { border-color: #F59E0B; }

@keyframes pulse-border {
  0%,100% { box-shadow: 0 0 0 0 rgba(245,158,11,0.15); }
  50%      { box-shadow: 0 0 0 8px rgba(245,158,11,0); }
}

.exec-header {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.exec-icon { font-size: 2rem; flex-shrink: 0; }
.exec-title { font-size: 1.05rem; font-weight: 700; color: var(--text-main); margin-bottom: 0.15rem; }
.exec-subtitle { font-size: 0.87rem; color: var(--text-muted); }
.exec-badge {
  margin-left: auto;
  padding: 0.3rem 0.85rem;
  border-radius: 999px;
  font-size: 0.78rem;
  font-weight: 700;
  background: var(--border-color);
  color: var(--text-muted);
  white-space: nowrap;
}
.exec-badge.status-processing { background: rgba(245,158,11,0.12); color: #B45309; }
.exec-badge.status-success    { background: rgba(16,185,129,0.12); color: #065F46; }
.exec-badge.status-error      { background: rgba(239,68,68,0.12); color: #991B1B; }
.exec-badge.status-warning    { background: rgba(245,158,11,0.12); color: #B45309; }

/* Progress bar */
.progress-section {
  display: flex;
  align-items: center;
  gap: 1rem;
}
.progress-track {
  flex: 1;
  height: 8px;
  background: var(--border-color);
  border-radius: 999px;
  overflow: hidden;
}
.progress-fill {
  height: 100%;
  background: var(--warning-color);
  border-radius: 999px;
  transition: width 0.5s ease;
  min-width: 4px;
}
.progress-label { font-size: 0.82rem; color: var(--text-muted); white-space: nowrap; }

/* Counters */
.exec-counters {
  display: flex;
  gap: 0.75rem;
  flex-wrap: wrap;
}
.counter-chip {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.35rem 0.9rem;
  border-radius: 999px;
  font-size: 0.82rem;
  font-weight: 600;
  border: 1px solid;
}
.chip-sent  { background: rgba(16,185,129,0.08); border-color: rgba(16,185,129,0.3); color: #065F46; }
.chip-error { background: rgba(239,68,68,0.08); border-color: rgba(239,68,68,0.3); color: #991B1B; }
.chip-total { background: rgba(99,102,241,0.08); border-color: rgba(99,102,241,0.3); color: var(--primary-color); }

/* Error detail */
.error-detail {
  background: rgba(239,68,68,0.05);
  border: 1px solid rgba(239,68,68,0.2);
  border-radius: 10px;
  padding: 0.9rem 1.1rem;
  font-size: 0.87rem;
  color: var(--text-main);
}
.error-detail strong { display: block; margin-bottom: 0.4rem; color: #991B1B; }
.error-detail p { color: var(--text-muted); margin: 0; }

.exec-footer {
  font-size: 0.8rem;
  color: var(--text-muted);
  padding-top: 0.5rem;
  border-top: 1px solid var(--border-color);
}

/* Trigger button */
.trigger-btn {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  white-space: nowrap;
  padding: 0.75rem 1.5rem;
  font-size: 0.95rem;
}
.spinner {
  width: 14px; height: 14px;
  border: 2px solid rgba(255,255,255,0.4);
  border-top-color: #fff;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
  display: inline-block;
}
@keyframes spin { to { transform: rotate(360deg); } }

.error-msg {
  color: var(--danger-color);
  margin-top: 1rem;
  font-size: 0.88rem;
  padding: 0.6rem 1rem;
  background: rgba(239,68,68,0.05);
  border-radius: 8px;
  border: 1px solid rgba(239,68,68,0.15);
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

/* AUTO SEND SETTINGS TOGGLE STYLE */
.auto-send-settings {
  background: rgba(255, 255, 255, 0.05);
  border: 1px dashed var(--border-color);
  border-radius: 12px;
  padding: 1rem 1.5rem;
  margin-bottom: 1.5rem;
  transition: all 0.3s ease;
}
.auto-send-settings:hover {
  background: rgba(255, 255, 255, 0.08);
  border-color: var(--primary-color);
}
.settings-row {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}
.settings-text {
  display: flex;
  flex-direction: column;
  gap: 0.2rem;
}
.settings-label {
  font-size: 0.92rem;
  font-weight: 700;
  color: var(--text-main);
}
.settings-desc {
  font-size: 0.78rem;
  color: var(--text-muted);
}

/* Switch styling */
.switch {
  position: relative;
  display: inline-block;
  width: 50px;
  height: 26px;
  flex-shrink: 0;
}
.switch input { 
  opacity: 0;
  width: 0;
  height: 0;
}
.slider {
  position: absolute;
  cursor: pointer;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: #cbd5e1;
  transition: .4s;
  border-radius: 34px;
}
.slider:before {
  position: absolute;
  content: "";
  height: 18px;
  width: 18px;
  left: 4px;
  bottom: 4px;
  background-color: white;
  transition: .4s;
  border-radius: 50%;
  box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}
input:checked + .slider {
  background-color: var(--primary-color);
}
input:focus + .slider {
  box-shadow: 0 0 1px var(--primary-color);
}
input:checked + .slider:before {
  transform: translateX(24px);
}
</style>
