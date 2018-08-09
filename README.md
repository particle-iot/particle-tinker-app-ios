#Particle Tinker app for iOS

Please visit [http://docs.particle.io/photon/tinker/](http://docs.particle.io/photon/tinker/) for more info about this app.

## Building app from the source code

The application code in this repo is stripped from private keys used by the application. To get the app to compile you either have to provide the missing keys or remove the references to these files and comment out the code that uses them. The missing files are:
1. `Keys.swift` from PhotonTinker folder
2. `GoogleService-Info.plist` from PhotonTinker folder

Use `Keys.template.swift` (located in root folder) as a template for `Keys.swift`. This file contains 3 keys:
1. `segmentAnalyticsWriteKey` - obtained from https://app.segment.com/ by creating an iOS app source and copying API write key.
2. `oAuthClientId` - obtained from [https://console.particle.io/authentication](https://console.particle.io/authentication).
3. `oAuthSecret` - obtained from [https://console.particle.io/authentication](https://console.particle.io/authentication).

You can obtain `GoogleService-Info.plist` by following [Firebase integration tutorial](https://firebase.google.com/docs/ios/setup).

After missing files are provided, simply run `pod install` and compile the app.

