# Blog Platform API

A small blog platform made of two independent Express servers and a browser UI. The Auth Server issues access and refresh JWTs on port 4000. The Blog API verifies access tokens itself on port 5000 and does not call the Auth Server. The Blog API also serves Zach's Blog at `http://localhost:5000`.

## Setup

Install Node.js 18 or newer, then from this folder run:

```sh
npm install
```

The local `.env` is git-ignored and contains a development-only secret. Replace `JWT_SECRET` with a long random value before using this beyond local testing. Both servers load that same root `.env` file.

Start each server in its own terminal:

```sh
npm run auth
npm run blog
```

Open `http://localhost:5000` to read posts, create a reader or author account, sign in, and publish as an author. The browser stores the login tokens in localStorage and refreshes expired access tokens automatically.

Users and posts are held in in-memory arrays and synchronized to server-side `node-localstorage` files in each service's `data/` folder. This provides the localStorage-style persistence requested by the assignment; browser `localStorage` is not accessible from a Node server. The data folders are git-ignored.

## Auth endpoints (port 4000)

- `POST /register` with `{ "username", "password", "role" }`; role must be `reader`, `author`, or `admin`.
- `POST /login` with `{ "username", "password" }`; returns `accessToken` and `refreshToken`.
- `POST /refresh` with `{ "refreshToken" }`; returns a new access token after checking its type, signature, expiry, and saved token value.
- `POST /logout` with `{ "refreshToken" }`; revokes the saved refresh token.

## Blog endpoints (port 5000)

- `GET /api/posts` and `GET /api/posts/:id` are public.
- `POST /api/posts` requires an author or admin access token; body is `{ "title", "content" }`.
- `PUT /api/posts/:id` requires the post owner or an admin; body may contain `title` and/or `content`.
- `DELETE /api/posts/:id` requires an admin token.
- `GET /api/me/posts` requires any valid access token and lists only that user's posts.

Send protected requests with `Authorization: Bearer <accessToken>`. All API errors use `{ "error": "message" }`.
