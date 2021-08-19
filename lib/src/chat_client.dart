part of twilio_programmable_chat;

/// Chat client - main entry point for the Chat SDK.
class ChatClient {
  /// Stream for the native chat events.
  late StreamSubscription<dynamic> _chatStream;

  /// Stream for native Channel events
  late StreamSubscription<dynamic> _channelEventStream;

  /// Stream for the notification events.
  late StreamSubscription<dynamic> _notificationStream;

  //#region Private API properties
  final Channels _channels = Channels();

  ConnectionState _connectionState = ConnectionState.UNKNOWN;

  final String _myIdentity;

  final Users _users = Users();

  bool _isReachabilityEnabled = false;
  //#endregion

  //#region Public API properties
  /// [Channels] available to the current client.
  Channels get channels {
    return _channels;
  }

  /// Current transport state
  ConnectionState get connectionState {
    return _connectionState;
  }

  /// Get user identity for the current user.
  String get myIdentity {
    return _myIdentity;
  }

  /// Get [Users] interface.
  Users get users {
    return _users;
  }

  /// Get reachability service status.
  bool get isReachabilityEnabled {
    return _isReachabilityEnabled;
  }
  //#endregion

  //#region Channel events
  final StreamController<Channel> _onChannelAddedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user has a channel added to their channel list, channel status is not specified.
  late Stream<Channel> onChannelAdded;

  final StreamController<Channel> _onChannelDeletedCtrl = StreamController<Channel>.broadcast();

  /// Called when one of the channel of the current user is deleted.
  late Stream<Channel> onChannelDeleted;

  final StreamController<Channel> _onChannelInvitedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user was invited to a channel, channel status is [ChannelStatus.INVITED].
  late Stream<Channel> onChannelInvited;

  final StreamController<Channel> _onChannelJoinedCtrl = StreamController<Channel>.broadcast();

  /// Called when the current user either joined or was added into a channel, channel status is [ChannelStatus.JOINED].
  late Stream<Channel> onChannelJoined;

  final StreamController<Channel> _onChannelSynchronizationChangeCtrl = StreamController<Channel>.broadcast();

  /// Called when channel synchronization status changed.
  ///
  /// Use [Channel.synchronizationStatus] to obtain new channel status.
  late Stream<Channel> onChannelSynchronizationChange;

  final StreamController<ChannelUpdatedEvent> _onChannelUpdatedCtrl = StreamController<ChannelUpdatedEvent>.broadcast();

  /// Called when the channel is updated.
  ///
  /// [Channel] synchronization updates are delivered via different callback.
  late Stream<ChannelUpdatedEvent> onChannelUpdated;
  //#endregion

  //#region ChatClient events
  final StreamController<ChatClientSynchronizationStatus> _onClientSynchronizationCtrl = StreamController<ChatClientSynchronizationStatus>.broadcast();

  /// Called when client synchronization status changes.
  late Stream<ChatClientSynchronizationStatus> onClientSynchronization;

  final StreamController<ConnectionState> _onConnectionStateCtrl = StreamController<ConnectionState>.broadcast();

  /// Called when client connnection state has changed.
  late Stream<ConnectionState> onConnectionState;

  final StreamController<ErrorInfo> _onErrorCtrl = StreamController<ErrorInfo>.broadcast();

  /// Called when an error condition occurs.
  late Stream<ErrorInfo> onError;
  //#endregion

  //#region Notification events
  final StreamController<String> _onAddedToChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for added to channel event.
  late Stream<String> onAddedToChannelNotification;

  final StreamController<String> _onInvitedToChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for invited to channel event.
  late Stream<String> onInvitedToChannelNotification;

  final StreamController<NewMessageNotificationEvent> _onNewMessageNotificationCtrl = StreamController<NewMessageNotificationEvent>.broadcast();

  /// Called when client receives a push notification for new message.
  late Stream<NewMessageNotificationEvent> onNewMessageNotification;

  final StreamController<ErrorInfo> _onNotificationFailedCtrl = StreamController<ErrorInfo>.broadcast();

  /// Called when registering for push notifications fails.
  late Stream<ErrorInfo> onNotificationFailed;

  final StreamController<String> _onRemovedFromChannelNotificationCtrl = StreamController<String>.broadcast();

  /// Called when client receives a push notification for removed from channel event.
  late Stream<String> onRemovedFromChannelNotification;
  //#endregion

  //#region Token events
  final StreamController<void> _onTokenAboutToExpireCtrl = StreamController<void>.broadcast();

  /// Called when token is about to expire soon.
  ///
  /// In response, [ChatClient] should generate a new token and call [ChatClient.updateToken] as soon as possible.
  late Stream<void> onTokenAboutToExpire;

  final StreamController<void> _onTokenExpiredCtrl = StreamController<void>.broadcast();

