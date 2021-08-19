import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/chat/chat_model.dart';

class ChatBloc {
  final String myIdentity;
  final ChatClient chatClient;

  late BehaviorSubject<ChatModel> _channelDescriptorController;
  ValueStream<ChatModel> get channelDescriptorStream => _channelDescriptorController.stream;
  final List<StreamSubscription> _subscriptions = <StreamSubscription>[];
  final List<StreamSubscription> _channelSubscriptions = <StreamSubscription>[];
  Map<String, int?> unreadMessagesMap = {};
  Map<String, ChannelStatus> channelStatusMap = {};

  ChatBloc({required this.myIdentity, required this.chatClient}) {
    _channelDescriptorController = BehaviorSubject<ChatModel>();
    _subscriptions.add(chatClient.onChannelAdded.listen((event) {
      print('ChatBloc => chatClient.onChannelAdded => $event');
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelDeleted.listen((event) {
      print('ChatBloc => chatClient.onChannelDeleted => $event');
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelUpdated.listen((event) {
      print('ChatBloc => chatClient.onChannelUpdated => $event');
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelSynchronizationChange.listen((event) {
      print('ChatBloc => chatClient.onChannelSynchronizationChange => $event');
      retrieve();
    }));
    _subscriptions.add(chatClient.onChannelInvited.listen((event) {
      print('ChatBloc => chatClient.onChannelInvited => $event');
      retrieve();
    }));
    _subscriptions.add(chatClient.onNotificationRegistered.listen((event) {
      print('ChatBloc => chatClient.onNotificationRegistered => $event');
      // Do things
    }));
    _subscriptions.add(chatClient.onNotificationDeregistered.listen((event) {
      print('ChatBloc => chatClient.onNotificationDeregistered => $event');
      // Do things
    }));
    _subscriptions.add(chatClient.onNotificationFailed.listen((event) {
      print('ChatBloc => chatClient.onNotificationFailed => $event');
      // Do things
    }));
  }

  Future addChannel(String channelName, ChannelType type) async {
    _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
    final channel = await chatClient.channels.createChannel(channelName, type);
    if (channel != null) await retrieve();
  }

  Future joinChannel(Channel channel) async {
    channel.onSynchronizationChanged.listen((event) {
      retrieve();
    });
    await channel.join();
  }

  Future retrieve() async {
    _channelDescriptorController.add(ChatModel(isLoading: true));
    _channelSubscriptions.forEach((sub) => sub.cancel());
    _channelSubscriptions.clear();
    unreadMessagesMap.clear();

    // TODO: Handle pagination, don't litter
    final userChannelPaginator = await chatClient.channels.getUserChannelsList();
    final publicChannelPaginator = await chatClient.channels.getPublicChannelsList();

    for (var channelDescriptor in userChannelPaginator.items) {
      final channel = await channelDescriptor.getChannel();
      if (channel == null) {
        continue;
      }
      await _updateUnreadMessageCountForChannel(channelDescriptor);
      channelStatusMap[channel.sid] = channel.status;

      _channelSubscriptions.add(channel.onMemberAdded.listen((event) {
        retrieve();
      }));
      _channelSubscriptions.add(channel.onMemberDeleted.listen((event) {
        retrieve();
      }));
    }

    for (var channelDescriptor in publicChannelPaginator.items) {
      final channel = await channelDescriptor.getChannel();
      if (channel == null) {
        continue;
      }
      await _updateUnreadMessageCountForChannel(channelDescriptor);
      channelStatusMap[channel.sid] = channel.status;

      _channelSubscriptions.add(channel.onMemberAdded.listen((event) {
        retrieve();
      }));
      _channelSubscriptions.add(channel.onMemberDeleted.listen((event) {
        retrieve();
      }));
    }
    _channelDescriptorController.add(ChatModel(publicChannels: publicChannelPaginator.items, userChannels: userChannelPaginator.items));
  }

  Future registerForNotifications() async {
    var token;
    if (Platform.isAndroid) {
      token = await FirebaseMessaging.instance.getToken();
    }
    await chatClient.registerForNotification(token);
  }

  Future unregisterForNotifications() async {
    var token;
    if (Platform.isAndroid) {
      token = await FirebaseMessaging.instance.getToken();
    }
    await chatClient.unregisterForNotification(token);
  }

  Future _updateUnreadMessageCountForChannel(ChannelDescriptor channelDescriptor) async {
    final userHasJoined = (await channelDescriptor.status) == ChannelStatus.JOINED;
    if (!userHasJoined) {
      unreadMessagesMap[channelDescriptor.sid] = channelDescriptor.messagesCount;
    } else {
      unreadMessagesMap[channelDescriptor.sid] = await channelDescriptor.unconsumedMessagesCount;
    }
  }

  Future destroyChannel(ChannelDescriptor channelDescriptor) async {
    try {
      _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
      final channel = await channelDescriptor.getChannel();
      if (channel != null) {
        await channel.destroy();
        await retrieve();
      }
    } catch (e) {
      _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: false));
    }
  }

  Future updateChannel(ChannelDescriptor channelDescriptor, String name) async {
    _channelDescriptorController.add(channelDescriptorStream.value.copyWith(isLoading: true));
    final channel = await channelDescriptor.getChannel();
    if (channel != null) {
      await channel.setFriendlyName(name);
      await retrieve();
    }
  }

  void dispose() {
    _channelDescriptorController.close();
    _subscriptions.forEach((sub) => sub.cancel());
    _subscriptions.clear();
  }
}
