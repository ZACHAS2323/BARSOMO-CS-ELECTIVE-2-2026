# Fieldnotes Blog Platform

Web Development final exam project: a React frontend, two independent Express
servers, and MariaDB storage. The Auth Server issues access JWTs and manages
refresh tokens. The Blog API verifies access JWTs with the shared secret and
does not call the Auth Server.

## Requirements

- Node.js 18 or newer
- XAMPP with MySQL/MariaDB enabled
- npm

## Database setup

1. Start **MySQL** in the XAMPP Control Panel.
2. Open phpMyAdmin (`http://localhost/phpmyadmin`) or the MySQL console.
3. Import [`database/schema.sql`](./database/schema.sql). It creates the
   `blog_platform` database, role records, and `users`, `refresh_tokens`, and
   `posts` tables.
4. Copy `.env.example` to `.env` and set your MariaDB credentials and a long,
   unique `JWT_SECRET`. Do not commit `.env`.
5. To grant admin privileges, register an account first, then run this query in
   phpMyAdmin, replacing the username:

   ```sql
   USE blog_platform;
   UPDATE users
   SET role_id = (SELECT id FROM roles WHERE role = 'admin')
   WHERE username = 'your_username';
   ```

   Then sign out and back in so the account receives a token with its new role.
   Public registration intentionally allows only `reader` and `author`; an
   administrator must assign the `admin` role in the database.

## Install and run

From this directory:

```powershell
npm install
npm --prefix frontend install
npm run dev
```

The three services run in separate processes:

- React/Vite: `http://localhost:5173`
- Auth Server: `http://localhost:4000`
- Blog API: `http://localhost:5000`

Build the React frontend for production with `npm run build`. The Blog API
serves `frontend/dist` when that folder exists.

## API

### Auth Server (port 4000)

- `POST /register` — `{ "username", "password", "role", "email?" }`
- `POST /login` — `{ "username", "password" }`; returns access and refresh tokens
- `POST /refresh` — `{ "refreshToken" }`; returns a new access token
- `POST /logout` — `{ "refreshToken" }`; revokes the refresh token

Email may be omitted for API compatibility; the server generates a local
`@local.invalid` address. Passwords are bcrypt-hashed. Refresh tokens are
random and only their SHA-256 hashes are stored in the database.

### Blog API (port 5000)

- `GET /api/posts` and `GET /api/posts/:id` are public.
- `POST /api/posts` requires an `author` or `admin` access token.
- `PUT /api/posts/:id` requires the post owner or an `admin`.
- `DELETE /api/posts/:id` requires an `admin`.
- `GET /api/me/posts` requires any valid access token.

Send protected requests with `Authorization: Bearer <accessToken>`.

## Schema

`roles` has one-to-many relationships with `users`; users have one-to-many
relationships with `refresh_tokens` and `posts`. Posts store the author ID as a
foreign key, and database constraints preserve referential integrity.
