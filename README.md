<!-- markdownlint-configure-file { "first-line-heading": 0 } -->

# Detox Prerequisites
1. Install Command Line Tools (detox-cli): npm install detox-cli --global
2. Install applesimutils to work with iOS simulators
- brew tap wix/brew
- brew install applesimutils
3. Initialize: npn init
4. Bootstrap, Detox offers you a first-class integration with Jest: npm install "jest@^29" --save-dev
5. Install Detox: npm install detox --save-dev
6. Initialize Detox: detox init
7. Configure the Binary Path config in .detoxrc.js
Ex binaryPath: 'Users/user/Documents/Projects/System/android/app/build/outputs/apk/debug/app-debug.apk',
8. Configure the Device config in .detoxrc.js
nano ~/.zshrc
Find the device name executing: $ANDROID_SDK_ROOT/emulator/emulator -list-avds
Ex: avdName: 'Pixel_3a_API_30_x86'
Ex: avdName: 'Medium_Phone_API_35'
9. Build the application:
cd android
./gradlew assembleRelease
./gradlew assembleAndroidTest

./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug
./gradlew assembleRelease assembleAndroidTest -DtestBuildType=release

10. Execute the command to run:
detox test --configuration android.emu.debug --record-logs all
detox test -c android.emu.debug --record-logs all --take-screenshots all --record-videos all --force-adb-install

# Inspect Android elements
1. Saves the UI hierarchy: adb shell uiautomator dump
2. It saves on /sdcard/window_dump.xml
3. Verify if the file exists: adb shell ls /sdcard/window_dump.xml
4. Pull the file to local machine: adb pull /sdcard/window_dump.xml


# Browserstack Detox Project

1. Clone the project: https://github.com/pb2323/cloud_detox_support/tree/master/examples/demo-react-native
2. Run: npm install
3. Run: npm install -g jest
4. Run: npm install -g detox-cli
5. Run: mkdir android/app/src/main/assets
6. Run: npx react-native bundle --platform android --dev false --entry-file index.js --bundle-output android/app/src/main/assets/index.android.bundle --assets-dest android/app/src/main/res
7. Create the network_security_config.xml
/Users/marcelonagase/Documents/Projects/cloud_detox_support/examples/demo-react-native/android/app/src/main/res/xml/network_security_config.xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>
8. Change the gradle.properties to org.gradle.jvmargs=-Xmx3g -Dfile.encoding=UTF-8
9. Change the build.gradle to update minSdkVersion = 21 to minSdkVersion = 24
/Users/marcelonagase/Documents/Projects/cloud_detox_support/examples/demo-react-native/android/build.gradle
10. Change the settings.gradle to include:
pluginManagement {
    buildscript {
        repositories {
            mavenCentral()
            maven {
                url = uri("https://storage.googleapis.com/r8-releases/raw")
            }
        }
        dependencies {
            classpath("com.android.tools:r8:8.2.24")
        }
    }
}
11. Run the command to build main app APK
./gradlew assembleDebug

12. Run: the command to build detox android app client
./gradlew assembleAndroidTest

13. Run: detox test -c android.emu.debug --loglevel trace


# Error
1. Error: 09:08:00.838 detox[84255] i Detox can't seem to connect to the test app(s)!
thrown: "Exceeded timeout of 120000 ms for a hook.
Add a timeout value to this test to increase the timeout, if this is a long-running test. See https://jestjs.io/docs/api#testname-fn-timeout."

Solution: Need to configure 
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">10.0.2.2</domain>
        <domain includeSubdomains="true">localhost</domain>
    </domain-config>
</network-security-config>

2. Error: the app has crashed, see the details below:
    @Thread main(2):
    java.lang.UnsatisfiedLinkError: couldn't find DSO to load: libhermes.so

Add configurations.all section to android/build.gradle file
        // add below code - start
        configurations.all {
            resolutionStrategy {
                // use 0.9.0 to fix crash on Android 11
                force "com.facebook.soloader:soloader:0.9.0+"
            }
        }
        // code - end

Add the following to your android/app/build.gradle file:

dependencies {
   ....
   implementation 'com.facebook.soloader:soloader:0.9.0+'
   ....
}

https://www.repeato.app/resolving-the-javalangunsatisfiedlinkerror-couldnt-find-dso-to-load-libhermesso-error-in-react-native/
https://stackoverflow.com/questions/57036317/react-native-java-lang-unsatisfiedlinkerror-couldnt-find-dso-to-load-libherm
https://stackoverflow.com/questions/60206386/react-native-app-crashes-on-start-due-to-soloader-issue


