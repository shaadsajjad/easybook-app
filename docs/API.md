# EasyBook API: Frontend Guide

> **Status:** every endpoint is live: health, auth, profile (including change password), services, appointments and the AI assistant.
> Changes to the API are listed in the [Changelog](#12-changelog).

---

## 1. Overview

EasyBook is a mobile app for booking local services, such as a haircut, a massage or a home cleaning.
This API handles accounts, the service catalogue, available time slots, appointments, and an AI assistant that recommends services.

---

## 2. Base URLs

| Environment | Base URL |
|---|---|
| Local (iOS simulator / desktop) | `http://localhost:4000/api/v1` |
| Local (Android emulator) | `http://10.0.2.2:4000/api/v1` (`10.0.2.2` is the emulator's alias for your computer) |
| Production (Render) | `https://easybook-api-d89z.onrender.com/api/v1` |

**Cold starts:** the production server runs on Render's free tier, which sleeps when it is idle. The **first request after a quiet period can take 30–50 seconds**. Use a generous timeout (60s) for the first call, or call `GET /health` on the splash screen to wake the server.

---

## 3. Quick start

**1. Create an account**

```bash
curl -X POST http://localhost:4000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"name":"Ayesha Rahman","email":"ayesha@example.com","password":"Secret123"}'
```

The response contains `data.token`. Save it securely (for example with `flutter_secure_storage`).

**2. Send the token on protected requests**

```bash
curl http://localhost:4000/api/v1/users/me \
  -H "Authorization: Bearer <token>"
```

**3. Fetch services** (public, no token needed)

```bash
curl "http://localhost:4000/api/v1/services?featured=true"
```

You can check the server is up right now:

```bash
curl http://localhost:4000/api/v1/health
```

```json
{ "success": true, "data": { "status": "ok", "uptime": 2 } }
```

---

## 4. Authentication

- Log in or register to get a **JWT token**. Send it on every protected request:
  ```
  Authorization: Bearer <token>
  ```
- **Lifetime:** 7 days. There is no refresh token. When it expires, the user logs in again.
- **401 Unauthorized** means the token is missing, malformed or expired. **The app should clear the stored token and send the user to the login screen.**

The three 401 messages you can get (real responses):

```json
{ "success": false, "message": "Authentication required. Please log in." }
```
```json
{ "success": false, "message": "Invalid token. Please log in again." }
```
```json
{ "success": false, "message": "Your session has expired. Please log in again." }
```

You can show `message` to the user as is.

---

## 5. Conventions

### Response shape

Every response is JSON with a `success` flag.

**Success**

```json
{
  "success": true,
  "data": { },
  "message": "optional, human readable",
  "meta": { }
}
```

`message` and `meta` appear only when they apply. `meta` is used for pagination.

**Error**

```json
{
  "success": false,
  "message": "Human readable message you can show to the user",
  "errors": [{ "field": "email", "message": "Invalid email address" }]
}
```

`errors` appears only on **422 validation** errors. Each item names the `field` it belongs to, so you can show the message under that form field. Nested fields use dots (for example `history.0.content`).

Real 422 example:

```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "name", "message": "Invalid input: expected string, received undefined" },
    { "field": "qty", "message": "Too small: expected number to be >0" }
  ]
}
```

### Pagination (used by `GET /services`)

Send `?page=1&limit=20`. The default is page 1 with 20 items, and `limit` can be at most 50. List responses include:

```json
"meta": { "page": 1, "limit": 20, "total": 10, "totalPages": 1 }
```

### Dates and times: always UTC

- **Always send and receive UTC**, in ISO 8601 format: `2026-11-20T03:00:00.000Z`.
- **Convert to local time only for display**: `DateTime.parse(value).toLocal()`.
- When sending a time, use `dateTime.toUtc().toIso8601String()`.
- The one exception is the `date` query parameter on availability, which is a plain calendar date (`YYYY-MM-DD`) in the business's time zone (**Asia/Dhaka, UTC+6**).
- Business hours are **09:00–18:00 Dhaka time**, every day. Slots start every **30 minutes**.

### Prices

`price` is returned as a **string** with two decimals, in **Bangladeshi Taka (BDT, ৳)**, for example `"500.00"`. This keeps the exact value (no floating-point rounding). In Dart, use `double.parse(json['price'])` for display or `Decimal.parse` if you do any money maths.

### Enums

`AppointmentStatus`:

| Value | Meaning |
|---|---|
| `PENDING` | Just booked. **The only status the user can cancel.** All new bookings start here. |
| `CONFIRMED` | Confirmed by the business. |
| `CANCELLED` | Cancelled. The time slot is free again. |
| `COMPLETED` | The appointment took place. |

---

## 6. Status codes and errors

| Code | When it happens | What the app should do |
|---|---|---|
| 200 | Request succeeded | Use `data` |
| 201 | Something was created (account, booking) | Use `data`, show a success state |
| 400 | The request body is not valid JSON | Bug in the app; show a generic error |
| 401 | Token missing, invalid or expired; or wrong login details | On protected routes: clear the token and go to login. On login: show `message` |
| 403 | Not allowed | Show `message` |
| 404 | Route, record or id not found (including someone else's booking) | Show "not found" and go back |
| 409 | Conflict: email already registered, slot already booked, booking can't be cancelled | Show `message` and refresh the data (e.g. reload availability) |
| 413 | Request body over 10 KB | Shorten the input |
| 422 | Validation failed | Show each `errors[].message` under its `field` |
| 429 | Too many requests | Show `message` and ask the user to wait |
| 500 | Unexpected server error | Show "Something went wrong" and offer a retry |
| 502 / 503 | AI assistant unavailable, busy or timed out | Show `message` in the chat and offer a retry |

Real examples:

```json
// 400
{ "success": false, "message": "Malformed JSON in request body" }
```
```json
// 404 (unknown route)
{ "success": false, "message": "Route not found: GET /api/v1/does-not-exist" }
```
```json
// 413
{ "success": false, "message": "Request body is too large" }
```
```json
// 500
{ "success": false, "message": "Something went wrong. Please try again." }
```

**Rate limits** (per device IP unless noted):

| Routes | Limit |
|---|---|
| All routes | 300 requests / 15 minutes |
| `/auth/*` | 20 requests / 15 minutes |
| `/ai/*` | 10 requests / minute **per user** |

---

## 7. Booking flow guide

The screens and calls, in order. All of these endpoints are live.

1. **Home / service list:** `GET /services` (with `search`, `category`, `featured`, `minPrice`, `maxPrice`, `page`). Use `GET /services/categories` for filter chips.
2. **Service detail:** `GET /services/:id`.
3. **Pick a date:** the user picks a calendar day.
4. **Show time slots:** `GET /services/:id/availability?date=YYYY-MM-DD`. Show every slot and **disable the ones with `available: false`** (already booked, in the past, or too late to finish before closing).
5. **Book:** `POST /appointments` with `{ serviceId, startTime, notes? }`. Send `startTime` exactly as it came from the availability response.
   - `201` means it's booked. The status will be `PENDING`.
   - `409` means someone else just took the slot. Show the message and reload availability (step 4).
6. **Confirmation screen:** show the returned appointment (convert times to local).
7. **My Bookings:** `GET /appointments?type=upcoming` and `GET /appointments?type=past` (two tabs). Use `GET /appointments/:id` for detail.
8. **Cancel:** `PATCH /appointments/:id/cancel`. **Only `PENDING` bookings can be cancelled.** Show the Cancel button only when `status == "PENDING"`. Other statuses return `409`.

---

## 8. Endpoints

### GET /health

Checks the server is running. Also useful for waking the server on the splash screen.

**Auth required:** No

**Request:** no parameters.

**Success: 200**

```json
{ "success": true, "data": { "status": "ok", "uptime": 2 } }
```

`uptime` is the number of seconds since the server started.

**Tested scenarios**
- [x] returns 200 with status ok and the uptime in seconds
- [x] sets security headers from helmet and hides x-powered-by
- [x] unknown routes return 404 in the standard error shape
- [x] malformed JSON returns 400 in the standard error shape
- [x] a body larger than 10kb returns 413 in the standard error shape

**Frontend notes:** call this with a long timeout (60s) on app start to wake the production server.

### POST /auth/register

Creates a new account and logs the user in right away.

**Auth required:** No (rate limited: 20 requests per 15 minutes)

**Body**

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `name` | string | Yes | 2–100 characters, trimmed. `"Ayesha Rahman"` |
| `email` | string | Yes | Valid email, max 254. Stored in lowercase, so `Ayesha@Example.com` becomes `ayesha@example.com` |
| `password` | string | Yes | 8–72 characters, with **at least one letter and one number**. `"Secret123"` |

**Success: 201**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "bc3101b4-c476-434a-b6a2-5163af163feb",
      "name": "Ayesha Rahman",
      "email": "ayesha.docs@example.com",
      "phone": null,
      "createdAt": "2026-11-16T15:22:46.585Z",
      "updatedAt": "2026-11-16T15:22:46.585Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3OTQ4NDI1NjYs...(shortened)"
  },
  "message": "Account created"
}
```

**Errors**

409: email already registered (letter case is ignored):
```json
{ "success": false, "message": "An account with this email already exists" }
```

422: validation failed. A field can appear more than once if it breaks several rules:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "name", "message": "Name must be at least 2 characters" },
    { "field": "email", "message": "Enter a valid email address" },
    { "field": "password", "message": "Password must be at least 8 characters" },
    { "field": "password", "message": "Password must contain at least one number" }
  ]
}
```

When a field is missing, the messages are `"Name is required"`, `"Email is required"` and `"Password is required"`.

**Tested scenarios**
- [x] creates an account and returns the user and a token
- [x] returns a token that works on protected routes
- [x] stores the email trimmed and in lowercase
- [x] stores a bcrypt hash, never the plain password
- [x] never includes the password or its hash in the response
- [x] returns 409 when the email is already registered, ignoring letter case
- [x] returns 422 with an error for each missing field
- [x] returns 422 when the email is invalid
- [x] returns 422 when the password is shorter than 8 characters
- [x] returns 422 when the password has no number
- [x] returns 422 when the password has no letter
- [x] returns 422 when the name is too short

**Frontend notes:** apply the same password rules in the form so users get instant feedback. Save `data.token` and go straight to Home, without asking the user to log in again.

---

### POST /auth/login

Logs in with email and password.

**Auth required:** No (rate limited: 20 requests per 15 minutes)

**Body**

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `email` | string | Yes | Any letter case. `"demo@example.com"` |
| `password` | string | Yes | `"Demo1234"` |

**Success: 200**

```json
{
  "success": true,
  "data": {
    "user": {
      "id": "1dd058fe-a3f7-4a74-8d13-d82c020f1de5",
      "name": "Demo User",
      "email": "demo@example.com",
      "phone": "+8801700000000",
      "createdAt": "2026-11-16T15:12:36.469Z",
      "updatedAt": "2026-11-16T15:12:41.547Z"
    },
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpYXQiOjE3OTQ4NDI1Njcs...(shortened)"
  },
  "message": "Logged in"
}
```

**Errors**

401: wrong password **or** unknown email. The message is the same on purpose, for security:
```json
{ "success": false, "message": "Invalid email or password" }
```

422: missing fields:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "email", "message": "Email is required" },
    { "field": "password", "message": "Password is required" }
  ]
}
```

429: too many attempts:
```json
{ "success": false, "message": "Too many login attempts. Please try again in 15 minutes." }
```

**Tested scenarios**
- [x] returns the user and a token for the correct email and password
- [x] accepts the email in any letter case
- [x] never includes the password or its hash in the response
- [x] returns 401 with a generic message when the password is wrong
- [x] returns the same 401 message when the email does not exist
- [x] returns 422 with an error for each missing field
- [x] returns 422 when the email is invalid

**Frontend notes:** on 401 here, show `message` on the login form. Don't treat it as an expired session. **Logout** has no endpoint, because tokens are stateless: delete the stored token on the device.

---

### GET /users/me

Returns the logged-in user's profile. Use it on app start to check that a stored token still works.

**Auth required:** Yes

**Success: 200**

```json
{
  "success": true,
  "data": {
    "id": "bc3101b4-c476-434a-b6a2-5163af163feb",
    "name": "Ayesha Rahman",
    "email": "ayesha.docs@example.com",
    "phone": null,
    "createdAt": "2026-11-16T15:22:46.585Z",
    "updatedAt": "2026-11-16T15:22:46.585Z"
  }
}
```

**Errors:** 401 (see [Authentication](#4-authentication)). If the account was deleted, the message is:
```json
{ "success": false, "message": "Account not found. Please log in again." }
```

**Tested scenarios**
- [x] returns the logged-in user's profile
- [x] never includes the password hash
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired
- [x] returns 401 when the account behind a valid token no longer exists

**Frontend notes:** on splash, if a token is stored, call this. 200 goes to Home; 401 clears the token and goes to Login. This gives you the persistent session.

---

### PATCH /users/me

Updates the profile. Only `name` and `phone` can change. **The email cannot be changed.**

**Auth required:** Yes

**Body** (send at least one field)

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `name` | string | No | 2–100 characters, trimmed. `"Ayesha R."` |
| `phone` | string \| null | No | 7–20 digits, may start with `+`, spaces and dashes allowed. `"+8801712345678"`. Send `null` to remove it |

Any other field (including `email`) is rejected with 422.

**Success: 200**

```json
{
  "success": true,
  "data": {
    "id": "bc3101b4-c476-434a-b6a2-5163af163feb",
    "name": "Ayesha R.",
    "email": "ayesha.docs@example.com",
    "phone": "+8801712345678",
    "createdAt": "2026-11-16T15:22:46.585Z",
    "updatedAt": "2026-11-16T15:22:48.638Z"
  },
  "message": "Profile updated"
}
```

**Errors**

422: trying to change the email:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "email", "message": "Email cannot be changed" }] }
```

