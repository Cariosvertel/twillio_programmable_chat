part of twilio_programmable_chat;

/// Container for channel object.
class Channel {
  //#region Private API properties
  final String _sid;

  ChannelType _type;

  Attributes _attributes;

  late Messages _messages;

  ChannelStatus _status = ChannelStatus.UNKNOWN;

  late Members _members;

  ChannelSynchronizationStatus _synchronizationStatus = ChannelSynchronizationStatus.NONE;

  DateTime? _dateCreated;

  String? _createdBy;

  DateTime? _dateUpdated;

  DateTime? _lastMessageDate;

  int? _lastMessageIndex;

  bool _isSubscribed = false;

  bool _hasSynchronized = false;
  //#endregion

  //#region Public API properties
  /// Get unique identifier for this channel.
  ///
  /// This identifier can be used to get this [Channel] again using [Channels.getChannel].
  /// The channel SID is persistent and globally unique.
  String get sid {
    return _sid;
  }

  /// The channel type.
  ChannelType get type {
    return _type;
  }

  /// Get messages object that allows access to messages in the channel.
  Messages get messages {
    return _messages;
  }

  /// Get the current user's participation status on this channel.
  ChannelStatus get status {
    return _status;
  }

  /// Get members object that allows access to member roster in the channel.
  ///
  /// You need to synchronize the channel before you can call this method unless you just joined the channel, in which case it synchronizes automatically.
  Members get members {
    return _members;
  }

  /// Get the current synchronization status for channel.
  ChannelSynchronizationStatus get synchronizationStatus {
    return _synchronizationStatus;
  }

  /// Get creation date of the channel.
  DateTime? get dateCreated {
    return _dateCreated;
  }

  /// Get creator of the channel.
  String? get createdBy {
    return _createdBy;
  }

  /// Get update date of the channel.
  ///
  /// Update date changes when channel attributes, friendly name or unique name are modified. It will not change in response to messages posted or members added or removed.
  DateTime? get dateUpdated {
    return _dateUpdated;
  }

  /// Get last message date in the channel.
  DateTime? get lastMessageDate {
    return _lastMessageDate;
  }

  /// Get last message's index in the channel.
  int? get lastMessageIndex {
    return _lastMessageIndex;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }

  /// True if the channel has, in the lifetime of the ChatClient reached
  /// ChannelSynchronizationStatus.ALL
  ///
  /// This has been added to address the fact that when a user Joins a channel
  /// That channels synchronization status reverts to IDENTIFIER, and never
  /// returns to ALL
  bool get hasSynchronized {
    return _hasSynchronized;
  }

  bool get isSubscribed {
    return _isSubscribed;
  }
  //#endregion

  //#region Message events
  final StreamController<Message> _onMessageAddedCtrl = StreamController<Message>.broadcast();

  /// Called when a [Message] is added to the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was added by using [Message.getChannel] or [Message.channelSid].
  late Stream<Message> onMessageAdded;

  final StreamController<MessageUpdatedEvent> _onMessageUpdatedCtrl = StreamController<MessageUpdatedEvent>.broadcast();

  /// Called when a [Message] is changed in the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was updated by using [Message.getChannel] or [Message.channelSid].
  /// [Message] change events include body updates and attribute updates.
  late Stream<MessageUpdatedEvent> onMessageUpdated;

  final StreamController<Message> _onMessageDeletedCtrl = StreamController<Message>.broadcast();

  /// Called when a [Message] is deleted from the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was deleted by using [Message.getChannel] or [Message.channelSid].
  late Stream<Message> onMessageDeleted;
  //#endregion

  //#region Member events
  final StreamController<Member> _onMemberAddedCtrl = StreamController<Member>.broadcast();

  /// Called when a [Member] is added to the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was added by using [Member.getChannel].
  late Stream<Member> onMemberAdded;

  final StreamController<MemberUpdatedEvent> _onMemberUpdatedCtrl = StreamController<MemberUpdatedEvent>.broadcast();

  /// Called when a [Member] is changed in the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was updated by using [Member.getChannel].
  /// [Member] change events include body updates and attribute updates.
  late Stream<MemberUpdatedEvent> onMemberUpdated;

  final StreamController<Member> _onMemberDeletedCtrl = StreamController<Member>.broadcast();

  /// Called when a [Member] is deleted from the channel the current user is subscribed to.
  ///
  /// You could obtain the [Channel] where it was deleted by using [Member.getChannel].
  late Stream<Member> onMemberDeleted;
  //#endregion

