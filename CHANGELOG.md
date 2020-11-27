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
