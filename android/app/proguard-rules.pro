# Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# gRPC OkHttp
-keep class com.squareup.okhttp.** { *; }
-dontwarn com.squareup.okhttp.**

# Prevent reflective stripping (e.g., Firestore .data()?['username'])
-keepclassmembers class ** {
    public *;
}
