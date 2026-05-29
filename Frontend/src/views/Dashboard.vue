<template>
  <div class="dashboard-container">
    <!-- WELCOME HEADER (With Premium Action) -->
    <div class="welcome-header glass-panel">
      <div class="welcome-text-container">
        <h1>Hola, {{ authStore.user?.nombreCompleto || 'Usuario' }} 👋</h1>
        <p class="welcome-subtitle">
          Bienvenido al panel de control de <strong>{{ establishmentNombre || authStore.user?.establecimientoNombre || 'Establecimiento de Salud' }}</strong>
        </p>
        <div class="welcome-meta-row">
          <div class="welcome-date">
            <span class="calendar-icon">📅</span> {{ currentDateText }}
          </div>
        </div>
      </div>

      <!-- Prominent Premium Action Button -->
      <div class="header-action-container">
        <div class="action-buttons-row">
          <button 
            @click="triggerReminders" 
            class="btn btn-premium-action"
            :disabled="isProcessing"
          >
            <span class="btn-icon" v-if="!isProcessing">
              <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" fill="currentColor" class="bi bi-whatsapp" viewBox="0 0 16 16">
                <path d="M13.601 2.326A7.85 7.85 0 0 0 7.994 0C3.627 0 .068 3.558.064 7.926c0 1.399.366 2.76 1.057 3.965L0 16l4.204-1.102a7.9 7.9 0 0 0 3.79.949h.004c4.368 0 7.927-3.561 7.928-7.928a7.89 7.89 0 0 0-2.325-5.6zM7.994 14.521a6.6 6.6 0 0 1-3.356-.92l-.24-.144-2.494.654.666-2.433-.156-.251a6.56 6.56 0 0 1-1.007-3.505c0-3.626 2.957-6.584 6.591-6.584a6.56 6.56 0 0 1 4.66 1.931 6.56 6.56 0 0 1 1.928 4.66c-.004 3.639-2.961 6.592-6.592 6.592m3.69-3.186c-.202-.101-1.202-.594-1.387-.662-.185-.069-.32-.103-.453.1-.133.203-.518.662-.636.793-.118.131-.236.148-.438.047-.202-.101-.853-.314-1.624-1.002-.6-.535-1.005-1.197-1.123-1.4-.118-.202-.013-.311.088-.412.091-.091.202-.236.303-.354.101-.118.136-.201.203-.336.067-.136.033-.254-.017-.354-.05-.101-.452-1.09-.619-1.492-.164-.398-.343-.344-.47-.35-.122-.007-.263-.009-.404-.009c-.14 0-.37.053-.564.263-.194.21-0.738.721-0.738 1.76s.755 2.037.86 2.179c.105.14 1.487 2.27 3.6 3.185.502.217.893.347 1.199.444.503.16 0.961.137 1.323.083.404-.061 1.202-.491 1.371-1.02.169-.53.169-.98.118-1.079-.05-.099-.185-.15-.387-.25"/>
              </svg>
            </span>
            <span class="btn-icon pulse-spinner" v-else>⚙️</span>
            {{ isProcessing ? 'Procesando...' : 'Iniciar Envío WhatsApp' }}
          </button>
          
          <button @click="openCredentialsModal" class="btn-settings-credentials" title="Configurar Credenciales de Scraping">
            ⚙️
          </button>
        </div>
        <!-- Status Pill relocated under the button -->
        <div class="status-pill" :class="statusClass">
          <span class="status-dot"></span>
          <span class="status-text">{{ isProcessing ? 'Enviando...' : statusText }}</span>
        </div>
        <p v-if="errorMsg" class="error-msg header-error">{{ errorMsg }}</p>
      </div>
    </div>

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
        <div class="chart-header-row">
          <div class="chart-title-col">
            <h3>Mensajes de la Semana</h3>
            <p class="chart-subtitle">Mensajes enviados de Lunes a Domingo</p>
          </div>
          <!-- Week Date Picker -->
          <div class="chart-filter-wrapper">
            <input type="week" v-model="selectedWeek" class="picker-input" />
          </div>
        </div>
        <div class="bar-chart">
          <div v-for="(item, index) in daysWithDates" :key="item.name" class="bar-wrapper">
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
            <span class="bar-label">{{ item.name }}</span>
            <span class="bar-date">{{ item.date }}</span>
          </div>
        </div>
      </div>

      <!-- Specialties Chart (Premium Donut Chart) -->
      <div class="glass-panel chart-card">
        <div class="chart-header-row">
          <div class="chart-title-col">
            <h3>Distribución por Especialidad</h3>
            <p class="chart-subtitle">Especialidades con mayor número de envíos</p>
          </div>
          <!-- Day Date Picker -->
          <div class="chart-filter-wrapper specialty-filter">
            <label class="filter-toggle">
              <input type="checkbox" v-model="filterSpecialtyByDay" />
              <span class="toggle-label">Por día</span>
            </label>
            <input 
              type="date" 
              v-if="filterSpecialtyByDay" 
              v-model="selectedDay" 
              :min="selectedWeekRange.min"
              :max="selectedWeekRange.max"
              class="picker-input date-picker" 
            />
          </div>
        </div>
        
        <div class="donut-chart-container" v-if="topSpecialties.length > 0">
          <!-- Donut SVG -->
          <div class="donut-svg-wrapper">
            <svg class="donut-svg" viewBox="0 0 100 100">
              <!-- Background Circle track -->
              <circle cx="50" cy="50" r="40" fill="transparent" stroke="var(--border-color)" stroke-width="10" />
              
              <!-- Segment Slices -->
              <circle 
                v-for="slice in specialtiesChartData" 
                :key="slice.name"
                cx="50"
                cy="50"
                r="40"
                fill="transparent"
                :stroke="slice.color"
                stroke-width="10"
                :stroke-dasharray="`${slice.strokeLength} 251.327`"
                :stroke-dashoffset="slice.strokeOffset"
                stroke-linecap="round"
                transform="rotate(-90 50 50)"
                class="donut-slice"
              />
              
              <!-- Total Sent Count in Center -->
              <g class="donut-center-text">
                <text x="50" y="47" text-anchor="middle" class="donut-total-num">{{ specialtiesTotalMessages }}</text>
                <text x="50" y="64" text-anchor="middle" class="donut-total-label">Envíos</text>
              </g>
            </svg>
          </div>
          
          <!-- Interactive Legend -->
          <div class="donut-legend">
            <div v-for="slice in specialtiesChartData" :key="slice.name" class="legend-item">
              <div class="legend-color-indicator" :style="{ backgroundColor: slice.color }"></div>
              <div class="legend-info">
                <span class="legend-name">{{ slice.name }}</span>
                <span class="legend-percentage">{{ slice.count }} envíos ({{ slice.percentage }}%)</span>
              </div>
            </div>
          </div>
        </div>
        
        <div v-else class="empty-chart">
          Sin registros para la fecha seleccionada.
        </div>
      </div>
    </div>
    <!-- Modal de Credenciales de Scraping (Glassmorphic) -->
    <div v-if="showCredentialsModal" class="modal-overlay" @click.self="closeCredentialsModal">
      <div class="modal-content glass-panel animate-fade-in credential-modal">
        <div class="modal-header">
          <div class="header-info">
            <span class="modal-badge-status status-success">Seguro</span>
            <h3>Credenciales del Sistema Externo</h3>
            <p class="modal-patient-name">Ingresar usuario y contraseña de REFCON</p>
          </div>
          <button @click="closeCredentialsModal" class="btn-close">&times;</button>
        </div>
        
        <div class="modal-body credential-modal-body">
          <form @submit.prevent="saveCredentials" class="credentials-form">
            <div class="form-group-custom">
              <label class="form-label-custom">Usuario REFCON</label>
              <input 
                type="text" 
                v-model="credUser" 
                required 
                placeholder="Ingresa tu usuario del sistema externo" 
                class="form-input-custom" 
              />
            </div>
            
            <div class="form-group-custom">
              <label class="form-label-custom">Contraseña REFCON</label>
              <input 
                type="password" 
                v-model="credPassword" 
                :placeholder="credHasPassword ? '•••••••• (Contraseña guardada - escribe para cambiar)' : 'Ingresa tu contraseña'" 
                class="form-input-custom" 
              />
            </div>

            <div class="form-actions-custom">
              <p v-if="credSuccessMsg" class="success-msg-custom">{{ credSuccessMsg }}</p>
              <p v-if="credErrorMsg" class="error-msg-custom">{{ credErrorMsg }}</p>
              <button type="submit" class="btn-save-credentials" :disabled="credLoading">
                {{ credLoading ? 'Guardando...' : 'Guardar Credenciales' }}
              </button>
            </div>
          </form>
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
const establishmentNombre = ref('')
let pollInterval = null

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})


