import { spawn, spawnSync } from 'node:child_process'
import { resolve } from 'node:path'

const frontendRoot = process.cwd()
const repoRoot = resolve(frontendRoot, '..')
const backendRoot = resolve(frontendRoot, '../backend')

let backendProcess
let frontendProcess

function spawnProcess(command, args, cwd) {
  const child = spawn(command, args, {
    cwd,
    env: process.env,
    stdio: 'inherit',
    shell: false
  })

  child.on('exit', (code, signal) => {
    if (signal || code !== 0) {
      shutdown(code ?? 1)
    }
  })

  return child
}

async function waitForHttp(url, timeoutMs = 120_000) {
  const startedAt = Date.now()

  while (Date.now() - startedAt < timeoutMs) {
    try {
      const response = await fetch(url)

      if (response.ok) {
        return
      }
    } catch {
      // keep waiting
    }

    await new Promise((resolve) => setTimeout(resolve, 1000))
  }

  throw new Error(`Timed out waiting for ${url}`)
}

function shutdown(exitCode = 0) {
  for (const child of [frontendProcess, backendProcess]) {
    if (child && !child.killed) {
      child.kill('SIGTERM')
    }
  }

  process.exit(exitCode)
}

process.on('SIGINT', () => shutdown(0))
process.on('SIGTERM', () => shutdown(0))

const composeResult = spawnSync('docker', ['compose', 'up', '-d', '--wait', 'postgres', 'mailpit'], {
  cwd: repoRoot,
  stdio: 'inherit'
})

if (composeResult.status !== 0) {
  throw new Error('Docker Compose setup failed')
}

backendProcess = spawnProcess('./mvnw', ['spring-boot:run'], backendRoot)
await waitForHttp('http://127.0.0.1:8080/actuator/health')

frontendProcess = spawnProcess('npm', ['run', 'dev', '--', '--host', '127.0.0.1', '--port', '4173'], frontendRoot)
await waitForHttp('http://127.0.0.1:4173')

await new Promise(() => {})
