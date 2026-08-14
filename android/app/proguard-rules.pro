# GuardPost release ProGuard / R8 rules.
# Only rules required so the release build does not strip classes that are
# needed at runtime by the in-app purchase (RevenueCat) and Firebase plugins.

# RevenueCat / purchases_flutter (uses reflection + JSON-serialized models)
-keep class com.revenuecat.purchases.** { *; }
-keep class com.android.billingclient.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Preserve metadata that plugins rely on for serialization
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
