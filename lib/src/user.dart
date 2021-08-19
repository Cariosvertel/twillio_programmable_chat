part of twilio_programmable_chat;

class User {
  //#region Private API properties
  String? _friendlyName;

  Attributes _attributes;

  final String _identity;

  bool _isOnline = false;

  bool _isNotifiable = false;

  bool _isSubscribed = false;
  //#endregion

  //#region Public API properties
  /// Method that returns the friendlyName from the user info.
  String? get friendlyName {
    return _friendlyName;
  }

  /// Returns the identity of the user.
  String get identity {
    return _identity;
  }

  /// Return user's online status, if available,
  // TODO(WLFN): Should probaly be a async method for real time
  bool get isOnline {
    return _isOnline;
  }

  /// Return user's push reachability.
  // TODO(WLFN): Should probaly be a async method for real time
  bool get isNotifiable {
    return _isNotifiable;
  }

  /// Check if this user receives real-time status updates.
  bool get isSubscribed {
    return _isSubscribed;
  }

  /// Get attributes map
  Attributes get attributes {
    return _attributes;
  }
  //#endregion

  User(this._identity, this._attributes);

  /// Construct from a map.
  factory User._fromMap(Map<String, dynamic> map) {
    final user = User(
      map['identity'],
      map['attributes'] != null ? Attributes.fromMap(map['attributes'].cast<String, dynamic>()) : Attributes(AttributesType.NULL, null),
    );
    user._updateFromMap(map);
    return user;
  }

  //#region Public API methods
  Future<void> unsubscribe() async {
    try {
      // TODO(WLFN): It is still in the [Users.subscribedUsers] list...
      await TwilioProgrammableChat._methodChannel.invokeMethod('User#unsubscribe', {'identity': _identity});
    } on PlatformException catch (err) {
      throw TwilioProgrammableChat._convertException(err);
    }
  }
  //#endregion

  /// Update properties from a map.
  void _updateFromMap(Map<String, dynamic> map) {
    _friendlyName = map['friendlyName'];
    _isOnline = map['isOnline'] ?? false;
    _isNotifiable = map['isNotifiable'] ?? false;
    _isSubscribed = map['isSubscribed'] ?? false;
    _attributes = map['attributes'] != null ? Attributes.fromMap(map['attributes'].cast<String, dynamic>()) : _attributes;
  }
}
