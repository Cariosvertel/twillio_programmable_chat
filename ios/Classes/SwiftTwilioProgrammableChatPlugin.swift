import Flutter
import UIKit
import TwilioChatClient

public class SwiftTwilioProgrammableChatPlugin: NSObject, FlutterPlugin {
    public static var loggingSink: FlutterEventSink?

    public static var notificationSink: FlutterEventSink?

    public static var nativeDebug = false

    public static var messenger: FlutterBinaryMessenger?

    public static var chatListener: ChatListener?

    public static var channelEventSink: FlutterEventSink?

    public static var channelListeners: [String: ChannelListener] = [:]

    public static var mediaProgressSink: FlutterEventSink?

    public static var reasonForTokenRetrieval: String?

    public static var instance: SwiftTwilioProgrammableChatPlugin?

    public static func debug(_ msg: String) {
        if SwiftTwilioProgrammableChatPlugin.nativeDebug {
            NSLog(msg)
            guard let loggingSink = loggingSink else {
                return
            }
            loggingSink(msg)
        }
    }

    private var methodChannel: FlutterMethodChannel?

    private var chatChannel: FlutterEventChannel?

    private var channelEventChannel: FlutterEventChannel?

    private var mediaProgressChannel: FlutterEventChannel?

    private var loggingChannel: FlutterEventChannel?

    private var notificationChannel: FlutterEventChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        instance = SwiftTwilioProgrammableChatPlugin()
        instance?.onRegister(registrar)
    }

    public func onRegister(_ registrar: FlutterPluginRegistrar) {
        SwiftTwilioProgrammableChatPlugin.messenger = registrar.messenger()
        let pluginHandler = PluginHandler()
        methodChannel = FlutterMethodChannel(name: "twilio_programmable_chat", binaryMessenger: registrar.messenger())
        methodChannel?.setMethodCallHandler(pluginHandler.handle)

        chatChannel = FlutterEventChannel(name: "twilio_programmable_chat/chat", binaryMessenger: registrar.messenger())
        chatChannel?.setStreamHandler(ChatStreamHandler())

        channelEventChannel = FlutterEventChannel(name: "twilio_programmable_chat/channel", binaryMessenger: registrar.messenger())
        channelEventChannel?.setStreamHandler(ChannelStreamHandler())

        mediaProgressChannel = FlutterEventChannel(
            name: "twilio_programmable_chat/media_progress", binaryMessenger: registrar.messenger())
        mediaProgressChannel?.setStreamHandler(MediaProgressStreamHandler())

        loggingChannel = FlutterEventChannel(
            name: "twilio_programmable_chat/logging", binaryMessenger: registrar.messenger())
        loggingChannel?.setStreamHandler(LoggingStreamHandler())

        notificationChannel = FlutterEventChannel(
            name: "twilio_programmable_chat/notification", binaryMessenger: registrar.messenger())
        notificationChannel?.setStreamHandler(NotificationStreamHandler())

        registrar.addApplicationDelegate(self)
    }

    public func registerForNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted: Bool, _: Error?) in
                SwiftTwilioProgrammableChatPlugin.debug("User responded to permissions request: \(granted)")
                if granted {
                    DispatchQueue.main.async {
                        SwiftTwilioProgrammableChatPlugin.debug("Requesting APNS token")
                        SwiftTwilioProgrammableChatPlugin.reasonForTokenRetrieval = "register"
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        }
        result(nil)
    }

    public func unregisterForNotification(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if #available(iOS 10.0, *) {
            DispatchQueue.main.async {
                SwiftTwilioProgrammableChatPlugin.debug("Requesting APNS token")
                SwiftTwilioProgrammableChatPlugin.reasonForTokenRetrieval = "deregister"
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
        result(nil)
    }

    public func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        SwiftTwilioProgrammableChatPlugin.debug("didRegisterForRemoteNotificationsWithDeviceToken => onSuccess: \((deviceToken as NSData).description)")
        if let reason = SwiftTwilioProgrammableChatPlugin.reasonForTokenRetrieval {
            if reason == "register" {
                SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.register(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                    SwiftTwilioProgrammableChatPlugin.debug("registered for notifications: \(result.isSuccessful())")
                    SwiftTwilioProgrammableChatPlugin.sendNotificationEvent("registered", data: ["result": result.isSuccessful()], error: result.error)
                })
            } else {
                SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.deregister(withNotificationToken: deviceToken, completion: { (result: TCHResult) in
                    SwiftTwilioProgrammableChatPlugin.debug("deregistered for notifications: \(result.isSuccessful())")
                    SwiftTwilioProgrammableChatPlugin.sendNotificationEvent("deregistered", data: ["result": result.isSuccessful()], error: result.error)
                })
            }
        }
    }

    public func application(_ application: UIApplication,
                            didFailToRegisterForRemoteNotificationsWithError
        error: Error) {
        SwiftTwilioProgrammableChatPlugin.debug("didFailToRegisterForRemoteNotificationsWithError => onFail")
        SwiftTwilioProgrammableChatPlugin.sendNotificationEvent("registered", data: ["result": false], error: error)
    }

    private static func sendNotificationEvent(_ name: String, data: [String: Any]? = nil, error: Error? = nil) {
        let eventData = ["name": name, "data": data, "error": Mapper.errorToDict(error)] as [String: Any?]

        if let notificationSink = SwiftTwilioProgrammableChatPlugin.notificationSink {
            notificationSink(eventData)
        }
    }

    class ChatStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            guard let chatListener = SwiftTwilioProgrammableChatPlugin.chatListener else { return nil }
            SwiftTwilioProgrammableChatPlugin.debug("ChatStreamHandler.onListen => Chat eventChannel attached")
            chatListener.events = events
            chatListener.chatClient?.delegate = chatListener
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("ChatStreamHandler.onCancel => Chat eventChannel detached")
            guard let chatListener = SwiftTwilioProgrammableChatPlugin.chatListener else { return nil }
            chatListener.events = nil
            return nil
        }
    }

    class ChannelStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("ChannelStreamHandler.onListen => Channel eventChannel attached")
            channelEventSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("ChannelStreamHandler.onCancel => Channel eventChannel detached")
            channelEventSink = nil
            return nil
        }
    }

    class MediaProgressStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            debug("MediaProgressStreamHandler.onListen => MediaProgress eventChannel attached")
            SwiftTwilioProgrammableChatPlugin.mediaProgressSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            debug("MediaProgressStreamHandler.onCancel => MediaProgress eventChannel detached")
            SwiftTwilioProgrammableChatPlugin.mediaProgressSink = nil
            return nil
        }
    }

    class LoggingStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("LoggingStreamHandler.onListen => Logging eventChannel attached")
            SwiftTwilioProgrammableChatPlugin.loggingSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("LoggingStreamHandler.onCancel => Logging eventChannel detached")
            SwiftTwilioProgrammableChatPlugin.loggingSink = nil
            return nil
        }
    }

    class NotificationStreamHandler: NSObject, FlutterStreamHandler {
        func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("NotificationStreamHandler.onListen => Notification eventChannel attached")
            SwiftTwilioProgrammableChatPlugin.notificationSink = events
            return nil
        }

        func onCancel(withArguments arguments: Any?) -> FlutterError? {
            SwiftTwilioProgrammableChatPlugin.debug("NotificationStreamHandler.onCancel => Notification eventChannel detached")
            SwiftTwilioProgrammableChatPlugin.notificationSink = nil
            return nil
        }
    }
}
