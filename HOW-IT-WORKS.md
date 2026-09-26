# Guidr waitlist site: how it works

**Live link:** https://guidrtravel-cmd.github.io/waitlist/

## Files
| File | What it is |
|---|---|
| `index.html` | The entire website. Push to `main` and it's live in 1-2 minutes. |
| `.nojekyll` | Tells GitHub Pages to serve files as-is. |
| `supabase/schema.sql` | Snapshot of the backend already live in Supabase (reference only). |

## Hosting
GitHub Pages, repo `guidrtravel-cmd/waitlist`, branch `main`, folder `/ (root)`.

## Backend (Supabase project "wishlist website-guidr")
- Signups are stored in `public.waitlist` (email, source, referrer, lang, tz, created_at).
- The page only calls `join_waitlist` and `waitlist_count`. Rate limiting, bad-email and throwaway-inbox blocking happen server side.
- The publishable key is sent only in the `apikey` header.

## Seeing signups
Supabase dashboard -> wishlist website-guidr -> Table Editor -> `waitlist`, or SQL:
```sql
select email, source, created_at from public.waitlist order by created_at desc;
select source, count(*) from public.waitlist group by 1 order by 2 desc;
```

## Tracking where signups come from
Add `?src=instagram` (or tiktok, friend...) to the link. It's saved in the `source` column.

## Quick edits
| Want to change | Where in `index.html` |
|---|---|
| Text | `<main class="hero">` |
| Hide counter until N signups | `const MIN_SHOW = 1;` |
| Colors | `:root { ... }` in `<style>` |
| Glass look | the `.glass` rules (pure CSS, attached to each element so it never drifts on scroll) |
