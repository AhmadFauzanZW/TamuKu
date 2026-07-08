# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# MinIO / S3
-keep class io.minio.** { *; }

# Hive
-keep class ** extends hive.* { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**
