-keepattributes InnerClasses, Exceptions

-keep class com.facebook.react.fabric.FabricUIManager { *; }
-keep class com.facebook.react.fabric.mounting.MountItemDispatcher { *; }
-keep class com.facebook.react.modules.** { *; }
-keep class com.facebook.react.uimanager.** { *; }
-keep class com.facebook.react.animated.** { *; }
-keep class com.facebook.react.ReactApplication { *; }
-keep class com.facebook.react.ReactNativeHost { *; }
-keep class com.facebook.react.ReactHost { *; }
-keep class com.facebook.react.runtime.ReactHostImpl { *; }
-keep class com.facebook.react.runtime.BridgelessReactContext { *; }
-keep class com.facebook.react.runtime.ReactInstance { *; }
-keep class com.facebook.react.modules.core.JavaTimerManager { *; }
-keep class com.facebook.react.defaults.DefaultNewArchitectureEntryPoint { *; }

-keep class com.facebook.react.ReactInstanceManager { *; }
-keep class com.facebook.react.ReactInstanceManager** { *; }
-keep class com.facebook.react.ReactInstanceEventListener { *; }
-keep class com.facebook.react.soloader.OpenSourceMergedSoMapping { *; }
-keep class com.facebook.soloader.SoLoader { *; }
-keep class com.facebook.soloader.ExternalSoMapping { *; }

-keep class com.facebook.react.views.slider.** { *; }
-keep class com.google.android.material.slider.** { *; }
-keep class com.reactnativecommunity.slider.** { *; }
-keep class com.reactnativecommunity.asyncstorage.** { *; }

-keep class kotlin.reflect.** { *; }
-keep class kotlin.KotlinVersion { *; }
-keep class kotlin.sequences.** { *; }
-keep class kotlin.Triple { *; }
-keep class kotlin.properties.** { *; }
-keep class kotlin.coroutines.CoroutineDispatcher { *; }
-keep class kotlin.coroutines.CoroutineScope { *; }
-keep class kotlin.coroutines.CoroutineContext { *; }
-keep class kotlinx.coroutines.BuildersKt { *; }
-keep class kotlin.jvm.** { *; }
-keep class kotlin.collections.** { *; }
-keep class kotlin.text.** { *; }
-keep class kotlin.io.** { *; }
-keep class okhttp3.** { *; }
-keep class kotlin.LazyKt { *; }

-keep class androidx.concurrent.futures.** { *; }

-dontwarn androidx.appcompat.**
-dontwarn javax.lang.model.element.**

