<template>
  <div class="expired-container">
    <!-- Header Banner -->
    <div class="expired-header glass-panel">
      <div class="header-left">
        <div class="header-icon">🗓️</div>
        <div>
          <h1>Citas por Reprogramar</h1>
          <p class="header-subtitle">
            Pacientes cuya cita ya pasó — el sistema <strong>no envió WhatsApp</strong> a estos pacientes.
            Contacta o reprograma cada caso.
          </p>
        </div>
      </div>
      <div class="header-right">
        <div class="badge-count" v-if="!loading">
          <span class="count-num">{{ filteredVencidas.length }}</span>
          <span class="count-lbl">registros</span>
        </div>
        <button @click="fetchVencidas" class="btn-refresh-expired">
          <svg xmlns="http://www.w3.org/2000/svg" width="15" height="15" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
            <path stroke-linecap="round" stroke-linejoin="round" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15" />
          </svg>
          Actualizar
        </button>
      </div>
    </div>

    <!-- Filter Bar -->
    <div class="glass-panel filter-panel">
      <div class="filter-grid">
        <div class="filter-group">
          <label>🔍 Buscar</label>
          <input v-model="searchQuery" placeholder="DNI, nombre, especialidad..." class="filter-input" />
        </div>
        <div class="filter-group">
          <label>📅 Cita desde</label>
          <input type="date" v-model="fechaDesde" class="filter-input" />
        </div>
        <div class="filter-group">
          <label>📅 Cita hasta</label>
          <input type="date" v-model="fechaHasta" class="filter-input" />
        </div>
        <div class="filter-group">
          <label>🏥 Especialidad</label>
          <select v-model="especialidadFilter" class="filter-input">
            <option value="">Todas</option>
            <option v-for="esp in uniqueEspecialidades" :key="esp" :value="esp">{{ esp }}</option>
          </select>
        </div>
        <div class="filter-group filter-actions">
          <button @click="clearFilters" class="btn-clear-filter">Limpiar filtros</button>
        </div>
      </div>
    </div>

    <!-- Loading State -->
    <div v-if="loading" class="loading-state glass-panel">
      <div class="loading-spinner"></div>
      <p>Cargando citas vencidas...</p>
    </div>

    <!-- Empty State -->
    <div v-else-if="filteredVencidas.length === 0" class="empty-state glass-panel">
      <div class="empty-illustration">✅</div>
      <h3>Sin citas vencidas</h3>
      <p v-if="searchQuery || fechaDesde || fechaHasta || especialidadFilter">
        No hay resultados para los filtros aplicados. <button class="btn-link" @click="clearFilters">Limpiar filtros</button>
      </p>
      <p v-else>No se han detectado citas vencidas. Los pacientes reciben sus recordatorios con anticipación.</p>
    </div>

    <!-- Table -->
    <div v-else class="glass-panel table-panel">
      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th class="col-num">#</th>
              <th>DNI</th>
              <th>Paciente</th>
              <th>Celular</th>
              <th>Especialidad</th>
              <th>Fecha de Cita (Vencida)</th>
              <th>Est. Destino</th>
              <th>Médico</th>
              <th>Consultorio</th>
              <th>Detectado el</th>
              <th style="text-align:center">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(item, index) in filteredVencidas" :key="item.mensajeID" class="expired-row">
              <td class="col-num"><strong>{{ index + 1 }}</strong></td>
              <td><span class="dni-badge">{{ item.pacienteDni }}</span></td>
              <td class="patient-name">{{ item.pacienteNombre }}</td>
              <td>
                <a :href="'tel:' + item.pacienteCelular" class="phone-link" :title="'Llamar a ' + item.pacienteNombre">
                  📞 {{ item.pacienteCelular }}
                </a>
              </td>
              <td><span class="specialty-chip">{{ item.especialidad || '-' }}</span></td>
              <td>
                <div class="expired-date">
                  <span class="expired-date-icon">⚠️</span>
                  <span class="expired-date-text">{{ formatDate(item.fechaCita) }}</span>
                </div>
              </td>
              <td>{{ item.establecimientoDestino || '-' }}</td>
              <td>{{ item.medico || '-' }}</td>
              <td>{{ item.consultorio || '-' }}</td>
              <td class="detection-date">{{ formatDetectionDate(item.fechaDeteccion) }}</td>
              <td style="text-align:center">
                <button @click="openDetail(item)" class="btn-detail">
                  <svg xmlns="http://www.w3.org/2000/svg" width="13" height="13" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5">
                    <path stroke-linecap="round" stroke-linejoin="round" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
                    <path stroke-linecap="round" stroke-linejoin="round" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
                  </svg>
                  Ver Detalle
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Detail Modal -->
    <div v-if="showModal && selectedItem" class="modal-overlay" @click.self="closeModal">
      <div class="modal-content glass-panel animate-fade-in">
        <div class="modal-header">
          <div class="header-info">
            <span class="modal-badge-expired">🗓️ Cita Vencida</span>
            <h3>{{ selectedItem.pacienteNombre }}</h3>
            <p class="modal-sub">DNI: {{ selectedItem.pacienteDni }} · Cel: {{ selectedItem.pacienteCelular }}</p>
          </div>
          <button @click="closeModal" class="btn-close">&times;</button>
        </div>

        <div class="modal-body">
          <!-- Left: patient data -->
          <div class="detail-sections">
            <div class="detail-group">
              <h4>👥 Datos del Paciente</h4>
              <div class="detail-grid">
                <div class="detail-card">
                  <span class="d-label">DNI</span>
                  <span class="d-value">{{ selectedItem.pacienteDni }}</span>
                </div>
                <div class="detail-card">
                  <span class="d-label">Celular</span>
                  <span class="d-value">
                    <a :href="'tel:' + selectedItem.pacienteCelular" class="phone-link-modal">📞 {{ selectedItem.pacienteCelular }}</a>
                  </span>
                </div>
              </div>
            </div>

            <div class="detail-group">
              <h4>🏥 Destino de Referencia</h4>
              <div class="detail-grid">
                <div class="detail-card">
                  <span class="d-label">Establecimiento Destino</span>
                  <span class="d-value">{{ selectedItem.establecimientoDestino || '-' }}</span>
                </div>
                <div class="detail-card">
                  <span class="d-label">Especialidad</span>
                  <span class="d-value">{{ selectedItem.especialidad }}</span>
                </div>
              </div>
            </div>

            <div class="detail-group">
              <h4>📅 Información de la Cita</h4>
              <div class="detail-list">
                <div class="detail-row">
                  <span class="d-label-flat">👨‍⚕️ Médico:</span>
                  <span class="d-value-flat primary">{{ selectedItem.medico || 'No especificado' }}</span>
                </div>
                <div class="detail-row">
                  <span class="d-label-flat">🚪 Consultorio:</span>
                  <span class="d-value-flat primary">{{ selectedItem.consultorio || 'No especificado' }}</span>
                </div>
                <div class="detail-row">
                  <span class="d-label-flat">🔑 ID Cita / Referencia:</span>
                  <span class="d-value-flat">{{ selectedItem.idCita }} / {{ selectedItem.idReferencia || '-' }}</span>
                </div>
                <div class="detail-row highlight-expired">
                  <span class="d-label-flat">⚠️ Fecha Cita Vencida:</span>
                  <span class="d-value-flat expired-text">{{ formatDate(selectedItem.fechaCita) }}</span>
                </div>
                <div class="detail-row">
                  <span class="d-label-flat">🕐 Detectado el:</span>
                  <span class="d-value-flat">{{ formatDate(selectedItem.fechaDeteccion) }}</span>
                </div>
              </div>
            </div>
          </div>

          <!-- Right: action banner -->
          <div class="action-section">
            <div class="expired-action-banner">
              <div class="action-icon">🗓️</div>
              <div class="action-content">
                <h4>Acción Requerida</h4>
                <p>Esta cita ya pasó su fecha. El paciente <strong>no recibió notificación</strong> por WhatsApp.</p>
                <p class="action-hint">Contacta al paciente para:</p>
                <ul class="action-list">
                  <li>📞 Verificar si asistió a su cita</li>
                  <li>📋 Reprogramar la referencia en REFCON</li>
                  <li>💊 Dar seguimiento médico si es necesario</li>
                </ul>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()
