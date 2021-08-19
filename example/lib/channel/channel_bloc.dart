import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';
import 'package:twilio_programmable_chat_example/channel/channel_model.dart';
import 'package:twilio_programmable_chat_example/channel/media_model.dart';

class ChannelBloc {
  late BehaviorSubject<ChannelModel> _messageSubject;
  late ValueStream<ChannelModel> messageStream;
  late BehaviorSubject<String?> _typingSubject;
  late ValueStream<String?> typingStream;
  late List<StreamSubscription> _subscriptions;
  Map<String?, BehaviorSubject<MediaModel>> mediaSubjects = <String?, BehaviorSubject<MediaModel>>{};

  TextEditingController messageController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  String myUsername;
  String? tempDirPath;
  ChatClient chatClient;
  ChannelDescriptor channelDescriptor;
  Channel? channel;

  ChannelBloc({required this.myUsername, required this.chatClient, required this.channelDescriptor}) {
    _messageSubject = BehaviorSubject<ChannelModel>();
    _messageSubject.add(ChannelModel());
    messageStream = _messageSubject.stream;
    _subscriptions = <StreamSubscription>[];
    _typingSubject = BehaviorSubject<String?>();
    typingStream = _typingSubject.stream;
    messageController.addListener(_onTyping);

    channelDescriptor.getChannel().then((channel) {
      this.channel = channel;
      _subscribeToChannel();
      channel?.getFriendlyName().then((friendlyName) {
        _messageSubject.add(
          _messageSubject.value.copyWith(friendlyName: friendlyName),
        );
      });
    });
  }

  Future _onTyping() async {
    await channel?.typing();
  }

  Future _subscribeToChannel() async {
    final uChannel = channel;
    if (uChannel == null) {
      return;
    }
    print('ChannelBloc::subscribeToChannel');
    if (uChannel.hasSynchronized) {
      await _getMessages(uChannel);
    }

    _subscriptions.add(uChannel.onSynchronizationChanged.listen((event) async {
      if (event.synchronizationStatus == ChannelSynchronizationStatus.ALL) {
        await _getMessages(event);
      }
    }));
    _subscriptions.add(uChannel.onMessageAdded.listen((Message message) {
      _messageSubject.add(_messageSubject.value.addMessage(message));
      if (message.hasMedia) {
        _getImage(message);
      }
    }));
    _subscriptions.add(uChannel.onTypingStarted.listen((TypingEvent event) {
      _typingSubject.add(event.member.identity);
    }));
    _subscriptions.add(uChannel.onTypingEnded.listen((TypingEvent event) {
      _typingSubject.add(null);
    }));
  }

  Future _getMessages(Channel channel) async {
    final friendlyName = await channel.getFriendlyName();
    final messageCount = await channel.getMessagesCount();
    final messages = await channel.messages.getLastMessages(messageCount);
    messages.where((message) => message.hasMedia).forEach(_getImage);
    _messageSubject.add(_messageSubject.value.copyWith(
      friendlyName: friendlyName,
      messages: messages,
    ));
    await _updateLastConsumedMessageIndex(channel, messages);
  }

  Future _updateLastConsumedMessageIndex(Channel channel, List<Message> messages) async {
    final lastConsumedMessageIndex = messages.isNotEmpty && messages.last.messageIndex != null ? messages.last.messageIndex : 0;
    await channel.messages.setLastConsumedMessageIndexWithResult(lastConsumedMessageIndex!);
  }

  Future sendMessage() async {
    final message = MessageOptions()
      ..withBody(messageController.text)
      ..withAttributes({'name': myUsername});
    await channel?.messages.sendMessage(message);
  }

  Future sendImage() async {
    final image = await _imagePicker.getImage(source: ImageSource.gallery);
    if (image != null) {
      final file = File(image.path);
      final mimeType = mime(image.path);
      if (mimeType != null) {
        final message = MessageOptions()
          ..withMedia(file, mimeType)
          ..withAttributes({'name': myUsername});
        await channel?.messages.sendMessage(message);
      }
    }
  }

  Future leaveChannel() async {
    final uChannel = channel;
    if (uChannel == null) {
      return;
    }
    if (uChannel.type == ChannelType.PUBLIC) {
      return uChannel.leave();
    } else {
      await uChannel.leave();
      return uChannel.destroy();
    }
  }

  Future _getImage(Message message) async {
    final uMessageMedia = message.media;
    if (uMessageMedia == null) {
      return;
    }
    final subject = BehaviorSubject<MediaModel>();
    subject.add(MediaModel(isLoading: true, message: message));
    mediaSubjects[message.sid] = subject;

    if (tempDirPath == null) {
      final tempDir = await getTemporaryDirectory();
      tempDirPath = tempDir.path;
    }
    final uFileName = uMessageMedia.fileName;
    final path = '$tempDirPath/'
        '${(uFileName != null && uFileName.isNotEmpty) ? uFileName : uMessageMedia.sid}.'
        '${extensionFromMime(uMessageMedia.type)}';
    final outputFile = File(path);

    await uMessageMedia.download(outputFile);
    subject.add(subject.value.copyWith(isLoading: false, file: outputFile));
  }

  Future dispose() async {
    await _messageSubject.close();
    _subscriptions.forEach((s) => s.cancel());
    _subscriptions.clear();
    messageController.removeListener(_onTyping);
  }
}
