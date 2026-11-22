# Supabase-Flutter Activity: Price Filter and Pagination

Standalone Flutter app for the CS Elective 2 Supabase-Flutter activity. It
provides email/password authentication, a database-backed price range slider,
and six-product pages.

## Supabase setup

This app reads the `public.products` table and requires an authenticated user.
It is configured for the Supabase project used by ShopHub. Apply the ShopHub
schema migration from the `flutter-final-exam-project` branch first, and make
sure the Email auth provider is enabled. The products SELECT policy must allow
authenticated customers to read products.

The Supabase URL and publishable key are configured in `lib/main.dart`. A
publishable key is intended for client apps; never put a service-role key in
Flutter code.

## Price filtering and pagination

The slider's upper bound comes from the highest product price in Supabase.
Dragging the slider updates its local preview; releasing it applies the filter
and resets to page one. Riverpod owns the selected range and current page.

The product service sends `gte`/`lte` price filters, name ordering, and a
zero-based `.range(...)` to Supabase. It requests an exact count in that same
query so the UI can show the page count and enable or disable navigation.
Each page contains at most six products.

## Run

```powershell
flutter pub get
flutter run -d chrome
```

```powershell
flutter analyze
flutter test
```