// Credentials Modal State
const showCredentialsModal = ref(false)
const credUser = ref('')
const credPassword = ref('')
const credHasPassword = ref(false)
const credLoading = ref(false)
const credSuccessMsg = ref('')
const credErrorMsg = ref('')

const openCredentialsModal = async () => {
  showCredentialsModal.value = true
  credSuccessMsg.value = ''
  credErrorMsg.value = ''
  credUser.value = ''
  credPassword.value = ''
  
  try {
    const res = await api.get('/reminders/credentials')
    if (res.data) {
      credUser.value = res.data.usuarioReferencial || ''
      credHasPassword.value = res.data.hasPassword
    }
  } catch (err) {
    console.error('Error fetching credentials', err)
  }
}

const closeCredentialsModal = () => {
  showCredentialsModal.value = false
}

const saveCredentials = async () => {
  credLoading.value = true
  credSuccessMsg.value = ''
  credErrorMsg.value = ''
  
  try {
    await api.post('/reminders/credentials', {
      usuarioReferencial: credUser.value,
      claveReferencial: credPassword.value || null
    })
    credSuccessMsg.value = 'Credenciales guardadas correctamente.'
    credHasPassword.value = true
    credPassword.value = ''
    setTimeout(() => {
      closeCredentialsModal()
    }, 1500)
  } catch (err) {
    credErrorMsg.value = err.response?.data?.message || 'Error al guardar las credenciales.'
  } finally {
    credLoading.value = false
  }
}


