<template>
  <div class="history-container">
    <div class="glass-panel table-panel">
      <div class="panel-header">
        <div class="header-title-row">
          <h2>Historial de Mensajes</h2>
          <button @click="fetchHistory" class="btn btn-secondary btn-refresh">Actualizar</button>
        </div>
        
        <div class="filter-bar-row">
          <div class="filter-item search-item">
            <label>Buscar</label>
            <input v-model="searchQuery" placeholder="DNI, paciente, especialidad..." class="search-input" />
          </div>
          <div class="filter-item type-item">
            <label>Filtrar por</label>
            <select v-model="dateTypeFilter" class="status-select">
              <option value="envio">Fecha Envío</option>
              <option value="cita">Fecha Cita</option>
            </select>
          </div>
          <div class="filter-item date-item">
            <label>Desde</label>
            <input type="date" v-model="startDate" class="date-input" />
          </div>
          <div class="filter-item date-item">
            <label>Hasta</label>
            <input type="date" v-model="endDate" class="date-input" />
          </div>
          <div class="filter-item status-item">
            <label>Estado</label>
            <select v-model="statusFilter" class="status-select">
              <option value="">Todos</option>
              <option value="Enviado">Enviado</option>
              <option value="Fallido">Fallido</option>
            </select>
          </div>
          <div class="filter-item action-item">
            <button @click="clearFilters" class="btn btn-clear">Mostrar todo</button>
          </div>
        </div>
      </div>

      <div class="table-wrapper">
        <table v-if="filteredHistory.length > 0">
          <thead>
            <tr>
              <th class="col-num">#</th>
              <th>DNI</th>
              <th>Paciente</th>
              <th>Celular</th>
              <th>Est. Destino</th>
              <th>Especialidad</th>
              <th>Fecha Cita</th>
              <th>Fecha Envío</th>
              <th>Estado</th>
              <th style="text-align: center;">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredHistory" :key="item.mensajeID">
              <td class="col-num"><strong>{{ index + 1 }}</strong></td>
              <td>{{ item.pacienteDni }}</td>
              <td>{{ item.pacienteNombre }}</td>
              <td>{{ item.pacienteCelular }}</td>
              <td>{{ item.establecimientoDestino || '-' }}</td>
              <td>{{ item.especialidad }}</td>
              <td>{{ formatDate(item.fechaCita) }}</td>
              <td>{{ formatDate(item.fechaHoraEnvio) }}</td>
              <td>
                <span :class="['badge', getStatusBadge(item.estadoEnvio)]">
                  {{ item.estadoEnvio }}
                </span>
              </td>
              <td style="text-align: center;">
                <button @click="openModal(item)" class="btn-action-detail" title="Ver Detalle Completo">
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5" class="btn-detail-icon">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  <span>Ver Detalle</span>
                </button>
              </td>
            </tr>
          </tbody>
        </table>
        <div v-else class="empty-state">
          No se encontraron mensajes en el historial para los filtros seleccionados.
        </div>
      </div>
    </div>

    <!-- Modal de Detalles Premium (Glassmorphic) -->
    <div v-if="showModal && selectedItem" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content glass-panel animate-fade-in">
        <div class="modal-header">
          <div class="header-info">
            <span class="modal-badge-status" :class="getStatusBadge(selectedItem.estadoEnvio)">
              {{ selectedItem.estadoEnvio }}
            </span>
            <h3>Detalle del Recordatorio</h3>
            <p class="modal-patient-name">{{ selectedItem.pacienteNombre }}</p>
          </div>
          <button @click="closeModal" class="btn-close">&times;</button>
        </div>
        
        <div class="modal-body">
          <!-- Information Sections Grouped Logically -->
          <div class="details-sections">
            
            <!-- SECTION 1: PATIENT DATA -->
            <div class="details-group-section">
              <h4 class="section-group-title">👥 Datos del Paciente</h4>
              <div class="details-grid">
                <div class="detail-card">
                  <span class="detail-label">DNI del Paciente</span>
                  <span class="detail-value">{{ selectedItem.pacienteDni }}</span>
                </div>
                <div class="detail-card">
                  <span class="detail-label">Celular</span>
                  <span class="detail-value">{{ selectedItem.pacienteCelular }}</span>
                </div>
              </div>
            </div>

            <!-- SECTION 2: DESTINATION DATA -->
            <div class="details-group-section">
              <h4 class="section-group-title">🏢 Destino de Referencia</h4>
              <div class="details-grid">
                <div class="detail-card">
                  <span class="detail-label">Establecimiento de Destino</span>
                  <span class="detail-value">{{ selectedItem.establecimientoDestino || '-' }}</span>
                </div>
                <div class="detail-card">
                  <span class="detail-label">Especialidad (Servicio)</span>
                  <span class="detail-value">{{ selectedItem.especialidad }}</span>
                </div>
              </div>
            </div>

            <!-- SECTION 3: CITATION & ATTEMPTS DATA -->
            <div class="details-group-section">
              <h4 class="section-group-title">📅 Cita & Atención</h4>
              <div class="details-list-flat">
                <div class="detail-row highlight-row">
                  <span class="detail-label-flat">👨‍⚕️ Médico Tratante:</span>
                  <span class="detail-value-flat highlight-text">{{ selectedItem.medico || 'No especificado' }}</span>
                </div>
                <div class="detail-row highlight-row">
                  <span class="detail-label-flat">🚪 Consultorio:</span>
                  <span class="detail-value-flat highlight-text">{{ selectedItem.consultorio || 'No especificado' }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label-flat">🔑 ID Cita / Referencia:</span>
                  <span class="detail-value-flat">{{ selectedItem.idCita }} / {{ selectedItem.idReferencia || '-' }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label-flat">📅 Fecha de Cita:</span>
                  <span class="detail-value-flat">{{ formatDate(selectedItem.fechaCita) }}</span>
                </div>
                <div class="detail-row">
                  <span class="detail-label-flat">✉️ Fecha de Envío:</span>
                  <span class="detail-value-flat">{{ formatDate(selectedItem.fechaHoraEnvio) }}</span>
                </div>
              </div>
            </div>

          </div>
          
          <!-- Message Preview inside a mockup phone -->
          <div class="message-preview-section">
            <h4>Mensaje Enviado al Paciente</h4>
            <div class="phone-mockup">
              <div class="phone-header">
                <div class="phone-avatar">🩺</div>
                <div class="phone-chat-info">
                  <span class="phone-chat-name">Bot mensajería REFCON</span>
                  <span class="phone-chat-status">en línea</span>
                </div>
              </div>
              <div class="phone-body">
                <div class="chat-bubble received">
                  <p class="formatted-message">{{ getDynamicMessage(selectedItem) }}</p>
                  <span class="chat-time">{{ formatTimeOnly(selectedItem.fechaHoraEnvio) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()
const history = ref([])

// Details Modal State
const showModal = ref(false)
const selectedItem = ref(null)

const openModal = (item) => {
  selectedItem.value = item
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedItem.value = null
}

const formatTimeOnly = (dateString) => {
  if (!dateString) return ''
  const date = new Date(dateString)
  return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })
}

const getDynamicMessage = (item) => {
  if (!item) return ''
  
  const formatDateTime = (dateString) => {
    if (!dateString) return ''
    const d = new Date(dateString)
    const day = String(d.getDate()).padStart(2, '0')
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const year = d.getFullYear()
    const hours = String(d.getHours()).padStart(2, '0')
    const minutes = String(d.getMinutes()).padStart(2, '0')
    const seconds = String(d.getSeconds()).padStart(2, '0')
    return `${day}/${month}/${year} ${hours}:${minutes}:${seconds}`
  }

  const estOrigen = (item.establecimientoNombre || '').toUpperCase()
  const paciente = (item.pacienteNombre || '').toUpperCase()
  const dni = item.pacienteDni || ''
  const estDestino = (item.establecimientoDestino || 'HOSPITAL MARIA AUXILIADORA').toUpperCase()
  const servicio = (item.especialidad || '').toUpperCase()
  const consultorio = (item.consultorio || 'CONSULTORIO1').toUpperCase()
  const medico = (item.medico || '').toUpperCase()
  const fechaHora = formatDateTime(item.fechaCita)

  return `${estOrigen}

----------------------------------------
- Paciente: ${paciente}
- DNI: ${dni}
----------------------------------------
- Establecimiento de Destino: ${estDestino}
- Servicio: ${servicio}
- Consultorio: ${consultorio}
- Médico: ${medico}
- Fecha y Hora: *${fechaHora}*
----------------------------------------
* Llegar media hora antes de la cita *`
}

// Filters state
const searchQuery = ref('')
const statusFilter = ref('')
const dateTypeFilter = ref('envio') // Default to sent date

const getTodayString = () => {
  const today = new Date()
  return today.toISOString().split('T')[0]
}

const startDate = ref(getTodayString())
const endDate = ref(getTodayString())

const clearFilters = () => {
  searchQuery.value = ''
  statusFilter.value = ''
  startDate.value = ''
  endDate.value = ''
  dateTypeFilter.value = 'envio'
}

const filteredHistory = computed(() => {
  return history.value.filter(item => {
    // 1. Text Search
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase().trim()
      const matchesText = 
        (item.pacienteNombre && item.pacienteNombre.toLowerCase().includes(q)) ||
        (item.pacienteDni && item.pacienteDni.includes(q)) ||
        (item.especialidad && item.especialidad.toLowerCase().includes(q)) ||
        (item.establecimientoDestino && item.establecimientoDestino.toLowerCase().includes(q))
      if (!matchesText) return false
    }

    // 2. Status Filter
    if (statusFilter.value && item.estadoEnvio !== statusFilter.value) {
      return false
    }

    // 3. Date Range Filter (Dynamic field select: fechaHoraEnvio or fechaCita)
    const targetDateStr = dateTypeFilter.value === 'envio' ? item.fechaHoraEnvio : item.fechaCita
    if (targetDateStr) {
      const itemDate = new Date(targetDateStr)
      itemDate.setHours(0, 0, 0, 0)

      if (startDate.value) {
        const start = new Date(startDate.value + 'T00:00:00')
        if (itemDate < start) return false
      }
      if (endDate.value) {
        const end = new Date(endDate.value + 'T00:00:00')
        if (itemDate > end) return false
      }
    } else {
      if (startDate.value || endDate.value) return false
    }

    return true
  })
})

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

const fetchHistory = async () => {
  try {
    const res = await api.get('/reminders/history')
    history.value = res.data
  } catch (err) {
    console.error('Error fetching history', err)
  }
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleString()
}

const getStatusBadge = (status) => {
  if (status === 'Enviado') return 'badge-success'
  if (status === 'Fallido') return 'badge-danger'
  return 'badge-warning'
}

onMounted(() => {
  fetchHistory()
})
</script>

<style scoped>
.history-container {
  width: 100%;  
  margin: 0 auto;
}
.table-panel {
  padding: 2rem;
}
.panel-header {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  margin-bottom: 2rem;
  border-bottom: 1px solid var(--border-color);
  padding-bottom: 1.5rem;
}
.header-title-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  width: 100%;
}
.filter-bar-row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
  width: 100%;
}
.filter-item {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
}
.search-item { flex: 2; min-width: 180px; }
.type-item { flex: 1; min-width: 120px; }
.date-item { flex: 1; min-width: 130px; }
.status-item { flex: 1; min-width: 120px; }
.action-item { display: flex; align-items: flex-end; }

