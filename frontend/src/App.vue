<template>
  <div class="app-shell" data-testid="home-shell">
    <header class="shell-header">
      <p class="page-label">Startseite</p>
      <h1 data-testid="app-title">HeizInventur</h1>
    </header>

    <main class="shell-main" aria-label="Inhaltsbereich Startseite">
      <p class="intro">
        Willkommen in der Inventurerfassung. Die Kernnavigation wird in den
        naechsten Phasen verfuegbar.
      </p>
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
