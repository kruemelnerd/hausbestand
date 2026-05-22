import { expect, test } from '@playwright/test'

test('zeigt die deaktivierten Navigationsplatzhalter der Startseite', async ({ page }) => {
  await page.goto('/')

  await expect(page.getByTestId('app-title')).toHaveText('HeizInventur')
  await expect(page.getByText('Startseite')).toBeVisible()

  for (const testId of [
    'nav-placeholder-haeuser',
    'nav-placeholder-grundrisse',
    'nav-placeholder-reports'
  ]) {
    const button = page.getByTestId(testId)

    await expect(button).toBeVisible()
    await expect(button).toBeDisabled()
    await expect(button).toHaveAttribute('aria-disabled', 'true')
  }
})