422: empty body:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "body", "message": "Send at least one of: name, phone" }] }
```

422: an unknown field, for example `passwordHash`, gives `{ "field": "passwordHash", "message": "This field is not allowed" }`.

401: see [Authentication](#4-authentication).

**Tested scenarios**
- [x] updates the name and phone and returns the updated profile
- [x] updates only the fields that are sent
- [x] clears the phone number when phone is null
- [x] returns 422 and keeps the email unchanged when trying to change the email
- [x] returns 422 for fields that are not allowed, such as passwordHash
- [x] returns 422 when the body is empty
- [x] returns 422 when the name is too short
- [x] returns 422 when the phone number is invalid
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired
- [x] returns 401 when the account behind a valid token no longer exists

**Frontend notes:** show the email as read-only on the profile screen. Replace the cached user with `data` from the response.

---

### PATCH /users/me/password

Changes the logged-in user's password. The user must enter their current password.

**Auth required:** Yes (rate limited like login: 20 requests per 15 minutes)

**Body**

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `currentPassword` | string | Yes | The password the user has now. `"OldPass123"` |
| `newPassword` | string | Yes | Same rules as registration: 8–72 characters, **at least one letter and one number**, and different from the current one. `"NewPass456"` |

Any other field is rejected with 422.

**Success: 200**

```json
{ "success": true, "data": null, "message": "Password changed" }
```

The user **stays logged in**: the current token keeps working until it expires (7 days), so you don't need to log in again. From now on, login works only with the new password.

**Errors**

422: wrong current password. This is **not** a 401, so it doesn't log the user out:
```json
{
  "success": false,
  "message": "Current password is incorrect",
  "errors": [{ "field": "currentPassword", "message": "Current password is incorrect" }]
}
```

422: the new password breaks the rules:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "newPassword", "message": "Password must be at least 8 characters" },
    { "field": "newPassword", "message": "Password must contain at least one number" }
  ]
}
```

