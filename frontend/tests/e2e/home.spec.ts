import { expect, test } from '@playwright/test'

test('zeigt HeizInventur-Startseite mit Platzhaltern', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByTestId('app-title')).toBeVisible()
  await expect(page.getByTestId('app-title')).toHaveText('HeizInventur')
  await expect(page.getByText('Startseite')).toBeVisible()
  await expect(page.getByTestId('nav-placeholder-haeuser')).toBeVisible()
})
