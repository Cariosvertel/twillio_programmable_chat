import 'dart:io';

import 'package:twilio_programmable_chat/twilio_programmable_chat.dart';

class MediaModel {
  bool isLoading;
  Message message;
  File? file;

  MediaModel({this.isLoading = false, required this.message, this.file});

  MediaModel copyWith({bool? isLoading, Message? message, File? file}) {
    return MediaModel(
      isLoading: isLoading ?? this.isLoading,
      message: message ?? this.message,
      file: file ?? this.file,
    );
  }
}
