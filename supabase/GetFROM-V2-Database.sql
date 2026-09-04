create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade,full_name text,role text not null default 'user' check(role in('user','admin','super_admin')),created_at timestamptz default now());
create table if not exists public.forms(id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,title text not null,description text default '',fields jsonb default '[]'::jsonb,published boolean default false,created_at timestamptz default now(),updated_at timestamptz default now());
create table if not exists public.submissions(id uuid primary key default gen_random_uuid(),form_id uuid not null references public.forms(id) on delete cascade,answers jsonb default '{}'::jsonb,created_at timestamptz default now());
create table if not exists public.apps(id uuid primary key default gen_random_uuid(),owner_id uuid not null references auth.users(id) on delete cascade,name text not null,description text default '',theme jsonb default '{}'::jsonb,pages jsonb default '[]'::jsonb,published boolean default false,created_at timestamptz default now(),updated_at timestamptz default now());
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$begin insert into public.profiles(id,full_name,role) values(new.id,coalesce(new.raw_user_meta_data->>'full_name','GetFROM User'),'user') on conflict(id) do nothing;return new;end;$$;
drop trigger if exists on_auth_user_created on auth.users;create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create or replace function public.is_super_admin() returns boolean language sql stable security definer set search_path=public as $$select exists(select 1 from public.profiles where id=auth.uid() and role='super_admin');$$;
alter table public.profiles enable row level security;alter table public.forms enable row level security;alter table public.submissions enable row level security;alter table public.apps enable row level security;
create policy "profiles read" on public.profiles for select to authenticated using(id=auth.uid() or public.is_super_admin());
create policy "profiles admin update" on public.profiles for update to authenticated using(public.is_super_admin()) with check(public.is_super_admin());
create policy "forms owner" on public.forms for all to authenticated using(owner_id=auth.uid() or public.is_super_admin()) with check(owner_id=auth.uid() or public.is_super_admin());
create policy "forms public" on public.forms for select to anon,authenticated using(published=true);
create policy "submissions insert" on public.submissions for insert to anon,authenticated with check(exists(select 1 from public.forms where id=form_id and published=true));
create policy "submissions read" on public.submissions for select to authenticated using(public.is_super_admin() or exists(select 1 from public.forms where id=form_id and owner_id=auth.uid()));
create policy "apps owner" on public.apps for all to authenticated using(owner_id=auth.uid() or public.is_super_admin()) with check(owner_id=auth.uid() or public.is_super_admin());
create policy "apps public" on public.apps for select to anon,authenticated using(published=true);
-- After registering, run:
-- update public.profiles set role='super_admin' where id=(select id from auth.users where email='YOUR_EMAIL_HERE');