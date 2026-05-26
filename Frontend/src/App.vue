<template>
  <div class="app-layout" :class="{ 'has-sidebar': authStore.isAuthenticated && !authStore.isAdmin }">
    <nav v-if="authStore.isAuthenticated" :class="authStore.isAdmin ? 'navbar glass-panel' : 'sidebar glass-panel'">
      <div class="nav-brand">
        🩺 Recordatorios
      </div>
      <div class="nav-links">
        <router-link to="/">Dashboard</router-link>
        <router-link to="/patients">Pacientes</router-link>
        <router-link to="/history">Historial</router-link>
        
        <template v-if="authStore.isAdmin">
          <div class="divider"></div>
          <router-link to="/admin/establecimientos" class="admin-link">🏢 Establecimientos</router-link>
          <router-link to="/admin/usuarios" class="admin-link">👥 Usuarios</router-link>
        </template>

        <button @click="logout" class="btn btn-logout">Salir</button>
      </div>
    </nav>
    <main class="main-content">
      <router-view></router-view>
    </main>
  </div>
</template>

<script setup>
import { useAuthStore } from './stores/auth'
import { useRouter } from 'vue-router'

const authStore = useAuthStore()
const router = useRouter()

const logout = () => {
  authStore.logout()
  router.push('/login')
}
</script>

<style scoped>
.app-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

/* Base Navbar style (horizontal for Admins) */
.navbar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem 2rem;
  margin: 1rem;
  border-radius: 12px;
}
.navbar .nav-links {
  display: flex;
  gap: 1.5rem;
  align-items: center;
}
.navbar .nav-links a {
  color: var(--text-main);
  text-decoration: none;
  font-weight: 500;
  transition: color 0.2s;
}
.navbar .nav-links a:hover, .navbar .nav-links a.router-link-active {
  color: var(--primary-color);
}

/* Sidebar style (vertical for normal Tenants - on the right) */
.app-layout.has-sidebar {
  flex-direction: row;
}
.sidebar {
  width: 260px;
  height: calc(100vh - 2rem);
  margin: 1rem;
  padding: 2rem 1.25rem;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  justify-content: flex-start;
  gap: 2rem;
  position: sticky;
  top: 1rem;
  border-radius: 16px;
  flex-shrink: 0;
}
.sidebar .nav-brand {
  font-weight: 700;
  font-size: 1.2rem;
  color: var(--primary-color);
  width: 100%;
  text-align: center;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}
.sidebar .nav-links {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  width: 100%;
  height: 100%;
}
.sidebar .nav-links a {
  color: var(--text-main);
  text-decoration: none;
  font-weight: 500;
  transition: all 0.2s ease;
  padding: 0.75rem 1rem;
  border-radius: 8px;
  width: 100%;
  display: block;
}
.sidebar .nav-links a:hover, .sidebar .nav-links a.router-link-active {
  background: var(--primary-light);
  color: var(--primary-color);
}
.sidebar .btn-logout {
  margin-top: auto; /* Pushes logout to the bottom */
  width: 100%;
}

.nav-brand {
  font-weight: 700;
  font-size: 1.25rem;
  color: var(--primary-color);
}

.divider {
  width: 1px;
  height: 24px;
  background-color: var(--border-color);
  margin: 0 0.5rem;
}
.admin-link {
  color: var(--warning-color) !important;
}
.admin-link:hover, .admin-link.router-link-active {
  color: var(--primary-color) !important;
}
.btn-logout {
  background: transparent;
  border: 1px solid var(--border-color);
  color: var(--text-muted);
  padding: 0.5rem 1rem;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}
.btn-logout:hover {
  background: var(--danger-light);
  color: var(--danger-color);
  border-color: var(--danger-color);
}
.main-content {
  flex: 1;
  padding: 2rem;
  display: flex;
  flex-direction: column;
  overflow-y: auto;
}
</style>