  /// Called when token has expired.
  ///
  /// In response, [ChatClient] should generate a new token and call [ChatClient.updateToken] as soon as possible.
  late Stream<void> onTokenExpired;
  //#endregion

  //#region User events
  final StreamController<User> _onUserSubscribedCtrl = StreamController<User>.broadcast();

  /// Called when a user is subscribed to and will receive realtime state updates.
  late Stream<User> onUserSubscribed;

  final StreamController<User> _onUserUnsubscribedCtrl = StreamController<User>.broadcast();

  /// Called when a user is unsubscribed from and will not receive realtime state updates anymore.
  late Stream<User> onUserUnsubscribed;

  final StreamController<UserUpdatedEvent> _onUserUpdatedCtrl = StreamController<UserUpdatedEvent>.broadcast();

  /// Called when user info is updated for currently loaded users.
  late Stream<UserUpdatedEvent> onUserUpdated;

  final StreamController<NotificationRegistrationEvent> _onNotificationRegisteredCtrl = StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationRegistered;

  final StreamController<NotificationRegistrationEvent> _onNotificationDeregisteredCtrl = StreamController<NotificationRegistrationEvent>.broadcast();

  /// Called when attempt to register device for notifications has completed.
  late Stream<NotificationRegistrationEvent> onNotificationDeregistered;
  //#endregion

  ChatClient(this._myIdentity) {
    onChannelAdded = _onChannelAddedCtrl.stream;
    onChannelDeleted = _onChannelDeletedCtrl.stream;
    onChannelInvited = _onChannelInvitedCtrl.stream;
    onChannelJoined = _onChannelJoinedCtrl.stream;
    onChannelSynchronizationChange = _onChannelSynchronizationChangeCtrl.stream;
    onChannelUpdated = _onChannelUpdatedCtrl.stream;
    onClientSynchronization = _onClientSynchronizationCtrl.stream;
    onConnectionState = _onConnectionStateCtrl.stream;
    onError = _onErrorCtrl.stream;
    onAddedToChannelNotification = _onAddedToChannelNotificationCtrl.stream;
    onInvitedToChannelNotification = _onInvitedToChannelNotificationCtrl.stream;
    onNewMessageNotification = _onNewMessageNotificationCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;
    onRemovedFromChannelNotification = _onRemovedFromChannelNotificationCtrl.stream;
    onTokenAboutToExpire = _onTokenAboutToExpireCtrl.stream;
    onTokenExpired = _onTokenExpiredCtrl.stream;
    onUserSubscribed = _onUserSubscribedCtrl.stream;
    onUserUnsubscribed = _onUserUnsubscribedCtrl.stream;
    onUserUpdated = _onUserUpdatedCtrl.stream;
    onNotificationRegistered = _onNotificationRegisteredCtrl.stream;
    onNotificationDeregistered = _onNotificationDeregisteredCtrl.stream;
    onNotificationFailed = _onNotificationFailedCtrl.stream;

    _chatStream = TwilioProgrammableChat._chatChannel.receiveBroadcastStream(0).listen(_parseEvents);
    _channelEventStream = TwilioProgrammableChat._channelEventChannel.receiveBroadcastStream(0).listen(_parseChannelEvents);
    _notificationStream = TwilioProgrammableChat._notificationChannel.receiveBroadcastStream(0).listen(_parseNotificationEvents);
  }

  /// Construct from a map.
  factory ChatClient._fromMap(Map<String, dynamic> map) {
    final chatClient = ChatClient(map['myIdentity']);
    chatClient._updateFromMap(map);
    return chatClient;
  }