422: the new password is the same as the current one:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "newPassword", "message": "New password must be different from the current password" }] }
```

When a field is missing, the messages are `"Current password is required"` and `"Password is required"`.

401: see [Authentication](#4-authentication). 429: too many attempts.

**Tested scenarios**
- [x] changes the password so only the new one works for login
- [x] stores the new password as a bcrypt hash
- [x] returns 422 and keeps the old password when the current password is wrong
- [x] returns 422 when the new password breaks the password rules
- [x] returns 422 when the new password is the same as the current one
- [x] returns 422 with an error for each missing field
- [x] returns 422 for fields that are not allowed
- [x] never includes a password or hash in the response
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired
- [x] returns 401 when the account behind a valid token no longer exists

**Frontend notes:** use three fields (current, new, confirm new) and check that "confirm new" matches in the app. The API doesn't receive it. On 200, show a success message and clear the form.

---

### GET /services

Lists active services, with search, filters and pagination. **Featured services come first**, then the rest in alphabetical order.

**Auth required:** No

**Query parameters** (all optional; combine them freely)

| Param | Type | Rules / example |
|---|---|---|
| `search` | string | Matches the **name or description**, ignoring letter case. Max 100. `?search=massage` |
| `category` | string | Exact category name, ignoring letter case. `?category=Wellness` (get the list from `/services/categories`) |
| `featured` | `true` \| `false` | `?featured=true` returns only featured services |
| `minPrice` | number | ≥ 0, inclusive. `?minPrice=500` |
| `maxPrice` | number | ≥ 0, inclusive, must be ≥ `minPrice`. `?maxPrice=2000` |
| `page` | integer | ≥ 1, default `1` |
| `limit` | integer | 1–50, default `20` |

**Success: 200** (`GET /services?featured=true&limit=2`)

```json
{
  "success": true,
  "data": [
    {
      "id": "5e000000-0000-4000-8000-000000000001",
      "name": "Classic Haircut",
      "description": "A tailored haircut with wash, styling and a hot towel finish.",
      "price": "500.00",
      "durationMinutes": 30,
      "imageUrl": "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80&auto=format&fit=crop",
      "category": "Hair & Beauty",
      "isFeatured": true,
      "createdAt": "2026-11-16T15:12:33.721Z",
      "updatedAt": "2026-11-16T15:12:38.784Z"
    },
    {
      "id": "5e000000-0000-4000-8000-000000000004",
      "name": "Full Body Massage",
      "description": "A 60-minute Swedish massage to release tension and improve circulation.",
      "price": "3000.00",
      "durationMinutes": 60,
      "imageUrl": "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&q=80&auto=format&fit=crop",
      "category": "Wellness",
      "isFeatured": true,
      "createdAt": "2026-11-16T15:12:34.525Z",
      "updatedAt": "2026-11-16T15:12:39.585Z"
    }
  ],
  "meta": { "page": 1, "limit": 2, "total": 4, "totalPages": 2 }
}
```

No matches is **not** an error: you get `"data": []` and `"total": 0`.

**Errors**

422: invalid query values:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "featured", "message": "Must be \"true\" or \"false\"" },
    { "field": "limit", "message": "Must be at most 50" }
  ]
}
```

