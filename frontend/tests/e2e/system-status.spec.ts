import { expect, test } from '@playwright/test'

test('zeigt die Phase-4-Reachability der Systemstatus-Kachel', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByTestId('system-status-badge')).toHaveText('Backend erreichbar')
  await expect(page.getByText('Datenbank erreichbar')).toBeVisible()
})
