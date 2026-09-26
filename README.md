# Guidr waitlist

Live at **https://guidrtravel-cmd.github.io/waitlist/**

- `index.html`: the whole page (HTML + CSS + JS), no build step. Logos are inline SVG in the file.
- Backend: Supabase project `wishlist website-guidr`. Signups go through two functions, `join_waitlist` and `waitlist_count`. The `waitlist` table is RLS-locked, so nobody can read the list from the browser.
- Background photos + share card live in the public `site` storage bucket of that project.
- See `HOW-IT-WORKS.md` for details.
