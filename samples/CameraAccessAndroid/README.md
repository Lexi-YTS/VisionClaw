# Camera Access App

A sample Android application demonstrating integration with Meta Wearables Device Access Toolkit. This app showcases streaming video from Meta AI glasses, capturing photos, and managing connection states.

## Features

- Connect to Meta AI glasses
- Stream camera feed from the device
- Capture photos from glasses
- Share captured photos

## Prerequisites

- Android Studio Arctic Fox (2021.3.1) or newer
- JDK 11 or newer
- Android SDK 31+ (Android 12.0+)
- Meta Wearables Device Access Toolkit (included as a dependency)
- A Meta AI glasses device for testing (optional for development)

## Building the app

### Using Android Studio

1. Clone this repository
1. Open the project in Android Studio
1. Add your personal access token (classic) to the `local.properties` file as `github_token=...` (see [SDK for Android setup](https://wearables.developer.meta.com/docs/getting-started-toolkit/#sdk-for-android-setup))
1. Click **File** > **Sync Project with Gradle Files**
1. Click **Run** > **Run...** > **app**

If you use the GitHub CLI, the helper script can write the current token into
`local.properties` without printing it:

```bash
scripts/configure-github-packages.sh
```

The token must include `read:packages`. If it does not, run:

```bash
gh auth refresh -s read:packages
```

### Command-line install

To build, install, launch, and forward the local OpenClaw gateway through USB:

```bash
scripts/install-debug.sh
```

This sets:

```bash
adb reverse tcp:18789 tcp:18789
```

With that reverse tunnel active, configure Android OpenClaw settings as:

- Host: `http://127.0.0.1`
- Port: `18789`

## Running the app

1. Turn 'Developer Mode' on in the Meta AI app.
1. Launch the app.
1. Press the "Connect" button to complete app registration.
1. Once connected, the camera stream from the device will be displayed
1. Use the on-screen controls to:
   - Capture photos
   - View and save captured photos
   - Disconnect from the device

## Troubleshooting

**Gradle sync fails with 401 Unauthorized** -- Make sure `local.properties`
contains `github_token=...`, or export `GITHUB_TOKEN` before running Gradle. The
token needs `read:packages` scope.

**Gemini API key rejected** -- Use a Google AI Studio key from
<https://aistudio.google.com/apikey>. Gemini keys normally start with `AIza`.

**OpenClaw is not reachable from Android** -- If the phone is connected by USB,
run `adb reverse tcp:18789 tcp:18789` and use `http://127.0.0.1:18789` from the
app. If using Wi-Fi instead, the OpenClaw gateway must bind to LAN/tailnet and
the phone must be on the same reachable network.

For issues related to the Meta Wearables Device Access Toolkit, please refer to the [developer documentation](https://wearables.developer.meta.com/docs/develop/) or visit our [discussions forum](https://github.com/facebook/meta-wearables-dat-android/discussions)

## License

This source code is licensed under the license found in the LICENSE file in the root directory of this source tree.
