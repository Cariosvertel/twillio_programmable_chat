## [Notice: Twilio Sunsetting Programmable Chat on July 25, 2022](https://www.twilio.com/changelog/programmable-chat-end-of-life)

# twilio_programmable_chat
Flutter plugin for [Twilio Programmable Chat](https://www.twilio.com/chat?utm_source=opensource&utm_campaign=flutter-plugin), which enables you to build a chat application. \
This Flutter plugin is a community-maintained project for [Twilio Programmable Chat](https://www.twilio.com/vidchateo?utm_source=opensource&utm_campaign=flutter-plugin) and not maintained by Twilio. If you have any issues, please file an issue instead of contacting support.

This package is currently work-in-progress and should not be used for production apps. We can't guarantee that the current API implementation will stay the same between versions, until we have reached v1.0.0.

# Example
Check out our comprehensive [example](https://gitlab.com/twilio-flutter/programmable-chat/tree/master/example) provided with this plugin.

## Join the community
If you have any question or problems, please join us on [Discord](https://discord.gg/MWnu4nW)

## FAQ
Read the [Frequently Asked Questions](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/FAQ.md) first before creating a new issue.

## Supported platforms
* Android
* iOS
* ~~Web~~ (not yet)

# Code samples

We will add some code samples soon

# Push Notifications

## General

**Required steps for enabling push notifications in iOS and Android apps apply.**

Some links for more information:
- [Push notification configuration](https://www.twilio.com/docs/chat/push-notification-configuration)
- [iOS info](https://www.twilio.com/docs/chat/ios/push-notifications-ios)
- [Android info](https://www.twilio.com/docs/chat/android/push-notifications)

**Note:** At this time it seems that both the Android and iOS SDKs only support registering for push notifications once per connection.

## Platform Specifics

The iOS and Android SDKs take different approaches to push notifications. **Notable differences include:**

## iOS
1. The iOS SDK uses APNs whereas Android uses FCM.
2. The iOS SDK handles receiving and displaying push notifications.
3. Due to the fact that APNs token format has changed across iOS implementations, we have elected to retrieve the token from the OS ourselves at time of registration rather than attempting to anticipate what method of encoding might be used when transferring the token back and forth across layers of the app, or what format the token might take.

## Android
1. The Android SDK offers options for GCM and FCM. As GCM has largely been deprecated by Google, we have elected to only handle FCM.
2. The Android SDK does not receive messages or handle notifications.
3. Rather than introducing a dependency on `firebase` to the plugin, we have elected to leave token retrieval, message and notification handling to the user of the plugin.
    - An example of this can be seen in the example app.
    - Notable parts of the implementation in the example app include:
      * `Application.kt` - which is used to allow for receiving background messages with `firebase_messaging`
       and displaying them with `flutter_local_notifications`, as the plugins must be registered independently
       of the `Activity` lifecycle.
      * `main.dart` - which configures `FirebaseMessaging` with message handlers,
       initializes `FlutterLocalNotificationsPlugin`, and creates a notification channel.
      * `chat_bloc.dart` - which retrieves tokens (if on Android), and registers and unregisters for notifications.


# Development and Contributing
Interested in contributing? We love merge requests! See the [Contribution](https://gitlab.com/twilio-flutter/programmable-chat/blob/master/CONTRIBUTING.md) guidelines.

# Contributions By

[![HomeX - Home Repairs Made Easy](https://homex.com/static/brand/homex-logo-green.svg)](https://homex.com)
