create extension if not exists pgcrypto;

create table if not exists public.gf_profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 full_name text,
 role text not null default 'user' check(role in('user','admin','super_admin','blocked')),
 created_at timestamptz default now()
);

create table if not exists public.gf_apps(
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 name text not null,
 category text,
 description text,
 theme text default '#6d4aff',
 published boolean default false,
 config jsonb not null default '{"pages":[]}'::jsonb,
 created_at timestamptz default now()
);

create table if not exists public.gf_forms(
 id uuid primary key default gen_random_uuid(),
 owner_id uuid not null references auth.users(id) on delete cascade,
 title text not null,
 config jsonb not null default '{"fields":[]}'::jsonb,
 created_at timestamptz default now()
);

create table if not exists public.gf_submissions(
 id uuid primary key default gen_random_uuid(),
 form_id uuid not null references public.gf_forms(id) on delete cascade,
 payload jsonb not null default '{}'::jsonb,
 created_at timestamptz default now()
);

alter table public.gf_profiles enable row level security;
alter table public.gf_apps enable row level security;
alter table public.gf_forms enable row level security;
alter table public.gf_submissions enable row level security;

drop policy if exists "profile self read" on public.gf_profiles;
create policy "profile self read" on public.gf_profiles for select to authenticated using(id=auth.uid());

drop policy if exists "admins profiles" on public.gf_profiles;
create policy "admins profiles" on public.gf_profiles for select to authenticated using(
 exists(select 1 from public.gf_profiles me where me.id=auth.uid() and me.role in('admin','super_admin'))
);

drop policy if exists "apps owner all" on public.gf_apps;
create policy "apps owner all" on public.gf_apps for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());

drop policy if exists "published apps public" on public.gf_apps;
create policy "published apps public" on public.gf_apps for select to anon,authenticated using(published=true);

drop policy if exists "forms owner all" on public.gf_forms;
create policy "forms owner all" on public.gf_forms for all to authenticated using(owner_id=auth.uid()) with check(owner_id=auth.uid());

drop policy if exists "forms public lookup" on public.gf_forms;
create policy "forms public lookup" on public.gf_forms for select to anon,authenticated using(true);

drop policy if exists "public submit" on public.gf_submissions;
create policy "public submit" on public.gf_submissions for insert to anon,authenticated with check(true);

drop policy if exists "submission owner read" on public.gf_submissions;
create policy "submission owner read" on public.gf_submissions for select to authenticated using(
 exists(select 1 from public.gf_forms f where f.id=form_id and f.owner_id=auth.uid())
);

create or replace function public.gf_new_user()
returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.gf_profiles(id,full_name)
 values(new.id,coalesce(new.raw_user_meta_data->>'full_name',''))
 on conflict(id) do nothing;
 return new;
end;$$;

drop trigger if exists gf_new_user_trigger on auth.users;
create trigger gf_new_user_trigger after insert on auth.users
for each row execute procedure public.gf_new_user();

-- AFTER REGISTERING YOUR FIRST ACCOUNT:
-- Find your UUID in Authentication > Users, then run:
-- update public.gf_profiles set role='super_admin' where id='PASTE-YOUR-UUID-HERE';