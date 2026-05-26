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
            <button @click="clearFilters" class="btn btn-clear">Limpiar</button>
          </div>
        </div>
      </div>

      <div class="table-wrapper">
        <table v-if="filteredHistory.length > 0">
          <thead>
            <tr>
              <th>DNI</th>
              <th>Paciente</th>
              <th>Celular</th>
              <th>Est. Destino</th>
              <th>Especialidad</th>
              <th>Fecha Cita</th>
              <th>Fecha Envío</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredHistory" :key="item.mensajeID">
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
            </tr>
          </tbody>
        </table>
        <div v-else class="empty-state">
          No se encontraron mensajes en el historial para los filtros seleccionados.
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
  baseURL: 'http://localhost:5146/api',
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
  max-width: 1200px;
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
</style>
