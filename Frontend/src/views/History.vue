<template>
  <div class="history-container">
    <div class="glass-panel table-panel">
      <div class="panel-header">
        <h2>Historial de Mensajes</h2>
        <button @click="fetchHistory" class="btn btn-secondary">Actualizar</button>
      </div>

      <div class="table-wrapper">
        <table v-if="history.length > 0">
          <thead>
            <tr>
              <th>Paciente</th>
              <th>Celular</th>
              <th>Especialidad</th>
              <th>Fecha Cita</th>
              <th>Fecha Envío</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in history" :key="item.mensajeID">
              <td>{{ item.pacienteNombre }}</td>
              <td>{{ item.pacienteCelular }}</td>
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
          No hay mensajes en el historial.
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()
const history = ref([])

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
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1.5rem;
}
.btn-secondary {
  background: rgba(255,255,255,0.1);
  color: white;
  border: 1px solid var(--border-color);
}
.btn-secondary:hover {
  background: rgba(255,255,255,0.2);
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