  //#region Typing events
  final StreamController<TypingEvent> _onTypingStartedCtrl = StreamController<TypingEvent>.broadcast();

  /// Called when an [Member] starts typing in a [Channel].
  late Stream<TypingEvent> onTypingStarted;

  final StreamController<TypingEvent> _onTypingEndedCtrl = StreamController<TypingEvent>.broadcast();

  /// Called when an [Member] stops typing in a [Channel\.
  ///
  /// Typing indicator has a timeout after user stops typing to avoid triggering it too often. Expect about 5 seconds delay between stopping typing and receiving typing ended event.
  late Stream<TypingEvent> onTypingEnded;
  //#endregion

  //#region Synchronization event
  final StreamController<Channel> _onSynchronizationChangedCtrl = StreamController<Channel>.broadcast();

  /// Called when channel synchronization status changed.
  late Stream<Channel> onSynchronizationChanged;
  //#endregion

  Channel(
    this._sid,
    this._createdBy,
    this._dateCreated,
    this._type,
    this._attributes,
  ) {
    onMessageAdded = _onMessageAddedCtrl.stream;
    onMessageUpdated = _onMessageUpdatedCtrl.stream;
    onMessageDeleted = _onMessageDeletedCtrl.stream;
    onMemberAdded = _onMemberAddedCtrl.stream;
    onMemberUpdated = _onMemberUpdatedCtrl.stream;
    onMemberDeleted = _onMemberDeletedCtrl.stream;
    onTypingStarted = _onTypingStartedCtrl.stream;
    onTypingEnded = _onTypingEndedCtrl.stream;
    onSynchronizationChanged = _onSynchronizationChangedCtrl.stream;

    _messages = Messages(this);
    _members = Members(_sid);
  }

  /// Construct from a map.
  factory Channel._fromMap(Map<String, dynamic> map) {
    final channel = Channel(
      map['sid'],
      map['createdBy'],
      map['dateCreated'] != null ? DateTime.parse(map['dateCreated']) : null,
      EnumToString.fromString(ChannelType.values, map['type']) ?? ChannelType.PUBLIC,
      map['attributes'] != null ? Attributes.fromMap(map['attributes'].cast<String, dynamic>()) : Attributes(AttributesType.NULL, null),
    );
    channel._updateFromMap(map);
    return channel;
  }