// Filter history for the selected week
const weeklyHistory = computed(() => {
  return history.value.filter(m => isDateInSelectedWeek(m.fechaHoraEnvio, selectedWeek.value))
})

// Metrics computation filtered by selected week
const totalPatients = computed(() => {
  // Extract unique patients who had messages in this selected week
  const uniquePatients = new Set(weeklyHistory.value.map(m => m.pacienteNombre || m.pacienteID))
  return uniquePatients.size
})
const totalMessages = computed(() => weeklyHistory.value.length)
const successfulMessages = computed(() => weeklyHistory.value.filter(m => m.estadoEnvio === 'Enviado').length)
const failedMessages = computed(() => weeklyHistory.value.filter(m => m.estadoEnvio === 'Error').length)

const currentDateText = computed(() => {
  const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' }
  const dateStr = new Date().toLocaleDateString('es-ES', options)
  return dateStr.charAt(0).toUpperCase() + dateStr.slice(1)
})

// ISO Week helper functions for date picker
const getISOWeek = (d) => {
  d = new Date(Date.UTC(d.getFullYear(), d.getMonth(), d.getDate()))
  d.setUTCDate(d.getUTCDate() + 4 - (d.getUTCDay() || 7))
  const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1))
  const weekNo = Math.ceil((((d - yearStart) / 86400000) + 1) / 7)
  return `${d.getUTCFullYear()}-W${String(weekNo).padStart(2, '0')}`
}

const isDateInSelectedWeek = (dateStr, weekStr) => {
  if (!dateStr || !weekStr) return false
  const [year, weekNum] = weekStr.split('-W').map(Number)
  
  const simple = new Date(year, 0, 1 + (weekNum - 1) * 7)
  const dow = simple.getDay()
  const ISOweekStart = new Date(simple)
  if (dow <= 4) {
    ISOweekStart.setDate(simple.getDate() - simple.getDay() + 1)
  } else {
    ISOweekStart.setDate(simple.getDate() + 8 - simple.getDay())
  }
  
  // Set start time to 00:00:00.000 local
  ISOweekStart.setHours(0, 0, 0, 0)
  
  const ISOweekEnd = new Date(ISOweekStart)
  ISOweekEnd.setDate(ISOweekStart.getDate() + 7)
  
  const date = new Date(dateStr)
  return date >= ISOweekStart && date < ISOweekEnd
}

const selectedWeek = ref(getISOWeek(new Date()))

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

// Specialty Day Filters
const filterSpecialtyByDay = ref(false)
const selectedDay = ref(new Date().toISOString().split('T')[0])

// Compute min and max days for the currently selected week
const selectedWeekRange = computed(() => {
  if (!selectedWeek.value) return { min: '', max: '' }
  const [year, weekNum] = selectedWeek.value.split('-W').map(Number)
  
  const simple = new Date(year, 0, 1 + (weekNum - 1) * 7)
  const dow = simple.getDay()
  const ISOweekStart = new Date(simple)
  if (dow <= 4) {
    ISOweekStart.setDate(simple.getDate() - simple.getDay() + 1)
  } else {
    ISOweekStart.setDate(simple.getDate() + 8 - simple.getDay())
  }
  
  // Start Monday
  ISOweekStart.setHours(0, 0, 0, 0)
  
  // End Sunday (start day + 6 days)
  const ISOweekEnd = new Date(ISOweekStart)
  ISOweekEnd.setDate(ISOweekStart.getDate() + 6)
  
  return {
    min: ISOweekStart.toISOString().split('T')[0],
    max: ISOweekEnd.toISOString().split('T')[0]
  }
})

