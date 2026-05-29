<template>
  <div class="admin-container">
    <div class="glass-panel table-panel">
      <div class="panel-header">
        <h2>Gestión de Usuarios</h2>
        <button @click="openCreateModal" class="btn btn-primary">Nuevo Usuario</button>
      </div>

      <div class="table-wrapper">
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Establecimiento</th>
              <th>Nombre</th>
              <th>Email</th>
              <th>Estado</th>
              <th>Rol</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in usuarios" :key="item.usuarioID">
              <td>{{ item.usuarioID }}</td>
              <td>{{ item.establecimientoNombre }}</td>
              <td>{{ item.nombreCompleto }}</td>
              <td>{{ item.email }}</td>
              <td>
                <span :class="['badge', item.estado === 'Activo' ? 'badge-success' : 'badge-danger']">
                  {{ item.estado }}
                </span>
              </td>
              <td>
                <span :class="['badge', item.rol === 'Admin' ? 'badge-admin' : 'badge-user']">{{ item.rol }}</span>
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
        <h3>{{ isEditing ? 'Editar' : 'Nuevo' }} Usuario</h3>
        <form @submit.prevent="save">
          <div class="form-group">
            <label>Establecimiento</label>
            <select v-model="form.establecimientoID" required class="form-select" :class="{ 'input-error': errors.EstablecimientoID }">
              <option value="" disabled>Seleccione un establecimiento</option>
              <option v-for="est in establecimientos" :key="est.establecimientoID" :value="est.establecimientoID">
                {{ est.nombreEstablecimiento }}
              </option>
            </select>
            <span class="field-error" v-if="errors.EstablecimientoID">{{ errors.EstablecimientoID.join(', ') }}</span>
          </div>
          <div class="form-group">
            <label>Nombre Completo</label>
            <input v-model="form.nombreCompleto" required :class="{ 'input-error': errors.NombreCompleto }" />
            <span class="field-error" v-if="errors.NombreCompleto">{{ errors.NombreCompleto.join(', ') }}</span>
          </div>
          <div class="form-group">
            <label>Email</label>
            <input type="email" v-model="form.email" required :class="{ 'input-error': errors.Email }" />
            <span class="field-error" v-if="errors.Email">{{ errors.Email.join(', ') }}</span>
          </div>
          <div class="form-group">
            <label>Contraseña {{ isEditing ? '(Dejar en blanco para no cambiar)' : '' }}</label>
            <input type="password" v-model="form.contrasena" :required="!isEditing" :class="{ 'input-error': errors.Contrasena }" />
            <span class="field-error" v-if="errors.Contrasena">{{ errors.Contrasena.join(', ') }}</span>
          </div>
          <div class="form-group">
            <label>Rol</label>
            <select v-model="form.rol" class="form-select">
              <option value="User">User (Establecimiento)</option>
              <option value="Admin">Admin (Super Administrador)</option>
            </select>
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
const usuarios = ref([])
const establecimientos = ref([])
const showModal = ref(false)
const isEditing = ref(false)
const errors = ref({})
const form = ref({ usuarioID: 0, establecimientoID: '', nombreCompleto: '', email: '', contrasena: '', estado: 'Activo', rol: 'User' })

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL || 'http://localhost:5146/api',
  headers: { Authorization: `Bearer ${authStore.token}` }
})

const fetchData = async () => {
  const resUsers = await api.get('/admin/usuarios')
  usuarios.value = resUsers.data
  const resEst = await api.get('/admin/establecimientos')
  establecimientos.value = resEst.data
}

const openCreateModal = () => {
  isEditing.value = false
  errors.value = {}
  form.value = { usuarioID: 0, establecimientoID: '', nombreCompleto: '', email: '', contrasena: '', estado: 'Activo', rol: 'User' }
  showModal.value = true
}

const openEditModal = (item) => {
  isEditing.value = true
  errors.value = {}
  form.value = { ...item, contrasena: '' } // Clear password field for editing
  showModal.value = true
}

const save = async () => {
  errors.value = {}
  try {
    if (isEditing.value) {
      await api.put(`/admin/usuarios/${form.value.usuarioID}`, form.value)
    } else {
      await api.post('/admin/usuarios', form.value)
    }
    showModal.value = false
    fetchData()
  } catch (e) {
    if (e.response?.status === 400 && e.response?.data?.errors) {
      errors.value = e.response.data.errors
    } else {
      alert(e.response?.data?.message || 'Error al guardar')
    }
  }
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
.badge-admin { background: rgba(99, 102, 241, 0.2); color: #6366F1; }
.badge-user { background: rgba(148, 163, 184, 0.15); color: #94A3B8; }

/* Modal */
.modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.6); display: flex; align-items: center; justify-content: center; z-index: 100; }
.modal-content { width: 400px; padding: 2rem; max-height: 90vh; overflow-y: auto; }
.form-group { margin-bottom: 1rem; }
.form-select { width: 100%; padding: 0.75rem; background: rgba(15, 23, 42, 0.6); border: 1px solid var(--border-color); border-radius: 8px; color: white; }
.modal-actions { display: flex; justify-content: flex-end; gap: 1rem; margin-top: 2rem; }
.input-error { border-color: var(--danger-color) !important; }
.field-error { color: var(--danger-color); font-size: 0.8rem; margin-top: 0.25rem; display: block; }
</style>
