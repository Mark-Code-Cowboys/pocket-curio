# google_mlkit_text_recognition references the optional non-Latin
# recognizers (compileOnly deps we deliberately don't bundle — only the
# Latin model ships). Tell R8 the missing classes are expected.
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.devanagari.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**

# ML Kit reaches its recognizer internals indirectly; shrinking them
# NPEs at runtime (TextRecognizer.processImage). Keep them whole.
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.odml.** { *; }