const vencidas = ref([])
const loading = ref(true)

const showModal = ref(false)
const selectedItem = ref(null)

const searchQuery = ref('')
const fechaDesde = ref('')
const fechaHasta = ref('')
const especialidadFilter = ref('')

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: { Authorization: `Bearer ${authStore.token}` }
})

const fetchVencidas = async () => {
  loading.value = true
  try {
    const res = await api.get('/reminders/vencidas')
    vencidas.value = res.data
  } catch (err) {
    console.error('Error al cargar citas vencidas:', err)
  } finally {
    loading.value = false
  }
}

const uniqueEspecialidades = computed(() => {
  const set = new Set(vencidas.value.map(v => v.especialidad).filter(Boolean))
  return [...set].sort()
})

const filteredVencidas = computed(() => {
  return vencidas.value.filter(item => {
    // Text search
    if (searchQuery.value) {
      const q = searchQuery.value.toLowerCase()
      const match =
        (item.pacienteNombre && item.pacienteNombre.toLowerCase().includes(q)) ||
        (item.pacienteDni && item.pacienteDni.includes(q)) ||
        (item.especialidad && item.especialidad.toLowerCase().includes(q)) ||
        (item.establecimientoDestino && item.establecimientoDestino.toLowerCase().includes(q))
      if (!match) return false
    }

    // Especialidad filter
    if (especialidadFilter.value && item.especialidad !== especialidadFilter.value) return false

    // Date range filter on fechaCita
    if (item.fechaCita) {
      const citaDate = new Date(item.fechaCita)
      citaDate.setHours(0, 0, 0, 0)
      if (fechaDesde.value) {
        const desde = new Date(fechaDesde.value + 'T00:00:00')
        if (citaDate < desde) return false
      }
      if (fechaHasta.value) {
        const hasta = new Date(fechaHasta.value + 'T00:00:00')
        if (citaDate > hasta) return false
      }
    } else {
      if (fechaDesde.value || fechaHasta.value) return false
    }

    return true
  })
})

