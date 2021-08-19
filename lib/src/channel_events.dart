part of twilio_programmable_chat;

//#region Channel events
class MessageUpdatedEvent {
  final Message message;

  final MessageUpdateReason reason;

  MessageUpdatedEvent(this.message, this.reason);
}

class MemberUpdatedEvent {
  final Member member;

  final MemberUpdateReason reason;

  MemberUpdatedEvent(this.member, this.reason);
}

class TypingEvent {
  final Channel channel;

  final Member member;

  TypingEvent(this.channel, this.member);
}
//#endregion
