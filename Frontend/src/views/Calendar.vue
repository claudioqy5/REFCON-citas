<template>
  <div class="calendar-page-container">
    <!-- WELCOME HEADER (Agenda Control) -->
    <div class="welcome-header glass-panel">
      <div class="welcome-text-container">
        <h1>Agenda Mensual de Citas 📅</h1>
        <p class="welcome-subtitle">
          Visualiza los pacientes programados y el estado de sus recordatorios de citas en <strong>{{ establishmentNombre || authStore.user?.establecimientoNombre || 'Establecimiento de Salud' }}</strong>
        </p>
      </div>

      <!-- Month Navigation Controls -->
      <div class="calendar-nav-controls">
        <button @click="prevMonth" class="btn btn-nav">&larr; Anterior</button>
        
        <div class="select-wrapper">
          <select v-model="currentMonth" class="nav-select">
            <option v-for="(name, idx) in monthNames" :key="idx" :value="idx">
              {{ name }}
            </option>
          </select>
        </div>

        <div class="select-wrapper">
          <select v-model="currentYear" class="nav-select">
            <option v-for="y in availableYears" :key="y" :value="y">
              {{ y }}
            </option>
          </select>
        </div>

        <button @click="nextMonth" class="btn btn-nav">Siguiente &rarr;</button>
      </div>
    </div>

    <!-- MAIN TWO-COLUMN LAYOUT -->
    <div class="calendar-main-grid">
      <!-- LEFT COLUMN: Calendar Grid and Search -->
      <div class="calendar-grid-card glass-panel">
        <div class="calendar-header-actions">
          <div class="month-title-display">
            <h2>{{ monthNames[currentMonth] }} {{ currentYear }}</h2>
          </div>
          <div class="search-box-container">
            <span class="search-icon">🔍</span>
            <input 
              v-model="searchQuery" 
              type="text" 
              placeholder="Buscar paciente, DNI o especialidad..." 
              class="search-input"
            />
          </div>
        </div>

        <!-- Days of Week labels -->
        <div class="days-of-week-header">
          <span v-for="day in daysOfWeek" :key="day" class="day-name-lbl">{{ day }}</span>
        </div>

        <!-- Grid cells -->
        <div class="calendar-cells-grid">
          <div 
            v-for="cell in calendarCells" 
            :key="cell.key" 
            class="calendar-cell"
            :class="{ 
              'other-month': !cell.isCurrentMonth,
              'is-today': isToday(cell.date),
              'is-selected': selectedDate && isSameDay(cell.date, selectedDate)
            }"
            @click="selectDate(cell.date)"
          >
            <div class="cell-header">
              <span class="day-number">{{ cell.day }}</span>
              <span v-if="isToday(cell.date)" class="today-badge">Hoy</span>
            </div>
            
            <div class="cell-appointments">
              <div 
                v-for="(appt, aIdx) in getAppointmentsForCell(cell.date).slice(0, 3)" 
                :key="aIdx" 
                class="appt-mini-pill"
                :class="appt.estadoEnvio === 'Enviado' ? 'status-sent' : 'status-failed'"
                :title="`${appt.pacienteNombre} - ${appt.especialidad}`"
              >
                <span class="appt-time" v-if="appt.fechaCita">{{ formatApptTime(appt.fechaCita) }}</span>
                <span class="appt-name">{{ appt.pacienteNombre }}</span>
              </div>
              
              <div 
                v-if="getAppointmentsForCell(cell.date).length > 3" 
                class="appt-more-badge"
              >
                +{{ getAppointmentsForCell(cell.date).length - 3 }} más
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- RIGHT COLUMN: Appointment Details for Selected Day -->
      <div class="calendar-details-card glass-panel">
        <div class="details-header">
          <h3>Detalle de Citas</h3>
          <p class="details-date-subtitle">{{ formatLongDate(selectedDate) }}</p>
        </div>

        <div v-if="selectedDayAppointments.length > 0" class="details-appointments-list">
          <div 
            v-for="appt in selectedDayAppointments" 
            :key="appt.mensajeID" 
            class="detail-appointment-item"
          >
            <div class="appt-primary-info">
              <span class="appt-item-time" v-if="appt.fechaCita">⏰ {{ formatApptTime(appt.fechaCita) }}</span>
              <span 
                class="appt-item-badge" 
                :class="appt.estadoEnvio === 'Enviado' ? 'badge-success' : 'badge-danger'"
              >
                {{ appt.estadoEnvio === 'Enviado' ? 'Recordatorio Enviado' : 'Error de Envío' }}
              </span>
            </div>

            <h4 class="appt-patient-name">{{ appt.pacienteNombre }}</h4>
            
            <div class="appt-meta-grid">
              <div class="appt-meta-item">
                <span class="meta-label">DNI:</span>
                <span class="meta-val">{{ appt.pacienteDni || 'N/A' }}</span>
              </div>
              <div class="appt-meta-item">
                <span class="meta-label">Celular:</span>
                <span class="meta-val">{{ appt.pacienteCelular || 'N/A' }}</span>
              </div>
              <div class="appt-meta-item">
                <span class="meta-label">Especialidad:</span>
                <span class="meta-val specialty-val">{{ appt.especialidad || 'General' }}</span>
              </div>
              <div class="appt-meta-item" v-if="appt.consultorio">
                <span class="meta-label">Consultorio:</span>
                <span class="meta-val">{{ appt.consultorio }}</span>
              </div>
              <div class="appt-meta-item" v-if="appt.medico">
                <span class="meta-label">Médico:</span>
                <span class="meta-val">{{ appt.medico }}</span>
              </div>
              <div class="appt-meta-item" v-if="appt.establecimientoDestino">
                <span class="meta-label">Destino:</span>
                <span class="meta-val">{{ appt.establecimientoDestino }}</span>
              </div>
            </div>
          </div>
        </div>

        <div v-else class="details-empty-state">
          <div class="empty-icon">📅</div>
          <h4>Sin citas registradas</h4>
          <p>No se encontraron citas o recordatorios programados para este día.</p>
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
const establishmentNombre = ref('')
const searchQuery = ref('')
let pollInterval = null

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

