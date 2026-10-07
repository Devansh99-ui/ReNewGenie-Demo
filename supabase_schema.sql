-- ReNewGenie: tables for accounts, impact log, marketplace board and photo labels.
-- NOT yet run against a real project. Test on a throwaway Supabase project first.

create table if not exists impact_log (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  logged_on   date not null default current_date,
  material    text not null check (material in ('plastic','glass','aluminium','steel','paper','cardboard','ewaste','clothes')),
  kg          numeric not null check (kg > 0 and kg <= 10000),
  created_at  timestamptz not null default now()
);

create table if not exists listings (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  title       text not null check (char_length(title) between 3 and 80),
  material    text not null,
  kg          numeric not null check (kg > 0),
  area        text not null,
  reserved_by uuid references auth.users(id),
  created_at  timestamptz not null default now()
);

create table if not exists labels (
  id          bigint generated always as identity primary key,
  user_id     uuid not null references auth.users(id) on delete cascade,
  predicted   text not null,
  confidence  numeric not null check (confidence between 0 and 1),
  true_label  text not null,
  created_at  timestamptz not null default now()
);

alter table impact_log enable row level security;
alter table listings   enable row level security;
alter table labels     enable row level security;

-- impact log: private to its owner
create policy "own log read"   on impact_log for select using (auth.uid() = user_id);
create policy "own log insert" on impact_log for insert with check (auth.uid() = user_id);
create policy "own log delete" on impact_log for delete using (auth.uid() = user_id);

-- listings: everyone signed in can read; only the owner can create or delete
create policy "listings read"   on listings for select using (auth.role() = 'authenticated');
create policy "listings insert" on listings for insert with check (auth.uid() = user_id);
create policy "listings delete" on listings for delete using (auth.uid() = user_id);
-- reserving: any signed-in user may set reserved_by to themselves on an unreserved listing
create policy "listings reserve" on listings for update
  using (reserved_by is null) with check (reserved_by = auth.uid());

-- labels: private to their owner
create policy "own labels read"   on labels for select using (auth.uid() = user_id);
create policy "own labels insert" on labels for insert with check (auth.uid() = user_id);
