# 🔒 GuardPost - Personal Digital Security Control Center

[![Build GuardPost APK](https://github.com/factonezy/guardpost/actions/workflows/build.yml/badge.svg)](https://github.com/factonezy/guardpost/actions/workflows/build.yml)

## 📱 About

GuardPost is a comprehensive personal cybersecurity app that helps you:

- **🔍 Email Breach Check** — Check if your email has been in data breaches
- **🔑 Password Strength Analyzer** — Test password strength with real-time suggestions
- **🛡️ Phishing Link Scanner** — Scan suspicious URLs before clicking
- **📊 Security Score** — Overall security score (A-F grade) with recommendations
- **💎 Premium Features** — Dark web monitoring, family plan, instant alerts

## ✨ Features

| Feature | Free | Premium |
|---------|------|---------|
| Email breach check | ✅ | ✅ Unlimited |
| Password strength checker | ✅ | ✅ |
| Phishing link scanner | ✅ | ✅ Unlimited |
| Personal Security Score | ✅ | ✅ + History |
| Dark web monitoring | ❌ | ✅ |
| Instant breach alerts | ❌ | ✅ |
| Family plan (5 users) | ❌ | ✅ |
| Priority support | ❌ | ✅ |

## 📸 Screenshots

*(Add screenshots here after building)*

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.27+)
- Android Studio / VS Code
- Firebase project (for auth + backend)

### Installation

```bash
# Clone the repo
git clone https://github.com/factonezy/guardpost.git
cd guardpost

# Get dependencies
flutter pub get

# Run on device/emulator
flutter run
```

### Firebase Setup
1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable Email/Password authentication
3. Download `google-services.json` and place in `android/app/`
4. Enable Firestore (for premium features)

### 🔑 API Keys Setup (REQUIRED for Breach & Phishing features)

Two core features need free API keys. Without them the app silently returns
"no breach / safe" results. Pass them at build/run time with `--dart-define`:

| Key | Used for | Get it from |
|-----|----------|------------|
| `HIBP_API_KEY` | Email breach check (Have I Been Pwned) | https://haveibeenpwned.com/API/Key |
| `SAFE_BROWSING_API_KEY` | Phishing link scan (Google Safe Browsing) | https://developers.google.com/safe-browsing |
| `REVENUECAT_API_KEY` | **Real subscriptions / payments** | https://app.revenuecat.com (create app, copy API key) |

```bash
flutter run \
  --dart-define=HIBP_API_KEY=your_hibp_key \
  --dart-define=SAFE_BROWSING_API_KEY=your_sb_key \
  --dart-define=REVENUECAT_API_KEY=your_rc_key
```

> The `REVENUECAT_API_KEY` is what makes the app actually earn money. Create a
> RevenueCat project, add the "premium" entitlement, configure products
> (monthly / yearly with a 7-day free trial) in Google Play / App Store, and
> the `SubscriptionService` will unlock premium only after a real purchase.

### 💳 Subscriptions (RevenueCat)
GuardPost uses **RevenueCat** for real in-app purchases (not fake). Setup:
1. Create a RevenueCat project and copy the API key into `REVENUECAT_API_KEY`.
2. Create products in Play Store / App Store: `monthly`, `annual` (with 7-day free trial), and a `premium` entitlement.
3. That's it — `lib/services/subscription_service.dart` handles purchase, restore and status sync.

### 📦 Release build & Play Store
1. Generate a keystore: `keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload`
2. Copy `android/key.properties.example` → `android/key.properties` and fill values (already git-ignored).
3. Build: `flutter build appbundle --release --dart-define=...` (upload the `.aab` to Play Console).

### Notification Permission (Android 13+)
The app requests `POST_NOTIFICATIONS` at startup (via `permission_handler`).
The permission is already declared in `android/app/src/main/AndroidManifest.xml`.

### Building APK

```bash
# Debug APK
flutter build apk --debug

# Release APK (GitHub Actions auto-builds this)
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

## 💰 Subscription

GuardPost uses RevenueCat for subscription management.

| Plan | Price | Features |
|------|-------|----------|
| Free | $0 | Basic checks, limited scans |
| Monthly | $2.99 | All premium features |
| Yearly | $29.99 | Best value (save $6) |
| Trial | 7 days free | Full premium access |

## 🛠️ Tech Stack

- **Flutter** — Cross-platform framework
- **Firebase** — Auth, Firestore, Analytics
- **Have I Been Pwned API** — Breach database
- **Google Safe Browsing** — Phishing protection
- **RevenueCat** — Subscription management

## 📄 License

© 2026 GuardPost. All rights reserved.
Last build triggered: Wed Aug 12 16:55:59 UTC 2026