.search-input, .date-input, .status-select {
  padding: 0.6rem 0.8rem;
  font-size: 0.9rem;
  border: 1px solid rgba(0, 0, 0, 0.1);
  border-radius: 8px;
  background: #FFFFFF;
}
.search-input:focus, .date-input:focus, .status-select:focus {
  border-color: var(--primary-color);
  outline: none;
}

.btn-refresh {
  background: #E2E8F0;
  color: #475569;
  border: 1px solid var(--border-color);
  padding: 0.5rem 1rem;
  font-size: 0.9rem;
}
.btn-refresh:hover {
  background: #CBD5E1;
}
.btn-clear {
  background: var(--danger-light);
  color: var(--danger-color);
  padding: 0.6rem 1.2rem;
  font-size: 0.9rem;
  border-radius: 8px;
}
.btn-clear:hover {
  background: rgba(239, 68, 68, 0.2);
}
.table-wrapper {
  overflow-x: auto;
}
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}
th {
  color: var(--text-muted);
  font-weight: 600;
  font-size: 0.875rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}
tr:hover td {
  background: rgba(255, 255, 255, 0.02);
}
.empty-state {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}
.badge {
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 600;
}
.badge-success {
  background: rgba(16, 185, 129, 0.2);
  color: #10B981;
}
.badge-danger {
  background: rgba(239, 68, 68, 0.2);
  color: #EF4444;
}
.badge-warning {
  background: rgba(245, 158, 11, 0.2);
  color: #F59E0B;
}

