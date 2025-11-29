# Keep device_calendar plugin classes
-keep class com.builttoroam.devicecalendar.** { *; }
-keep class com.builttoroam.** { *; }

# Keep calendar model classes and their fields
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Keep all native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Prevent obfuscation of classes with native methods
-keepclasseswithmembers class * {
    native <methods>;
}