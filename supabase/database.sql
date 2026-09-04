-- ============================================
-- GETFROM - SUPABASE DATABASE SETUP
-- Run this entire file in Supabase SQL Editor
-- ============================================

create extension if not exists pgcrypto;

-- USER PROFILES
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'user',
  created_at timestamptz default now()
);

-- FORMS
create table if not exists public.forms (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text default '',
  fields jsonb not null default '[]'::jsonb,
  published boolean not null default false,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- FORM SUBMISSIONS
create table if not exists public.submissions (
  id uuid primary key default gen_random_uuid(),
  form_id uuid not null references public.forms(id) on delete cascade,
  answers jsonb not null default '{}'::jsonb,
  created_at timestamptz default now()
);

-- Enable Row Level Security
alter table public.profiles enable row level security;
alter table public.forms enable row level security;
alter table public.submissions enable row level security;

-- Profiles policies
drop policy if exists "users read own profile" on public.profiles;
create policy "users read own profile"
on public.profiles for select
to authenticated
using (auth.uid() = id);

drop policy if exists "users update own profile" on public.profiles;
create policy "users update own profile"
on public.profiles for update
to authenticated
using (auth.uid() = id);

-- Forms policies
drop policy if exists "owners manage own forms" on public.forms;
create policy "owners manage own forms"
on public.forms for all
to authenticated
using (auth.uid() = owner_id)
with check (auth.uid() = owner_id);

drop policy if exists "public can read published forms" on public.forms;
create policy "public can read published forms"
on public.forms for select
to anon, authenticated
using (published = true);

-- Submission policies
drop policy if exists "public can submit to published forms" on public.submissions;
create policy "public can submit to published forms"
on public.submissions for insert
to anon, authenticated
with check (
  exists (
    select 1 from public.forms
    where forms.id = form_id and forms.published = true
  )
);

drop policy if exists "owners read form submissions" on public.submissions;
create policy "owners read form submissions"
on public.submissions for select
to authenticated
using (
  exists (
    select 1 from public.forms
    where forms.id = submissions.form_id
    and forms.owner_id = auth.uid()
  )
);

-- Automatically create a profile after signup
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer set search_path = public
as $$
begin
  insert into public.profiles (id, full_name)
  values (new.id, coalesce(new.raw_user_meta_data->>'full_name', 'GetFROM User'));
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
