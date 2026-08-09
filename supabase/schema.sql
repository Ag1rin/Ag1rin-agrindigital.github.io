-- Run once in Supabase → SQL Editor
-- https://supabase.com/dashboard/project/wmlsuujrtzoevrduzuew/sql/new

create extension if not exists "pgcrypto";

create table if not exists public.registrations (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  name text not null,
  age int,
  phone text not null,
  email text,
  city text,
  experience text,
  days text[] default '{}',
  times text[] default '{}',
  notes text,
  lang text
);

-- One registration per phone (normalized digits like 09xxxxxxxxx)
create unique index if not exists registrations_phone_unique
  on public.registrations (phone);

alter table public.registrations enable row level security;

grant usage on schema public to anon, authenticated;
grant insert on table public.registrations to anon;
grant select on table public.registrations to anon, authenticated;

drop policy if exists "anon_insert_registrations" on public.registrations;
create policy "anon_insert_registrations"
  on public.registrations
  for insert
  to anon
  with check (true);

-- Admin panel (static site) reads with publishable key after UI login
drop policy if exists "authenticated_select_registrations" on public.registrations;
drop policy if exists "anon_select_registrations" on public.registrations;
create policy "anon_select_registrations"
  on public.registrations
  for select
  to anon, authenticated
  using (true);

create or replace function public.registration_count()
returns bigint
language sql
security definer
set search_path = public
as $$
  select count(*)::bigint from public.registrations;
$$;

revoke all on function public.registration_count() from public;
grant execute on function public.registration_count() to anon, authenticated;