const clearFilters = () => {
  searchQuery.value = ''
  fechaDesde.value = ''
  fechaHasta.value = ''
  especialidadFilter.value = ''
}

const openDetail = (item) => {
  selectedItem.value = item
  showModal.value = true
}

const closeModal = () => {
  showModal.value = false
  selectedItem.value = null
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleString('es-PE', {
    day: '2-digit', month: '2-digit', year: 'numeric',
    hour: '2-digit', minute: '2-digit'
  })
}

const formatDetectionDate = (dateString) => {
  if (!dateString) return '-'
  return new Date(dateString).toLocaleDateString('es-PE', {
    day: '2-digit', month: '2-digit', year: 'numeric'
  })
}

onMounted(fetchVencidas)
</script>

<style scoped>
.expired-container {
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
  width: 100%;
}

/* Header */
.expired-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1.5rem 2rem;
  gap: 1.5rem;
  border-left: 4px solid #F59E0B;
}
.header-left {
  display: flex;
  align-items: center;
  gap: 1.25rem;
}
.header-icon {
  font-size: 2.5rem;
  line-height: 1;
}
.expired-header h1 {
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0 0 0.3rem 0;
}
.header-subtitle {
  font-size: 0.88rem;
  color: var(--text-muted);
  margin: 0;
  max-width: 500px;
}
.header-right {
  display: flex;
  align-items: center;
  gap: 1rem;
  flex-shrink: 0;
}
.badge-count {
  display: flex;
  flex-direction: column;
  align-items: center;
  background: rgba(245,158,11,0.1);
  border: 1px solid rgba(245,158,11,0.3);
  border-radius: 12px;
  padding: 0.5rem 1rem;
}
.count-num {
  font-size: 1.8rem;
  font-weight: 800;
  color: #D97706;
  line-height: 1;
}
.count-lbl {
  font-size: 0.7rem;
  color: #92400E;
  text-transform: uppercase;
  font-weight: 600;
  letter-spacing: 0.5px;
}
.btn-refresh-expired {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.6rem 1.2rem;
  background: rgba(245,158,11,0.08);
  border: 1.5px solid rgba(245,158,11,0.3);
  border-radius: 8px;
  color: #B45309;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-refresh-expired:hover {
  background: #F59E0B;
  color: white;
  border-color: #F59E0B;
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(245,158,11,0.25);
}