Other 422 messages: `"Must be a number"` (a price), `"Must be 1 or more"` (page), and `"maxPrice must be greater than or equal to minPrice"`.

**Tested scenarios**
- [x] returns active services with pagination meta and price as a 2-decimal string
- [x] lists featured services first, then by name
- [x] hides inactive services
- [x] searches the name case-insensitively
- [x] searches the description too
- [x] filters by category, ignoring letter case
- [x] filters featured and non-featured services
- [x] filters by an inclusive price range
- [x] combines search, category and price filters
- [x] paginates with page and limit and reports the totals in meta
- [x] returns an empty list when nothing matches
- [x] returns 422 when limit is above 50 or page is below 1
- [x] returns 422 when featured is not true or false
- [x] returns 422 when a price is not a number
- [x] returns 422 when maxPrice is lower than minPrice

**Frontend notes:**
- For the home screen, use `?featured=true` for the "Featured" carousel and a plain `GET /services` for the full list.
- Debounce the search box (about 300 ms).
- For infinite scroll, load the next `page` while `page < totalPages`.
- Show an empty state when `data` is `[]`.

---

### GET /services/categories

The distinct categories of active services, in alphabetical order. Use them for filter chips.

**Auth required:** No

**Success: 200**

```json
{ "success": true, "data": ["Hair & Beauty", "Health", "Home Services", "Wellness"] }
```

**Tested scenarios**
- [x] returns the distinct categories of active services in alphabetical order
- [x] returns an empty list when there are no services

**Frontend notes:** pass the chosen value as `?category=` exactly as received.

---

### GET /services/:id

The full details of one service.

**Auth required:** No

**Path parameters:** `id` (uuid)

**Success: 200**

```json
{
  "success": true,
  "data": {
    "id": "5e000000-0000-4000-8000-000000000004",
    "name": "Full Body Massage",
    "description": "A 60-minute Swedish massage to release tension and improve circulation.",
    "price": "3000.00",
    "durationMinutes": 60,
    "imageUrl": "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&q=80&auto=format&fit=crop",
    "category": "Wellness",
    "isFeatured": true,
    "createdAt": "2026-11-16T15:12:34.525Z",
    "updatedAt": "2026-11-16T15:12:39.585Z"
  }
}
```

**Errors**

404: unknown id, a malformed id, or a service that is no longer offered:
```json
{ "success": false, "message": "Service not found" }
```

**Tested scenarios**
- [x] returns the full service details
- [x] returns 404 for an unknown id
- [x] returns 404 for an id that is not a valid uuid
- [x] returns 404 for an inactive service

**Frontend notes:** show `durationMinutes` as "60 min" or "1 h". The Book button leads to the date picker and then availability.

---

### GET /services/:id/availability

Every time slot of one day for this service, each marked `available: true` or `false`.

**Auth required:** No

**Path parameters:** `id` (uuid)

**Query parameters**

| Param | Type | Required | Rules / example |
|---|---|---|---|
| `date` | string | Yes | `YYYY-MM-DD`, a calendar date in the business time zone (Asia/Dhaka). `?date=2026-11-18` |

How slots work:
- Slots start every **30 minutes** from **09:00 to 17:30 Dhaka time**, which is 18 slots a day. `startTime` and `endTime` are **UTC**.
- `endTime = startTime + durationMinutes`.
- A slot is `available: false` when **any** of these is true:
  - it has already started (or the date is in the past),
  - the service would not finish by closing time (18:00),
  - it overlaps an existing booking for this service. Cancelled bookings don't count.

**Success: 200** (the Full Body Massage, 60 minutes, which has a booking at 11:00–12:00 Dhaka time. Slots 8–15 are left out here.)