// Automatically keep selectedDay within the new week range when selectedWeek changes
import { watch } from 'vue'

watch(selectedWeekRange, (newRange) => {
  if (newRange.min) {
    const current = new Date(selectedDay.value)
    const minDate = new Date(newRange.min)
    const maxDate = new Date(newRange.max)
    if (isNaN(current.getTime()) || current < minDate || current > maxDate) {
      selectedDay.value = newRange.min
    }
  }
}, { immediate: true })

// ── Gráfica semanal ───────────────────────────────────────────────────────────
const daysOfWeek = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']

const daysWithDates = computed(() => {
  if (!selectedWeekRange.value.min) return daysOfWeek.map(d => ({ name: d.substring(0, 3), date: '' }));
  const minDate = new Date(selectedWeekRange.value.min);
  const result = [];
  for (let i = 0; i < 7; i++) {
    const d = new Date(minDate);
    d.setUTCDate(d.getUTCDate() + i);
    const dayName = daysOfWeek[i].substring(0, 3);
    const dateStr = `${String(d.getUTCDate()).padStart(2, '0')}/${String(d.getUTCMonth() + 1).padStart(2, '0')}`;
    result.push({ name: dayName, date: dateStr });
  }
  return result;
})
const weeklyCounts = computed(() => {
  const counts = [0, 0, 0, 0, 0, 0, 0]
  history.value.forEach(item => {
    if (item.fechaHoraEnvio && isDateInSelectedWeek(item.fechaHoraEnvio, selectedWeek.value)) {
      const day = new Date(item.fechaHoraEnvio).getDay() // 0 = Sun, 1 = Mon...
      const index = day === 0 ? 6 : day - 1
      counts[index]++
    }
  })
  return counts
})
const getBarHeight = (count) => {
  const max = Math.max(...weeklyCounts.value, 1)

  const percentage = (count / max) * 90 // max height 90% of the bar-chart container
  return `${Math.max(percentage, 5)}%`
}

// Specialty Chart computations (For Circular Donut Chart)
const topSpecialties = computed(() => {
  const specMap = {}
  history.value.forEach(item => {
    if (item.especialidad) {
      let matches = false
      if (filterSpecialtyByDay.value) {
        if (item.fechaHoraEnvio) {
          const itemDayStr = new Date(item.fechaHoraEnvio).toISOString().split('T')[0]
          matches = (itemDayStr === selectedDay.value)
        }
      } else {
        // By default, match only the week currently selected in weekly chart
        matches = isDateInSelectedWeek(item.fechaHoraEnvio, selectedWeek.value)
      }
      
      if (matches) {
        specMap[item.especialidad] = (specMap[item.especialidad] || 0) + 1
      }
    }
  })
  return Object.keys(specMap).map(name => ({
    name,
    count: specMap[name]
  })).sort((a, b) => b.count - a.count).slice(0, 5) // Grab up to 5 top specialties
})

const specialtiesTotalMessages = computed(() => {
  return topSpecialties.value.reduce((acc, curr) => acc + curr.count, 0)
})

const specialtiesChartData = computed(() => {
  const total = topSpecialties.value.reduce((acc, curr) => acc + curr.count, 0)
  if (total === 0) return []
  
  let currentOffset = 0
  const colors = [
    '#6366f1', // Indigo
    '#10b981', // Emerald
    '#3b82f6', // Blue
    '#f59e0b', // Amber
    '#8b5cf6', // Purple
  ]
  
  return topSpecialties.value.map((spec, index) => {
    const percentage = spec.count / total
    const strokeLength = percentage * 251.327 // 2 * pi * r (r=40)
    const strokeOffset = 251.327 - currentOffset
    currentOffset += strokeLength
    
    return {
      name: spec.name,
      count: spec.count,
      percentage: Math.round(percentage * 100),
      strokeLength,
      strokeOffset,
      color: colors[index % colors.length]
    }
  })
})

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
    const [resStatus, resHistory, resPatients, resEst] = await Promise.all([
      api.get('/reminders/status'),
      api.get('/reminders/history'),
      api.get('/reminders/patients'),
      api.get('/reminders/establishment')
    ])
    currentStatus.value = resStatus.data.estado
    lastPeticion.value  = resStatus.data.ultimaPeticion ?? null
    history.value       = resHistory.data
    patients.value      = resPatients.data
    if (resEst.data && resEst.data.name) {
      establishmentNombre.value = resEst.data.name
      // Auto-update the authStore user object so other views can benefit immediately
      if (authStore.user) {
        authStore.user.establecimientoNombre = resEst.data.name
        localStorage.setItem('user', JSON.stringify(authStore.user))
      }
    }
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