  //#region Public API methods
  /// Method to update the authentication token for this client.
  Future<void> updateToken(String token) async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('ChatClient#updateToken', <String, Object>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Cleanly shuts down the messaging client when you are done with it.
  ///
  /// It will dispose() the client after shutdown, so it could not be reused.
  Future<void> shutdown() async {
    try {
      await Channels._shutdown();
      await _chatStream.cancel();
      await _channelEventStream.cancel();
      await _notificationStream.cancel();
      TwilioProgrammableChat.chatClient = null;
      return await TwilioProgrammableChat._methodChannel.invokeMethod('ChatClient#shutdown', null);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Registers for push notifications. Uses APNs on iOS and FCM on Android.
  ///
  /// Token is only used on Android. iOS implementation retrieves APNs token itself.
  ///
  /// Twilio iOS SDK handles receiving messages when app is in the background and displaying
  /// notifications.
  Future<void> registerForNotification(String? token) async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('registerForNotification', <String, Object?>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Unregisters for push notifications.  Uses APNs on iOS and FCM on Android.
  ///
  /// Token is only used on Android. iOS implementation retrieves APNs token itself.
  Future<void> unregisterForNotification(String? token) async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('unregisterForNotification', <String, Object?>{'token': token});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _connectionState = EnumToString.fromString(ConnectionState.values, map['connectionState']) ?? ConnectionState.UNKNOWN;
    _isReachabilityEnabled = map['isReachabilityEnabled'] ?? false;

    if (map['channels'] != null) {
      final channelsMap = Map<String, dynamic>.from(map['channels']);
      _channels._updateFromMap(channelsMap);
    }

    if (map['users'] != null) {
      final usersMap = Map<String, dynamic>.from(map['users']);
      _users._updateFromMap(usersMap);
    }
  }

  /// Parse native chat client events to the right event streams.
  void _parseEvents(dynamic event) {
    final String? eventName = event['name'];
    if (eventName == null) {
      TwilioProgrammableChat._log('ChatClient => _parseEvents => eventName is null.');
      return;
    }
    TwilioProgrammableChat._log("ChatClient => Event '$eventName' => ${event["data"]}, error: ${event["error"]}");
    final data = event['data'] != null ? Map<String, dynamic>.from(event['data']) : null;
    if(data == null) {
      switch (eventName) {
        case 'tokenAboutToExpire':
          _onTokenAboutToExpireCtrl.add(null);
          break;
        case 'tokenExpired':
          _onTokenExpiredCtrl.add(null);
          break;
      }
      return;
    }

    if (data['chatClient'] != null) {
      final chatClientMap = Map<String, dynamic>.from(data['chatClient']);
      _updateFromMap(chatClientMap);
    }

    ErrorInfo? exception;
    if (event['error'] != null) {
      final errorMap = Map<String, dynamic>.from(event['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int, errorMap['message'], errorMap['status'] as int);
    }

    Map<String, dynamic>? channelMap;
    if (data['channel'] != null) {
      channelMap = Map<String, dynamic>.from(data['channel'] as Map<dynamic, dynamic>);
    }

    Map<String, dynamic>? userMap;
    if (data['user'] != null) {
      userMap = Map<String, dynamic>.from(data['user'] as Map<dynamic, dynamic>);
    }

    final channelSid = data['channelSid'] as String?;

    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap = Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      if (reasonMap['type'] == 'channel') {
        reason = EnumToString.fromString(ChannelUpdateReason.values, reasonMap['value']);
      } else if (reasonMap['type'] == 'user') {
        reason = EnumToString.fromString(UserUpdateReason.values, reasonMap['value']);
      }
    }

    switch (eventName) {
      case 'addedToChannelNotification':
        if (channelSid != null) {
          _onAddedToChannelNotificationCtrl.add(channelSid);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'addedToChannelNotification' => Attempting to operate on NULL.");
        }
        break;
      case 'channelAdded':
        if (channelMap != null) {
          Channels._updateChannelFromMap(channelMap);
          _onChannelAddedCtrl.add(Channels._channelsMap[channelMap['sid']]!);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelAdded' => Attempting to operate on NULL.");
        }
        break;
      case 'channelDeleted':
        if (channelMap == null) {
          TwilioProgrammableChat._log("ChatClient => case 'channelDeleted' => channelMap is NULL.");
          return;
        }
        final channel = Channels._channelsMap[channelMap['sid']];
        Channels._channelsMap.remove(channelMap['sid']);
        channel?._updateFromMap(channelMap);
        if (channel != null) {
          _onChannelDeletedCtrl.add(channel);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelDeleted' => channel is NULL.");
        }
        break;
      case 'channelInvited':
        if (channelMap != null) {
          Channels._updateChannelFromMap(channelMap);
          _onChannelInvitedCtrl.add(Channels._channelsMap[channelMap['sid']]!);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelInvited' => channelMap is NULL.");
        }
        break;
      case 'channelJoined':
        if (channelMap != null) {
          Channels._updateChannelFromMap(channelMap);
          _onChannelJoinedCtrl.add(Channels._channelsMap[channelMap['sid']]!);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelJoined' => channelMap is NULL.");
        }
        break;
      case 'channelSynchronizationChange':
        if (channelMap != null) {
          Channels._updateChannelFromMap(channelMap);
          _onChannelSynchronizationChangeCtrl.add(Channels._channelsMap[channelMap['sid']]!);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelSynchronizationChange' => channelMap is NULL.");
        }
        break;
      case 'channelUpdated':
        if (channelMap != null && channelMap['sid'] != null && reason != null) {
          Channels._updateChannelFromMap(channelMap);
          _onChannelUpdatedCtrl.add(ChannelUpdatedEvent(
            Channels._channelsMap[channelMap['sid']]!,
            reason,
          ));
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'channelUpdated' => channelMap: $channelMap, reason: $reason");
        }
        break;
      case 'clientSynchronization':
        final synchronizationStatus = EnumToString.fromString(ChatClientSynchronizationStatus.values, data['synchronizationStatus']);
        if (synchronizationStatus != null) {
          _onClientSynchronizationCtrl.add(synchronizationStatus);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'clientSynchronization' => Attempting to operate on NULL.");
        }
        break;
      case 'connectionStateChange':
        final connectionState = EnumToString.fromString(ConnectionState.values, data['connectionState']);
        if (connectionState != null) {
          _connectionState = connectionState;
          _onConnectionStateCtrl.add(connectionState);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'connectionStateChange' => Attempting to operate on NULL.");
        }
        break;
      case 'error':
        if (exception != null) {
          _onErrorCtrl.add(exception);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'error' => Attempting to operate on NULL.");
        }
        break;
      case 'invitedToChannelNotification':
        if (channelSid != null) {
          _onInvitedToChannelNotificationCtrl.add(channelSid);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'invitedToChannelNotification' => Attempting to operate on NULL.");
        }
        break;
      case 'newMessageNotification':
        final messageSid = data['messageSid'] as String?;
        final messageIndex = data['messageIndex'] as int?;
        if (channelSid != null && messageSid != null && messageIndex != null) {
          _onNewMessageNotificationCtrl.add(NewMessageNotificationEvent(channelSid, messageSid, messageIndex));
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'newMessageNotification' => channelSid: $channelSid, messageSid: $messageSid, messageIndex: $messageIndex");
        }
        break;
      case 'notificationFailed':
        if (exception != null) {
          _onNotificationFailedCtrl.add(exception);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'notificationFailed' => Attempting to operate on NULL.");
        }
        break;
      case 'removedFromChannelNotification':
        if (channelSid != null) {
          _onRemovedFromChannelNotificationCtrl.add(channelSid);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'removedFromChannelNotification' => Attempting to operate on NULL.");
        }
        break;
      case 'userSubscribed':
        if (userMap == null) {
          TwilioProgrammableChat._log("ChatClient => case 'userSubscribed' => userMap is NULL.");
          return;
        }
        users._updateFromMap({
          'subscribedUsers': [userMap]
        });
        final user = users.getUserById(userMap['identity']);
        if (user != null) {
          _onUserSubscribedCtrl.add(user);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'userSubscribed' => user is NULL.");
        }
        break;
      case 'userUnsubscribed':
        if (userMap == null) {
          TwilioProgrammableChat._log("ChatClient => case 'userUnsubscribed' => userMap is NULL.");
          return;
        }
        final user = users.getUserById(userMap['identity']);
        if (user != null) {
          user._updateFromMap(userMap);
          users.subscribedUsers.removeWhere((u) => u.identity == userMap!['identity']);
          _onUserUnsubscribedCtrl.add(user);
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'userUnsubscribed' => cannot resolve userById: ${userMap['identity']}.");
        }
        break;
      case 'userUpdated':
        if (userMap == null || reason == null) {
          TwilioProgrammableChat._log("ChatClient => case 'userUpdated' => userMap: $userMap, reason: $reason");
          return;
        }
        users._updateFromMap({
          'subscribedUsers': [userMap]
        });
        final user = users.getUserById(userMap['identity']);
        if (user != null) {
          _onUserUpdatedCtrl.add(UserUpdatedEvent(user, reason));
        } else {
          TwilioProgrammableChat._log("ChatClient => case 'userUpdated' => user is NULL.");
        }
        break;
      default:
        TwilioProgrammableChat._log("Event '$eventName' not yet implemented");
        break;
    }
  }

  void _parseChannelEvents(dynamic event) {
    final data = Map<String, dynamic>.from(event['data']);
    final String? channelSid = data['channelSid'];
    if (channelSid != null) {
      _channels._routeChannelEvent(channelSid, event);
    }
  }

  /// Parse native chat client events to the right event streams.
  void _parseNotificationEvents(dynamic event) {
    final String? eventName = event['name'];
    if (eventName == null) {
      TwilioProgrammableChat._log('ChatClient => _parseNotificationEvents => eventName is null.');
      return;
    }
    TwilioProgrammableChat._log("ChatClient => Event '$eventName' => ${event["data"]}, error: ${event["error"]}");
    final data = Map<String, dynamic>.from(event['data']);

    ErrorInfo? exception;
    if (event['error'] != null) {
      final errorMap = Map<String, dynamic>.from(event['error'] as Map<dynamic, dynamic>);
      exception = ErrorInfo(errorMap['code'] as int, errorMap['message'], errorMap['status'] as int);
    }

    switch (eventName) {
      case 'registered':
        _onNotificationRegisteredCtrl.add(NotificationRegistrationEvent(data['result'], exception));
        break;
      case 'deregistered':
        _onNotificationDeregisteredCtrl.add(NotificationRegistrationEvent(data['result'], exception));
        break;
      default:
        TwilioProgrammableChat._log("Notification event '$eventName' not yet implemented");
        break;
    }
  }
}
