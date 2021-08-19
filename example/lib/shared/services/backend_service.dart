import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/services.dart';
import 'package:twilio_programmable_chat_example/models/twilio_chat_token_request.dart';
import 'package:twilio_programmable_chat_example/models/twilio_chat_token_response.dart';

abstract class BackendService {
  Future<TwilioChatTokenResponse> createToken(TwilioChatTokenRequest twilioChatTokenRequest);
}

class TwilioFirebaseFunctions implements BackendService {
  TwilioFirebaseFunctions._();

  static final instance = TwilioFirebaseFunctions._();

  @override
  Future<TwilioChatTokenResponse> createToken(TwilioChatTokenRequest twilioChatTokenRequest) async {
    try {
      final response = await FirebaseFunctions.instance.httpsCallable('createToken').call(twilioChatTokenRequest.toMap());
      return TwilioChatTokenResponse.fromMap(Map<String, dynamic>.from(response.data));
    } on FirebaseFunctionsException catch (e) {
      throw PlatformException(
        code: e.code,
        message: e.message,
        details: e.details,
      );
    }
  }
}
