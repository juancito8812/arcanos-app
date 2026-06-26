# Flutter: keep everything
-keep class io.flutter.** { *; }
-keep class com.psicotarot.arcanos_mayores.** { *; }
-keep class androidx.** { *; }

# Keep Flutter engine
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.view.** { *; }

# Keep JSON parsing
-keepclassmembers class * {
    @com.fasterxml.jackson.annotation.* <fields>;
}

# Keep Gson/Moshi
-keepattributes Signature
-keepattributes *Annotation*

# Keep Kotlin
-keep class kotlin.** { *; }

# Keep OpenFileX
-keep class com.open_filex.** { *; }

# Keep sqflite
-keep class sqflite.** { *; }

# Keep Play Core (referenced by Flutter engine for deferred components)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