/* Filter Panel */
.filter-panel {
  padding: 1.25rem 2rem;
}
.filter-grid {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  align-items: flex-end;
}
.filter-group {
  display: flex;
  flex-direction: column;
  gap: 0.4rem;
  flex: 1;
  min-width: 160px;
}
.filter-group label {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.filter-input {
  padding: 0.6rem 0.85rem;
  font-size: 0.9rem;
  border: 1px solid var(--border-color);
  border-radius: 8px;
  background: rgba(255,255,255,0.7);
  color: var(--text-main);
  transition: border-color 0.2s;
}
.filter-input:focus {
  border-color: #F59E0B;
  outline: none;
  box-shadow: 0 0 0 3px rgba(245,158,11,0.1);
}
.filter-actions { justify-content: flex-end; }
.btn-clear-filter {
  padding: 0.6rem 1.2rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: #B45309;
  background: rgba(245,158,11,0.08);
  border: 1px solid rgba(245,158,11,0.25);
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-clear-filter:hover {
  background: rgba(245,158,11,0.15);
}

/* Loading State */
.loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem;
  gap: 1rem;
  color: var(--text-muted);
}
.loading-spinner {
  width: 36px;
  height: 36px;
  border: 3px solid rgba(245,158,11,0.2);
  border-top-color: #F59E0B;
  border-radius: 50%;
  animation: spin 0.8s linear infinite;
}
@keyframes spin { to { transform: rotate(360deg); } }

/* Empty State */
.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 4rem;
  text-align: center;
  gap: 0.75rem;
}
.empty-illustration {
  font-size: 4rem;
  margin-bottom: 0.5rem;
  animation: float 3s ease-in-out infinite;
}
@keyframes float {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-6px); }
}
.empty-state h3 {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0;
}
.empty-state p {
  font-size: 0.9rem;
  color: var(--text-muted);
  margin: 0;
}
.btn-link {
  background: none;
  border: none;
  color: #D97706;
  font-weight: 600;
  cursor: pointer;
  text-decoration: underline;
  font-size: inherit;
}

/* Table */
.table-panel { padding: 2rem; }
.table-wrapper { overflow-x: auto; }
table {
  width: 100%;
  border-collapse: collapse;
}
th, td {
  padding: 0.9rem 1rem;
  text-align: left;
  border-bottom: 1px solid var(--border-color);
}
th {
  color: var(--text-muted);
  font-weight: 600;
  font-size: 0.8rem;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  background: rgba(245,158,11,0.03);
}
.expired-row:hover td {
  background: rgba(245,158,11,0.02);
}
.col-num { width: 40px; text-align: center; color: var(--text-muted); }

.dni-badge {
  font-family: monospace;
  font-size: 0.85rem;
  background: rgba(99,102,241,0.07);
  border: 1px solid rgba(99,102,241,0.15);
  border-radius: 6px;
  padding: 0.2rem 0.5rem;
  color: var(--primary-color);
  font-weight: 700;
}

.patient-name {
  font-weight: 600;
  color: var(--text-h);
}

.phone-link {
  color: #059669;
  text-decoration: none;
  font-weight: 600;
  font-size: 0.87rem;
  transition: color 0.2s;
}
.phone-link:hover { color: #047857; text-decoration: underline; }

.specialty-chip {
  display: inline-block;
  background: rgba(99,102,241,0.08);
  color: var(--primary-color);
  border: 1px solid rgba(99,102,241,0.15);
  border-radius: 6px;
  padding: 0.2rem 0.6rem;
  font-size: 0.78rem;
  font-weight: 600;
}

.expired-date {
  display: flex;
  align-items: center;
  gap: 0.4rem;
}
.expired-date-text {
  font-weight: 700;
  color: #B45309;
  font-size: 0.88rem;
}

.detection-date {
  font-size: 0.8rem;
  color: var(--text-muted);
}

.btn-detail {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.4rem 0.9rem;
  background: rgba(245,158,11,0.06);
  border: 1.5px solid rgba(245,158,11,0.2);
  border-radius: 9999px;
  color: #92400E;
  font-size: 0.77rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.25s ease;
}
.btn-detail:hover {
  background: #F59E0B;
  color: white;
  border-color: #F59E0B;
  transform: translateY(-1px);
  box-shadow: 0 4px 10px rgba(245,158,11,0.25);
}

/* Modal */
.modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(15,23,42,0.4);
  backdrop-filter: blur(8px);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 9999;
  padding: 2rem;
}
.modal-content {
  background: rgba(255,255,255,0.88);
  border: 1px solid rgba(255,255,255,0.4);
  border-radius: 20px;
  width: 100%;
  max-width: 950px;
  max-height: 88vh;
  display: flex;
  flex-direction: column;
  box-shadow: 0 20px 50px rgba(0,0,0,0.15);
  overflow: hidden;
}
.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  padding: 1.5rem 2rem;
  border-bottom: 1px solid var(--border-color);
  background: rgba(245,158,11,0.04);
}
.modal-badge-expired {
  display: inline-block;
  background: rgba(245,158,11,0.15);
  color: #92400E;
  border: 1px solid rgba(245,158,11,0.3);
  border-radius: 999px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.5px;
  padding: 0.2rem 0.7rem;
  margin-bottom: 0.4rem;
}
.modal-header h3 {
  font-size: 1.2rem;
  font-weight: 700;
  color: var(--text-h);
  margin: 0.3rem 0 0.1rem 0;
}
.modal-sub {
  font-size: 0.85rem;
  color: var(--text-muted);
  margin: 0;
}
.btn-close {
  background: rgba(0,0,0,0.05);
  border: none;
  font-size: 1.4rem;
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
  background: rgba(239,68,68,0.1);
  color: #EF4444;
}
.modal-body {
  padding: 2rem;
  overflow-y: auto;
  display: grid;
  grid-template-columns: 1.2fr 1fr;
  gap: 2rem;
}

