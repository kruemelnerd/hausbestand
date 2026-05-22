export type SystemStatus = {
  application: string
  database: string
}

function isSystemStatus(value: unknown): value is SystemStatus {
  return (
    typeof value === 'object' &&
    value !== null &&
    'application' in value &&
    'database' in value &&
    typeof (value as Record<string, unknown>).application === 'string' &&
    typeof (value as Record<string, unknown>).database === 'string'
  )
}

export async function fetchSystemStatus(): Promise<SystemStatus> {
  const response = await fetch('/api/system/status', {
    headers: {
      Accept: 'application/json'
    }
  })

  if (!response.ok) {
    throw new Error(`Statusabruf fehlgeschlagen (${response.status})`)
  }

  const payload: unknown = await response.json()

  if (!isSystemStatus(payload)) {
    throw new Error('Unerwartetes Statusformat vom Backend')
  }

  return payload
}
