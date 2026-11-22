# ShopHub E-Commerce App

ShopHub is a Flutter e-commerce app backed by Supabase. It has customer and
admin experiences, email/password and Google sign-in, product image storage,
and database-enforced access policies.

## Features

- Customers can browse and search products, filter by category, manage a cart,
  check out, and review their order history.
- Admins can manage products and categories and update order statuses.
- Checkout runs in one PostgreSQL function. It reads current product prices,
  locks and checks stock, decrements inventory, and saves an order and item
  snapshots atomically.
- Riverpod providers manage asynchronous data and cart state.

## Supabase setup

1. Create a Supabase project.
2. In the Supabase SQL Editor, run
   `supabase/migrations/20261122000000_initial_ecommerce.sql` once. It creates
   the schema, profile trigger, checkout function, storage bucket, and RLS
   policies. This migration also creates profiles for existing Auth users.
3. Run `supabase/seed_shirts.sql` to add or update the sample shirt products and
   their image URLs. The seed can be run again without duplicating those
   products.
4. In Authentication settings, enable the Email provider. For Google sign-in,
   enable the Google provider and configure its OAuth client credentials and
   redirect URLs in Supabase and Google Cloud.
5. In `lib/main.dart`, use the project URL and publishable key for your
   Supabase project. Never put a service-role or secret key in the Flutter app.
6. To grant admin access, first sign up the intended account, then run this in
   the SQL Editor, replacing the email:

   ```sql
   update public.profiles
   set role_id = (select id from public.roles where name = 'admin')
   where id = (
     select id
     from auth.users
     where lower(email) = lower('admin@example.com')
   );
   ```

   New users are customers by default. Customers cannot change their own role.

## Why RLS matters

Hiding admin buttons is only a UI choice: a user could still call the Supabase
API directly. Row Level Security checks every database request, so the backend
enforces role and ownership rules even when a client bypasses the app UI.

The policies allow customers to read products and categories, read and update
their own profile (but not its role), read only their own orders and order
items, and invoke the checkout function. Admin policies permit catalog
management and order-status updates. Checkout is the only client-accessible
path for creating orders; it obtains names and prices from the database.

## Run locally

```powershell
flutter pub get
flutter run -d chrome
```

Run checks with:

```powershell
flutter analyze
flutter test
```

## Submission checklist

- Capture Supabase screenshots of the schema, functions and triggers, Auth
  users, and RLS policies.
- Put those screenshots in a Google Drive folder shared with the instructor.
- Submit the GitHub branch URL and the shared Drive folder URL.
