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
            <h3>Envíos por Semana</h3>
            <p class="chart-subtitle">Mensajes enviados de Lunes a Domingo</p>
          </div>
          <!-- Week filter selector -->
          <div class="week-filter-container">
            <div class="week-picker-popover-wrapper">
              <!-- Popover Toggle Button -->
              <button 
                @click="showCalendarPopover = !showCalendarPopover" 
                class="btn-week-picker"
              >
                📅 {{ currentWeekRangeLabel }}
              </button>
              
              <!-- Floating Popover -->
              <div v-if="showCalendarPopover" class="calendar-popover glass-panel">
                <div class="popover-nav">
                  <button @click="prevPopoverMonth" class="popover-nav-btn">&larr;</button>
                  <span class="popover-nav-title">{{ monthNames[popoverMonth] }} {{ popoverYear }}</span>
                  <button @click="nextPopoverMonth" class="popover-nav-btn">&rarr;</button>
                </div>
                
                <div class="popover-days-header">
                  <span v-for="d in daysOfWeekShort" :key="d" class="popover-day-lbl">{{ d }}</span>
                </div>
                
                <div class="popover-weeks-container">
                  <div 
                    v-for="(week, wIdx) in popoverCells" 
                    :key="wIdx" 
                    class="popover-week-row"
                    :class="{ 'is-selected-week': isWeekSelected(week) }"
                    @click="selectWeekFromDate(week[0].date)"
                  >
                    <div 
                      v-for="(cell, cIdx) in week" 
                      :key="cIdx" 
                      class="popover-day-cell"
                      :class="{ 'other-month-day': !cell.isCurrentMonth }"
                    >
                      {{ cell.day }}
                    </div>
                  </div>
                </div>
              </div>
            </div>
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
const selectedWeekKey = ref(null)
const showCalendarPopover = ref(false)
const popoverMonth = ref(new Date().getMonth())
const popoverYear = ref(new Date().getFullYear())

const monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]
const daysOfWeekShort = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']

const currentWeekRangeLabel = computed(() => {
  const week = selectedWeekData.value
  if (!week.monday) return 'Seleccionar Semana'
  const options = { day: '2-digit', month: '2-digit' }
  const monStr = week.monday.toLocaleDateString('es-ES', options)
  const sunStr = week.sunday.toLocaleDateString('es-ES', options)
  return `Semana del ${monStr} al ${sunStr}`
})

const getMonday = (d) => {
  const date = new Date(d)
  const day = date.getDay()
  const diff = date.getDate() - day + (day === 0 ? -6 : 1)
  const monday = new Date(date.getFullYear(), date.getMonth(), diff)
  monday.setHours(0, 0, 0, 0)
  return monday
}

const selectWeekFromDate = (d) => {
  const mon = getMonday(d)
  selectedWeekKey.value = mon.getTime()
  showCalendarPopover.value = false
}

const prevPopoverMonth = () => {
  if (popoverMonth.value === 0) {
    popoverMonth.value = 11
    popoverYear.value--
  } else {
    popoverMonth.value--
  }
}

const nextPopoverMonth = () => {
  if (popoverMonth.value === 11) {
    popoverMonth.value = 0
    popoverYear.value++
  } else {
    popoverMonth.value++
  }
}

const isWeekSelected = (week) => {
  if (!selectedWeekKey.value) return false
  const mondayOfThisWeek = getMonday(week[0].date)
  return mondayOfThisWeek.getTime() === selectedWeekKey.value
}

const popoverCells = computed(() => {
  const cells = []
  const firstDay = new Date(popoverYear.value, popoverMonth.value, 1)
  const firstDayIndex = firstDay.getDay()
  const leadingDays = firstDayIndex === 0 ? 6 : firstDayIndex - 1
  
  const prevMonthDays = new Date(popoverYear.value, popoverMonth.value, 0).getDate()
  const currentMonthDays = new Date(popoverYear.value, popoverMonth.value + 1, 0).getDate()
  
  // Prev month cells
  for (let i = leadingDays - 1; i >= 0; i--) {
    const day = prevMonthDays - i
    cells.push({
      day,
      isCurrentMonth: false,
      date: new Date(popoverYear.value, popoverMonth.value - 1, day)
    })
  }
  
  // Current month cells
  for (let i = 1; i <= currentMonthDays; i++) {
    cells.push({
      day: i,
      isCurrentMonth: true,
      date: new Date(popoverYear.value, popoverMonth.value, i)
    })
  }
  
  // Next month cells
  const total = cells.length
  const trailing = total % 7 === 0 ? 0 : 7 - (total % 7)
  for (let i = 1; i <= trailing; i++) {
    cells.push({
      day: i,
      isCurrentMonth: false,
      date: new Date(popoverYear.value, popoverMonth.value + 1, i)
    })
  }
  
  // Group cells into arrays of 7 days (weeks!)
  const weeks = []
  for (let i = 0; i < cells.length; i += 7) {
    weeks.push(cells.slice(i, i + 7))
  }
  return weeks
})
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

// Weekly Chart computations (Filtered by Selected Week)
const daysOfWeek = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo']

const formatWeekLabel = (monday, sunday, isCurrent = false) => {
  const options = { day: '2-digit', month: '2-digit', year: 'numeric' }
  const monStr = monday.toLocaleDateString('es-ES', options)
  const sunStr = sunday.toLocaleDateString('es-ES', options)
  const prefix = isCurrent ? 'Semana Actual: ' : 'Semana: '
  return `${prefix}${monStr} al ${sunStr}`
}

