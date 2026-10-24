# Flutter wraps its own engine rules; these cover common release-shrink pitfalls.

# flutter_local_notifications uses reflection on its scheduled-notification models.
-keep class com.dexterous.** { *; }

# Keep annotations used by Gson/reflection-based plugin serialization.
-keepattributes *Annotation*, Signature, InnerClasses, EnclosingMethod
