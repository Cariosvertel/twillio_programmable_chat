import Flutter
import Foundation
import TwilioChatClient

public class ChatClientMethods {
    public static func updateToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any?] else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing parameters", details: nil))
        }

        guard let token = arguments["token"] as? String else {
            return result(FlutterError(code: "MISSING_PARAMS", message: "Missing 'token' parameter", details: nil))
        }

        let flutterResult = result
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.updateToken(token, completion: {(result: TCHResult) -> Void in
            if result.isSuccessful() {
                SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onSuccess")
                flutterResult(nil)
            } else {
                if let error = result.error as NSError? {
                    SwiftTwilioProgrammableChatPlugin.debug("ChatClientMethods.updateToken => onError: \(error)")
                    flutterResult(FlutterError(code: "\(error.code)", message: "\(error.description)", details: nil))
                }
            }
            } as TCHCompletion)
    }

    public static func shutdown(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        SwiftTwilioProgrammableChatPlugin.chatListener?.chatClient?.shutdown()
        disposeListeners()
        result(nil)
    }

    private static func disposeListeners() {
        SwiftTwilioProgrammableChatPlugin.chatListener = nil
        SwiftTwilioProgrammableChatPlugin.channelListeners.removeAll()
    }
}