const availableWeeks = computed(() => {
  const weeksMap = {}
  
  // Always ensure current week is an option first
  const now = new Date()
  const dayNow = now.getDay()
  const diffNow = now.getDate() - dayNow + (dayNow === 0 ? -6 : 1)
  const currMon = new Date(now.getFullYear(), now.getMonth(), diffNow)
  currMon.setHours(0, 0, 0, 0)
  const currSun = new Date(currMon.getTime() + 6 * 24 * 60 * 60 * 1000)
  currSun.setHours(23, 59, 59, 999)
  
  const currKey = currMon.getTime()
  weeksMap[currKey] = {
    monday: currMon,
    sunday: currSun,
    label: formatWeekLabel(currMon, currSun, true)
  }
  
  history.value.forEach(item => {
    if (item.fechaHoraEnvio) {
      const date = new Date(item.fechaHoraEnvio)
      const day = date.getDay()
      const diff = date.getDate() - day + (day === 0 ? -6 : 1)
      const monday = new Date(date.getFullYear(), date.getMonth(), diff)
      monday.setHours(0, 0, 0, 0)
      
      const sunday = new Date(monday.getTime() + 6 * 24 * 60 * 60 * 1000)
      sunday.setHours(23, 59, 59, 999)
      
      const key = monday.getTime()
      if (!weeksMap[key]) {
        weeksMap[key] = {
          monday,
          sunday,
          label: formatWeekLabel(monday, sunday, false)
        }
      }
    }
  })
  
  // Return sorted descending (newest weeks first)
  return Object.values(weeksMap).sort((a, b) => b.monday - a.monday)
})

const selectedWeekData = computed(() => {
  if (!selectedWeekKey.value) return { monday: null, sunday: null }
  return availableWeeks.value.find(w => w.monday.getTime() === selectedWeekKey.value) || { monday: null, sunday: null }
})

const weeklyCounts = computed(() => {
  const counts = [0, 0, 0, 0, 0, 0, 0]
  const week = selectedWeekData.value
  if (!week.monday) return counts
  
  const start = week.monday.getTime()
  const end = week.sunday.getTime()
  
  history.value.forEach(item => {
    if (item.fechaHoraEnvio) {
      const date = new Date(item.fechaHoraEnvio)
      const time = date.getTime()
      if (time >= start && time <= end) {
        const day = date.getDay() // 0 = Sun, 1 = Mon...
        const index = day === 0 ? 6 : day - 1
        counts[index]++
      }
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
    // Set default selected week if not set yet
    if (availableWeeks.value.length > 0 && !selectedWeekKey.value) {
      selectedWeekKey.value = availableWeeks.value[0].monday.getTime()
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
  min-height: 100%;
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
  box-sizing: border-box;
}
.chart-card {
  padding: 2vh 2rem;
  display: flex;
  flex-direction: column;
  box-sizing: border-box;
  height: 70vh;
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
  align-items: center;
  gap: 1rem;
  margin-bottom: 1.5vh;
}

/* Week Selector Styles */
.week-filter-container {
  display: flex;
  align-items: center;
  flex-shrink: 0;
}

/* Week Picker styles */
.week-picker-popover-wrapper {
  position: relative;
  display: inline-block;
}

.btn-week-picker {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.5rem 1rem;
  font-size: 0.85rem;
  font-weight: 700;
  border: 1px solid var(--border-color);
  background: var(--bg-color);
  color: var(--text-main);
  border-radius: 10px;
  cursor: pointer;
  transition: all 0.2s ease;
  box-shadow: 0 4px 12px rgba(0,0,0,0.03);
}

.btn-week-picker:hover {
  border-color: var(--primary-color);
  background: var(--primary-light);
  color: var(--primary-color);
}

.calendar-popover {
  position: absolute;
  top: 110%;
  right: 0;
  width: 250px;
  background: rgba(255, 255, 255, 0.95);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 0.75rem;
  box-shadow: 0 10px 30px rgba(0,0,0,0.08);
  z-index: 999;
}

.popover-nav {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 0.5rem;
}

.popover-nav-btn {
  background: transparent;
  border: none;
  cursor: pointer;
  font-size: 0.9rem;
  padding: 0.2rem 0.4rem;
  color: var(--text-muted);
  border-radius: 4px;
  transition: all 0.2s;
}

.popover-nav-btn:hover {
  background: rgba(0,0,0,0.05);
  color: var(--primary-color);
}

.popover-nav-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text-h);
}

.popover-days-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  text-align: center;
  font-size: 0.7rem;
  font-weight: 700;
  color: var(--text-muted);
  margin-bottom: 0.35rem;
}

.popover-weeks-container {
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.popover-week-row {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  padding: 2px 0;
}

.popover-week-row:hover {
  background: var(--primary-light);
}

.popover-week-row.is-selected-week {
  background: var(--primary-color);
}

.popover-day-cell {
  text-align: center;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-main);
  padding: 0.25rem 0;
}

.popover-week-row:hover .popover-day-cell {
  color: var(--primary-color);
}

.popover-week-row.is-selected-week .popover-day-cell {
  color: #FFFFFF;
}

.other-month-day {
  opacity: 0.35;
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
