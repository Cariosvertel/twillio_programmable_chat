part of twilio_programmable_chat;

//#region ChatClient events
class ChannelUpdatedEvent {
  final Channel channel;

  final ChannelUpdateReason reason;

  ChannelUpdatedEvent(this.channel, this.reason);
}

class UserUpdatedEvent {
  final User user;

  final UserUpdateReason reason;

  UserUpdatedEvent(this.user, this.reason);
}

class NewMessageNotificationEvent {
  final String channelSid;

  final String messageSid;

  final int messageIndex;

  NewMessageNotificationEvent(this.channelSid, this.messageSid, this.messageIndex);
}

class NotificationRegistrationEvent {
  final bool? isSuccessful;

  final ErrorInfo? error;

  NotificationRegistrationEvent(this.isSuccessful, this.error);
}
//#endregion
