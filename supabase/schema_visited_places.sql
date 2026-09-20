create table visited_places (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references auth.users(id) on delete cascade,
  destination_id uuid not null references destinations(id) on delete cascade,
  visited_at     timestamptz not null default now(),
  unique (user_id, destination_id)
);

create index idx_visited_places_user_id on visited_places (user_id);
create index idx_visited_places_destination_id on visited_places (destination_id);

-- RLS: users can only ever see/write their own visited rows. This is the DB-level
-- enforcement of "only signed-in users can mark places visited" — the app also
-- gates the UI, but this holds even if that check is ever bypassed.
alter table visited_places enable row level security;

create policy "users can view their own visited places"
  on visited_places for select using (auth.uid() = user_id);

create policy "users can mark their own visited places"
  on visited_places for insert with check (auth.uid() = user_id);

create policy "users can unmark their own visited places"
  on visited_places for delete using (auth.uid() = user_id);
