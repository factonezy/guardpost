# 🔥 Firebase Setup Guide (GuardPost Android)

App `firebase_auth` use karta hai (login/signup). Iske liye apna **khud ka Firebase project**
banana padega — repo mein jo `google-services.json` hai wo **dusre account** ka hai,
toh login fail hoga jab tak tum apna nahi daalte.

Package name already fixed hai: **`com.guardpost.app`**

---

## Step 1 — Firebase project banao
1. Jaao → https://console.firebase.google.com
2. **Add project** → naam do (e.g. `GuardPost`) → Continue → Create project
3. Project khul gaya.

## Step 2 — Android app register karo
1. Project overview pe **Android icon** (🤖) dabao → "Register app"
2. **Android package name** mein likho: `com.guardpost.app`
   (yehi `android/app/build.gradle` mein `applicationId` hai — match hona zaroori hai)
3. App nickname optional hai → **Register app**
4. **google-services.json download** karo
5. Us file ko **`guardpost/android/app/google-services.json`** pe replace karo
   (purani dusre wali delete ho jayegi)

> ✅ Baaki sab already set hai (gradle plugin, classpath) — sirf ye file daalni hai.

## Step 3 — Email/Password auth ON karo
1. Left menu → **Authentication** → **Sign-in method** tab
2. **Email/Password** enable karo → Save
3. (Optional) **Email verification** baad mein enable kar sakte ho

## Step 4 — (Optional) Firestore
App abhi Firestore directly use nahi karta, lekin agar user data / scan history
save karni ho toh:
1. Left menu → **Firestore Database** → **Create database**
2. Start in **test mode** (ya rules set karo) → Create

## Step 5 — Run karo
```bash
cd guardpost
flutter pub get
flutter run          # phone ya emulator
```
Login screen pe email + password se signup karo → agar Firebase sahi hai toh
user banega aur Home screen khulega.

---

## ❓ Problems?

**Login fail ho raha / "invalid api key"**
→ `google-services.json` sahi jagah hai ya nahi check karo (`android/app/`).
→ Package name `com.guardpost.app` hi hona chahiye Firebase mein.

**SHA-1 fingerprint chahiye?** (sirf Google/Phone sign-in ke liye — Email/Password ko nahi chahiye)
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Wo SHA-1 Firebase project settings → "Add fingerprint" mein daal sakte ho.

**Firebase CLI se bhi kar sakte ho (aasan):**
```bash
npm install -g firebase-tools
firebase login
flutter pub global activate flutterfire_cli
flutterfire configure
```
`flutterfire configure` khud `google-services.json` + `firebase_options.dart` bana deta hai.

---

## ✅ Verify
- Signup successful + user Firebase Console → Authentication mein dikh raha hai
- App Home screen pe pahunch raha hai

Ab app real Firebase pe chal raha hai. Agla step: **RevenueCat** (paisa ke liye) ya
**Play Store publish**.