3. Errro: 16174 E AndroidXTracer: java.lang.NoSuchMethodError: No static method forceEnableAppTracing()V in class Landroidx/tracing/Trace; or its super classes (declaration of 'androidx.tracing.Trace' appears in /data/app/~~iJfobSwK8Ch7FOFExRAjQA==/com.detox.rn.example--9lFcI6qhHQvg8q5RnP5SA==/base.apk)
04-03 11:29:09.502 16150 
Solution:
https://github.com/android/android-test/issues/1755
 Include androidx.tracing:tracing on app/build.gradle
dependencies {
    implementation "androidx.tracing:tracing:1.1.0"
}

Include the config on .detoxrc.js
  session: {
    debugSynchronization: 5000,  // Wait up to 5 seconds for synchronization
  },

4. Error: Failed resolution of: Lcom/facebook/react/defaults/DefaultNewArchitectureEntryPoint

Solution: 


5. Error: Execution failed for task ':app:checkDebugDuplicateClasses'.
> A failure occurred while executing com.android.build.gradle.internal.tasks.CheckDuplicatesRunnable
   > Duplicate class com.facebook.hermes.BuildConfig found in modules jetified-hermes-debug-runtime (hermes-debug.aar) and jetified-hermes-engine-0.69-debug.7-debug-runtime (com.facebook.react:hermes-engine:0.69.7)

Solution:
In android/app/build.gradle, add following in your Android {} node
android {
...
    configurations {
        all*.exclude group: "com.facebook.react", module: "react-native"
    }
}


# Steps to Run Detox Tests

- Android
1. Clone the project: https://github.com/wix/Detox
2. Run: cd examples/demo-react-native
3. Run: npm install
4. Remove buildToolsVersion = rootProject.ext.buildToolsVersion in app/build.gradle

- Run Debug Tests (Not possible to test the build file outside the react-native repo)
5. Change the Android Emulator configuration
6. Run: cd android ; ./gradlew assembleDebug assembleAndroidTest -DtestBuildType=debug ; cd -
- Files will be generated on:
Detox/examples/demo-react-native/android/app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk
Detox/examples/demo-react-native/android/app/build/outputs/apk/debug/app-debug.apk

7. Run: detox test --configuration android.emu.debug

- Run Release Tests
8. Change the Android Emulator configuration
9. Run: cd android ; ./gradlew assembleRelease assembleAndroidTest -DtestBuildType=release ; cd -
- Files will be generated on:
Detox/examples/demo-react-native/android/app/build/outputs/apk/androidTest/release/app-release-androidTest.apk
Detox/examples/demo-react-native/android/app/build/outputs/apk/release/app-release.apk

10. Run: detox test --configuration android.emu.release

- iOS
1. Run: cd ios && bundle exec pod install
2. Run: bundle install --path vendor/bundle

- Run Debug Tests (Not possible to test the build file outside the react-native repo)
3. Change the iOS Simulator configuration
4. Run: detox build --configuration ios.sim.debug
- Files will be generated on:
ios/build/Build/Products/Debug-iphonesimulator/example.app

5. Run: detox test --configuration ios.sim.debug

- Run Release Tests
6. Change the iOS Simulator configuration
7. Run: detox build --configuration ios.sim.release
- Files will be generated on:
ios/build/Build/Products/Release-iphonesimulator/example.app

8. Run: detox test --configuration ios.sim.release

- Error: FAILURE: Build failed with an exception.
What went wrong:
Could not determine the dependencies of task ':app:compileDebugJavaWithJavac'.
> Could not resolve all dependencies for configuration ':app:debugCompileClasspath'.
   > Could not resolve com.facebook.react:react-android:0.76.3.
     Required by:
         project :app
      > Could not resolve com.facebook.react:react-android:0.76.3.

Solution:
https://www.youtube.com/watch?app=desktop&v=fsghCzRmN0k
Remove buildToolsVersion = rootProject.ext.buildToolsVersion in app/build.gradle

