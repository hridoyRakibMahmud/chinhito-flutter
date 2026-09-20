-- ============================================
-- USER_PROFILES
-- Public-readable mirror of the auth.users fields the feed needs to show
-- (author name/avatar) — auth.users itself isn't queryable by the client.
-- Populated automatically on signup via a trigger, never written directly
-- by the app.
-- ============================================
create table user_profiles (
  id          uuid primary key references auth.users(id) on delete cascade,
  full_name   text,
  avatar_url  text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

create trigger trg_user_profiles_updated_at
  before update on user_profiles
  for each row execute function set_updated_at();

alter table user_profiles enable row level security;

create policy "profiles are publicly readable"
  on user_profiles for select using (true);

create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.user_profiles (id, full_name, avatar_url)
  values (
    new.id,
    new.raw_user_meta_data ->> 'full_name',
    new.raw_user_meta_data ->> 'avatar_url'
  );
  return new;
end;
$$ language plpgsql security definer set search_path = public;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ============================================
-- FEED_POSTS
-- Text-only posts, optionally tagged to a destination. No edit/delete for
-- now (not in scope) — no comments table either (only likes were named).
-- ============================================
create table feed_posts (
  id             uuid primary key default gen_random_uuid(),
  -- References user_profiles, not auth.users directly: the feed query embeds
  -- user_profiles (to show author name/avatar publicly, since auth.users
  -- itself isn't queryable by the client), and PostgREST can only auto-embed
  -- across a real foreign key. user_profiles.id already has its own FK to
  -- auth.users(id), created in the same transaction by the signup trigger
  -- above, so referential integrity still holds transitively.
  user_id        uuid not null references user_profiles(id) on delete cascade,
  destination_id uuid references destinations(id) on delete set null,
  body           text not null check (char_length(trim(body)) > 0),
  created_at     timestamptz not null default now()
);

create index idx_feed_posts_created_at on feed_posts (created_at desc);
create index idx_feed_posts_destination_id on feed_posts (destination_id);

alter table feed_posts enable row level security;

-- Feed browsing is public, same as the map — only posting requires sign-in.
create policy "posts are publicly readable"
  on feed_posts for select using (true);

create policy "users can create their own posts"
  on feed_posts for insert with check (auth.uid() = user_id);

-- ============================================
-- POST_LIKES
-- ============================================
create table post_likes (
  id         uuid primary key default gen_random_uuid(),
  post_id    uuid not null references feed_posts(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (post_id, user_id)
);

create index idx_post_likes_post_id on post_likes (post_id);

alter table post_likes enable row level security;

create policy "likes are publicly readable"
  on post_likes for select using (true);

create policy "users can like posts as themselves"
  on post_likes for insert with check (auth.uid() = user_id);

create policy "users can unlike their own likes"
  on post_likes for delete using (auth.uid() = user_id);