/* Detail sections */
.detail-sections { display: flex; flex-direction: column; gap: 1.5rem; }
.detail-group { display: flex; flex-direction: column; gap: 0.75rem; }
.detail-group h4 {
  font-size: 0.82rem;
  font-weight: 700;
  color: #B45309;
  text-transform: uppercase;
  letter-spacing: 0.75px;
  margin: 0;
  border-bottom: 1.5px solid rgba(245,158,11,0.15);
  padding-bottom: 0.35rem;
}
.detail-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
}
.detail-card {
  background: rgba(255,255,255,0.5);
  border: 1px solid rgba(255,255,255,0.6);
  padding: 0.85rem 1rem;
  border-radius: 12px;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}
.d-label {
  font-size: 0.72rem;
  font-weight: 600;
  color: var(--text-muted);
  text-transform: uppercase;
  letter-spacing: 0.5px;
}
.d-value {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--text-h);
}
.detail-list {
  display: flex;
  flex-direction: column;
  background: rgba(255,255,255,0.45);
  border: 1px solid rgba(255,255,255,0.6);
  border-radius: 14px;
  overflow: hidden;
}
.detail-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.7rem 1.25rem;
  border-bottom: 1px solid rgba(0,0,0,0.04);
}
.detail-row:last-child { border-bottom: none; }
.highlight-expired { background: rgba(245,158,11,0.05); }
.d-label-flat {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--text-muted);
}
.d-value-flat {
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--text-h);
  text-align: right;
}
.d-value-flat.primary { color: var(--primary-color); }
.expired-text { color: #B45309; }
.phone-link-modal {
  color: #059669;
  text-decoration: none;
  font-weight: 700;
}
.phone-link-modal:hover { text-decoration: underline; }

/* Action section */
.action-section { display: flex; flex-direction: column; }
.expired-action-banner {
  background: linear-gradient(135deg, rgba(245,158,11,0.06) 0%, rgba(251,191,36,0.04) 100%);
  border: 1.5px solid rgba(245,158,11,0.25);
  border-radius: 16px;
  padding: 1.75rem;
  display: flex;
  gap: 1rem;
  flex-direction: column;
  align-items: flex-start;
  height: 100%;
  box-sizing: border-box;
}
.action-icon { font-size: 2.5rem; }
.action-content h4 {
  font-size: 1rem;
  font-weight: 700;
  color: #92400E;
  margin: 0 0 0.75rem 0;
}
.action-content p {
  font-size: 0.87rem;
  color: #78350F;
  margin: 0 0 0.5rem 0;
}
.action-hint { font-weight: 600; }
.action-list {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0 0 0;
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}
.action-list li {
  font-size: 0.85rem;
  color: #92400E;
  font-weight: 500;
}

/* Animate */
.animate-fade-in {
  animation: fadeIn 0.25s cubic-bezier(0.16, 1, 0.3, 1) forwards;
}
@keyframes fadeIn {
  from { opacity: 0; transform: scale(0.96) translateY(8px); }
  to { opacity: 1; transform: scale(1) translateY(0); }
}

@media (max-width: 768px) {
  .modal-body { grid-template-columns: 1fr; }
  .expired-header { flex-direction: column; align-items: flex-start; }
  .filter-group { min-width: 140px; }
}
</style>
