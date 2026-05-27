<template>
  <div class="patients-container">
    <div class="glass-panel table-panel">
      <div class="panel-header">
        <h2>Pacientes Registrados</h2>
        <div class="filter-wrapper">
          <input v-model="searchQuery" placeholder="Buscar por nombre o DNI..." class="search-input" />
          <button @click="fetchPatients" class="btn btn-secondary">Actualizar</button>
        </div>
      </div>

      <div class="table-wrapper">
        <table v-if="filteredPatients.length > 0">
          <thead>
            <tr>              
              <th>DNI</th>
              <th>Nombre Completo</th>
              <th>Celular</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in filteredPatients" :key="item.pacienteID">              
              <td>{{ item.dni }}</td>
              <td>{{ item.nombreCompleto }}</td>
              <td>{{ item.celular }}</td>
            </tr>
          </tbody>
        </table>
        <div v-else class="empty-state">
          No se encontraron pacientes que coincidan con la búsqueda.
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
const patients = ref([])
const searchQuery = ref('')

const filteredPatients = computed(() => {
  if (!searchQuery.value) return patients.value
  const query = searchQuery.value.toLowerCase().trim()
  return patients.value.filter(p => 
    p.nombreCompleto.toLowerCase().includes(query) || 
    p.dni.includes(query)
  )
})

const api = axios.create({
  baseURL: 'http://localhost:5146/api',
  headers: {
    Authorization: `Bearer ${authStore.token}`
  }
})

const fetchPatients = async () => {
  try {
    const res = await api.get('/reminders/patients')
    patients.value = res.data
  } catch (err) {
    console.error('Error fetching patients', err)
  }
}

onMounted(() => {
  fetchPatients()
})
</script>

<style scoped>
.patients-container {
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
  gap: 1.5rem;
}
.filter-wrapper {
  display: flex;
  gap: 1rem;
  align-items: center;
  width: 100%;
  max-width: 450px;
  justify-content: flex-end;
}
.search-input {
  max-width: 280px;
  padding: 0.6rem 1rem;
  font-size: 0.9rem;
}
.btn-secondary {
  background: #E2E8F0;
  color: #475569;
  border: 1px solid var(--border-color);
}
.btn-secondary:hover {
  background: #CBD5E1;
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
  background: rgba(0, 0, 0, 0.01);
}
.empty-state {
  text-align: center;
  padding: 3rem;
  color: var(--text-muted);
}
</style>