// Current view state
const today = new Date()
const currentMonth = ref(today.getMonth())
const currentYear = ref(today.getFullYear())
const selectedDate = ref(new Date())

const monthNames = [
  'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 
  'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
]
const daysOfWeek = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']

const availableYears = computed(() => {
  const start = today.getFullYear() - 3
  const years = []
  for (let i = 0; i < 6; i++) {
    years.push(start + i)
  }
  return years
})

// Navigation actions
const prevMonth = () => {
  if (currentMonth.value === 0) {
    currentMonth.value = 11
    currentYear.value--
  } else {
    currentMonth.value--
  }
}

const nextMonth = () => {
  if (currentMonth.value === 11) {
    currentMonth.value = 0
    currentYear.value++
  } else {
    currentMonth.value++
  }
}

const selectDate = (date) => {
  selectedDate.value = date
}

// Helpers
const isToday = (date) => {
  const d = new Date()
  return date.getDate() === d.getDate() &&
         date.getMonth() === d.getMonth() &&
         date.getFullYear() === d.getFullYear()
}

const isSameDay = (date1, date2) => {
  if (!date1 || !date2) return false
  return date1.getDate() === date2.getDate() &&
         date1.getMonth() === date2.getMonth() &&
         date1.getFullYear() === date2.getFullYear()
}

const formatApptTime = (dateStr) => {
  try {
    const d = new Date(dateStr)
    if (isNaN(d.getTime())) return ''
    return d.toLocaleTimeString('es-ES', { hour: '2-digit', minute: '2-digit', hour12: false })
  } catch (e) {
    return ''
  }
}

