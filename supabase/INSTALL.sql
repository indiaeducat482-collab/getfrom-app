create extension if not exists pgcrypto;
create table if not exists public.gf_apps(id uuid primary key,owner_id uuid references auth.users(id) on delete cascade,name text not null,category text,description text,theme text default '#7446ed',published boolean default false,config jsonb default '{"pages":[]}',created_at timestamptz default now());
alter table public.gf_apps enable row level security;
drop policy if exists "owner apps" on public.gf_apps;
create policy "owner apps" on public.gf_apps for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());
drop policy if exists "public apps" on public.gf_apps;
create policy "public apps" on public.gf_apps for select to anon,authenticated using(published=true);