/* Action button inside table (Premium Glassmorphic Pill) */
.btn-action-detail {
  background: rgba(99, 102, 241, 0.06);
  color: var(--primary-color);
  border: 1.5px solid rgba(99, 102, 241, 0.15);
  padding: 0.45rem 1.1rem;
  border-radius: 9999px; /* Perfect pill shape */
  font-size: 0.78rem;
  font-weight: 700;
  cursor: pointer;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  box-shadow: 0 2px 6px rgba(99, 102, 241, 0.04);
  letter-spacing: 0.2px;
}

.btn-detail-icon {
  transition: transform 0.4s ease;
}

.btn-action-detail:hover {
  background: var(--primary-color);
  color: #FFFFFF;
  border-color: var(--primary-color);
  transform: translateY(-2px);
  box-shadow: 0 6px 16px rgba(99, 102, 241, 0.24);
}

.btn-action-detail:hover .btn-detail-icon {
  transform: scale(1.15) rotate(15deg);
}

.btn-action-detail:active {
  transform: translateY(0) scale(0.97);
  box-shadow: 0 2px 8px rgba(99, 102, 241, 0.15);
}

/* Glassmorphic Modal Overlay */
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
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--primary-color);
  margin: 0;
}

.modal-badge-status {
  display: inline-block;
  font-size: 0.7rem;
  text-transform: uppercase;
  letter-spacing: 0.5px;
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
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 2rem;
  background: rgba(255, 255, 255, 0.25);
}

