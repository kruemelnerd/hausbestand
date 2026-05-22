<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { fetchSystemStatus, type SystemStatus } from './system-status'

const status = ref<SystemStatus | null>(null)
const loading = ref(true)
const errorMessage = ref('')

const statusBadge = {
  loading: 'Lädt...'
}

async function loadSystemStatus() {
  loading.value = true
  errorMessage.value = ''

  try {
    status.value = await fetchSystemStatus()
  } catch (error) {
    status.value = null
    errorMessage.value = error instanceof Error ? error.message : 'Systemstatus nicht verfügbar'
  } finally {
    loading.value = false
  }
}

onMounted(() => {
  void loadSystemStatus()
})
</script>

<template>
  <div class="app-shell" data-testid="home-shell">
    <header class="shell-header">
      <p class="page-label">Startseite</p>
      <h1 data-testid="app-title">HeizInventur</h1>
    </header>

    <main class="shell-main" aria-label="Inhaltsbereich Startseite">
      <p class="intro">
        Willkommen in der Inventurerfassung. Die Kernnavigation wird in den naechsten Phasen
        verfuegbar.
      </p>

      <section class="status-card" aria-labelledby="system-status-title">
        <div class="status-card__header">
          <p class="page-label" id="system-status-title">Systemstatus</p>
          <span
            v-if="loading"
            class="status-badge status-badge--loading"
            data-testid="system-status-badge"
          >
            {{ statusBadge.loading }}
          </span>
          <span
            v-else-if="status"
            class="status-badge status-badge--success"
            data-testid="system-status-badge"
          >
            Backend erreichbar
          </span>
          <span
            v-else
            class="status-badge status-badge--error"
            data-testid="system-status-badge"
          >
            Fehler
          </span>
        </div>

        <p v-if="loading" data-testid="system-status-loading">Systemstatus wird geladen.</p>
        <p v-else-if="errorMessage" data-testid="system-status-error">{{ errorMessage }}</p>
        <ul v-else class="status-list" data-testid="system-status-success">
          <li>
            <strong>Backend</strong> erreichbar
          </li>
          <li>
            <strong>Datenbank</strong> erreichbar
          </li>
          <li>
            Anwendung: {{ status?.application }} · Datenbank: {{ status?.database }}
          </li>
        </ul>
      </section>
    </main>

    <nav class="shell-nav" aria-label="Hauptnavigation Platzhalter">
      <button data-testid="nav-placeholder-haeuser" type="button" aria-disabled="true" disabled>
        Haeuser (demnaechst)
      </button>
      <button data-testid="nav-placeholder-grundrisse" type="button" aria-disabled="true" disabled>
        Grundrisse (demnaechst)
      </button>
      <button data-testid="nav-placeholder-reports" type="button" aria-disabled="true" disabled>
        Reports (demnaechst)
      </button>
    </nav>
  </div>
</template>