android {
    REMOVE
    buildToolsVersion = rootProject.ext.buildToolsVersion
}
```
  Detox
</h1>
<p align="center">
<b>Gray box end-to-end testing and automation framework for mobile apps.</b>
</p>
<p align="center">
<img alt="Demo" src="docs/img/Detox.gif"/>
</p>
<h1></h1>

<img src="https://user-images.githubusercontent.com/1962469/89655670-1c235c80-d8d3-11ea-9320-0f865767ef5d.png" alt="" height=24 width=1> [![NPM Version](https://img.shields.io/npm/v/detox.svg?style=flat)](https://www.npmjs.com/package/detox) [![NPM Downloads](https://img.shields.io/npm/dm/detox.svg?style=flat)](https://www.npmjs.com/package/detox) [![Build status](https://badge.buildkite.com/39afde30a964a6763de9753762bc80264ba141e1c1f41fc878.svg)](https://buildkite.com/wix-mobile-oss/detox) [![Coverage Status](https://coveralls.io/repos/github/wix/Detox/badge.svg?branch=master)](https://coveralls.io/github/wix/Detox?branch=master) [![Detox is released under the MIT license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE) [![PR's welcome!](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://wix.github.io/Detox/docs/contributing) [![Discord](https://img.shields.io/discord/957617863550697482?color=%235865F2\&label=discord)](https://discord.gg/CkD5QKheF5) [![Twitter Follow](https://img.shields.io/twitter/follow/detoxe2e?label=Follow\&style=social)](https://twitter.com/detoxe2e)

## What Does a Detox Test Look Like?

This is a test for a login screen, it runs on a device/simulator like an actual user:

```js
describe('Login flow', () => {
  beforeEach(async () => {
    await device.reloadReactNative();
  });

  it('should login successfully', async () => {
    await element(by.id('email')).typeText('john@example.com');
    await element(by.id('password')).typeText('123456');

    const loginButton = element(by.text('Login'));
    await loginButton.tap();

    await expect(loginButton).not.toExist();
    await expect(element(by.label('Welcome'))).toBeVisible();
  });
});
```

[Get started with Detox now!](https://wix.github.io/Detox/docs/introduction/getting-started)

## About

High velocity native mobile development requires us to adopt continuous integration workflows, which means our reliance on manual QA has to drop significantly. Detox tests your mobile app while it’s running in a real device/simulator, interacting with it just like a real user.

The most difficult part of automated testing on mobile is the tip of the testing pyramid - E2E. The core problem with E2E tests is flakiness - tests are usually not deterministic. We believe the only way to tackle flakiness head on is by moving from black box testing to gray box testing. That’s where Detox comes into play.

- **Cross Platform:** Write end-to-end tests in JavaScript for React Native apps (Android & iOS).
- **Debuggable:** Modern async-await API allows breakpoints in asynchronous tests to work as expected.
- **Automatically Synchronized:** Stops flakiness at the core by monitoring asynchronous operations in your app.
- **Made For CI:** Execute your E2E tests on CI platforms like Travis CI, Circle CI or Jenkins without grief.
- **Runs on Devices:** Gain confidence to ship by testing your app on a device/simulator just like a real user (not yet supported on iOS).
- **Test Runner Agnostic:** Detox provides a set of APIs to use with any test runner without it. It comes with [Jest](https://jestjs.io) integration out of the box.

## Supported React Native Versions

Detox was built from the ground up to support React Native projects.

While Detox should work out of the box with almost any React Native version of the latest minor releases, official support is provided for React Native versions `0.73.x`, `0.74.x`, `0.75.x` and `0.76.x`, including React Native's ["New Architecture"](https://reactnative.dev/docs/the-new-architecture/landing-page).

Newer versions may work with Detox but have not been thoroughly tested by the Detox team.

Although we do not officially support older React Native versions, we do our best to keep Detox compatible with them.

Also, in case of a problem with an unsupported version of React Native, please [submit an issue](https://github.com/wix/Detox/issues/new/choose) or write us in our [Discord server](https://discord.gg/CkD5QKheF5) and we will do our best to help out.

### Known Issues with React Native

- Visibility edge-case on Android: see this [RN issue](https://github.com/facebook/react-native/issues/23870).

## Get Started with Detox

Read the [Getting Started Guide](https://wix.github.io/Detox/docs/introduction/getting-started) to get Detox running on your app in less than 10 minutes.

## Documents Site

Explore further about using Detox from our new **[website](https://wix.github.io/Detox/)**.

## Core Principles

We believe that the only way to address the core difficulties with mobile end-to-end testing is by rethinking some of the principles of the entire approach. See what Detox [does differently](https://wix.github.io/Detox/docs/articles/design-principles).

## Contributing to Detox

Detox has been open-source from the first commit. If you’re interested in helping out with our roadmap, please see issues tagged with the [<img src="docs/img/github-label-contributors.png">](https://github.com/wix/Detox/labels/user%3A%20looking%20for%20contributors) label. If you have encountered a bug or would like to suggest a new feature, please open an issue.

Dive into Detox core by reading the [Detox Contribution Guide](https://wix.github.io/Detox/docs/contributing).

## License

- Detox is licensed under the [MIT License](LICENSE)

## Non-English Resources (Community)

- [Getting Started (Brazilian Portuguese)](https://medium.com/quia-digital/iniciando-com-detox-framework-1-4-ce31ad7ae812)