const formatLongDate = (date) => {
  if (!date) return ''
  const options = { weekday: 'long', day: 'numeric', month: 'long', year: 'numeric' }
  const formatted = date.toLocaleDateString('es-ES', options)
  return formatted.charAt(0).toUpperCase() + formatted.slice(1)
}

// Generate calendar days
const calendarCells = computed(() => {
  const cells = []
  
  // First day of the month
  const firstDay = new Date(currentYear.value, currentMonth.value, 1)
  // Day of week index (0 = Sun, 1 = Mon ... 6 = Sat)
  const firstDayIndex = firstDay.getDay()
  // Align Monday as 0 (0 = Lun, 1 = Mar ... 6 = Dom)
  const leadingDays = firstDayIndex === 0 ? 6 : firstDayIndex - 1
  
  const prevMonthDays = new Date(currentYear.value, currentMonth.value, 0).getDate()
  const currentMonthDays = new Date(currentYear.value, currentMonth.value + 1, 0).getDate()
  
  // 1. Prev month leading cells
  for (let i = leadingDays - 1; i >= 0; i--) {
    const day = prevMonthDays - i
    cells.push({
      day,
      isCurrentMonth: false,
      date: new Date(currentYear.value, currentMonth.value - 1, day),
      key: `prev-${day}`
    })
  }
  
  // 2. Current month cells
  for (let i = 1; i <= currentMonthDays; i++) {
    cells.push({
      day: i,
      isCurrentMonth: true,
      date: new Date(currentYear.value, currentMonth.value, i),
      key: `curr-${i}`
    })
  }
  
  // 3. Next month trailing cells to round to grid row boundaries
  const total = cells.length
  const trailing = total % 7 === 0 ? 0 : 7 - (total % 7)
  for (let i = 1; i <= trailing; i++) {
    cells.push({
      day: i,
      isCurrentMonth: false,
      date: new Date(currentYear.value, currentMonth.value + 1, i),
      key: `next-${i}`
    })
  }
  
  return cells
})