/* Details Layout Segmented Structure */
.details-sections {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
}

.details-group-section {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.section-group-title {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--primary-color);
  text-transform: uppercase;
  letter-spacing: 0.75px;
  margin: 0;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  border-bottom: 1.5px solid rgba(99, 102, 241, 0.08);
  padding-bottom: 0.35rem;
}

/* Details Grid */
.details-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
  align-content: start;
}

.details-list-flat {
  display: flex;
  flex-direction: column;
  background: rgba(255, 255, 255, 0.45);
  border: 1px solid rgba(255, 255, 255, 0.6);
  border-radius: 14px;
  overflow: hidden;
}

.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1.25rem;
  border-bottom: 1px solid rgba(0, 0, 0, 0.04);
}

.detail-row:last-child {
  border-bottom: none;
}

.highlight-row {
  background: rgba(99, 102, 241, 0.02);
}

.detail-label-flat {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
}

.detail-value-flat {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text-h);
  text-align: right;
}

.detail-card {
  background: rgba(255, 255, 255, 0.5);
  border: 1px solid rgba(255, 255, 255, 0.6);
  padding: 0.85rem 1rem;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.premium-card {
  background: rgba(99, 102, 241, 0.03);
  border: 1px solid rgba(99, 102, 241, 0.15);
}

.detail-label {
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.detail-value {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text-h);
}

.highlight-text {
  color: var(--primary-color);
}

/* WhatsApp Phone Mockup styling */
.message-preview-section {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.message-preview-section h4 {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text-h);
  text-transform: uppercase;
  margin: 0;
  letter-spacing: 0.5px;
}

.phone-mockup {
  border: 4px solid #1E293B;
  border-radius: 18px;
  overflow: hidden;
  background-color: #E5DDD5; /* WhatsApp background */
  box-shadow: 0 10px 25px rgba(0,0,0,0.08);
  display: flex;
  flex-direction: column;
  height: auto;
}

.phone-header {
  background: #075E54;
  color: #FFFFFF;
  padding: 0.6rem 1rem;
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.phone-avatar {
  width: 32px;
  height: 32px;
  background: rgba(255,255,255,0.2);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.1rem;
}

.phone-chat-info {
  display: flex;
  flex-direction: column;
}

.phone-chat-name {
  font-size: 0.85rem;
  font-weight: 700;
}

.phone-chat-status {
  font-size: 0.65rem;
  opacity: 0.85;
}

.phone-body {
  flex-grow: 1;
  padding: 1rem;
  overflow-y: auto;
  display: flex;
  align-items: flex-end;
  background-image: radial-gradient(rgba(0, 0, 0, 0.04) 15%, transparent 15%),
                    radial-gradient(rgba(0, 0, 0, 0.04) 15%, transparent 15%);
  background-size: 16px 16px;
  background-position: 0 0, 8px 8px;
}

.chat-bubble {
  background: #FFFFFF;
  border-radius: 0px 10px 10px 10px;
  padding: 0.6rem 0.8rem;
  max-width: 90%;
  box-shadow: 0 2px 5px rgba(0,0,0,0.05);
  position: relative;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}

.chat-bubble::before {
  content: '';
  position: absolute;
  top: 0;
  left: -8px;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 0 8px 8px 0;
  border-color: transparent #FFFFFF transparent transparent;
}

.formatted-message {
  margin: 0;
  font-size: 0.8rem;
  color: #111111;
  white-space: pre-line;
  line-height: 1.4;
}

.chat-time {
  font-size: 0.6rem;
  color: #777777;
  align-self: flex-end;
}

/* Animations */
.animate-fade-in {
  animation: fadeIn 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}

@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.96) translateY(8px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}

@media (max-width: 768px) {
  .modal-body {
    grid-template-columns: 1fr;
    max-height: 70vh;
  }
  .modal-content {
    max-height: 95vh;
  }
}

@media (max-width: 480px) {
  .details-grid {
    grid-template-columns: 1fr;
  }
}
.col-num {
  width: 40px;
  text-align: center;
  color: var(--text-muted);
}
</style>