/* Premium Action Control in Header */
.header-action-container {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.5rem;
  flex-shrink: 0;
}

.btn-premium-action {
  font-size: 14px; /* Scaled to fit beautifully in the header */
  letter-spacing: 2px;
  text-transform: uppercase;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.75rem;
  font-weight: bold;
  padding: 0.8rem 1.8rem;
  
  border-radius: 9999px; /* Pill-shaped round borders */
  position: relative;
  /* Deep floating shadows */
  box-shadow: 0 10px 20px rgba(250, 235, 105, 0.15), 0 3px 6px rgba(0, 0, 0, 0.10);
  color: #419661ff;
  background: transparent;
  text-decoration: none;
  transition: 0.3s ease all;
  z-index: 1;
  cursor: pointer;
  white-space: nowrap;
}

.btn-premium-action::before {
  transition: 0.5s all ease;
  position: absolute;
  top: 0;
  left: 50%;
  right: 50%;
  bottom: 0;
  opacity: 0;
  content: '';
  background-color: #419661ff;
  z-index: -1;
  border-radius: 9999px; /* Matches the round borders */
}

.btn-premium-action:hover:not(:disabled), .btn-premium-action:focus:not(:disabled) {
  color: white;
  transform: translateY(-4px); /* Floating lift effect */
  /* Intense neon glow when floating on hover */
  box-shadow: 0 15px 25px rgba(135, 192, 144, 0.35), 0 5px 10px rgba(255, 0, 114, 0.15);
}

.btn-premium-action:hover::before, .btn-premium-action:focus::before {
  transition: 0.5s all ease;
  left: 0;
  right: 0;
  opacity: 1;
}

.btn-premium-action:active:not(:disabled) {
  transform: scale(0.9) translateY(0);
  box-shadow: 0 4px 8px rgba(255, 0, 114, 0.15);
}

.btn-premium-action:disabled {
  background: #cbd5e1;
  color: #94a3b8;
  border-color: #cbd5e1;
  cursor: not-allowed;
  box-shadow: none;
}

