import Flutter
import TwilioChatClient

public class ChannelListener: NSObject, TCHChannelDelegate {
    let channelSid: String

    init(_ channelSid: String) {
        self.channelSid = channelSid
    }

    // onMessageAdded
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageAdded message: TCHMessage) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageAdded => messageSid = \(String(describing: message.sid))")
        sendEvent("messageAdded", data: [
            "channelSid": channelSid,
            "message": Mapper.messageToDict(message, channelSid: channel.sid)
        ])
    }

    // onMessageUpdated
    public func chatClient(
        _ client: TwilioChatClient, channel: TCHChannel, message: TCHMessage, updated: TCHMessageUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageUpdated => messageSid = \(String(describing: message.sid)), " +
            "updated = \(String(describing: updated))")
        sendEvent("messageUpdated", data: [
            "channelSid": channelSid,
            "message": Mapper.messageToDict(message, channelSid: channel.sid),
            "reason": [
                "type": "message",
                "value": Mapper.messageUpdateToString(updated)
            ]
        ])
    }

    // onMessageDeleted
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, messageDeleted message: TCHMessage) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMessageDeleted => messageSid = \(String(describing: message.sid))")
        sendEvent("messageDeleted", data: [
            "channelSid": channelSid,
            "message": Mapper.messageToDict(message, channelSid: channel.sid)
        ])
    }

    // onMemberAdded
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberJoined member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberAdded => memberSid = \(String(describing: member.sid))")
        sendEvent("memberAdded", data: [
            "channelSid": channelSid,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onMemberUpdated
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                           member: TCHMember, updated: TCHMemberUpdate) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberUpdated => memberSid = \(String(describing: member.sid)), " +
            "updated = \(String(describing: updated))")
        sendEvent("memberUpdated", data: [
            "channelSid": channelSid,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any,
            "reason": [
                "type": "member",
                "value": Mapper.memberUpdateToString(updated)
            ]
        ])
    }

    // onMemberDeleted
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel, memberLeft member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onMemberDeleted => memberSid = \(String(describing: member.sid))")
        sendEvent("memberDeleted", data: [
            "channelSid": channelSid,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onTypingStarted
    public func chatClient(_ client: TwilioChatClient, typingStartedOn channel: TCHChannel, member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onTypingStarted => channelSid = \(String(describing: channel.sid)), " +
            "memberSid = \(String(describing: member.sid))")
        sendEvent("typingStarted", data: [
            "channelSid": channelSid,
            "channel": Mapper.channelToDict(channel) as Any,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onTypingEnded
    public func chatClient(_ client: TwilioChatClient, typingEndedOn channel: TCHChannel, member: TCHMember) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onTypingEnded => channelSid = \(String(describing: channel.sid)), " +
            "memberSid = \(String(describing: member.sid))")
        sendEvent("typingEnded", data: [
            "channelSid": channelSid,
            "channel": Mapper.channelToDict(channel) as Any,
            "member": Mapper.memberToDict(member, channelSid: channel.sid) as Any
        ])
    }

    // onSynchronizationChanged
    public func chatClient(_ client: TwilioChatClient, channel: TCHChannel,
                           synchronizationStatusUpdated status: TCHChannelSynchronizationStatus) {
        SwiftTwilioProgrammableChatPlugin.debug(
            "ChannelListener.onSynchronizationChanged => channelSid = \(String(describing: channel.sid))")
        sendEvent("synchronizationChanged", data: [
            "channelSid": channelSid,
            "channel": Mapper.channelToDict(channel) as Any
        ])
    }

    private func sendEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = [
            "name": name,
            "data": data,
            "error": Mapper.errorToDict(error)
            ] as [String: Any?]

        if let events = SwiftTwilioProgrammableChatPlugin.channelEventSink {
            events(eventData)
        }
    }
}