  //#region Public API methods
  /// Join the current user to this channel.
  ///
  /// Joining the channel is a prerequisite for sending and receiving messages in the channel. You can join the channel or you could be added to it by another channel member.
  ///
  /// You could also be invited to the channel by another member. In this case you will not be added to the channel right away but instead receive a [ChatClient.onChannelInvited] callback.
  /// You accept the invitation by calling [Channel.join] or decline it by calling [Channel.declineInvitation].
  Future<void> join() async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#join', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Leave this channel.
  Future<void> leave() async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#leave', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Indicate that Member is typing in this channel.
  ///
  /// You should call this method to indicate that a local user is entering a message into current channel. The typing state is forwarded to users subscribed to this channel through [Channel.onTypingStarted] and [Channel.onTypingEnded] callbacks.
  /// After approximately 5 seconds after the last [Channel.typing] call the SDK will emit [Channel.onTypingEnded] signal.
  /// One common way to implement this indicator is to call [Channel.typing] repeatedly in response to key input events.
  Future<void> typing() async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#typing', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Decline an invite to this channel.
  ///
  /// If a user is invited to the channel, they can choose to either [Channel.join] the channel to accept the invitation or [Channel.declineInvitation] to decline.
  Future<void> declineInvitation() async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#declineInvitation', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Destroy this channel.
  ///
  /// Note: this will delete the [Channel] and all associated metadata from the service instance. [Members] in the channel and all channel messages, including posted media will be lost.
  /// There is no undo for this operation!
  Future<void> destroy() async {
    try {
      await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#destroy', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get total number of messages in the channel.
  //
  /// This method is semi-realtime. This means that this data will be eventually correct, but will also possibly be incorrect for a few seconds.
  /// The Chat system does not provide real time events for counter values changes.
  ///
  /// So this is quite useful for any UI badges, but is not recommended to build any core application logic based on these counters being accurate in real time.
  ///
  /// This function performs an async call to service to obtain up-to-date message count.
  /// The retrieved value is then cached for 5 seconds so there is no reason to call this function more often than once in 5 seconds.
  Future<int> getMessagesCount() async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getMessagesCount', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get number of unconsumed messages in the channel.
  ///
  /// This method is semi-realtime. This means that this data will be eventually correct, but will also possibly be incorrect for a few seconds.
  /// The Chat system does not provide real time events for counter values changes.
  ///
  /// So this is quite useful for any “unread messages count” badges, but is not recommended to build any core application logic based on these counters being accurate in real time.
  ///
  /// This function performs an async call to service to obtain up-to-date message count.
  /// The retrieved value is then cached for 5 seconds so there is no reason to call this function more often than once in 5 seconds.
  Future<int> getUnconsumedMessagesCount() async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getUnconsumedMessagesCount', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get total number of members in the channel roster.
  ///
  /// This method is semi-realtime. This means that this data will be eventually correct, but will also possibly be incorrect for a few seconds.
  /// The Chat system does not provide real time events for counter values changes.
  ///
  /// So this is quite useful for any UI badges, but is not recommended to build any core application logic based on these counters being accurate in real time.
  ///
  /// This function performs an async call to service to obtain up-to-date member count.
  /// The retrieved value is then cached for 5 seconds so there is no reason to call this function more often than once in 5 seconds.
  Future<int> getMembersCount() async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getMembersCount', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set attributes associated with this channel.
  ///
  /// Attributes are stored as a JSON format object, of arbitrary internal structure. Channel attributes are limited in size to 32Kb.
  /// Passing null attributes will reset channel attributes string to empty.
  Future<Map<String, dynamic>> setAttributes(Map<String, dynamic> attributes) async {
    try {
      return Map<String, dynamic>.from(await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#setAttributes', {'channelSid': _sid, 'attributes': attributes}));
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get friendly name of the channel.
  ///
  /// Friendly name is a free-form text string, it is not unique and could be used for user-friendly channel name display in the UI.
  Future<String?> getFriendlyName() async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getFriendlyName', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Update the friendly name for this channel.
  Future<String?> setFriendlyName(String friendlyName) async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#setFriendlyName', {'channelSid': _sid, 'friendlyName': friendlyName});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// The current user's notification level on this channel.
  ///
  /// This property reflects whether the user will receive push notifications for activity on this channel.
  Future<NotificationLevel?> getNotificationLevel() async {
    try {
      return EnumToString.fromString(NotificationLevel.values, await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getNotificationLevel', {'channelSid': _sid}));
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Set the user's notification level for the channel.
  ///
  /// This property determines whether the user will receive push notifications for activity on this channel.
  Future<NotificationLevel?> setNotificationLevel(NotificationLevel notificationLevel) async {
    try {
      return EnumToString.fromString(
        NotificationLevel.values,
        await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#setNotificationLevel', {
          'channelSid': _sid,
          'notificationLevel': EnumToString.convertToString(notificationLevel),
        }),
      );
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get unique name of the channel.
  ///
  /// Unique name is similar to SID but can be specified by the user.
  Future<String?> getUniqueName() async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#getUniqueName', {'channelSid': _sid});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Update the unique name for this channel.
  ///
  /// Unique name is unique within Service Instance. You will receive an error if you try to set a name that is not unique.
  Future<String?> setUniqueName(String uniqueName) async {
    try {
      return await TwilioProgrammableChat._methodChannel.invokeMethod('Channel#setUniqueName', {'channelSid': _sid, 'uniqueName': uniqueName});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update _isSubscribed
  void _setSubscribed(bool subscribed) {
    _isSubscribed = subscribed;
  }

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _synchronizationStatus = EnumToString.fromString(ChannelSynchronizationStatus.values, map['synchronizationStatus']) ?? ChannelSynchronizationStatus.NONE;
    if (_synchronizationStatus == ChannelSynchronizationStatus.ALL) {
      _hasSynchronized = true;
    }

    if (map['messages'] != null) {
      final messagesMap = Map<String, dynamic>.from(map['messages']);
      _messages._updateFromMap(messagesMap);
    }

    if (map['attributes'] != null) {
      _attributes = Attributes.fromMap(map['attributes'].cast<String, dynamic>());
    }

    if (map['type'] != null) {
      final type = EnumToString.fromString(ChannelType.values, map['type']);
      if (type != null) {
        _type = type;
      }
    }

    _status = EnumToString.fromString(ChannelStatus.values, map['status']) ?? ChannelStatus.UNKNOWN;

    _createdBy ??= map['createdBy'];
    _dateCreated ??= map['dateCreated'] != null ? DateTime.parse(map['dateCreated']) : null;
    _dateUpdated = map['dateUpdated'] != null ? DateTime.parse(map['dateUpdated']) : null;
    _lastMessageDate = map['lastMessageDate'] != null ? DateTime.parse(map['lastMessageDate']) : null;
    _lastMessageIndex = map['lastMessageIndex'];
  }

  /// Parse native channel events to the right event streams.
  void _parseEvents(dynamic event) {
    final String? eventName = event['name'];
    if (eventName == null) {
      return;
    }
    TwilioProgrammableChat._log("Channel => Event '$eventName' => ${event["data"]}, error: ${event["error"]}");
    final data = Map<String, dynamic>.from(event['data']);

    if (data['channel'] != null) {
      final channelMap = Map<String, dynamic>.from(data['channel']);
      _updateFromMap(channelMap);
    }

    Message? message;
    if (data['message'] != null) {
      final messageMap = Map<String, dynamic>.from(data['message'] as Map<dynamic, dynamic>);
      // TODO(WLFN): should we cache this so we can just use references?
      message = Message._fromMap(messageMap, messages);
    }

    Member? member;
    if (data['member'] != null) {
      final memberMap = Map<String, dynamic>.from(data['member'] as Map<dynamic, dynamic>);
      // TODO(WLFN): should we cache this so we can just use references?
      member = Member._fromMap(memberMap);
    }

    dynamic reason;
    if (data['reason'] != null) {
      final reasonMap = Map<String, dynamic>.from(data['reason'] as Map<dynamic, dynamic>);
      switch (reasonMap['type']) {
        case 'message':
          reason = EnumToString.fromString(MessageUpdateReason.values, reasonMap['value']);
          break;
        case 'member':
          reason = EnumToString.fromString(MemberUpdateReason.values, reasonMap['value']);
          break;
      }
    }

    switch (eventName) {
      case 'messageAdded':
        if (message != null) {
          _onMessageAddedCtrl.add(message);
        } else {
          TwilioProgrammableChat._log("Channel => case 'messageAdded' => Attempting to operate on NULL.");
        }
        break;
      case 'messageUpdated':
        if (message != null && reason != null) {
          _onMessageUpdatedCtrl.add(MessageUpdatedEvent(message, reason));
        } else {
          TwilioProgrammableChat._log("Channel => case 'messageUpdated' => message: $message, reason: $reason");
        }
        break;
      case 'messageDeleted':
        if (message != null) {
          _onMessageDeletedCtrl.add(message);
        } else {
          TwilioProgrammableChat._log("Channel => case 'messageDeleted' => Attempting to operate on NULL.");
        }
        break;
      case 'memberAdded':
        if (member != null) {
          _onMemberAddedCtrl.add(member);
        } else {
          TwilioProgrammableChat._log("Channel => case 'memberAdded' => Attempting to operate on NULL.");
        }
        break;
      case 'memberUpdated':
        if (member != null && reason != null) {
          _onMemberUpdatedCtrl.add(MemberUpdatedEvent(member, reason));
        } else {
          TwilioProgrammableChat._log("Channel => case 'memberUpdated' => member: $member, reason: $reason");
        }
        break;
      case 'memberDeleted':
        if (member != null) {
          _onMemberDeletedCtrl.add(member);
        } else {
          TwilioProgrammableChat._log("Channel => case 'memberDeleted' => Attempting to operate on NULL.");
        }
        break;
      case 'typingStarted':
        if (member != null) {
          _onTypingStartedCtrl.add(TypingEvent(this, member));
        } else {
          TwilioProgrammableChat._log("Channel => case 'typingStarted' => Attempting to operate on NULL.");
        }
        break;
      case 'typingEnded':
        if (member != null) {
          _onTypingEndedCtrl.add(TypingEvent(this, member));
        } else {
          TwilioProgrammableChat._log("Channel => case 'typingEnded' => Attempting to operate on NULL.");
        }
        break;
      case 'synchronizationChanged':
        _onSynchronizationChangedCtrl.add(this);
        break;
      default:
        TwilioProgrammableChat._log("Event '$eventName' not yet implemented");
        break;
    }
  }
}
