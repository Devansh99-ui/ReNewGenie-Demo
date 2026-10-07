# Adding a real backend (what is missing today and how to add it)

The demo is a static site. That is good for a portfolio link but it means:
- no real user accounts: the impact log lives in the browser (`localStorage`);
- no shared community board outside Claude;
- no real bookings or collector data.

The original project report describes a Flask API with JWT login, a database and rate limiting. The cheapest way to get the same effect without running a server is **Supabase** (hosted Postgres with login and row-level security) or **Firebase**.

## Suggested Supabase plan
1. Create a free project at supabase.com. Enable email login.
2. Run `backend/supabase_schema.sql` (in this repo) in the SQL editor. It creates `impact_log`, `listings` and `labels` tables with row-level security so each user can only change their own rows.
3. Add the project URL and the public `anon` key to the page. The anon key is meant to be public, because row-level security is what protects the data. Never put the `service_role` key in the page.
4. Replace the three places in `app.js` that read and write the impact log, the board and the label list (`LOG`, the board code near `cboard`, and the `rg_fb` list) with calls to the Supabase client.

## Status
`backend/supabase_schema.sql` has **not been run against a real project** by me. Read it, run it on a throwaway project first, and test the policies by trying to read another user's row.

## What to tell an interviewer
"The demo runs entirely in the browser by design, so it has no server cost and the link never goes down. The real version would use Supabase for accounts and storage, with row-level security. The schema is in the repo, and the next step is wiring the page to it."