// Appointments grouping
const appointmentsByDay = computed(() => {
  const map = {}
  history.value.forEach(item => {
    if (item.fechaCita) {
      const date = new Date(item.fechaCita)
      const dayKey = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`
      if (!map[dayKey]) {
        map[dayKey] = []
      }
      map[dayKey].push(item)
    }
  })
  return map
})

const getAppointmentsForCell = (date) => {
  const key = `${date.getFullYear()}-${date.getMonth()}-${date.getDate()}`
  let list = appointmentsByDay.value[key] || []
  
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    list = list.filter(item => 
      (item.pacienteNombre && item.pacienteNombre.toLowerCase().includes(q)) ||
      (item.pacienteDni && item.pacienteDni.includes(q)) ||
      (item.especialidad && item.especialidad.toLowerCase().includes(q)) ||
      (item.medico && item.medico.toLowerCase().includes(q))
    )
  }
  
  // Sort by appointment time (extracted from fechaCita)
  return list.sort((a, b) => new Date(a.fechaCita) - new Date(b.fechaCita))
}

const selectedDayAppointments = computed(() => {
  if (!selectedDate.value) return []
  return getAppointmentsForCell(selectedDate.value)
})

// Data Fetching
const fetchData = async () => {
  try {
    const [resHistory, resEst] = await Promise.all([
      api.get('/reminders/history'),
      api.get('/reminders/establishment')
    ])
    history.value = resHistory.data
    if (resEst.data && resEst.data.name) {
      establishmentNombre.value = resEst.data.name
    }
  } catch (err) {
    console.error('Error fetching calendar appointments', err)
  }
}

onMounted(() => {
  fetchData()
  pollInterval = setInterval(fetchData, 10000)
})

onUnmounted(() => {
  if (pollInterval) clearInterval(pollInterval)
})
</script>

<style scoped>
.calendar-page-container {
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  width: 100%;
  height: calc(100vh - 8rem);
  box-sizing: border-box;
}

@media (max-width: 1024px) {
  .calendar-page-container {
    height: auto;
  }
}

/* Welcome Header Custom Styles */
.welcome-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.25rem 2.5rem;
  border-radius: 16px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.7) 0%, rgba(255, 255, 255, 0.4) 100%);
  border: 1px solid var(--border-color);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.02);
  gap: 2rem;
  box-sizing: border-box;
}

.welcome-header h1 {
  font-size: 1.6rem;
  font-weight: 700;
  margin: 0 0 0.35rem 0;
  color: var(--text-h);
}

.welcome-subtitle {
  font-size: 0.9rem;
  color: var(--text-muted);
  margin: 0;
}

/* Month Navigation Controls */
.calendar-nav-controls {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  flex-shrink: 0;
}

.btn-nav {
  padding: 0.5rem 1rem;
  font-size: 0.85rem;
  font-weight: 600;
  border: 1px solid var(--border-color);
  background: var(--bg-color);
  color: var(--text-main);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.btn-nav:hover {
  background: var(--primary-light);
  color: var(--primary-color);
  border-color: var(--primary-color);
}

.select-wrapper {
  position: relative;
}

.nav-select {
  padding: 0.5rem 1.75rem 0.5rem 0.75rem;
  font-size: 0.85rem;
  font-weight: 600;
  border: 1px solid var(--border-color);
  background: var(--bg-color);
  color: var(--text-main);
  border-radius: 8px;
  appearance: none;
  cursor: pointer;
  outline: none;
}

.select-wrapper::after {
  content: '▼';
  font-size: 0.6rem;
  position: absolute;
  right: 0.75rem;
  top: 50%;
  transform: translateY(-50%);
  color: var(--text-muted);
  pointer-events: none;
}

/* Layout Grid */
.calendar-main-grid {
  display: grid;
  grid-template-columns: 2.2fr 1fr;
  gap: 1.5rem;
  width: 100%;
  flex-grow: 1;
  min-height: 0;
  box-sizing: border-box;
}

@media (max-width: 1024px) {
  .calendar-main-grid {
    grid-template-columns: 1fr;
    overflow-y: auto;
  }
}

.calendar-grid-card {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1rem;
  height: 100%;
  box-sizing: border-box;
}

.calendar-header-actions {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 1rem;
}

.month-title-display h2 {
  font-size: 1.3rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0;
}

.search-box-container {
  display: flex;
  align-items: center;
  background: rgba(0, 0, 0, 0.03);
  border: 1px solid var(--border-color);
  border-radius: 10px;
  padding: 0.45rem 0.85rem;
  width: 280px;
  max-width: 100%;
}

.search-icon {
  margin-right: 0.5rem;
  font-size: 0.9rem;
  color: var(--text-muted);
}

.search-input {
  border: none;
  background: transparent;
  outline: none;
  width: 100%;
  font-size: 0.85rem;
  color: var(--text-main);
}

/* Calendar Days */
.days-of-week-header {
  display: grid;
  grid-template-columns: repeat(7, 1fr);
  text-align: center;
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 0.5rem;
  font-weight: 700;
  font-size: 0.82rem;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.calendar-cells-grid {
  display: grid;
  grid-template-columns: repeat(7, minmax(0, 1fr));
  grid-template-rows: repeat(6, 1fr);
  gap: 4px;
  flex-grow: 1;
  min-height: 0;
}

.calendar-cell {
  background: rgba(255, 255, 255, 0.4);
  border: 1px solid var(--border-color);
  border-radius: 8px;
  padding: 0.45rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
  cursor: pointer;
  transition: all 0.2s ease;
  position: relative;
  min-height: 0;
  min-width: 0;
  overflow: hidden;
}

.calendar-cell:hover {
  background: rgba(99, 102, 241, 0.04);
  border-color: var(--primary-color);
  transform: translateY(-1px);
}

.calendar-cell.other-month {
  opacity: 0.4;
  background: transparent;
}

.calendar-cell.is-today {
  border-color: var(--primary-color);
  box-shadow: 0 0 0 3px var(--primary-light);
  background: rgba(99, 102, 241, 0.02);
}

.calendar-cell.is-selected {
  border-color: var(--primary-color);
  background: var(--primary-light);
}

.cell-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.day-number {
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--text-main);
}

.today-badge {
  font-size: 0.58rem;
  font-weight: 700;
  background: var(--primary-color);
  color: #fff;
  padding: 1px 4px;
  border-radius: 4px;
  text-transform: uppercase;
}

.cell-appointments {
  display: flex;
  flex-direction: column;
  gap: 2px;
  overflow: hidden;
  flex-grow: 1;
}

.appt-mini-pill {
  font-size: 0.65rem;
  padding: 2px 4px;
  border-radius: 4px;
  display: flex;
  gap: 3px;
  font-weight: 600;
  min-width: 0;
}

.appt-mini-pill.status-sent {
  background: rgba(16, 185, 129, 0.1);
  color: #047857;
  border-left: 2px solid #10b981;
}

.appt-mini-pill.status-failed {
  background: rgba(239, 68, 68, 0.1);
  color: #b91c1c;
  border-left: 2px solid #ef4444;
}

.appt-time {
  font-weight: 700;
  flex-shrink: 0;
}

.appt-name {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  min-width: 0;
  flex: 1;
}

.appt-more-badge {
  font-size: 0.6rem;
  font-weight: 700;
  color: var(--text-muted);
  text-align: right;
  padding-right: 2px;
}

/* Right Column: Appointment Details */
.calendar-details-card {
  padding: 1.5rem;
  display: flex;
  flex-direction: column;
  gap: 1.25rem;
  height: 100%;
  box-sizing: border-box;
  overflow-y: auto;
}

.details-header {
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 0.75rem;
}

.details-header h3 {
  font-size: 1.15rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0 0 0.25rem 0;
}

.details-date-subtitle {
  font-size: 0.82rem;
  color: var(--primary-color);
  font-weight: 600;
  margin: 0;
}

.details-appointments-list {
  display: flex;
  flex-direction: column;
  gap: 1rem;
  flex-grow: 1;
}

.detail-appointment-item {
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid var(--border-color);
  border-radius: 12px;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.appt-primary-info {
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5rem;
}

.appt-item-time {
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--text-main);
}

.appt-item-badge {
  font-size: 0.65rem;
  font-weight: 700;
  padding: 2px 8px;
  border-radius: 9999px;
  text-transform: uppercase;
}

.badge-success {
  background: rgba(16, 185, 129, 0.1);
  color: #047857;
}

.badge-danger {
  background: rgba(239, 68, 68, 0.1);
  color: #b91c1c;
}

.appt-patient-name {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0;
}

.appt-meta-grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 0.4rem;
  font-size: 0.8rem;
}

.appt-meta-item {
  display: flex;
  gap: 0.5rem;
}

.meta-label {
  color: var(--text-muted);
  font-weight: 500;
  min-width: 85px;
}

.meta-val {
  color: var(--text-main);
  font-weight: 600;
}

.specialty-val {
  color: var(--primary-color);
}

.appt-message-preview {
  background: rgba(0, 0, 0, 0.02);
  border-radius: 8px;
  padding: 0.65rem;
  border-left: 3px solid var(--border-color);
}

.appt-message-preview strong {
  display: block;
  font-size: 0.75rem;
  color: var(--text-muted);
  margin-bottom: 0.25rem;
}

.appt-message-preview p {
  margin: 0;
  font-size: 0.78rem;
  color: var(--text-main);
  line-height: 1.35;
}

.details-empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  text-align: center;
  flex-grow: 1;
  padding: 3rem 1.5rem;
  color: var(--text-muted);
}

.empty-icon {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
  opacity: 0.6;
}

.details-empty-state h4 {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0 0 0.35rem 0;
}

.details-empty-state p {
  font-size: 0.8rem;
  margin: 0;
  max-width: 200px;
}
</style>
