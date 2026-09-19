# Chinhito — setup (step 1: scaffold + Supabase + Google OAuth)

## 1. Fill in `.env`

Copy already done (`.env` exists, gitignored). Fill in your Supabase project values:

```
SUPABASE_URL=https://YOUR_PROJECT_REF.supabase.co
SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY
```

Found in Supabase dashboard → Project Settings → API.

## 2. Enable Google provider in Supabase

Supabase dashboard → Authentication → Providers → Google → enable.
You'll need a Google Cloud OAuth **Web** client ID + secret (see step 3), pasted into this Supabase provider config.

Supabase gives you a callback URL here, looks like:
`https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
— you'll enter this in Google Cloud Console below.

## 3. Google Cloud Console — OAuth client(s)

Project → APIs & Services → Credentials → Create Credentials → OAuth client ID.

- **Web application** client (required — this is the one Supabase uses server-side):
  - Authorized redirect URI: `https://YOUR_PROJECT_REF.supabase.co/auth/v1/callback`
  - Paste this client's ID + secret into the Supabase Google provider (step 2).
- **Android** client (for native sign-in flow to skip the browser consent screen on repeat logins — optional for step 1, needed for polish later):
  - Package name: `com.chinhito.chinhito`
  - SHA-1: `cd android/app && keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android` (debug), plus your release keystore's SHA-1 before shipping.
- **iOS** client (same, optional now):
  - Bundle ID: check `ios/Runner.xcodeproj` (default `com.chinhito.chinhito` unless changed in Xcode).

The web app currently uses the app's own origin as the OAuth redirect (Supabase detects the session from the URL automatically). Mobile uses the custom scheme `io.chinhito.app://login-callback/`, already wired into `AndroidManifest.xml` and `Info.plist`.

## 4. Web redirect allowlist

Supabase dashboard → Authentication → URL Configuration → Redirect URLs — add whatever origin you'll run the web app from, e.g.:
- `http://localhost:PORT` (whatever `flutter run -d chrome` binds — check terminal output)
- your deployed web URL, once you have one

## 5. Run it

```
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # after any @riverpod change
flutter run -d chrome      # or an Android/iOS device/emulator
```

Tap the login icon top-right → "Continue with Google". On success you land on `/profile`
(gated: signed-out users are redirected to `/sign-in`; map/detail screens stay public per the product rule).

## What's stubbed for later steps

- `map_explore` — placeholder screen, wires to `geo_drilldown` + real Supabase tables in step 2.
- `destination_detail`, `visited_tracking`, `feed` — folders scaffolded (`data/domain/application/presentation`), empty.
