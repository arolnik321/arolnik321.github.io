# WhatToWatch — API Key Setup

You need three free API keys before building the app. All have generous free tiers suitable for development.

---

## 1. TMDB (The Movie Database)
**Free tier:** 40 requests / 10 seconds. No expiry.

1. Go to https://www.themoviedb.org/signup and create an account.
2. In your account settings, navigate to **API** → **Create** → select **Developer**.
3. Fill out the form (app name: "WhatToWatch", type: Personal).
4. Copy your **API Key (v3 auth)** — it looks like `abc123def456...`.

---

## 2. OMDb API
**Free tier:** 1,000 requests / day.

1. Go to https://www.omdbapi.com/apikey.aspx
2. Select **FREE** tier and enter your email.
3. Check your email for the activation link and click it.
4. Copy the API key from the confirmation email.

---

## 3. Watchmode
**Free tier:** 1,000 requests / month.

1. Go to https://api.watchmode.com and click **Sign Up**.
2. After signing in, go to your **Dashboard** → copy your **API Key**.

---

## Add Keys to Xcode

1. In Xcode, open your project's **Info.plist** (select the target → Info tab, or open the file directly).
2. Add three new rows:

| Key | Type | Value |
|-----|------|-------|
| `TMDB_API_KEY` | String | *(your TMDB key)* |
| `OMDB_API_KEY` | String | *(your OMDb key)* |
| `WATCHMODE_API_KEY` | String | *(your Watchmode key)* |

3. Build and run. `APIConfig` reads these at startup and will `fatalError` with a clear message if any are missing.

> **Security note:** Never commit your Info.plist with real keys to a public repo. Add `Info.plist` to `.gitignore` or use an `.xcconfig` file instead.

---

## Xcode Project Setup

1. Open Xcode → **File → New → Project** → choose **tvOS App**.
2. Set:
   - Product Name: `WhatToWatch`
   - Bundle Identifier: `com.yourname.whattowatch`
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Minimum Deployment: **tvOS 17.0**
3. Delete the default `ContentView.swift` Xcode generated.
4. Drag all files from `tvOS_App/WhatToWatch/` into the Xcode project navigator, ensuring **"Copy items if needed"** is checked and the target is selected.
5. Add the Info.plist keys (see above).
6. Build → Run on **Apple TV Simulator**.