.btn-icon {
  font-size: 1.1rem;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.pulse-spinner {
  animation: spin 2s infinite linear;
}

@keyframes spin {
  100% { transform: rotate(360deg); }
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

.status-idle {
  background: #f1f5f9;
  color: #64748b;
  border-color: #cbd5e1;
}
.status-idle .status-dot {
  background: #64748b;
}

.status-processing {
  background: #fef3c7;
  color: #d97706;
  border-color: #fcd34d;
}
.status-processing .status-dot {
  background: #d97706;
  animation: pulse-dot 1.5s infinite;
}

.status-success {
  background: #d1fae5;
  color: #059669;
  border-color: #6ee7b7;
}
.status-success .status-dot {
  background: #059669;
}

.status-error {
  background: #fee2e2;
  color: #dc2626;
  border-color: #fca5a5;
}
.status-error .status-dot {
  background: #dc2626;
}

@keyframes pulse-dot {
  0% { transform: scale(0.9); opacity: 0.6; }
  50% { transform: scale(1.2); opacity: 1; }
  100% { transform: scale(0.9); opacity: 0.6; }
}

.error-msg {
  color: var(--danger-color);
  margin-top: 0.25rem;
  font-size: 0.85rem;
  font-weight: 500;
}

.header-error {
  text-align: right;
  width: 100%;
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
  .header-error {
    text-align: left;
  }
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
.bar-date {
  font-size: 0.65rem;
  color: #94a3b8;
  font-weight: 400;
  margin-top: 0.15rem;
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

.chart-filter-wrapper {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.picker-input {
  border: 1px solid var(--border-color);
  background: var(--bg);
  color: var(--text-h);
  padding: 0.45rem 0.75rem;
  border-radius: 8px;
  font-size: 0.8rem;
  font-weight: 600;
  outline: none;
  transition: all 0.3s ease;
}

.picker-input:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.filter-toggle {
  display: flex;
  align-items: center;
  gap: 0.35rem;
  cursor: pointer;
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
  user-select: none;
}

.filter-toggle input[type="checkbox"] {
  accent-color: var(--primary-color);
  cursor: pointer;
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

.donut-legend {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  flex-grow: 1;
  max-width: 220px;
}

.legend-item {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.legend-color-indicator {
  width: 12px;
  height: 12px;
  border-radius: 4px;
  flex-shrink: 0;
}

.legend-info {
  display: flex;
  flex-direction: column;
}

.legend-name {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-h);
  line-height: 1.2;
}

.legend-percentage {
  font-size: 0.7rem;
  color: var(--text-muted);
  font-weight: 500;
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

@media (max-width: 480px) {
  .donut-chart-container {
    flex-direction: column;
    align-items: center;
  }
}

/* Scraping Credentials Settings Styling */
.action-buttons-row {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.btn-settings-credentials {
  background: rgba(255, 255, 255, 0.6);
  border: 1px solid var(--border-color);
  color: var(--text-h);
  width: 46px;
  height: 46px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.15rem;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  box-shadow: 0 4px 12px rgba(0,0,0,0.05);
}

.btn-settings-credentials:hover {
  background: #FFFFFF;
  border-color: var(--primary-color);
  transform: rotate(45deg) scale(1.05);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.15);
}

.btn-settings-credentials:active {
  transform: rotate(45deg) scale(0.95);
}

.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(15, 23, 42, 0.4);
  backdrop-filter: blur(8px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  padding: 2rem;
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


/* Modal Content Box */
.modal-content {
  background: rgba(255, 255, 255, 0.85);
  border: 1px solid rgba(255, 255, 255, 0.4);
  border-radius: 20px;
  width: 100%;
  max-width: 900px;
  max-height: 85vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 50px rgba(0, 0, 0, 0.15);
  overflow: hidden;
}

.credential-modal {
  max-width: 500px;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--border-color);
  background: rgba(255, 255, 255, 0.4);
}

.header-info h3 {
  font-size: 1.25rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0.5rem 0 0.1rem 0;
}

.modal-patient-name {
  font-size: 0.85rem;
  font-weight: 500;
  color: var(--text-muted);
  margin: 0;
}

.modal-badge-status {
  display: inline-block;
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-weight: 600;
}

.status-success {
  background: rgba(16, 185, 129, 0.2);
  color: #10B981;
}

.btn-close {
  background: rgba(0, 0, 0, 0.05);
  border: none;
  font-size: 1.5rem;
  width: 32px;
  height: 32px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--text-muted);
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-close:hover {
  background: var(--danger-light);
  color: var(--danger-color);
}

.modal-body {
  padding: 2rem;
  overflow-y: auto;
  background: rgba(255, 255, 255, 0.25);
}

.credential-modal-body {
  padding: 2rem;
}

/* Custom Form Styling */
.credentials-form {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
}

.form-group-custom {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.form-label-custom {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text-h);
}

.form-input-custom {
  padding: 0.75rem 1rem;
  font-size: 0.9rem;
  border: 1px solid rgba(0,0,0,0.1);
  border-radius: 10px;
  outline: none;
  background: #FFFFFF;
  transition: all 0.3s ease;
}

.form-input-custom:focus {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px rgba(99, 102, 241, 0.15);
}

.form-actions-custom {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 0.75rem;
  margin-top: 0.5rem;
}

.btn-save-credentials {
  background: var(--primary-color);
  color: #FFFFFF;
  border: none;
  padding: 0.8rem 1.8rem;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 10px 20px rgba(99, 102, 241, 0.15);
}

.btn-save-credentials:hover:not(:disabled) {
  transform: translateY(-2px);
  box-shadow: 0 15px 25px rgba(99, 102, 241, 0.25);
}

.btn-save-credentials:active:not(:disabled) {
  transform: translateY(0);
}

.btn-save-credentials:disabled {
  background: #cbd5e1;
  color: #94a3b8;
  box-shadow: none;
  cursor: not-allowed;
}

.success-msg-custom {
  color: #10B981;
  font-size: 0.8rem;
  font-weight: 600;
  margin: 0;
}

.error-msg-custom {
  color: #EF4444;
  font-size: 0.8rem;
  font-weight: 600;
  margin: 0;
}

/* Animations */
.animate-fade-in {
  animation: fadeIn 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.96) translateY(8px); }
  to { opacity: 1; transform: scale(1) translateY(0); }

}
</style>

