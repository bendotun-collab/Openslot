# OpenSlot v1.2

**Available when you are.**

OpenSlot is a marketplace for availability that would otherwise go unused.

## Marketplace lanes
- **Services** — appointments and service capacity
- **Dining** — restaurant table availability
- **Food & Catering** — catering capacity and prepared-food inventory

## Publishing availability
Businesses can:
1. **Post manually** — supported by the v1.2 data model.
2. **Connect Calendar** — Google Calendar and Square are represented as connection-ready providers. OAuth/API credentials and server-side sync must be configured before these buttons are treated as live integrations.

## Supabase
The browser uses only the public Supabase URL and publishable/anon key. Never expose a service-role/secret key.

For a **fresh Supabase project**, review and run:
`supabase/schema.sql`

> If you already ran an earlier OpenSlot schema, do **not** blindly rerun this file. Create a migration from the existing schema instead.

The schema includes RLS and an atomic `book_open_slot` function to reduce double-booking risk.

## Local setup
1. `npm install`
2. Copy `.env.example` to `.env.local`
3. Add `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`
4. `npm run dev`

## Netlify
- Build command: `npm run build`
- Publish directory: `dist`
- Add the two public Supabase environment variables in Netlify.

## Status
v1.2 now includes email/password authentication, provider onboarding, manual OpenSlot publishing, live inventory retrieval, customer booking through an atomic database function, and a basic provider dashboard. Payment/subscription billing and live calendar OAuth/sync remain intentionally disabled until their external credentials and workflows are configured.
