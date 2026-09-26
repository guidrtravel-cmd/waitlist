-- Guidr waitlist backend (Supabase project "wishlist website-guidr", ref ohrgavamspzzkzbopxrm)
-- Snapshot of what is live. Reference only: it's already deployed.

-- public.waitlist: the list. RLS on, no policies, so nobody can read/write it directly.
create table public.waitlist (
  id         bigint generated always as identity primary key,
  email      text not null unique,
  source     text,   -- ?src= / utm_source tag, or "direct"
  referrer   text,   -- hostname that linked to the page
  lang       text,   -- browser language
  tz         text,   -- browser time zone
  created_at timestamptz not null default now()
);
alter table public.waitlist enable row level security;

-- private schema (not exposed through the API):
--   private.settings (ip_salt), private.waitlist_attempts (salted IP hashes for rate limiting, kept 1 day)
--   private.join_waitlist(...)  SECURITY DEFINER: rate limit (30/10min, 300/day per IP), email shape check,
--                               throwaway-inbox block, insert (duplicates ignored), returns status/position/total
--   private.waitlist_count()    SECURITY DEFINER: count(*) from public.waitlist

-- Public wrappers: the only things the website (publishable key) can call.
--   public.join_waitlist(p_email, p_source, p_referrer, p_lang, p_tz) -> jsonb
--   public.waitlist_count() -> int
--
-- Responses from join_waitlist:
--   {ok:true, status:'joined', position:N, total:N}
--   {ok:true, status:'already', total:N}
--   {ok:false, error:'invalid_email' | 'disposable' | 'rate_limited'}
