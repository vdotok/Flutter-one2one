import 'dart:io';

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:uuid/uuid.dart';

void showCallkitIncoming() async {
  String _currentUuid = Uuid().v4();
  CallKitParams callKitParams = CallKitParams(
    id: _currentUuid,
    nameCaller: 'Hien Nguyen',
    appName: 'Callkit',
    avatar: 'https://i.pravatar.cc/100',
    handle: '0123456789',
    type: 0,
    textAccept: 'Accept',
    textDecline: 'Decline',
    duration: 30000,
    extra: <String, dynamic>{
      'callingData': {"isVideo": true},
      'userId': '1a2b3c4d'
    },
    headers: <String, dynamic>{'apiKey': 'Abc@123!', 'platform': 'flutter'},
    android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#0955fa',
        backgroundUrl: 'https://i.pravatar.cc/500',
        actionColor: '#4CAF50',
        incomingCallNotificationChannelName: "Incoming Call",
        missedCallNotificationChannelName: "Missed Call"),
    ios: IOSParams(
      iconName: 'CallKitLogo',
      handleType: 'generic',
      supportsVideo: true,
      maximumCallGroups: 2,
      maximumCallsPerCallGroup: 1,
      audioSessionMode: 'default',
      audioSessionActive: true,
      audioSessionPreferredSampleRate: 44100.0,
      audioSessionPreferredIOBufferDuration: 0.005,
      supportsDTMF: true,
      supportsHolding: true,
      supportsGrouping: false,
      supportsUngrouping: false,
      ringtonePath: 'system_ringtone_default',
    ),
  );
  await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
}

FlutterCallkitIncomingListeners() {
  FlutterCallkitIncoming.onEvent.listen((CallEvent? event) {
    if (event != null) {
      switch (event.event) {
        case Event.ACTION_CALL_INCOMING:
          // TODO: received an incoming call

          break;
        case Event.ACTION_CALL_START:
          // TODO: started an outgoing call
          // TODO: show screen calling in Flutter
          break;
        case Event.ACTION_CALL_ACCEPT:
          break;
        case Event.ACTION_CALL_DECLINE:
          // TODO: declined an incoming call

          break;
        case Event.ACTION_CALL_ENDED:
          // TODO: ended an incoming/outgoing call
          break;
        case Event.ACTION_CALL_TIMEOUT:
          // TODO: missed an incoming call
          {
            print("this is on time out ");
          }
          break;
        case Event.ACTION_CALL_CALLBACK:
          // TODO: only Android - click action `Call back` from missed call notification
          break;
        case Event.ACTION_CALL_TOGGLE_HOLD:
          // TODO: only iOS
          break;
        case Event.ACTION_CALL_TOGGLE_MUTE:
          // TODO: only iOS
          break;
        case Event.ACTION_CALL_TOGGLE_DMTF:
          // TODO: only iOS
          break;
        case Event.ACTION_CALL_TOGGLE_GROUP:
          // TODO: only iOS
          break;
        case Event.ACTION_CALL_TOGGLE_AUDIO_SESSION:
          // TODO: only iOS
          break;
        case Event.ACTION_DID_UPDATE_DEVICE_PUSH_TOKEN_VOIP:
          // TODO: only iOS
          break;
      }
    }
  });
}
