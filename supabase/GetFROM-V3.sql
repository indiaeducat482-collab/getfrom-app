create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,full_name text,role text default 'user',created_at timestamptz default now());
create table if not exists public.apps(id uuid primary key default gen_random_uuid(),owner_id uuid references auth.users(id) on delete cascade,name text not null,category text,description text,config jsonb default '{}'::jsonb,published boolean default false,created_at timestamptz default now());
create table if not exists public.templates(id uuid primary key default gen_random_uuid(),name text not null,category text,description text,config jsonb default '{}'::jsonb,active boolean default true);
create table if not exists public.forms(id uuid primary key default gen_random_uuid(),owner_id uuid references auth.users(id) on delete cascade,title text not null,fields jsonb default '[]'::jsonb,published boolean default false);
alter table public.profiles enable row level security;alter table public.apps enable row level security;alter table public.templates enable row level security;alter table public.forms enable row level security;
create policy "own apps" on public.apps for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());
create policy "read templates" on public.templates for select to anon,authenticated using(active=true);
create policy "own forms" on public.forms for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());
