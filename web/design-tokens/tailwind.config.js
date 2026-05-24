/**
 * GoMandap Tailwind CSS Configuration
 * =====================================
 * Extends Tailwind with GoMandap design tokens for the Next.js web portals.
 * All values are numerically identical to the Android GomandapTokens.
 *
 * Usage:
 *   Import this config in your Next.js project's tailwind.config.js:
 *   const gomandapConfig = require('./design-tokens/tailwind.config');
 *   module.exports = { presets: [gomandapConfig], ... }
 */

/** @type {import('tailwindcss').Config} */
module.exports = {
  theme: {
    extend: {
      /* ─── Colors ──────────────────────────────────────────────── */
      colors: {
        royalNavy: {
          DEFAULT: '#0F172A',
          light: '#1E293B',
          surface: '#334155',
        },
        champagneGold: {
          DEFAULT: '#DFBA73',
          light: '#F5E6C8',
          dark: '#C59A48',
        },
        emeraldGreen: {
          DEFAULT: '#10B981',
          light: '#D1FAE5',
          dark: '#059669',
        },
        neutrals: {
          pearlWhite: '#F8F9FA',
          softMist: '#F1F5F9',
          slateGray: '#64748B',
          lightSlate: '#E2E8F0',
        },
        semantic: {
          error: '#EF4444',
          errorLight: '#FEE2E2',
          warning: '#F59E0B',
          warningLight: '#FEF3C7',
          info: '#3B82F6',
          infoLight: '#DBEAFE',
        },
      },

      /* ─── Spacing (dp → rem, 16dp = 1rem) ─────────────────────── */
      spacing: {
        xxs: '0.25rem',   // 4dp
        xs: '0.5rem',     // 8dp
        sm: '0.75rem',    // 12dp
        md: '1rem',       // 16dp
        lg: '1.25rem',    // 20dp
        xl: '1.5rem',     // 24dp
        xxl: '2rem',      // 32dp
        xxxl: '3rem',     // 48dp
      },

      /* ─── Border Radius ───────────────────────────────────────── */
      borderRadius: {
        small: '0.5rem',       // 8dp
        medium: '0.75rem',     // 12dp
        large: '1rem',         // 16dp
        extraLarge: '1.5rem',  // 24dp
        pill: '9999px',        // fully rounded
      },

      /* ─── Font Size (sp → rem, 16sp = 1rem) ───────────────────── */
      fontSize: {
        'display-large': ['2.25rem', { lineHeight: '1.2', letterSpacing: '-0.03125rem', fontWeight: '900' }],
        'display-medium': ['1.75rem', { lineHeight: '1.2', letterSpacing: '-0.015625rem', fontWeight: '900' }],
        'headline-large': ['1.5rem', { lineHeight: '1.3', fontWeight: '700' }],
        'headline-medium': ['1.25rem', { lineHeight: '1.3', fontWeight: '700' }],
        'headline-small': ['1rem', { lineHeight: '1.4', fontWeight: '600' }],
        'body-large': ['1rem', { lineHeight: '1.5rem', fontWeight: '400' }],
        'body-medium': ['0.875rem', { lineHeight: '1.25rem', fontWeight: '400' }],
        'body-small': ['0.75rem', { lineHeight: '1rem', fontWeight: '400' }],
        'label-large': ['0.875rem', { lineHeight: '1.25rem', fontWeight: '600' }],
        'label-medium': ['0.75rem', { lineHeight: '1rem', fontWeight: '500' }],
        'label-small': ['0.625rem', { lineHeight: '0.875rem', fontWeight: '500' }],
      },

      /* ─── Font Family ─────────────────────────────────────────── */
      fontFamily: {
        primary: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
        display: ['Outfit', 'Inter', 'system-ui', 'sans-serif'],
      },

      /* ─── Box Shadow (elevation approximation) ────────────────── */
      boxShadow: {
        none: 'none',
        low: '0 1px 2px 0 rgba(15, 23, 42, 0.05)',
        medium: '0 4px 6px -1px rgba(15, 23, 42, 0.07), 0 2px 4px -2px rgba(15, 23, 42, 0.05)',
        high: '0 8px 16px -4px rgba(15, 23, 42, 0.10), 0 4px 6px -2px rgba(15, 23, 42, 0.05)',
        overlay: '0 16px 32px -8px rgba(15, 23, 42, 0.15), 0 8px 16px -4px rgba(15, 23, 42, 0.08)',
      },

      /* ─── Transitions ─────────────────────────────────────────── */
      transitionDuration: {
        fast: '150ms',
        normal: '250ms',
        slow: '350ms',
      },
    },
  },
  plugins: [],
};
