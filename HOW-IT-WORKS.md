# Guidr waitlist site: how it works

**Live link:** https://guidrtravel-cmd.github.io/waitlist/
**Survey (quiz) page:** https://guidrtravel-cmd.github.io/waitlist/quiz.html

## Files
| File | What it is |
|---|---|
| `index.html` | The current live landing page (email box). |
| `quiz.html` | The new survey: 12 quick questions, then email. Once approved it replaces `index.html`. |
| `privacy.html` | Privacy page linked from the quiz. |
| `.nojekyll` | Tells GitHub Pages to serve files as-is. |
| `supabase/schema.sql` | Snapshot of the backend (reference only). |

## Hosting
GitHub Pages, repo `guidrtravel-cmd/waitlist`, branch `main`, folder `/ (root)`. Push to `main` and it's live in 1-2 minutes.

## Backend (Supabase project "wishlist website-guidr")
- Everything is in `public.waitlist`: email, source, referrer, lang, tz, created_at, plus:
  - `answers` (jsonb): the quiz answers. Empty for people who signed up before the quiz.
  - `answered_at`: when they finished the quiz.
  - `promo_code`, `code_sent_at`: empty for now. Fill these before launch when you send the free-month codes.
- The page only calls `join_waitlist(p_email, p_source, p_referrer, p_lang, p_tz, p_answers)`. Rate limiting, bad-email and throwaway-inbox blocking happen server side. Same email twice = "already in" (answers get updated, no duplicate row).

## Answer keys (inside `answers`)
`vibe`, `with`, `age`, `discover` (list), `saved`, `style`, `pain` (list, max 2), `time`, `apps`, `ai`, `pay` (free/trip/monthly/yearly), `price` (only if they'd pay), `beta` (yes/maybe/no), `secs` (seconds to finish), `v` (quiz version).

## Pitch-deck numbers (Supabase -> SQL editor)
```sql
-- everyone + their answers
select email, source, answers, created_at from public.waitlist order by created_at desc;

-- headline numbers
select count(*) as signups,
       count(answers) as finished_quiz,
       round(100.0 * count(*) filter (where answers->>'pay' <> 'free') / nullif(count(answers),0)) as pct_would_pay,
       count(*) filter (where answers->>'beta' = 'yes') as beta_testers,
       round(100.0 * count(*) filter (where answers->>'ai' = 'off') / nullif(count(answers),0)) as pct_ai_plan_was_off
from public.waitlist;

-- breakdown of any single-choice question (swap 'pay' for vibe, age, time, style...)
select answers->>'pay' as answer, count(*) from public.waitlist where answers is not null group by 1 order by 2 desc;

-- breakdown of the pick-many questions (pain, discover)
select x as answer, count(*) from public.waitlist, jsonb_array_elements_text(answers->'pain') x group by 1 order by 2 desc;

-- what people would pay
select answers->>'pay' as how, answers->>'price' as max_price, count(*) from public.waitlist
where answers->>'pay' in ('trip','monthly','yearly') group by 1,2 order by 1,3 desc;

-- where signups come from (?src= links)
select source, count(*) from public.waitlist group by 1 order by 2 desc;

-- beta tester emails
select email from public.waitlist where answers->>'beta' = 'yes';
```

## Tracking where signups come from
Add `?src=instagram` (or whatsapp, reddit, x, school...) to the link. It's saved in the `source` column.

## Editing questions
In `quiz.html`, edit the `QUESTIONS` list. Keep each question's `id` the same once the quiz is live (they're the keys in `answers`).