```json
{
  "success": true,
  "data": {
    "serviceId": "5e000000-0000-4000-8000-000000000004",
    "date": "2026-11-18",
    "timeZone": "Asia/Dhaka",
    "durationMinutes": 60,
    "slots": [
      { "startTime": "2026-11-18T03:00:00.000Z", "endTime": "2026-11-18T04:00:00.000Z", "available": true },
      { "startTime": "2026-11-18T03:30:00.000Z", "endTime": "2026-11-18T04:30:00.000Z", "available": true },
      { "startTime": "2026-11-18T04:00:00.000Z", "endTime": "2026-11-18T05:00:00.000Z", "available": true },
      { "startTime": "2026-11-18T04:30:00.000Z", "endTime": "2026-11-18T05:30:00.000Z", "available": false },
      { "startTime": "2026-11-18T05:00:00.000Z", "endTime": "2026-11-18T06:00:00.000Z", "available": false },
      { "startTime": "2026-11-18T05:30:00.000Z", "endTime": "2026-11-18T06:30:00.000Z", "available": false },
      { "startTime": "2026-11-18T06:00:00.000Z", "endTime": "2026-11-18T07:00:00.000Z", "available": true },
      "...",
      { "startTime": "2026-11-18T10:30:00.000Z", "endTime": "2026-11-18T11:30:00.000Z", "available": true },
      { "startTime": "2026-11-18T11:00:00.000Z", "endTime": "2026-11-18T12:00:00.000Z", "available": true },
      { "startTime": "2026-11-18T11:30:00.000Z", "endTime": "2026-11-18T12:30:00.000Z", "available": false }
    ]
  }
}
```

Reading the example: `03:00Z` is 09:00 in Dhaka. The 10:30, 11:00 and 11:30 slots (Dhaka) overlap the 11:00–12:00 booking. The last slot, 17:30, would end at 18:30, after closing.

**Errors**

422: missing or invalid date:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "date", "message": "Date must be a real date in the format YYYY-MM-DD" }] }
```
When `date` is missing, the message is `"Date is required (YYYY-MM-DD)"`.

404: `{ "success": false, "message": "Service not found" }`

**Tested scenarios**
- [x] returns every 30-minute slot from 09:00 to 17:30 business time, in UTC
- [x] marks booked slots, and slots that would overlap a booking, as unavailable
- [x] keeps slots available when the booking on them was cancelled
- [x] is not affected by bookings of other services
- [x] marks slots that would end after closing time as unavailable
- [x] marks every slot of a past date as unavailable
- [x] marks slots that have already started today as unavailable
- [x] returns 422 when the date is missing
- [x] returns 422 when the date is not a real YYYY-MM-DD date
- [x] returns 404 for an unknown, malformed or inactive service

**Frontend notes:**
- Show every slot and **disable the ones with `available: false`**.
- Show times as `DateTime.parse(startTime).toLocal()`.
- When booking, send `startTime` back **exactly as received**.
- Build the `date` param from the picked day (`yyyy-MM-dd`), not from a UTC conversion.
- Reload this list after a 409 on booking.

---

### POST /appointments

Books a time slot for a service. New bookings always start as `PENDING`.

**Auth required:** Yes

**Body**

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `serviceId` | string (uuid) | Yes | From the service list. `"5e000000-0000-4000-8000-000000000001"` |
| `startTime` | string (ISO 8601) | Yes | **Send exactly a `startTime` from the availability response.** Must include a time zone (`Z` or `+06:00`). `"2026-11-20T04:00:00.000Z"` |
| `notes` | string | No | Up to 500 characters, trimmed. `"Short on the sides, please."` |

The server works out `endTime` (`startTime + durationMinutes`). The booking is rejected if:
- the time is in the past,
- it is not on a 30-minute slot (09:00, 09:30, …),
- it is outside business hours (09:00–18:00 Dhaka time),
- the service would run past closing, or
- it overlaps another booking for this service.

**Success: 201**

```json
{
  "success": true,
  "data": {
    "id": "4a202958-e874-485d-8e12-411f46c71aae",
    "serviceId": "5e000000-0000-4000-8000-000000000001",
    "startTime": "2026-11-20T04:00:00.000Z",
    "endTime": "2026-11-20T04:30:00.000Z",
    "status": "PENDING",
    "notes": "Short on the sides, please.",
    "createdAt": "2026-11-16T15:41:53.197Z",
    "updatedAt": "2026-11-16T15:41:53.197Z",
    "service": {
      "id": "5e000000-0000-4000-8000-000000000001",
      "name": "Classic Haircut",
      "price": "500.00",
      "durationMinutes": 30,
      "imageUrl": "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80&auto=format&fit=crop",
      "category": "Hair & Beauty"
    }
  },
  "message": "Appointment booked"
}
```

**Errors**

409: slot already taken (including when two people tap Book at the same moment):
```json
{ "success": false, "message": "This time slot is already booked. Please choose another time." }
```

422: the time breaks a booking rule. There is always one error, on `startTime`:
```json
{
  "success": false,
  "message": "This time cannot be booked",
  "errors": [{ "field": "startTime", "message": "Start time must be on a 30-minute slot (for example 09:00)" }]
}
```

| `errors[0].message` | Cause |
|---|---|
| `This time is in the past. Please choose a future slot.` | `startTime` is earlier than now |
| `Start time must be on a 30-minute slot (for example 09:00)` | e.g. 10:15 |
| `Bookings are only available between 09:00 and 18:00 (Asia/Dhaka time)` | before opening or from closing time onwards |
| `This service would end after closing time (18:00). Please choose an earlier slot.` | e.g. a 60-minute service at 17:30 |

422: invalid body:
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    { "field": "serviceId", "message": "serviceId must be a valid id" },
    { "field": "startTime", "message": "startTime must be an ISO 8601 date-time, e.g. 2026-11-18T03:00:00.000Z" }
  ]
}
```

404: the service does not exist or is no longer offered: `{ "success": false, "message": "Service not found" }`

