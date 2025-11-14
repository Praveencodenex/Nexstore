# Keep Razorpay classes completely
-keep class com.razorpay.** { *; }

# Handle missing Google Pay classes
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }

# General keep rules for payment processing
-keepclassmembers class com.razorpay.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keep class proguard.annotation.** { *; }
-dontwarn proguard.annotation.**