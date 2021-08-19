package twilio.flutter.twilio_programmable_chat

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import com.twilio.chat.ChatClient
import com.twilio.chat.ErrorInfo
import com.twilio.chat.StatusListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry.Registrar
import twilio.flutter.twilio_programmable_chat.listeners.ChannelListener
import twilio.flutter.twilio_programmable_chat.listeners.ChatListener

/** TwilioProgrammableChatPlugin */
class TwilioProgrammableChatPlugin : FlutterPlugin {
    private lateinit var methodChannel: MethodChannel

    private lateinit var chatChannel: EventChannel

    private lateinit var channelEventChannel: EventChannel

    private lateinit var mediaProgressChannel: EventChannel

    private lateinit var loggingChannel: EventChannel

    private lateinit var notificationChannel: EventChannel

    // This static function is optional and equivalent to onAttachedToEngine. It supports the old
    // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
    // plugin registration via this function while apps migrate to use the new Android APIs
    // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
    //
    // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
    // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
    // depending on the user's project. onAttachedToEngine or registerWith must both be defined
    // in the same class.
    companion object {
        @Suppress("unused")
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            instance = TwilioProgrammableChatPlugin()
            instance.onAttachedToEngine(registrar.context(), registrar.messenger())
        }

        lateinit var messenger: BinaryMessenger

        @JvmStatic
        lateinit var instance: TwilioProgrammableChatPlugin

        @JvmStatic
        var chatClient: ChatClient? = null

        val LOG_TAG = "Twilio_PChat"

        var mediaProgressSink: EventChannel.EventSink? = null

        var loggingSink: EventChannel.EventSink? = null

        var notificationSink: EventChannel.EventSink? = null

        var handler = Handler(Looper.getMainLooper())

        var nativeDebug: Boolean = false

        var chatListener: ChatListener? = null

        var channelListeners: HashMap<String, ChannelListener> = hashMapOf()

        var channelEventSink: EventChannel.EventSink? = null

        @JvmStatic
        fun debug(msg: String) {
            if (nativeDebug) {
                Log.d(LOG_TAG, msg)
                handler.post(Runnable {
                    loggingSink?.success(msg)
                })
            }
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        instance = this
        onAttachedToEngine(binding.applicationContext, binding.binaryMessenger)
    }

    private fun onAttachedToEngine(applicationContext: Context, messenger: BinaryMessenger) {
        TwilioProgrammableChatPlugin.messenger = messenger
        val pluginHandler = PluginHandler(applicationContext)
        methodChannel = MethodChannel(messenger, "twilio_programmable_chat")
        methodChannel.setMethodCallHandler(pluginHandler)

        chatChannel = EventChannel(messenger, "twilio_programmable_chat/chat")
        chatChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Chat eventChannel attached")
                chatListener?.events = events
                chatClient?.setListener(chatListener)
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Chat eventChannel detached")
                chatListener?.events = null
            }
        })

        channelEventChannel = EventChannel(messenger, "twilio_programmable_chat/channel")
        channelEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Channel eventChannel attached")
                channelEventSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Channel eventChannel detached")
                channelEventSink = null
            }
        })

        mediaProgressChannel = EventChannel(messenger, "twilio_programmable_chat/media_progress")
        mediaProgressChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => MediaProgress eventChannel attached")
                mediaProgressSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => MediaProgress eventChannel detached")
                mediaProgressSink = null
            }
        })

        loggingChannel = EventChannel(messenger, "twilio_programmable_chat/logging")
        loggingChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Logging eventChannel attached")
                loggingSink = events
            }

            override fun onCancel(arguments: Any?) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Logging eventChannel detached")
                loggingSink = null
            }
        })

        notificationChannel = EventChannel(messenger, "twilio_programmable_chat/notification")
        notificationChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Notification eventChannel attached")
                notificationSink = events
            }

            override fun onCancel(arguments: Any) {
                debug("TwilioProgrammableChatPlugin.onAttachedToEngine => Notification eventChannel detached")
                notificationSink = null
            }
        })
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        debug("TwilioProgrammableChatPlugin.onDetachedFromEngine")
        methodChannel.setMethodCallHandler(null)
        chatChannel.setStreamHandler(null)
        loggingChannel.setStreamHandler(null)
        notificationChannel.setStreamHandler(null)
        mediaProgressChannel.setStreamHandler(null)
    }

    fun registerForNotification(call: MethodCall, result: MethodChannel.Result) {
        val token: String = call.argument<String>("token")
                ?: return result.error("MISSING_PARAMS", "The parameter 'token' was not given", null)

        chatClient?.registerFCMToken(ChatClient.FCMToken(token), object : StatusListener() {
            override fun onSuccess() {
                debug("TwilioProgrammableChatPlugin.registerForNotification => registered with FCM $token")
                sendNotificationEvent("registered", mapOf("result" to true))
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo?) {
                debug("TwilioProgrammableChatPlugin.registerForNotification => failed to register with FCM")
                super.onError(errorInfo)
                sendNotificationEvent("registered", mapOf("result" to false), errorInfo)
                result.error("FAILED", "Failed to register for FCM notifications", errorInfo)
            }
        })
    }

    fun unregisterForNotification(call: MethodCall, result: MethodChannel.Result) {
        val token: String = call.argument<String>("token")
                ?: return result.error("MISSING_PARAMS", "The parameter 'token' was not given", null)

        chatClient?.unregisterFCMToken(ChatClient.FCMToken(token), object : StatusListener() {
            override fun onSuccess() {
                debug("TwilioProgrammableChatPlugin.unregisterForNotification => unregistered with FCM $token")
                sendNotificationEvent("deregistered", mapOf("result" to true))
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo?) {
                debug("TwilioProgrammableChatPlugin.unregisterForNotification => failed to unregister with FCM")
                super.onError(errorInfo)
                sendNotificationEvent("deregistered", mapOf("result" to false), errorInfo)
                result.error("FAILED", "Failed to unregister for FCM notifications", errorInfo)
            }
        })
    }

    private fun sendNotificationEvent(name: String, data: Any?, e: ErrorInfo? = null) {
        val eventData = mapOf("name" to name, "data" to data, "error" to Mapper.errorInfoToMap(e))
        notificationSink?.success(eventData)
    }
}
