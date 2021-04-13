## 0.1.1+7

* **Android**: Fixed type cast error parsing the `messageIndex` param for `getMessageByIndex` at native layer.

## 0.1.1+6

* Removed native layer Channel `EventChannel` when client is shutdown.

## 0.1.1+5

* Resolved a bug where `connectionState` could be `null` when network is disabled or changed.

## 0.1.1+4

* Resolved bug in which Channel event subscriptions failed to receive new events (e.g. `onMessageAdded`) after calling `shutdown` on an existing `ChatClient` and then initializing a new one with `TwilioProgrammableChat.create`

## 0.1.1+3

* Provided a default value of "" for `message.memberSid` when sending to the Dart layer from Swift.

## 0.1.1+2

* Updated previously final properties for `Channel` that are not available at `IDENTIFIER` sync state.

## 0.1.1+1

* Updated `enum_to_string` usage to improve pub score

## 0.1.1

* Added registration for Twilio push notifications via APNs on iOS.
* Added registration for Twilio push notifications via FCM on Android.
* Fixed handling of `userUpdated` event.
* Fixed `clientSynchronization` event broadcast for iOS.

## 0.1.0+4

* Fixes an issue where null data would prevent events from being parsed and distributed.

## 0.1.0+3

* Makes argument to Android `EventChannel.StreamHandler::onCancel` methods nullable
* Sets `EventChannel` `StreamHandler`s to `null` on `onDetachedFromEngine`

## 0.1.0+2

* Throws an `UnsupportedError` when the `TwilioProgrammableChat.create` is called again without first shutting down the existing `ChatClient`

## 0.1.0+1

* Fix dart implementation of Message::setAttributes

## 0.1.0

* Initial iOS & Android release
