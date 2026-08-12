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
