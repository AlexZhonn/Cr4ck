// @ts-check
const eslint = require('@eslint/js');
const { defineConfig } = require('eslint/config');
const tseslint = require('typescript-eslint');
const angular = require('angular-eslint');

module.exports = defineConfig([
  {
    files: ['**/*.ts'],
    extends: [
      eslint.configs.recommended,
      tseslint.configs.recommended,
      tseslint.configs.stylistic,
      angular.configs.tsRecommended,
    ],
    processor: angular.processInlineTemplates,
    rules: {
      // ── Angular selectors ─────────────────────────────────────────────────
      '@angular-eslint/directive-selector': [
        'error',
        { type: 'attribute', prefix: 'app', style: 'camelCase' },
      ],
      '@angular-eslint/component-selector': [
        'error',
        { type: 'element', prefix: 'app', style: 'kebab-case' },
      ],

      // ── Stylistic rules: warn for now, tighten incrementally ──────────────
      // The codebase uses constructor injection throughout; migrating to
      // inject() is a future refactor task (AUDIT-Q2 follow-up).
      '@angular-eslint/prefer-inject': 'warn',

      // Many error handlers use `any` for unknown error shapes.
      // Suppress at rule level; add explicit types incrementally.
      '@typescript-eslint/no-explicit-any': 'warn',

      // Empty arrow functions appear in HTTP error callbacks intentionally.
      '@typescript-eslint/no-empty-function': 'warn',

      // Unused vars: turn off underscore-prefixed vars (common pattern)
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
      ],
    },
  },
  {
    files: ['**/*.html'],
    extends: [angular.configs.templateRecommended, angular.configs.templateAccessibility],
    rules: {
      // Accessibility rules — AUDIT-F2 completed; escalated from warn to error.
      '@angular-eslint/template/button-has-type': 'error',
      '@angular-eslint/template/click-events-have-key-events': 'error',
      '@angular-eslint/template/interactive-supports-focus': 'error',
      '@angular-eslint/template/alt-text': 'error',
    },
  },
]);
