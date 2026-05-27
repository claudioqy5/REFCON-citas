<template>
  <div class="admin-container">
    <div class="glass-panel table-panel">
      <div class="panel-header">
        <h2>Gestión de Establecimientos</h2>
        <button @click="openCreateModal" class="btn btn-primary">Nuevo Establecimiento</button>
      </div>

      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Código Único</th>
              <th>Nombre</th>
              <th>Estado</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in establecimientos" :key="item.establecimientoID">
              <td>{{ item.establecimientoID }}</td>
              <td>{{ item.codigoUnico }}</td>
              <td>{{ item.nombreEstablecimiento }}</td>
              <td>
                <span :class="['badge', item.estado === 'Activo' ? 'badge-success' : 'badge-danger']">
                  {{ item.estado }}
                </span>
              </td>
              <td>
                <button @click="openEditModal(item)" class="btn btn-sm btn-secondary">Editar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal Form -->
    <div v-if="showModal" class="modal-overlay">
      <div class="glass-panel modal-content">
        <h3>{{ isEditing ? 'Editar' : 'Nuevo' }} Establecimiento</h3>
        <form @submit.prevent="save">
          <div class="form-group">
            <label>Código Único</label>
            <input v-model="form.codigoUnico" required />
          </div>
          <div class="form-group">
            <label>Nombre del Establecimiento</label>
            <input v-model="form.nombreEstablecimiento" required />
          </div>
          <div class="form-group" v-if="isEditing">
            <label>Estado</label>
            <select v-model="form.estado" class="form-select">
              <option value="Activo">Activo</option>
              <option value="Suspendido">Suspendido</option>
            </select>
          </div>
          <div class="modal-actions">
            <button type="button" @click="showModal = false" class="btn btn-secondary">Cancelar</button>
            <button type="submit" class="btn btn-primary">Guardar</button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useAuthStore } from '../stores/auth'
import axios from 'axios'

const authStore = useAuthStore()
const establecimientos = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const form = ref({ establecimientoID: 0, codigoUnico: '', nombreEstablecimiento: '', estado: 'Activo' })

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: { Authorization: `Bearer ${authStore.token}` }
})

const fetchData = async () => {
  const res = await api.get('/admin/establecimientos')
  establecimientos.value = res.data
}

const openCreateModal = () => {
  isEditing.value = false
  form.value = { establecimientoID: 0, codigoUnico: '', nombreEstablecimiento: '', estado: 'Activo' }
  showModal.value = true
}

const openEditModal = (item) => {
  isEditing.value = true
  form.value = { ...item }
  showModal.value = true
}

const save = async () => {
  if (isEditing.value) {
    await api.put(`/admin/establecimientos/${form.value.establecimientoID}`, form.value)
  } else {
    await api.post('/admin/establecimientos', form.value)
  }
  showModal.value = false
  fetchData()
}

onMounted(() => fetchData())
</script>

<style scoped>
.admin-container { max-width: 1200px; margin: 0 auto; }
.table-panel { padding: 2rem; }
.panel-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; }
table { width: 100%; border-collapse: collapse; }
th, td { padding: 1rem; text-align: left; border-bottom: 1px solid var(--border-color); }
.btn-sm { padding: 0.4rem 0.8rem; font-size: 0.85rem; }
.btn-secondary { background: #E2E8F0; color: #475569; }
.btn-secondary:hover { background: #CBD5E1; }
.badge { padding: 0.25rem 0.75rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 600; }
.badge-success { background: rgba(16, 185, 129, 0.2); color: #10B981; }
.badge-danger { background: rgba(239, 68, 68, 0.2); color: #EF4444; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal-content { width: 400px; padding: 2rem; }
.form-group { margin-bottom: 1rem; }
.form-select { width: 100%; padding: 0.75rem; background: rgba(15, 23, 42, 0.6); border: 1px solid var(--border-color); border-radius: 8px; color: white; }
.modal-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }
</style>
