# Device

The `device` object is globally available in every test file, unless you use `exposeGlobals: false` in the behavior config,
and even then you can import it from Detox package:

```js
const { device } = require('detox');
```

It enables control over the current attached device.

## Public Properties

### `device.id`

Holds the environment-unique ID of the device - namely, the `adb` ID on Android (e.g. `emulator-5554`) and the Mac-global simulator UDID on iOS, as used by `simctl` (e.g. `AAAAAAAA-BBBB-CCCC-DDDD-EEEEEEEEEEEE`).

The value will be `undefined` until the device is properly _prepared_ (i.e. in `detox.init()`).

### `device.name`

Holds a descriptive name of the device. Example: `emulator-5554 (Pixel_API_26)`

The value will be `undefined` until the device is properly _prepared_ (i.e. in `detox.init()`).

### `device.appLaunchArgs`

Access the launch-arguments predefined by the user in preliminary, static scopes such as the Detox [configuration file](../config/apps.mdx)
and [command-line arguments](../cli/test.md). This access allows, through dedicated methods, for both value-querying and modification:

```js
// Modify some of the predefined arguments:
device.appLaunchArgs.modify({
  mockServerPort: 1234,
});
// Retrieve the arguments:
device.appLaunchArgs.get(); // ==> { mockServerPort: 1234 }
// Reset (i.e. remove all arguments):
device.appLaunchArgs.reset();
```

In multi-app environments, you might want to persist your values between `device.selectApp(name)` calls:

```js
device.appLaunchArgs.modify({ transientArg: 'value' });
device.appLaunchArgs.shared.modify({
  permanentMockServerPort: 1234,
};

device.appLaunchArgs.get(); // ==> { permanentMockServerPort: 1234, transientArg: 'value' }
device.appLaunchArgs.shared.get(); // ==> { permanentMockServerPort: 1234 }

await device.selectApp('anotherApp');
device.appLaunchArgs.get(); // ==> { permanentMockServerPort: 1234 }
device.appLaunchArgs.reset();
device.appLaunchArgs.get(); // ==> { permanentMockServerPort: 1234 }
device.appLaunchArgs.shared.reset();
device.appLaunchArgs.get(); // ==> {}
```

This is the most flexible way of editing the launch arguments. Refer to the [launch arguments guide](../guide/launch-args.md) for complete details.

## Methods

### `device.selectApp(name)`

Use **only for advanced multi-app configs** when you need to switch between your apps
within the same test scenario. Refer to the [configuration doc](../config/apps.mdx)
to discover how to define multiple apps with different `name`s.

```js
await device.selectApp('myAppName');
```

As a side effect (due to the current architectural limitation) running `device.selectApp` terminates the previous
app that had been running before.

### `device.launchApp(params)`

Launch the app defined in the current [`configuration`](../config/overview.mdx).

`params`—object, containing one of more of the following keys and values:

#### 1. `newInstance`—Launching a New Instance of the App

Terminate the app and launch it again.

If set to `false`, the device will try to resume the app (e.g. bring from foreground to background). If the app isn’t running, **it will launch a new instance** nonetheless. **Default is `false`.**

```js
await device.launchApp({newInstance: true});
```

#### 2. `permissions`—Set Runtime Permissions (iOS Only)

Grants or denies runtime permissions to your application. This will cause the app to terminate before permissions are applied.

```js
await device.launchApp({permissions: {calendar: 'YES'}});
```