401: see [Authentication](#4-authentication).

**Tested scenarios**
- [x] books a free slot and returns it as PENDING with the service summary
- [x] accepts a start time sent with a time-zone offset instead of Z
- [x] returns 409 when the slot is already booked
- [x] returns 409 when the new booking would overlap part of an existing one
- [x] lets exactly one of several simultaneous requests for the same slot succeed
- [x] allows booking a slot again after its booking was cancelled
- [x] allows back-to-back bookings and the same time on a different service
- [x] returns 422 when the time is in the past
- [x] returns 422 when the time is not on the 30-minute slot grid
- [x] returns 422 when the time is outside business hours
- [x] returns 422 when the service would end after closing time
- [x] returns 404 when the service does not exist or is inactive
- [x] returns 422 with an error for each missing field
- [x] returns 422 when serviceId is not a uuid, startTime is not a date-time or notes are too long
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired

**Frontend notes:**
- On 201, show the confirmation screen from `data`. You don't need another request.
- On 409, show the message, then **reload availability** for that date. Someone else just took the slot.
- Disable the Book button while the request is in flight, so the user can't send it twice.

---

### GET /appointments

The logged-in user's bookings, for the **My Bookings** tabs.

**Auth required:** Yes

**Query parameters** (optional)

| Param | Values | Meaning |
|---|---|---|
| `type` | `upcoming` | `startTime` is now or later **and** status is `PENDING` or `CONFIRMED`. Sorted **soonest first**. |
| | `past` | Everything else: earlier bookings, plus any `CANCELLED` or `COMPLETED` (even a cancelled one in the future). Sorted **most recent first**. |
| | _(omitted)_ | All bookings, most recent first. |
| `status` | `PENDING`, `CONFIRMED`, `CANCELLED`, `COMPLETED` | Only this status. Can be combined with `type`. |

There is no pagination: a user has a small number of bookings.

**Success: 200** (`GET /appointments?type=upcoming` for the demo user. The first item is shown; the 2 others are left out.)

```json
{
  "success": true,
  "data": [
    {
      "id": "0dd86afd-ac86-4c4b-bdc3-5c60aa651f8c",
      "serviceId": "5e000000-0000-4000-8000-000000000004",
      "startTime": "2026-11-18T05:00:00.000Z",
      "endTime": "2026-11-18T06:00:00.000Z",
      "status": "CONFIRMED",
      "notes": "Medium pressure, please.",
      "createdAt": "2026-11-16T15:12:42.618Z",
      "updatedAt": "2026-11-16T15:12:42.618Z",
      "service": {
        "id": "5e000000-0000-4000-8000-000000000004",
        "name": "Full Body Massage",
        "price": "3000.00",
        "durationMinutes": 60,
        "imageUrl": "https://images.unsplash.com/photo-1544161515-4ab6ce6db874?w=800&q=80&auto=format&fit=crop",
        "category": "Wellness"
      }
    }
  ]
}
```

A user with no bookings gets `{ "success": true, "data": [] }`.

**Errors**

422:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "type", "message": "type must be \"upcoming\" or \"past\"" }] }
```

401:
```json
{ "success": false, "message": "Authentication required. Please log in." }
```

**Tested scenarios**
- [x] returns only the logged-in user's appointments, most recent first, with the service summary
- [x] returns upcoming appointments (future PENDING or CONFIRMED), soonest first
- [x] returns past appointments (earlier, cancelled or completed), most recent first
- [x] filters by status, alone or together with type
- [x] returns an empty list when the user has no appointments
- [x] returns 422 for an unknown type or status
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired

**Frontend notes:** use two tabs, Upcoming (`?type=upcoming`) and Past (`?type=past`). Show `status` as a coloured chip. Each item already contains `service`, so you can draw the card without fetching the service.

---

### GET /appointments/:id

One booking, with its service summary, for the booking detail screen.

**Auth required:** Yes

**Path parameters:** `id` (uuid)

**Success: 200**

```json
{
  "success": true,
  "data": {
    "id": "4a202958-e874-485d-8e12-411f46c71aae",
    "serviceId": "5e000000-0000-4000-8000-000000000001",
    "startTime": "2026-11-20T04:00:00.000Z",
    "endTime": "2026-11-20T04:30:00.000Z",
    "status": "PENDING",
    "notes": "Short on the sides, please.",
    "createdAt": "2026-11-16T15:41:53.197Z",
    "updatedAt": "2026-11-16T15:41:53.197Z",
    "service": {
      "id": "5e000000-0000-4000-8000-000000000001",
      "name": "Classic Haircut",
      "price": "500.00",
      "durationMinutes": 30,
      "imageUrl": "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80&auto=format&fit=crop",
      "category": "Hair & Beauty"
    }
  }
}
```

**Errors**

404: unknown id, malformed id, **or someone else's booking**. Other users' bookings are never revealed:
```json
{ "success": false, "message": "Appointment not found" }
```

401: see [Authentication](#4-authentication).

**Tested scenarios**
- [x] returns the appointment with its service summary
- [x] returns 404 for another user's appointment
- [x] returns 404 for an unknown id or an id that is not a valid uuid
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired

**Frontend notes:** show the Cancel button only when `status == "PENDING"`.

---

### PATCH /appointments/:id/cancel

Cancels a booking. **Only `PENDING` bookings can be cancelled.** Cancelling frees the slot for others straight away.

**Auth required:** Yes

**Path parameters:** `id` (uuid). There is no request body.

**Success: 200**

```json
{
  "success": true,
  "data": {
    "id": "4a202958-e874-485d-8e12-411f46c71aae",
    "serviceId": "5e000000-0000-4000-8000-000000000001",
    "startTime": "2026-11-20T04:00:00.000Z",
    "endTime": "2026-11-20T04:30:00.000Z",
    "status": "CANCELLED",
    "notes": "Short on the sides, please.",
    "createdAt": "2026-11-16T15:41:53.197Z",
    "updatedAt": "2026-11-16T15:41:56.168Z",
    "service": {
      "id": "5e000000-0000-4000-8000-000000000001",
      "name": "Classic Haircut",
      "price": "500.00",
      "durationMinutes": 30,
      "imageUrl": "https://images.unsplash.com/photo-1503951914875-452162b0f3f1?w=800&q=80&auto=format&fit=crop",
      "category": "Hair & Beauty"
    }
  },
  "message": "Appointment cancelled"
}
```

**Errors**

409: the booking is not `PENDING`. The message names the current status (`confirmed`, `completed` or `cancelled`):
```json
{ "success": false, "message": "Only pending appointments can be cancelled. This appointment is confirmed." }
```

404: unknown, malformed or someone else's: `{ "success": false, "message": "Appointment not found" }`

401: see [Authentication](#4-authentication).

**Tested scenarios**
- [x] cancels a pending appointment and returns it with status CANCELLED
- [x] frees the slot so it can be booked again
- [x] returns 409 for confirmed, completed or already cancelled appointments
- [x] returns 404 for another user's appointment and leaves it unchanged
- [x] returns 404 for an unknown id or an id that is not a valid uuid
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired

**Frontend notes:** ask "Cancel this booking?" before calling. On 200, update the item in place from `data`; it moves to the Past tab. On 409, show the message and refresh the list.

---

### POST /ai/chat

Asks the EasyBook AI assistant a question about services. It recommends services that fit the user's needs and answers basic questions (price, duration, what a service includes, how to book).

**Auth required:** Yes (rate limited: **10 messages per minute per user**)

How it works:
- On every request, the server loads the current active services from the database and gives them to the AI. Answers always match the real catalogue and prices.
- Off-topic questions are politely declined.
- The AI provider and its API key live **only on the server**. The app never talks to the AI provider directly.
- The server keeps no chat history. To keep a conversation going, the app sends the earlier messages in `history`.

**Body**

| Field | Type | Required | Rules / example |
|---|---|---|---|
| `message` | string | Yes | 1–500 characters, trimmed. `"I have a stiff back after long hours at my desk. What would you recommend?"` |
| `history` | array | No | Earlier turns, **oldest first**, up to 50 items. Only the **last 10** are used. Each item is `{ "role": "user" \| "assistant", "content": string (1–500 chars) }` |

**Success: 200**

```json
{
  "success": true,
  "data": {
    "reply": "For a stiff back from desk work, I recommend the Full Body Massage. It’s a 60‑minute Swedish massage that releases tension and improves circulation, perfect for easing muscle stiffness. The price is 3,000 BDT.",
    "suggestedServices": [
      { "id": "5e000000-0000-4000-8000-000000000004", "name": "Full Body Massage" }
    ]
  }
}
```

- `reply` is plain text.
- `suggestedServices` lists the services named in the reply, in order. It is **always an array** and can be empty, as here for an off-topic question:

```json
{
  "success": true,
  "data": {
    "reply": "I can't answer that question, but I can help you book services like a haircut, massage, or home cleaning in the EasyBook app. What would you like to do?",
    "suggestedServices": []
  }
}
```

A follow-up message, with `history` set to the earlier user and assistant messages:

```json
// request body
{
  "message": "Anything cheaper?",
  "history": [
    { "role": "user", "content": "I have a stiff back after long hours at my desk. What would you recommend?" },
    { "role": "assistant", "content": "A Full Body Massage would help. It is a 60-minute Swedish massage and costs 3000.00 BDT." }
  ]
}
// response
{
  "success": true,
  "data": {
    "reply": "A General Health Check-up costs 2000.00 BDT and takes 30 minutes, but it is not a massage.",
    "suggestedServices": [{ "id": "5e000000-0000-4000-8000-000000000010", "name": "General Health Check-up" }]
  }
}
```

The AI's wording varies from call to call. Only the response **shape** is guaranteed.

**Errors**

| Status | `message` | When |
|---|---|---|
| 503 | `The assistant took too long to answer. Please try again.` | The AI didn't answer within 15 seconds |
| 503 | `The assistant is busy right now. Please try again in a minute.` | The AI provider is rate-limited |
| 503 | `The assistant is not available at the moment.` | The assistant is switched off on the server |
| 502 | `The assistant is unavailable right now. Please try again in a moment.` | The provider failed or sent an empty answer |
| 429 | `You are sending messages too quickly. Please wait a minute and try again.` | More than 10 messages in a minute |

502/503 bodies never contain provider details:
```json
{ "success": false, "message": "The assistant is unavailable right now. Please try again in a moment." }
```

422: invalid message or history:
```json
{ "success": false, "message": "Validation failed", "errors": [{ "field": "history.0.role", "message": "role must be \"user\" or \"assistant\"" }] }
```

Other 422 messages: `"Message must be at most 500 characters"` (field `message` or `history.N.content`), `"Message cannot be empty"`, and `"history can have at most 50 messages"`.

401: see [Authentication](#4-authentication).

**Tested scenarios** (the AI provider is mocked in every test)
- [x] returns the assistant's reply and the services it mentioned
- [x] sends the active services with price and duration to the provider, and never inactive ones
- [x] sends only the last 10 history messages, in order, before the new message
- [x] removes Markdown bold markers so the reply is plain text
- [x] returns an empty suggestedServices list when no service is named
- [x] passes an abort signal so a slow provider is cut off
- [x] returns 503 with a friendly message when the provider times out
- [x] returns 502 with a friendly message and no provider details when the provider fails
- [x] returns 503 when the provider is rate-limited
- [x] returns 502 when the provider cannot be reached or sends an empty answer
- [x] returns 503 without calling the provider when no API key is configured
- [x] returns 422 when the message is longer than 500 characters
- [x] returns 422 when the message is missing or empty
- [x] returns 422 when a history item has an invalid role or too much content
- [x] returns 422 when history has more than 50 messages
- [x] returns 401 when no token is sent
- [x] returns 401 when the token is malformed
- [x] returns 401 when the token is expired

**Frontend notes:**
- Keep the conversation in app state and send the previous turns as `history` (oldest first). Sending only the last 10 is enough.
- Show a "typing…" indicator. Replies usually take 1–3 seconds, so set the client timeout to **at least 20 seconds**.
- Show `suggestedServices` as tappable chips under the reply, each opening `GET /services/:id`.
- Limit the text field to 500 characters.
- On 502, 503 or 429, show `message` as a system bubble with a Retry button.

---


---

## 9. Data models

Types use JSON terms. "Nullable" means the key is **always present** but its value can be `null`. A field marked _No_ is never null, so in Dart you can use non-nullable types for those.

### User

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | string (uuid) | No | |
| `name` | string | No | 2–100 chars |
| `email` | string | No | Always lowercase. Can't be changed |
| `phone` | string | **Yes** | `null` until the user adds one |
| `createdAt` | string (ISO 8601 UTC) | No | |
| `updatedAt` | string (ISO 8601 UTC) | No | |

```dart
class User {
  final String id, name, email;
  final String? phone;
  final DateTime createdAt, updatedAt;
}
```

### Service

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | string (uuid) | No | |
| `name` | string | No | |
| `description` | string | No | |
| `price` | **string** | No | Two decimals, BDT, e.g. `"500.00"`. Use `double.parse` |
| `durationMinutes` | int | No | |
| `imageUrl` | string (URL) | No | |
| `category` | string | No | One of `GET /services/categories` |
| `isFeatured` | bool | No | |
| `createdAt` / `updatedAt` | string (ISO 8601 UTC) | No | |

### ServiceSummary (inside an Appointment)

`id`, `name`, `price` (string), `durationMinutes`, `imageUrl`, `category`. None of them is nullable.

### Appointment

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `id` | string (uuid) | No | |
| `serviceId` | string (uuid) | No | |
| `startTime` | string (ISO 8601 UTC) | No | Convert with `.toLocal()` for display |
| `endTime` | string (ISO 8601 UTC) | No | `startTime + service.durationMinutes` |
| `status` | string enum | No | `PENDING` \| `CONFIRMED` \| `CANCELLED` \| `COMPLETED` |
| `notes` | string | **Yes** | |
| `createdAt` / `updatedAt` | string (ISO 8601 UTC) | No | |
| `service` | ServiceSummary | No | |

```dart
enum AppointmentStatus { PENDING, CONFIRMED, CANCELLED, COMPLETED }
// canCancel == (status == AppointmentStatus.PENDING)
```

### Availability

| Field | Type | Nullable | Notes |
|---|---|---|---|
| `serviceId` | string (uuid) | No | |
| `date` | string `YYYY-MM-DD` | No | Business date (Asia/Dhaka) |
| `timeZone` | string | No | `"Asia/Dhaka"` |
| `durationMinutes` | int | No | |
| `slots` | list of `{ startTime: string, endTime: string, available: bool }` | No | 18 slots per day, times in UTC |

### Auth result (register / login)

`{ user: User, token: string }`

### Chat reply (AI)

`{ reply: string, suggestedServices: [{ id: string, name: string }] }`. `suggestedServices` is always a list and may be empty.

### Pagination meta (`GET /services`)

`{ page: int, limit: int, total: int, totalPages: int }`. `totalPages` is `0` when there are no results.

## 10. Demo credentials

After `npm run seed`, this account exists with sample data:

| Email | Password |
|---|---|
| `demo@example.com` | `Demo1234` |

The demo user has four bookings, so every My Bookings state can be seen right away:

| Status | When |
|---|---|
| `COMPLETED` | 7 days ago (Past tab) |
| `CONFIRMED` | in 2 days (Upcoming tab) |
| `CANCELLED` | in 3 days (Past tab) |
| `PENDING` | in 5 days (Upcoming tab, can be cancelled) |

The seed also creates **10 services in 4 categories** (Hair & Beauty, Wellness, Home Services, Health). **4 of them are featured.** Rerunning the seed resets the demo user's bookings.

## 11. Test coverage summary

From the latest `npm test` run (2026-11-16). Every test runs against a real Postgres test database. The AI provider is always mocked.

| Area | Tests | Status |
|---|---|---|
| Health, unknown routes, body errors | 5 | ✅ passing |
| Shared middleware (validation, auth token, rate limit) | 9 | ✅ passing |
| Time-zone helpers | 6 | ✅ passing |
| Database double-booking constraint | 5 | ✅ passing |
| POST /auth/register | 12 | ✅ passing |
| POST /auth/login | 7 | ✅ passing |
| GET /users/me | 6 | ✅ passing |
| PATCH /users/me | 12 | ✅ passing |
| PATCH /users/me/password | 12 | ✅ passing |
| GET /services | 15 | ✅ passing |
| GET /services/categories | 2 | ✅ passing |
| GET /services/:id | 4 | ✅ passing |
| GET /services/:id/availability | 10 | ✅ passing |
| POST /appointments | 17 | ✅ passing |
| GET /appointments | 9 | ✅ passing |
| GET /appointments/:id | 6 | ✅ passing |
| PATCH /appointments/:id/cancel | 8 | ✅ passing |
| POST /ai/chat | 18 | ✅ passing |
| **Total** | **163** | ✅ **all passing** |

## 12. Changelog

- **2026-11-16:** The API is live in production at `https://easybook-api-d89z.onrender.com/api/v1`.

- **2026-11-16:** The AI rate limit (10 messages per minute) now counts per logged-in user instead of per IP address. Added data models, `docs/requests.http` and the ER diagram.
- **2026-11-16:** Added `PATCH /users/me/password` (change password).
- **2026-11-16:** Added `POST /ai/chat`, the AI service assistant. It runs on OpenRouter free models, with the key kept on the server.
- **2026-11-16:** Added `POST /appointments`, `GET /appointments`, `GET /appointments/:id` and `PATCH /appointments/:id/cancel`. Availability and booking now share the same rules, so a slot shown as available can always be booked unless someone takes it first.
- **2026-11-16:** Added `GET /services`, `GET /services/categories`, `GET /services/:id` and `GET /services/:id/availability`.
- **2026-11-16:** Added `POST /auth/register`, `POST /auth/login`, `GET /users/me` and `PATCH /users/me`. Unknown body fields now return 422 with `"This field is not allowed"`.
- **2026-11-16:** Database and demo data. The seed adds 10 services and a demo user (see Demo credentials). Prices are in BDT. No endpoint changes.
- **2026-11-16:** First version. `GET /health`, response and error conventions, and the booking flow outline.
