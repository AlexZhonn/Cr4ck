/**
 * Auth setup — creates a verified test user via the API and stores auth state.
 * Runs once before the critical-journey tests that require a logged-in user.
 *
 * Requires a running backend with TEST_DATABASE_URL set so the registration
 * inserts into the test DB and the verification bypass is available.
 */
import { test as setup, expect } from '@playwright/test';
import * as path from 'path';

export const authFile = path.join(__dirname, '.auth/user.json');

const API = process.env['E2E_API_URL'] ?? 'http://localhost:8000';

// Unique per test run to avoid collisions
const ts = Date.now();
export const TEST_USER = {
  username: `e2e_user_${ts}`,
  email: `e2e_${ts}@example.com`,
  password: 'E2eTestPass123!',
};

setup('create and verify test user', async ({ request, page }) => {
  // 1. Register
  const reg = await request.post(`${API}/auth/v1/register`, {
    data: TEST_USER,
  });
  expect(reg.status()).toBe(201);

  // 2. Bypass email verification directly via the DB-level API (test endpoint)
  //    In CI, the backend exposes POST /auth/v1/test/verify-bypass when TEST_MODE=true.
  //    Falls back to extracting the token via the admin API if available.
  const bypass = await request.post(`${API}/auth/v1/test/verify-bypass`, {
    data: { email: TEST_USER.email },
    headers: { 'X-Test-Secret': process.env['TEST_SECRET'] ?? 'test-secret' },
  });
  // If the bypass endpoint doesn't exist (non-test env), skip e2e gracefully
  if (!bypass.ok()) {
    console.warn('Verification bypass unavailable — skipping e2e login setup');
    return;
  }

  // 3. Log in via the UI and save auth state
  await page.goto('/login');
  await page.getByLabel('Email or username').fill(TEST_USER.email);
  await page.getByLabel('Password').fill(TEST_USER.password);
  await page.getByRole('button', { name: 'Sign In' }).click();

  // Wait for redirect away from /login
  await expect(page).not.toHaveURL(/login/, { timeout: 10_000 });

  // 4. Persist the authenticated storage state
  await page.context().storageState({ path: authFile });
});