Detox uses [AppleSimUtils](https://github.com/wix/AppleSimulatorUtils) and [`xcrun simctl`](https://nshipster.com/simctl/) to implement this functionality for iOS simulators.
Please make sure you have the most recent version of both tools installed, since we rely on their latest versions.

##### Supported Permissions

| Permission | Values                  | Notes                                                         |
|------------|-------------------------|---------------------------------------------------------------|
| location   | always / inuse / never / unset | inuse - provides location access only when the app is in use  |
| contacts   | YES / NO / unset / limited     | limited - grants limited access to contacts                   |
| photos     | YES / NO / unset / limited     | limited - grants limited access to photos                     |
| calendar   | YES / NO / unset        |                                                               |
| camera     | YES / NO / unset        |                                                               |
| medialibrary | YES / NO / unset      |                                                               |
| microphone | YES / NO / unset        |                                                               |
| motion     | YES / NO / unset        |                                                               |
| reminders  | YES / NO / unset        |                                                               |
| siri       | YES / NO / unset        |                                                               |
| notifications | YES / NO / unset     | Requires AppleSimUtils; unsupported by simctl                |
| health     | YES / NO / unset        | Requires AppleSimUtils; unsupported by simctl                |
| homekit    | YES / NO / unset        | Requires AppleSimUtils; unsupported by simctl                |
| speech     | YES / NO / unset        | Requires AppleSimUtils; unsupported by simctl                |
| faceid     | YES / NO / unset        | Requires AppleSimUtils; unsupported by simctl                |
| userTracking | YES / NO / unset      | Requires AppleSimUtils; unsupported by simctl                |

Check Detox's [own test suite](https://github.com/wix/Detox/blob/master/detox/test/e2e/13.permissions.test.js) for usage examples.

#### 3. `url`—Launching with URL

Launches the app with the specified URL to test your app’s deep link handling mechanism.

```js
await device.launchApp({url});
await device.launchApp({url, newInstance: true}); // Launch a new instance of the app
await device.launchApp({url, newInstance: false}); // Reuse existing instance
```

Read more [here](../guide/mocking-open-with-url.md). Go back to subsection 1 to read about the full effect of the `newInstance` argument.

#### 4. `userNotification`—Launching with User Notifications

Launches with the specified user notification.

```js
await device.launchApp({userNotification});
await device.launchApp({userNotification, newInstance: true}); // Launch a new instance of the app
await device.launchApp({userNotification, newInstance: false}); // Reuse existing instance
```

Read more [here](../guide/mocking-user-notifications.md). Go back to subsection 1 to read about the full effect of the `newInstance` argument.

#### 5. `userActivity`—Launch with User Activity (iOS Only)

Launches the app with the specified user activity.

```js
await device.launchApp({userActivity: activity});
await device.launchApp({userActivity: activity, newInstance: true}); //Launch a new instance of the app
await device.launchApp({userActivity: activity, newInstance: false}); //Reuse existing instance
```

Read more in [here](../guide/mocking-user-activity.md). Go back to subsection 1 to read about the full effect of the `newInstance` argument.

#### 6. `delete`—Delete and Reinstall Application Before Launching

Before launching the application, it is uninstalled and then reinstalled.

A flag that enables relaunching into a fresh installation of the app (it will uninstall and install the binary). Default is `false`.

```js
await device.launchApp({delete: true});
```

#### 7. `launchArgs`—Additional Process Launch Arguments

Launches the app on the device with on-site, user-specified launch arguments:

```js
await device.launchApp({
  launchArgs: {
    arg1: 1,
    arg2: "2",
  }
});
```

This is the most explicit and straightforward way of setting launch arguments. Refer to the [launch arguments guide](../guide/launch-args.md) for a complete overview on app launch arguments.

#### 8. `disableTouchIndicators`—Disable Touch Indicators (iOS Only)

Disables touch indicators on iOS. Default is `false`.

```js
await device.launchApp({disableTouchIndicators: true});
```

#### 9. `languageAndLocale`—Launch with a Specific Language and/or Local (iOS Only)

Launch the app with a specific system language

Information about accepted values can be found [here](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPInternational/LanguageandLocaleIDs/LanguageandLocaleIDs.html).

```js
await device.launchApp({
  languageAndLocale: {
    language: "es-MX",
    locale: "es-MX"
  }
});
```

With this API, you can run sets of E2E tests per language. For example:

```js
describe.each([
  ['es-MX'], ['fr-FR'], ['pt-BR'],
])(`Test suite (locale: %s)`, (locale) => {
  beforeAll(async () => {
    await device.launchApp({
      newInstance: true,
      languageAndLocale: {
        language: locale,
        locale
      }
    });
  });

  test('some description', async () => {
    // …
  });
});
```

#### 10. `detoxEnableSynchronization`—Initialize Detox with synchronization enabled or disabled at app launch

Launches the app with the synchronization mechanism enabled or disabled. Useful if the app cannot be synchronized during the launch process. Synchronization can later be enabled using `device.enableSynchronization()`.

```js
await device.launchApp({
  newInstance: true,
  launchArgs: { detoxEnableSynchronization: 0 }
});
```

#### 11. `detoxURLBlacklistRegex`—Initialize the URL Blacklist at app launch

Launches the app with a URL blacklist to disable network synchronization on certain endpoints.
Useful if the app makes frequent network calls to blacklisted endpoints upon startup.

> Note that due to the complexity of reg-exps and interoperability concerns, the implementation is fairly sensitive to the format of the string of urls.
> Please do your best to follow the example below:

```js
await device.launchApp({
  newInstance: true,
  launchArgs: { detoxURLBlacklistRegex: '\\("^http://192\.168\.1\.253:\\d{4}/.*","https://e\.crashlytics\.com/spi/v2/events"\\)' },
});
```

#### 12. `detoxDisableWebKitSecurity`—Disable WebKit Security (iOS Only)

Disables WebKit security on iOS. Default is `false`.

This is useful for testing web views with iframes that loads CORS-protected content.

:::caution Important

Some pages may not load correctly when WebKit security is disabled (for example, PCI DSS-compliant pages).
Disabling WebKit security may cause errors when loading pages that have strict security policies.

:::

```js
await device.launchApp({
  launchArgs: { detoxDisableWebKitSecurity: true }
});
```

### `device.terminateApp()`

By default, `terminateApp()` with no params will terminate the app file defined in the current [`configuration`](../config/overview.mdx).

To terminate another app, specify its bundle id

```js
await device.terminateApp('other.bundle.id');
```

### `device.sendToHome()`

Send application to background by bringing `com.apple.springboard` to the foreground.
Combining `sendToHome()` with `launchApp({newInstance: false})` will simulate app coming back from background.
Check out Detox’s [own test suite](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/06.device.test.js)

```js
await device.sendToHome();
await device.launchApp({newInstance: false});
// app returned from background, do stuff
```

Check out Detox’s [own test suite](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/06.device.test.js)

### `device.reloadReactNative()`

If this is a React Native app, reload the React Native JS bundle. This action is much faster than `device.launchApp()`, and can be used if you just need to reset your React Native logic.

<i>**Note:** This functionality does not work without faults. Under certain conditions, the system may not behave as expected and/or even crash. In these cases, use `device.launchApp()` to launch the app cleanly instead of only reloading the JS bundle.</i>

### `device.installApp()`

By default, `installApp()` with no params will install the app file defined in the current [`configuration`](../config/overview.mdx).

To install another app, specify its path

```js
await device.installApp('path/to/other/app');
```

### `device.uninstallApp()`

By default, `uninstallApp()` with no params will uninstall the app defined in the current [`configuration`](../config/overview.mdx).

To uninstall another app, specify its bundle id

```js
await device.uninstallApp('other.bundle.id');
```

### `device.openURL({url, sourceApp[optional]})`

Mock opening the app from URL. `sourceApp` is an optional **iOS-only** parameter to specify source application bundle id.

Read more in [Mocking Open with URL](../guide/mocking-open-with-url.md) section.
Check out Detox’s [own test suite](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/15.urls.test.js)

### `device.sendUserNotification(params)`

Mock handling of a user notification previously received in the system, while the app is already running.

Read more in [Mocking User Notifications](../guide/mocking-user-notifications.md) section.
Check out Detox’s [own test suite](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/11.user-notifications.test.js)

### `device.sendUserActivity(params)` **iOS Only**

Mock handling of received user activity when app is in foreground.
Read more in [Mocking User Activity](../guide/mocking-user-activity.md) section.
Check out Detox’s [own test suite](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/18.user-activities.test.js)

### `device.setOrientation(orientation)`

Takes `"portrait"` or `"landscape"` and rotates the device to the given orientation.

**Note:** Setting device orientation is only supported for iPhone devices, or for apps declared as requiring full screen on iPad. For all other cases, the current test will be failed.

Check out Detox’s [own test suite.](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/test/e2e/06.device-orientation.test.js)

### `device.setLocation(lat, lon)`

Sets the simulator/emulator location to the given latitude and longitude.

> On iOS `setLocation` depends on `xcrun simctl`, and we recommend using its latest version.
>
> On Android `setLocation` will work with both Android Emulator (bundled with Android development tools) and Genymotion. The correct permissions must be set in your app manifest.

```js
await device.setLocation(32.0853, 34.7818);
```

### `device.disableSynchronization()`

Temporarily disable synchronization (idle/busy monitoring) with the app - namely, stop waiting for the app to go idle before moving forward in the test execution.

This API is useful for cases where test assertions must be made in an area of your application where it is okay for it to ever remain partly _busy_ (e.g. due to an endlessly repeating on-screen animation).
However, using it inherently suggests that you are likely to resort to applying `sleep()`’s in your test code - testing that area, **which is not recommended and can never be 100% stable.** Therefore, as a rule of thumb, test code running "inside" a sync-disabled mode must be reduced to the bare minimum.

Note: Synchronization is enabled by default, and it gets **re-enabled on every launch of a new instance of the app.**

```js
await device.disableSynchronization();
```

### `device.enableSynchronization()`

Re-enable synchronization (idle/busy monitoring) with the app - namely, resume waiting for the app to go idle before moving forward in the test execution, after a previous disabling of it through a call to `device.disableSynchronization()`.

:warning: Note: Making this call would resume synchronization **instantly**, having its returned promise only resolve when the app becomes idle again. In other words, this **must only be called after you navigate back to "the safe zone", where the app should be able to eventually become idle again**, or it would remain suspended "forever" (i.e. until a safeguard time-out expires).

```js
await device.enableSynchronization();
```

### `device.setURLBlacklist([urls])`

Exclude synchronization with respect to network activity (i.e. don’t wait for network to go idle before moving forward in the test execution) according to **specific** endpoints, denoted as URL reg-exp’s. To disable endpoints at initialization, pass in the black-list as an [app-launch argument](../guide/launch-args.md) named `detoxURLBlacklistRegex` (as explained [here](#11-detoxurlblacklistregexinitialize-the-url-blacklist-at-app-launch)).

```js
await device.setURLBlacklist(['.*127.0.0.1.*', '.*my.ignored.endpoint.*']);
```

### `device.resetContentAndSettings()` **iOS Only**

Resets the Simulator to clean state (like the Simulator > Reset Content and Settings... menu item), especially removing
previously set permissions.

```js
await device.resetContentAndSettings();
```

### `device.getPlatform()`

Returns the current device, `ios` or `android`.

```js
if (device.getPlatform() === 'ios') {
  await expect(loopSwitch).toHaveValue('1');
}
```

### `device.tap(point, shouldIgnoreStatusBar)`

Perform a tap at arbitrary coordinates on the device's screen.

#### tap parameters

- `point` — Coordinates in the element's coordinate space (default value: `{x: 100, y: 100}`, platforms: Android & IOS) <br/>
- `shouldIgnoreStatusBar` — Coordinates will be measured starting from under the status bar (default value: `true`, platform: Android) <br/>

#### tap examples

```js

await device.tap();
await device.tap({ x: 100, y: 150 }, false);
await device.tap({ x: 100, y: 150 });
await device.tap(false);

```

### `device.longPress(point, duration, shouldIgnoreStatusBar)`

Perform a long press at arbitrary coordinates on the device's screen. Custom press duration if needed.

#### longPress parameters

- `point` — Coordinates in the element's coordinate space (default value: `{x: 100, y: 100}`, platforms: Android & IOS) <br/>
- `duration` — Custom press duration time, in milliseconds. (default values: Android: Standard long-press duration.  IOS: 1000 milliseconds, platforms: Android & IOS) <br/>
- `shouldIgnoreStatusBar` — Coordinates will be measured starting from under the status bar (default value: `true`, platform: Android) <br/>

#### longPress examples

```js

await device.longPress();
await device.longPress({ x: 100, y: 150 }, 2000, false);
await device.longPress({ x: 100, y: 150 }, 2000);
await device.longPress(2000, false);
await device.longPress({ x: 100, y: 150 }, false);
await device.longPress({ x: 100, y: 150 });
await device.longPress(2000);
await device.longPress(false);

```

### `device.takeScreenshot([name])`

Takes a screenshot of the device. For full details on taking screenshots with Detox, refer to the [screen-shots guide](../guide/taking-screenshots.md).

### `device.captureViewHierarchy([name])`

**iOS Only.** Saves a view hierarchy snapshot (`*.viewhierarchy`) of the
currently opened application to a temporary folder and schedules putting it to
the artifacts' folder upon the completion of the current test. The file can be
opened later in Xcode 12.0 and above.
See [Xcode 12 Release notes: #57933113](https://developer.apple.com/documentation/xcode-release-notes/xcode-12-release-notes#:~:text=57933113)
for more details.

The `name` parameter is optional — by default, it equals to `capture`.

```js
test('Capture view hierarchy', async () => {
  const temporaryArtifactPath = await device.captureViewHierarchy('myElements');

  // The temporary path will remain valid until the test completion.
  // Afterwards, the artifact will be moved, e.g.:
  // * on success, to: <artifacts-location>/✓ Capture view hierarchy/myElements.viewhierarchy
  // * on failure, to: <artifacts-location>/✗ Capture view hierarchy/myElements.viewhierarchy
});
```

### `device.generateViewHierarchyXml([shouldInjectTestIds])`

Generates a view hierarchy XML of the currently opened application. The XML is returned as a string.

The `shouldInjectTestIds` parameter is optional and defaults to `false`. When set to `true`, Detox will attempt to inject `testID` attributes into the XML for each element if undefined.

```js
const viewHierarchyXml = await device.generateViewHierarchyXml();
```

### `device.shake()` **iOS Only**

Simulate shake

### `device.setBiometricEnrollment(bool)` **iOS Only**

Toggles device enrollment in biometric authentication (Touch ID or Face ID).

```js
await device.setBiometricEnrollment(true);
// or
await device.setBiometricEnrollment(false);
```

### `device.matchFace()` **iOS Only**

Simulates the success of a face match via Face ID

### `device.unmatchFace()` **iOS Only**

Simulates the failure of face match via Face ID

### `device.matchFinger()` **iOS Only**

Simulates the success of a finger match via Touch ID

### `device.unmatchFinger()` **iOS Only**

Simulates the failure of a finger match via Touch ID

### `device.clearKeychain()` **iOS Only**

Clears the device keychain

### `device.setStatusBar()` **iOS Only**

Override simulator’s status bar. Available options:

```js
await device.setStatusBar({
  time: "12:34",
  // Set the date or time to a fixed value.
  // If the string is a valid ISO date string it will also set the date on relevant devices.
  dataNetwork: "wifi",
  // If specified must be one of 'hide', 'wifi', '3g', '4g', 'lte', 'lte-a', 'lte+', '5g', '5g+', '5g-uwb', or '5g-uc'.
  wifiMode: "failed",
  // If specified must be one of 'searching', 'failed', or 'active'.
  wifiBars: "2",
  // If specified must be 0-3.
  cellularMode: "searching",
  // If specified must be one of 'notSupported', 'searching', 'failed', or 'active'.
  cellularBars: "3",
  // If specified must be 0-4.
  operatorName: "A1",
  // Set the cellular operator/carrier name. Use '' for the empty string.
  batteryState: "charging",
  // If specified must be one of 'charging', 'charged', or 'discharging'.
  batteryLevel: "50",
  // If specified must be 0-100.
});
```

### `device.resetStatusBar()` **iOS Only**

Resets any override in simulator’s status bar.

### `device.reverseTcpPort()` **Android Only**

Reverse a TCP port from the device (guest) back to the host-computer, as typically done with the `adb reverse` command. The end result would be that all network requests going from the device to the specified port will be forwarded to the computer.

### `device.unreverseTcpPort()` **Android Only**

Clear a _reversed_ TCP-port (e.g. previously set using `device.reverseTcpPort()`).

### `device.pressBack()` **Android Only**

Simulate press back button.

```js
await device.pressBack();
```

### `device.getUiDevice()` **Android Only**

Exposes [`UiAutomator`’s `UiDevice` API](https://developer.android.com/reference/androidx/test/uiautomator/UiDevice).
**This is not a part of the official Detox API**, it may break and change whenever an update to `UiDevice` or `UiAutomator` Gradle dependencies (`androidx.test.uiautomator:uiautomator`) is introduced.

[`UiDevice`’s autogenerated code](https://github.com/wix/Detox/tree/a9a09246c05733f6b91cfcc0dba05a4714abca92/detox/src/android/espressoapi/UIDevice.js)
