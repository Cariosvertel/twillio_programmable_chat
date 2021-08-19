part of twilio_programmable_chat;

/// Provides access to users and allows to manipulate user information.
class Users {
  final List<User> _subscribedUsers = [];

  User? _myUser;

  /// Get a list of currently subscribed [User] objects.
  ///
  /// These objects receive status updates in real-time. When you subscribe to too many users simultaneously, the oldest subscribed users will be automatically unsubscribed.
  List<User> get subscribedUsers {
    return [..._subscribedUsers];
  }

  /// Get logged in [User] object.
  ///
  /// Returns the [User] object for your currently logged in [User]. You can query and update this object at will.
  User? get myUser {
    return _myUser;
  }

  Users();

  /// Get paginated user descriptors from a given channel.
  ///
  /// This is a convenience function allowing to query user list in a channel. The returned paginator can be used to iterate full user list in the channel roster.
  Future<Paginator<UserDescriptor>> getChannelUserDescriptors(String channelSid) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Users#getChannelUserDescriptors', {'channelSid': channelSid});
      final paginatorMap = Map<String, dynamic>.from(methodData);
      return Paginator<UserDescriptor>._fromMap(paginatorMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Get user descriptor based on user identity.
  Future<UserDescriptor> getUserDescriptor(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Users#getUserDescriptor', {'identity': identity});
      final userDescriptorMap = Map<String, dynamic>.from(methodData);
      return UserDescriptor._fromMap(userDescriptorMap);
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Retrieve user by id from the list of subscribe users
  User? getUserById(String id) {
    return subscribedUsers.firstWhereOrNull((u) => u.identity == id);
  }

  /// Get user based on user identity and subscribe to real-time updates for this user.
  ///
  /// There's a limit on the number of simultaneously subscribed objects in the SDK. This is to reduce consumed memory and network traffic.
  Future<User?> getAndSubscribeUser(String identity) async {
    try {
      final methodData = await TwilioProgrammableChat._methodChannel.invokeMethod('Users#getAndSubscribeUser', {'identity': identity});
      final userMap = Map<String, dynamic>.from(methodData);
      if (userMap['identity'] == null) {
        return null;
      }
      final user = _findOrCreateSubscribedUser(userMap);
      return user;
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    if (map['myUser'] != null) {
      final myUserMap = Map<String, dynamic>.from(map['myUser']);
      if (myUserMap['identity'] != null) {
        _myUser ??= User._fromMap(myUserMap);
        _myUser!._updateFromMap(myUserMap);
      }
    }
    if (map['subscribedUsers'] != null) {
      final List<Map<String, dynamic>> subscribedUsersList = map['subscribedUsers'].map<Map<String, dynamic>>((r) => Map<String, dynamic>.from(r)).toList();
      for (final subscribedUserMap in subscribedUsersList) {
        if (subscribedUserMap['identity'] != null) {
          _findOrCreateSubscribedUser(subscribedUserMap);
        }
      }
    }
  }

  User _findOrCreateSubscribedUser(Map<String, dynamic> map) {
    final subscribedUser = _subscribedUsers.firstWhere(
      (c) => c._identity == map['identity'],
      orElse: () => User._fromMap(map),
    );
    if (!_subscribedUsers.contains(subscribedUser)) {
      _subscribedUsers.add(subscribedUser);
    } else {
      subscribedUser._updateFromMap(map);
    }
    return subscribedUser;
  }
}
