-- ============================================
-- DIVISIONS
-- ============================================
create table divisions (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  name_bn       text,
  slug          text not null unique,
  geojson_id    text not null unique,
  centroid_lat  double precision,
  centroid_lng  double precision,
  display_order smallint,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index idx_divisions_slug on divisions (slug);

-- ============================================
-- DISTRICTS
-- ============================================
create table districts (
  id            uuid primary key default gen_random_uuid(),
  division_id   uuid not null references divisions(id) on delete cascade,
  name          text not null,
  name_bn       text,
  slug          text not null unique,
  geojson_id    text not null unique,
  centroid_lat  double precision,
  centroid_lng  double precision,
  display_order smallint,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

create index idx_districts_division_id on districts (division_id);
create index idx_districts_slug on districts (slug);

-- ============================================
-- DESTINATIONS (tourist points)
-- ============================================
create type destination_category as enum (
  'beach', 'hill', 'forest', 'historical', 'religious',
  'waterfall', 'lake', 'island', 'archaeological', 'other'
);

create table destinations (
  id             uuid primary key default gen_random_uuid(),
  district_id    uuid not null references districts(id) on delete cascade,
  name           text not null,
  name_bn        text,
  slug           text not null unique,
  description    text,
  category       destination_category not null default 'other',
  latitude       double precision not null,
  longitude      double precision not null,
  rating         numeric(2,1) default 0 check (rating >= 0 and rating <= 5),
  is_published   boolean not null default true,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index idx_destinations_district_id on destinations (district_id);
create index idx_destinations_slug on destinations (slug);
create index idx_destinations_category on destinations (category);
create index idx_destinations_published on destinations (is_published) where is_published = true;

-- ============================================
-- updated_at auto-touch trigger (reused across all three)
-- ============================================
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

create trigger trg_divisions_updated_at
  before update on divisions
  for each row execute function set_updated_at();

create trigger trg_districts_updated_at
  before update on districts
  for each row execute function set_updated_at();

create trigger trg_destinations_updated_at
  before update on destinations
  for each row execute function set_updated_at();

-- ============================================
-- RLS: public can read, nobody can write via the anon/client key.
-- The app only ever reads these tables directly; writes happen from the
-- Supabase dashboard/SQL editor (or a future admin tool using the service
-- role key, which bypasses RLS entirely).
-- ============================================
alter table divisions enable row level security;
alter table districts enable row level security;
alter table destinations enable row level security;

create policy "divisions are publicly readable"
  on divisions for select using (true);

create policy "districts are publicly readable"
  on districts for select using (true);

create policy "published destinations are publicly readable"
  on destinations for select using (is_published = true);
