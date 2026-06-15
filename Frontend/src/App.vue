<template>
  <div class="app-layout" :class="{ 'has-sidebar': authStore.isAuthenticated && !authStore.isAdmin }">
    <nav v-if="authStore.isAuthenticated" :class="authStore.isAdmin ? 'navbar glass-panel' : 'sidebar glass-panel'">
      <div class="nav-brand">
        <span class="brand-icon">🩺</span>
        <span class="brand-text">REFCON</span>
        <span class="brand-text">citas</span>
      </div>
      <div class="nav-links">
        <router-link to="/">
          <span class="link-icon">📊</span>
          <span class="link-text">Inicio</span>
        </router-link>
        <router-link to="/historical">
          <span class="link-icon">📈</span>
          <span class="link-text">Histórico</span>
        </router-link>
        <router-link to="/patients">
          <span class="link-icon">👥</span>
          <span class="link-text">Pacientes</span>
        </router-link>
        <router-link to="/calendar">
          <span class="link-icon">📅</span>
          <span class="link-text">Agenda</span>
        </router-link>
        <router-link to="/history">
          <span class="link-icon">📜</span>
          <span class="link-text">Historial</span>
        </router-link>
        
        <template v-if="authStore.isAdmin">
          <div class="divider"></div>
          <router-link to="/admin/establecimientos" class="admin-link">🏢 <span class="link-text">Establecimientos</span></router-link>
          <router-link to="/admin/usuarios" class="admin-link">👥 <span class="link-text">Usuarios</span></router-link>
        </template>

        <button @click="logout" class="btn btn-logout">
          <span class="link-icon">🚪</span>
          <span class="link-text">Salir</span>
        </button>
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

/* Sidebar style (vertical for normal Tenants) */
.app-layout.has-sidebar {
  flex-direction: row;
}
.sidebar {
  width: 78px; /* Sleek, minimal width when not hovered */
  height: calc(100vh - 2rem);
  margin: 1rem;
  padding: 2rem 0.5rem; /* Balanced horizontal padding */
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: flex-start;
  gap: 2rem;
  position: sticky;
  top: 1rem;
  border-radius: 16px;
  flex-shrink: 0;
  overflow: hidden;
  transition: all 0.4s cubic-bezier(0.25, 0.8, 0.25, 1);
  box-shadow: 0 4px 30px rgba(0, 0, 0, 0.03);
  box-sizing: border-box;  
  background: linear-gradient(180deg, rgba(15, 23, 42, 0.82) 0%, rgba(30, 41, 59, 0.85) 100%), url('./assets/sidebarfondo.jpg') no-repeat center center / cover;
  backdrop-filter: blur(10px);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

/* Beautiful hover expanding effect */
.sidebar:hover {
  width: 260px;
  padding: 2rem 1.25rem;
  align-items: flex-start;
  box-shadow: 0 10px 40px rgba(99, 102, 241, 0.08);
}

/* Brand header */
.sidebar .nav-brand {
  font-weight: 700;
  font-size: 1.2rem;
  color: var(--primary-color);
  width: 100%;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
  display: flex;
  align-items: center;
  justify-content: center;
  white-space: nowrap;
  box-sizing: border-box;
}

.sidebar:hover .nav-brand {
  justify-content: flex-start;
  padding-left: 0.5rem;
}

.brand-icon {
  font-size: 1.3rem;
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.sidebar .brand-text {
  opacity: 0;
  max-width: 0;
  display: inline-block;
  overflow: hidden;
  transform: translateX(-10px);
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  font-size: 1.2rem;
  font-weight: 700;
  pointer-events: none;
  white-space: nowrap;
}

.sidebar:hover .brand-text {
  opacity: 1;
  max-width: 150px;
  margin-left: 0.75rem;
  transform: translateX(0);
}

/* Sidebar Links */
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
  padding: 0.75rem;
  border-radius: 10px;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center; /* Perfectly center icons when collapsed */
  white-space: nowrap;
  box-sizing: border-box;
}

.sidebar:hover .nav-links a {
  justify-content: flex-start;
  padding: 0.75rem 1rem;
}

.sidebar .nav-links a:hover, .sidebar .nav-links a.router-link-active {
  background: var(--primary-light);
  color: var(--primary-color);
}

.link-icon {
  font-size: 1.2rem;
  flex-shrink: 0;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 24px; /* Fix icon width to ensure perfectly centered alignment */
  height: 24px;
}

.sidebar .link-text {
  opacity: 0;
  max-width: 0;
  display: inline-block;
  overflow: hidden;
  transform: translateX(-10px);
  transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
  pointer-events: none;
  white-space: nowrap;
}

.sidebar:hover .link-text {
  opacity: 1;
  max-width: 150px;
  margin-left: 1rem;
  transform: translateX(0);
}

/* Logout Button */
.sidebar .btn-logout {
  margin-top: auto; /* Pushes logout to the bottom */
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 0.75rem;
  white-space: nowrap;
  box-sizing: border-box;
}

.sidebar:hover .btn-logout {
  justify-content: flex-start;
  padding: 0.75rem 1rem;
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

/* Sidebar dark overrides for readability */
.sidebar .nav-brand {
  color: #FFFFFF !important;
  border-bottom: 1px solid rgba(255, 255, 255, 0.15) !important;
}

.sidebar .brand-text {
  color: #FFFFFF !important;
}

.sidebar .nav-links a {
  color: rgba(255, 255, 255, 0.75) !important;
}

.sidebar .nav-links a:hover {
  background: rgba(255, 255, 255, 0.1) !important;
  color: #FFFFFF !important;
}

.sidebar .nav-links a.router-link-active {
  background: rgba(99, 102, 241, 0.35) !important;
  color: #FFFFFF !important;
  border: 1px solid rgba(99, 102, 241, 0.5);
}

.sidebar .btn-logout {
  color: rgba(255, 255, 255, 0.75) !important;
  border: 1px solid rgba(255, 255, 255, 0.15) !important;
}

.sidebar .btn-logout:hover {
  background: rgba(239, 68, 68, 0.25) !important;
  border-color: rgba(239, 68, 68, 0.45) !important;
  color: #FFA3A3 !important;
}
</style>
