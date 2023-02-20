import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';
import './config.dart';
import '../../stun_client/flutter_stun_client.dart';

import '../InternetManager/InternetManager.dart';
import '../web_socket_connection.dart';

typedef InternetConnectivityCallBack = void Function(String mesg);
typedef OnConnectCallback = void Function(String res);
typedef OnRegisterCallback = void Function(Map<String, dynamic> response);
typedef OnErrorCallback = void Function(int code, String reason);

enum ErrorStatus {
  internetDisconnection,
}

enum VideoSource {
  Camera,
  Screen,
}

enum CallInProgressStatus {
  InCall,
  NotInCall,
  ReInvite,
}

enum CallState {
  CallStateNew,
  CallStateRinging,
  CallStateInvite,
  CallStateConnected,
  CallStateBye,
}

class Session {
  Session(
      {required this.sid,
      required this.to,
      required this.from,
      this.mediaType});
  List<String> to;
  String from;
  String sid;
  String? mediaType;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
}

class SignalingClient {
  static final SignalingClient _instance =
      SignalingClient._privateConstructor();
  static SignalingClient get instance => _instance;
  SignalingClient._privateConstructor() {
    print("this is constructor");
    // checkStatus();
  }

  //****************************************** for FocusWindow start *******************************************

  // checkStatus() {
  //   if (WebRTC.platformIsAndroid) {
  //     EventChannel focusEventChannel = EventChannel("focusEvent");
  //     focusEventChannel.receiveBroadcastStream().listen((onData) {
  //       print("focusStatus $onData");
  //     });
  //   }
  // }

//****************************************** for FocusWindow start *******************************************

//****************************************** callBacks *****************************************************

  InternetConnectivityCallBack? internetConnectivityCallBack;
  OnConnectCallback? onConnect;
  OnErrorCallback? onError;
  OnRegisterCallback? onRegister;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, CallState state)? onCallStateChange;
  Function()? unRegisterSuccessfullyCallBack;
  Function(Map<String, bool>)? onLocalAudioVideoStates;
//*************************************** callBacks ends here **********************************************

//***************************************** variables ******************************************************

  WebSocketConnection? _socket;
  String? wscompleteAddress;
  String? projectID;
  // int isCallStart = 0;
  Timer? timer;
  // bool inCall = false;
  CallInProgressStatus _callStatus = CallInProgressStatus.NotInCall;
  String tenantID = "12345";
  //forRegister variables
  String? refID_vdotok;
  String? authrizationToken_vdotok;
  String? projectID_vdotok;
  int? stunPort_vdotok;
  String? stunRoot_vdotok;

  //forRegister Variables
  int? pingInterval;
  String? mcToken;

  StunClient? stunClient;
  String? sessionInItReferenceID;
  Map<String, dynamic>? turnCredentials;
  Map<String, dynamic>? startCallOfferdata;
  Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  List<MediaStream> _remoteStreams = <MediaStream>[];
  List<RTCRtpSender> _senders = <RTCRtpSender>[];
  VideoSource _videoSource = VideoSource.Camera;

  RTCIceConnectionState _rtcIceConnectionState =
      RTCIceConnectionState.RTCIceConnectionStateClosed;

  String get sdpSemantics => 'unified-plan';

  Map<String, dynamic>? _iceServers;

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
    "type": "camera"
  };
  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };
  String? CallerSDP;
  Map<String, bool> LocalAudioVideoStates = {
    "MuteState": true,
    "SpeakerState": false,
    "CameraState": false,
    "ScreenShareState": false
  };

//***************************************** variables end here *********************************************

//****************************************** internet connection *******************************************

  InternetManager internetManager = InternetManager.instance;
  Stream<bool> state = InternetManager.instance.internetConnectState();
  Timer? _SocketConnecttimer;

  void checkConnectivity() async {
    print("this is state ${state}");
    state.listen((event) {
      print("ths is stream event $event");
      if (event) {
        print("internet connected...");
        internetConnectivityCallBack?.call("Connected");
        reConnectSocketConnectTimer();
        // resetSocketConnectTimer();
        // Timer(Duration(seconds: 5), () => print('done'));
      } else {
        _socket?.close();
        print("no internet...");
        // closeSocket();
        internetConnectivityCallBack?.call("Disconnected");
      }
    });
  }

  reConnectSocketConnectTimer() {
    _SocketConnecttimer?.cancel();
    _SocketConnecttimer = null;
    _SocketConnecttimer = Timer(Duration(seconds: 2), () async {
      bool flag = await getInternetStatus();
      if (flag) {
        connectSocket(projectID, wscompleteAddress);
      }
    });
  }

  Future<bool> getInternetStatus() async {
    return internetManager.getInternetStatus();
  }
//************************************** internet connection ends here **************************************

//******************************************* Socket Connectivity *******************************************
  Future<void> connect(projectid, completeAddress) async {
    wscompleteAddress = completeAddress;
    projectID = projectid;
    checkConnectivity();
  }

  Future<void> connectSocket(projectid, completeAddress) async {
    // completeAddress = "wss://r-signalling.vdotok.dev:8443/call";
    wscompleteAddress = completeAddress;
    projectID = projectid;
    await getInternetStatus().then((value) async {
      print("this is valuuueee $value");
      if (value) {
        try {
          _socket = WebSocketConnection(url: completeAddress);

          _socket?.onOpen = () {
            print("socket is open");
            onConnect?.call("connected");
          };
        } catch (e) {
          print("this is error in socket opening  $e");
        }
        try {
          _socket?.onMessage = (message) {
            _onMessage(json.decode(message));
          };
        } catch (e) {
          print("this is error on decode or else $e");
        }
        // _socket?.onError = () {
        //   print('this is onerrrrr');
        // };

        _socket?.onClose = (dynamic code, String? reason) {
          print("this is onclose socket $_socket");
          timer?.cancel();

          if (reason == null) {
            onError?.call(code, "no reason");

            reConnectSocketConnectTimer();
          } else {
            onError?.call(code, reason);

            reConnectSocketConnectTimer();
          }
        };

        await _socket?.connect();
      } else {
        print("here in falseeee $_socket");
        // onError?.call()
        //internetConnectivityCallBack?.call("Disconnected");
        //onError?.call(1000,"no internet connection");
      }
    }).catchError((onError) {
      print("this is onError of internet connection $onError");
    });
  }

//***************************************** Socket Connectivity ends here ************************************

//*************************************************** Close Socket *******************************************
  closeSocket() {
    if (_socket != null) {
      _socket?.close();
    }
  }

  //*********************************************Close Socket ends here***************************************

  String _generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  register(String refID, String authorization_token, String project_id,
      String stunIP, int stunPort) async {
    stunRoot_vdotok = stunIP;
    authrizationToken_vdotok = authorization_token;
    projectID_vdotok = project_id;
    stunPort_vdotok = stunPort;
    refID_vdotok = refID;

    // if (_rtcIceConnectionState ==
    //         RTCIceConnectionState.RTCIceConnectionStateClosed ||
    //     _rtcIceConnectionState ==
    //         RTCIceConnectionState.RTCIceConnectionStateFailed) {
    if (stunClient == null) {
      stunClient = StunClient.instance;
    } else {
      stunClient?.dispose();
    }

    if (await getInternetStatus()) {
      stunClient?.initStun(stunIP, stunPort);
    }

    stunClient?.onResults = ((res) => {print(res)});
    stunClient?.onNatType = (res) {
      print("i am in sdk  register");

      print("this is reference id ${refID_vdotok}");
      Map<String, dynamic> registerjson = {
        "type": "request",
        "requestType": "register",
        "requestID": _generateMd5(
            DateTime.now().millisecondsSinceEpoch.toString() +
                tenantID +
                refID_vdotok!),
        "projectID": project_id,
        "referenceID": refID_vdotok,
        "authorizationToken": authorization_token,
        "socketType": 0,
        "reConnect": (_callStatus == CallInProgressStatus.InCall ||
                _callStatus == CallInProgressStatus.ReInvite)
            ? 1
            : 0
      };
      registerjson.addAll(res);
      _socket?.send(registerjson);
    };
    // }
  }

//********************************************* Message from Server **********************************************

  void _onMessage(message) async {
    Map<String, dynamic> mapData = message;
    print("from backend requestType ${mapData["requestType"]}");
    print("from backend ${mapData}");

    switch (mapData["requestType"]) {
      case 'session_init':
        {
          if (sessionInItReferenceID == mapData["requestID"]) {
            turnCredentials = mapData["turn_credentials"];
            _startCallOne2OneOnBackendResponse(
                customData: startCallOfferdata!["customData"],
                from: startCallOfferdata!["from"],
                to: startCallOfferdata!["to"],
                media: startCallOfferdata!["media_type"],
                callType: startCallOfferdata!["call_type"],
                sessionType: startCallOfferdata!["session_type"]);

            print(mapData);
          }
        }
        break;
      case 'register':
        {
          if (mapData["responseCode"] == 200) {
            pingInterval = mapData["ping_interval"];
            mcToken = mapData["mcToken"].toString();
            onRegister?.call(mapData);
            if (mapData["reConnect"] == 0) {
            } else {
              var sessionId = mapData['active_session'][0]["sessionUUID"];
              Session? session = _sessions[sessionId];
              _callStatus = CallInProgressStatus.ReInvite;
              print("this is map data");
              // _closeSession(session!).then((value) {
              //   _reInviteOne2One(session, mapData);
              // });
              // session?.pc?.close().then((value) {
              _reInviteOne2One(session, mapData);
              // });
            }
            timer = Timer.periodic(Duration(seconds: pingInterval!), (Timer t) {
              sendPing(mcToken!);
            });
          }
        }
        break;
      case 'un_register':
        {
          unRegisterSuccessfullyCallBack?.call();
        }
        break;
      case "p2p_reInvite":
        {
          if (mapData["sdp_type"] == SdpType.sdpOffer) {
            var sessionId = mapData["sessionUUID"];
            Session? session = _sessions[sessionId];

            print("this is map data");
            _callStatus = CallInProgressStatus.ReInvite;

            // _closeSession(session!).then((value) {
            // _reInviteOne2One(session, mapData);
            // });

            // session?.pc?.close().then((value) {
            _reInviteOne2One(session, mapData);
            // });

            // caleeReceiveCallP2PReInvite(mapData);
          } else {
            var sessionId = mapData["sessionUUID"];
            Session? session = _sessions[sessionId];
            session!.pc!
              ..setRemoteDescription(
                  RTCSessionDescription(mapData['sdp'], "answer"));
          }
        }
        break;
      case 'incomingCall':
        {
          print("this is incomingCall");
          if (mapData["isPeer"] == 1) {
            turnCredentials = mapData["turn_credentials"];
            CallerSDP = mapData["callerSDP"];
          }
          _incomingCall(mapData);

          // isMissedCall = false;
          // userType = "callee";
          // print(
          //     "this is assosiated session uuid ${mapData} ${isCallInProgress}");
          // if (isCallInProgress) {
          //   print("i am here in busy session");
          //   busySession = true;
          //   Map<String, String> busyPacket = {
          //     "requestType": "session_busy",
          //     "mcToken": mcToken!,
          //     "sessionUUID": mapData["sessionUUID"],
          //     "referenceID": refID_vdotok!,
          //     "requestID": _generateMd5(
          //         DateTime.now().millisecondsSinceEpoch.toString() +
          //             tenantID +
          //             refID_vdotok!),
          //   };

          //   _socket?.send(busyPacket);
          // } else {
          //   busySession = false;

          //   // sessionUUID = mapData["sessionUUID"];
          //   if (mapData["call_type"] == "one_to_one" ||
          //       mapData["call_type"] == "one_to_many") {
          //     onetooneparticipantrefid = mapData["from"].toString();
          //     print(
          //         "thiss is one to one incominfg ref id $onetooneparticipantrefid");
          //     if (mapData["call_type"] == "one_to_one") {
          //       iscallonetoone = true;
          //       isCallInProgress = true;
          //     } else {
          //       //for some bugs
          //       if (mapData["associatedSessionUUID"] == null) {
          //         // singlesession
          //         isCallInProgress = true;
          //       } else {
          //         if (mapData["session_type"] == "call") {
          //         } else {
          //           isCallInProgress = true;
          //         }
          //       }
          //       //for some bugs
          //       //ismultisession = true;
          //       if (mapData["session_type"] == "call") {
          //         // callRequestid = mapData["requestID"];
          //         callSessionUUID = mapData["sessionUUID"];
          //       } else {
          //         // screenRequesid = mapData["requestID"];
          //         screenSessionUUID = mapData["sessionUUID"];
          //       }
          //       // sessionUUID = mapData["sessionUUID"];

          //       iscallonetomany = true;
          //     }

          //     print(
          //         "this is one to one incomng mapdata  $callSessionUUID  $screenSessionUUID");

          //     _incomingCall(mapData);
          //   } else {
          //     isCallInProgress = true;
          //     _incomingCall(mapData);
          //   }
          // }
        }
        break;

      case 'callResponse':
        {
          var description = mapData['sdpAnswer'];
          var sessionId = mapData['sessionUUID'];
          var session = _sessions[sessionId];
          session?.pc?.setRemoteDescription(
              RTCSessionDescription(description, "answer"));
          onCallStateChange?.call(session!, CallState.CallStateConnected);
        }
        break;
      case 'iceCandidate':
        {
          var to = mapData['referenceID'];
          var candidateMap = mapData['candidate'];
          var sessionId = mapData['sessionUUID'];
          var session = _sessions[sessionId];
          RTCIceCandidate candidate = RTCIceCandidate(candidateMap['candidate'],
              candidateMap['sdpMid'], candidateMap['sdpMLineIndex']);

          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[sessionId] =
                Session(to: [to], from: refID_vdotok!, sid: sessionId)
                  ..remoteCandidates.add(candidate);
          }
        }
        break;
      case "session_cancel":
        {
          print(
              "this is session cancel respoinse code ${mapData["responseCode"]}");
          if (mapData["responseCode"] == 410) {
            var sessionId = mapData['sessionUUID'];
            var session = _sessions.remove(sessionId);
            if (session != null) {
              onCallStateChange?.call(session, CallState.CallStateBye);
              _closeSession(session);
            }
            // print("call is not ended by caller");
            // _closeSessionLeftParticipant(mapData['referenceID']);

            // onParticipantsLeft?.call(mapData['referenceID'], false, false);
            // reCall = false;
            // inCall = false;
            // // }
          } else if (mapData["responseCode"] == 403 ||
              mapData["responseCode"] == 402) {
            // _statsEndCall().then((value) {
            //   print(
            //       "here in reponse code else 403 ${mapData["responseMessage"]}");
            //   insufficientBalance?.call(mapData["responseMessage"]);
            //   onCallHungUpByUser?.call(false);
            //   //resetConfigurations();

            //   closeSession(false);
            //   print("THSIISSIISISISISI IS SESSION");

            //   callversions = 0;
            //   callend = true;
            //   reCall = false;
            //   inCall = false;
            //   screenShareflag = false;
            //   requestIDType.clear();
            //   ismultisession = false;
            //   callSessionUUID = "";
            //   screenSessionUUID = "";
            //   iscallonetoone = false;
            //   iscallonetomany = false;
            //   isCallInProgress = false;
            // });
          } else {
            var sessionId = mapData['sessionUUID'];
            var session = _sessions.remove(sessionId);
            if (session != null) {
              onCallStateChange?.call(session, CallState.CallStateBye);
              _closeSession(session);
            }
            // _statsEndCall().then((value) {
            //   if (screenShareflag) {
            //     if (userType == "callee") {
            //       print("here in reponse code else");
            //       onCallHungUpByUser?.call(false);
            //       //resetConfigurations();

            //       closeSession(false);
            //       print("THSIISSIISISISISI IS SESSION");

            //       callversions = 0;
            //       callend = true;
            //       reCall = false;
            //       callSessionUUID = "";
            //       screenSessionUUID = "";
            //       screenShareflag = false;
            //       requestIDType.clear();
            //       ismultisession = false;
            //       inCall = false;
            //       iscallonetoone = false;
            //       iscallonetomany = false;
            //       isCallInProgress = false;
            //     } else {
            //       if (!kIsWeb)
            //         ReplayKitLauncher.launchReplayKitBroadcast('ScreenShare');
            //     }
            //   } else {
            //     print("here in reponse code else");
            //     onCallHungUpByUser?.call(false);
            //     //resetConfigurations();

            //     closeSession(false);
            //     print("THSIISSIISISISISI IS SESSION");
            //     if (isCallInProgress) {
            //       if (mapData["responseCode"] == 487) {
            //         isMissedCall = true;
            //         callversions = 0;

            //         callend = true;
            //         reCall = false;
            //         callSessionUUID = "";
            //         screenSessionUUID = "";
            //         screenShareflag = false;
            //         requestIDType.clear();
            //         ismultisession = false;
            //         inCall = false;
            //         iscallonetoone = false;
            //         iscallonetomany = false;
            //         isCallInProgress = false;
            //       }
            //     } else {
            //       isMissedCall = false;
            //     }
            //     callversions = 0;

            //     callend = true;
            //     reCall = false;
            //     callSessionUUID = "";
            //     screenSessionUUID = "";
            //     screenShareflag = false;
            //     requestIDType.clear();
            //     ismultisession = false;
            //     inCall = false;
            //     iscallonetoone = false;
            //     iscallonetomany = false;
            //     isCallInProgress = false;
            //   }
            // });
          }
        }
        break;
    }
  }

  sendPing(String mctoken) {
    print("this is socket $_socket");
    if (_socket != null) {
      try {
        var response = {
          "requestID": _generateMd5(
              DateTime.now().millisecondsSinceEpoch.toString() +
                  tenantID +
                  refID_vdotok!),
          "requestType": "ping",
          "mcToken": mctoken,
        };
        print("this is rpc in send ping $response");
        _socket?.send(response);
      } catch (e) {
        print("this is error in close socket $e");
        onError?.call(1005, "bad state");
      }
    } else {
      print("here in onError send ping");
      onError?.call(1000, "something wrong happened");
    }
  }

//********************************************* One2One Start **********************************************

  _startCallOne2OneOnBackendResponse(
      {String? from,
      required Map<String, dynamic> customData,
      required List<String> to,
      required String media,
      required String callType,
      required String sessionType}) async {
    bool isPermissionsGranted = kIsWeb
        ? true
        : Platform.isAndroid
            ? await _getPermissions(media)
            : true;
    if (isPermissionsGranted) {
      var sessionId = _generateMd5(
          DateTime.now().millisecondsSinceEpoch.toString() +
              tenantID +
              refID_vdotok!);
      Session session = await _createSession(null,
          to: to,
          from: from!,
          sessionId: sessionId,
          media: media,
          screenSharing: false);
      _sessions[sessionId] = session;
      if (media == 'data') {
        // _createDataChannel(session);
      }
      _createOffer(session, media, callType, sessionType, customData);
      onCallStateChange?.call(session, CallState.CallStateNew);
      onCallStateChange?.call(session, CallState.CallStateInvite);
    } else {
      print("permissions not granted");
    }
  }

  startCallonetoone(
      {String? from,
      Map<String, dynamic>? customData,
      List<String>? to,
      String? mediaType,
      // String? mcToken,
      String? callType,
      String? sessionType}) async {
    sessionInItReferenceID = _generateMd5(
        DateTime.now().millisecondsSinceEpoch.toString() +
            tenantID +
            refID_vdotok!);

    startCallOfferdata = {
      "customData": customData,
      "from": from,
      "to": to,
      "type": "request",
      "requestType": "session_init",
      "call_type": callType,
      "session_type": sessionType,
      "media_type": mediaType,
      "requestID": sessionInItReferenceID,
      "mcToken": mcToken
    };

    var d = {
      "from": from,
      "to": to,
      "type": "request",
      "requestType": "session_init",
      "call_type": callType,
      "session_type": sessionType,
      "media_type": mediaType,
      "requestID": sessionInItReferenceID,
      "mcToken": mcToken
    };

    _socket!.send(d);
  }

  _incomingCall(data) async {
    {
      var to = data['from'];
      var from = refID_vdotok!;
      var description = data['callerSDP'];
      var media = data['media_type'];
      var sessionId = data['sessionUUID'];
      var session = _sessions[sessionId];

      bool isPermissionsGranted = kIsWeb
          ? true
          : Platform.isAndroid
              ? await _getPermissions(media)
              : true;
      if (isPermissionsGranted) {
        var newSession = await _createSession(session,
            to: [to],
            from: from,
            sessionId: sessionId,
            media: media,
            screenSharing: false);
        _sessions[sessionId] = newSession;
        await newSession.pc
            ?.setRemoteDescription(RTCSessionDescription(description, "offer"));
        // await _createAnswer(newSession, media);

        if (newSession.remoteCandidates.length > 0) {
          newSession.remoteCandidates.forEach((candidate) async {
            await newSession.pc?.addCandidate(candidate);
          });
          newSession.remoteCandidates.clear();
        }
        onCallStateChange?.call(newSession, CallState.CallStateNew);
        onCallStateChange?.call(newSession, CallState.CallStateRinging);
      }
    }
  }

//********************************************* One2One End **********************************************

//********************************************* Reinvite One2One Start **********************************************
  _reInviteOne2One(Session? s, Map<String, dynamic> mapData) async {
    if (mapData["sdp_type"] == SdpType.sdpOffer) {
      Session session = await _createSession(s,
          to: [],
          from: "",
          sessionId: s!.sid,
          media: mapData["media_type"],
          screenSharing: false);
      _sessions[s.sid] = session;
      session.pc!
        ..setRemoteDescription(RTCSessionDescription(mapData["sdp"], "offer"))
            .then((value) async {
          _reInviteCreateOfferOne2One(
              session,
              mapData["media_type"],
              // startCallOfferdata!["call_type"],
              mapData["session_type"],
              SdpType.sdpAnswer);
        });
    } else {
      Session session = await _createSession(s,
          to: [],
          from: "",
          sessionId: s!.sid,
          media: mapData['active_session'][0]["media_type"],
          screenSharing: false);
      _sessions[s.sid] = session;
      _reInviteCreateOfferOne2One(
        session,
        mapData['active_session'][0]["media_type"],
        // startCallOfferdata!["call_type"],

        mapData['active_session'][0]["session_type"],
        SdpType.sdpOffer,
      );
    }
  }

  Future<void> _reInviteCreateOfferOne2One(
    Session session,
    String media,
    // String callType,
    String sessionType,
    String sdp_type,
    // Map<String, dynamic> customData,
  ) async {
    try {
      RTCSessionDescription? s;
      if (sdp_type == SdpType.sdpAnswer) {
        s = await session.pc!
            .createAnswer(media == 'data' ? _dcConstraints : {});
      } else {
        s = await session.pc!
            .createOffer(media == 'data' ? _dcConstraints : {});
      }

      await session.pc!.setLocalDescription(_fixSdp(s));

      Map<String, dynamic> offerJson;

      offerJson = {
        "type": "request",
        "requestType": "p2p_reInvite",
        "session_type": sessionType,
        "requestID": _generateMd5(
            DateTime.now().millisecondsSinceEpoch.toString() +
                tenantID +
                refID_vdotok!),
        "sessionUUID": session.sid,
        "referenceID": refID_vdotok,
        "mcToken": mcToken,
        "sdp_type": sdp_type,
        "sdpOffer": s.sdp.toString(),
      };

      print("this is json on create offer $offerJson");

      _socket?.send(offerJson);
      switchSpeaker(LocalAudioVideoStates["SpeakerState"]);
    } catch (e) {
      print(e.toString());
    }
  }

//********************************************* Reinvite One2One End **********************************************

// For Foreground Service start

  Future<void> _startForegroundService({
    bool holdWakeLock = false,
    Function? onStarted,
    Function? onStopped,
    required String iconName,
    int color = 0,
    required String title,
    String content = "",
    String subtext = "",
    bool chronometer = false,
    bool stopAction = false,
    String? stopIcon,
    String stopText = 'Close',
  }) async {
    // if (onStarted != null) {
    //   onStartedMethod = onStarted;
    // }

    // if (onStopped != null) {
    //   onStoppedMethod = onStopped;
    // }

    await WebRTC.invokeMethod("startForegroundService", <String, dynamic>{
      'holdWakeLock': holdWakeLock,
      'icon': iconName,
      'color': color,
      'title': title,
      'content': content,
      'subtext': subtext,
      'chronometer': chronometer,
      'stop_action': stopAction,
      'stop_icon': stopIcon,
      'stop_text': stopText,
    });
  }

  static Future<void> _stopForegroundService() async {
    await WebRTC.invokeMethod("stopForegroundService");
  }

  Future<bool> _startVdotokForegroundService() {
    return _startForegroundService(
      holdWakeLock: false,
      onStarted: () {
        print("Foreground on Started");
      },
      onStopped: () {
        print("Foreground on Stopped");
      },
      title: "Tcamera",
      content: "Tcamera sharing your screen.",
      iconName: "ic_stat_mobile_screen_share",
    ).then((value) {
      return true;
    }).catchError((onError) {
      return false;
    });
  }

// For Foreground Service End

//********************************************* Common Methods Start **********************************************
  void accept(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    _createAnswer(session, 'video');
  }

  void bye(String sessionId) {
    Map<String, dynamic> jsonData = {
      "type": "request",
      "requestType": "session_cancel",
      "requestID": _generateMd5(
          DateTime.now().millisecondsSinceEpoch.toString() +
              tenantID +
              refID_vdotok!),
      "sessionUUID": sessionId,
      "mcToken": mcToken
    };
    print("kdfhdjfkghfjg657657 $jsonData");
    _socket?.send(jsonData);
    var sess = _sessions[sessionId];
    if (sess != null) {
      _closeSession(sess);
    }
  }

  void reject(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sid);
  }

  void muteMic(bool flag) {
    if (_localStream != null) {
      // enabled = _localStream!.getAudioTracks()[0].enabled;
      print(
          "this is states $flag ${_localStream!.getAudioTracks()[0].enabled}");
      _localStream!.getAudioTracks()[0].enabled = flag;
    }

    LocalAudioVideoStates["MuteState"] = flag;
    onLocalAudioVideoStates?.call(LocalAudioVideoStates);
  }

  void switchCamera() {
    // if (WebRTC.platformIsIOS) {
    //   _localStream?.getVideoTracks()[0].switchCamera();
    // } else {
    if (_localStream != null) {
      if (_videoSource != VideoSource.Camera) {
        _senders.forEach((sender) {
          if (sender.track!.kind == 'video') {
            sender.replaceTrack(_localStream!.getVideoTracks()[0]);
          }
        });
        _videoSource = VideoSource.Camera;
        onLocalStream?.call(_localStream!);
      } else {
        Helper.switchCamera(_localStream!.getVideoTracks()[0]);
      }
    }
    // }
  }

  switchSpeaker(flag) {
    if (_localStream != null) {
      print(
          "this is audio state in video ${_localStream?.getAudioTracks()[0].enabled} this is flag $flag");
      _localStream?.getAudioTracks()[0].enableSpeakerphone(flag);
    }
    LocalAudioVideoStates["SpeakerState"] = flag;
    onLocalAudioVideoStates?.call(LocalAudioVideoStates);
  }

  void enableCamera(enabled) {
    print("this is bool $enabled");
    if (_localStream != null) {
      _localStream?.getVideoTracks()[0].enabled = enabled;
    }
    LocalAudioVideoStates["CameraState"] = enabled;
    onLocalAudioVideoStates?.call(LocalAudioVideoStates);
  }

  void switchToScreenSharing() async {
    if (_localStream != null && _videoSource != VideoSource.Screen) {
      MediaStream stream = await createStream("video", true);
      _senders.forEach((sender) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      });
      onLocalStream?.call(stream);
      _videoSource = VideoSource.Screen;
    } else {
      _stopForegroundService();
      MediaStream stream = await createStream("video", false);
      _senders.forEach((sender) {
        print("this is kind of video ${sender.track!.kind}");
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      });
      onLocalStream?.call(stream);
      _videoSource = VideoSource.Camera;
    }
  }

  Future<void> _createAnswer(Session session, String media) async {
    try {
      RTCSessionDescription s =
          await session.pc!.createAnswer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(_fixSdp(s));

      final Map<String, dynamic> _offerJson = {
        "type": "request",
        "requestID": _generateMd5(
            DateTime.now().millisecondsSinceEpoch.toString() +
                tenantID +
                refID_vdotok!),
        "sessionUUID": session.sid,
        "requestType": "session_invite",
        "responseCode": 200,
        "responseMessage": "accepted",
        "sdpOffer": s.sdp.toString()
      };
      _socket?.send(_offerJson);
      if (WebRTC.platformIsIOS) {
        switchSpeaker(LocalAudioVideoStates["SpeakerState"]);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<Session> _createSession(
    Session? session, {
    required List<String> to,
    required String from,
    required String sessionId,
    required String media,
    required bool screenSharing,
  }) async {
    var newSession = session ??
        Session(sid: sessionId, to: to, from: from, mediaType: media);
    _callStatus = CallInProgressStatus.InCall;
    if (media != 'data')
      _localStream = await createStream(media, screenSharing);
    _iceServers = {
      'iceServers': [
        {"urls": "stun:$stunRoot_vdotok"},
        {
          'url': turnCredentials!["url"][0],
          'username': turnCredentials!["username"],
          'credential': turnCredentials!["credential"],
        },
      ]
    };
    RTCPeerConnection pc = await createPeerConnection({
      ..._iceServers!,
      ...{'sdpSemantics': sdpSemantics}
    }, _config);
    if (media != 'data') {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            onAddRemoteStream?.call(newSession, stream);
            _remoteStreams.add(stream);
          };
          await pc.addStream(_localStream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          pc.onTrack = (event) {
            if (event.track.kind == 'video') {
              onAddRemoteStream?.call(newSession, event.streams[0]);
            }
          };
          // if (!WebRTC.platformIsIOS) {
          _localStream!.getTracks().forEach((track) async {
            _senders.add(await pc.addTrack(track, _localStream!));
          });
          // }

          break;
      }

      // Unified-Plan: Simuclast
      /*
      await pc.addTransceiver(
        track: _localStream.getAudioTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly, streams: [_localStream]),
      );

      await pc.addTransceiver(
        track: _localStream.getVideoTracks()[0],
        init: RTCRtpTransceiverInit(
            direction: TransceiverDirection.SendOnly,
            streams: [
              _localStream
            ],
            sendEncodings: [
              RTCRtpEncoding(rid: 'f', active: true),
              RTCRtpEncoding(
                rid: 'h',
                active: true,
                scaleResolutionDownBy: 2.0,
                maxBitrate: 150000,
              ),
              RTCRtpEncoding(
                rid: 'q',
                active: true,
                scaleResolutionDownBy: 4.0,
                maxBitrate: 100000,
              ),
            ]),
      );*/
      /*
        var sender = pc.getSenders().find(s => s.track.kind == "video");
        var parameters = sender.getParameters();
        if(!parameters)
          parameters = {};
        parameters.encodings = [
          { rid: "h", active: true, maxBitrate: 900000 },
          { rid: "m", active: true, maxBitrate: 300000, scaleResolutionDownBy: 2 },
          { rid: "l", active: true, maxBitrate: 100000, scaleResolutionDownBy: 4 }
        ];
        sender.setParameters(parameters);
      */
    }
    pc.onIceCandidate = (candidate) async {
      if (candidate == null) {
        print('onIceCandidate: complete!');
        return;
      }
      // This delay is needed to allow enough time to try an ICE candidate
      // before skipping to the next one. 1 second is just an heuristic value
      // and should be thoroughly tested in your own environment.
      await Future.delayed(
          const Duration(seconds: 1),
          () => _socket?.send({
                "requestType": "onIceCandidate",
                "type": "request",
                "referenceID": refID_vdotok,
                "sessionUUID": sessionId,
                "candidate": {
                  'sdpMLineIndex': candidate.sdpMLineIndex,
                  'sdpMid': candidate.sdpMid,
                  'candidate': candidate.candidate,
                }
              })

          // _send('candidate', {
          //       'to': peerId,
          //       'from': _selfId,
          //       'candidate': {
          //         'sdpMLineIndex': candidate.sdpMLineIndex,
          //         'sdpMid': candidate.sdpMid,
          //         'candidate': candidate.candidate,
          //       },
          //       'session_id': sessionId,
          //     })
          );
    };

    pc.onIceConnectionState = (state) {
      print("this is state of peerConnection $state");
      _rtcIceConnectionState = state;
      // if (state == RTCIceConnectionState.RTCIceConnectionStateClosed ||
      //     state == RTCIceConnectionState.RTCIceConnectionStateFailed) {
      //   register(refID_vdotok!, authrizationToken_vdotok!, projectID_vdotok!,
      //       stunRoot_vdotok!, stunPort_vdotok!);
      // }
    };

    pc.onRemoveStream = (stream) {
      // onRemoveRemoteStream?.call(newSession, stream);
      // _remoteStreams.removeWhere((it) {
      //   return (it.id == stream.id);
      // });
    };

    pc.onDataChannel = (channel) {
      // _addDataChannel(newSession, channel);
    };

    newSession.pc = pc;
    return newSession;
  }

  Future<bool> _getPermissions(String type) async {
    PermissionStatus cameraStatus;
    PermissionStatus audioStatus;

    if (type == "video") {
      cameraStatus = await Permission.camera.request();
      audioStatus = await Permission.microphone.request();
      print(
          "this is camera dn microphone permission $cameraStatus $audioStatus");
      if (cameraStatus.isGranted && audioStatus.isGranted) {
        return true;
      } else
        return false;
    } else if (type == "audio") {
      audioStatus = await Permission.microphone.request();
      print("this is microphone permission   $audioStatus");
      if (audioStatus.isGranted) {
        return true;
      } else
        return false;
    } else
      return false;
  }

  Future<MediaStream> createStream(String media, bool userScreen) async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': userScreen ? false : true,
      'video': userScreen
          ? true
          : {
              'mandatory': {
                'minWidth':
                    '640', // Provide your own width, height and frame rate here
                'minHeight': '480',
                'minFrameRate': '30',
              },
              'facingMode': 'user',
              'optional': [],
            }
    };
    Map<String, dynamic> onlyAudio = {'audio': true};
    late MediaStream stream;

    // if (WebRTC.platformIsDesktop) {
    //   // final source = await showDialog<DesktopCapturerSource>(
    //   //   context: context!,
    //   //   builder: (context) => ScreenSelectDialog(),
    //   // );
    //   // stream = await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
    //   //   'video': source == null
    //   //       ? true
    //   //       : {
    //   //           'deviceId': {'exact': source.id},
    //   //           'mandatory': {'frameRate': 30.0}
    //   //         }
    //   // });
    // } else {
    //   stream = await navigator.mediaDevices.getDisplayMedia(mediaConstraints);
    // }
    if (media == 'audio') {
      stream = await navigator.mediaDevices.getUserMedia(onlyAudio);
      stream.getAudioTracks()[0].enableSpeakerphone(false);
      _videoSource = VideoSource.Camera;
    } else if (media == "video" && userScreen == true) {
      await _startVdotokForegroundService();
      stream = await navigator.mediaDevices
          .getDisplayMedia({"video": true, "audio": true, "type": "camera"});
      _videoSource = VideoSource.Screen;
    } else if (media == "video" && userScreen == false) {
      stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      print(
          "this is audio state in video ${stream.getAudioTracks()[0].enabled}");
      stream.getAudioTracks()[0].enableSpeakerphone(true);
      _videoSource = VideoSource.Camera;
    }

    _updateAudioVideoStateInfo(stream, media);
    onLocalStream?.call(stream);
    return stream;
  }

  _updateAudioVideoStateInfo(MediaStream stream, String mediaType) {
    if (stream != null) {
      if (mediaType == "audio") {
        //forSpeaker

        //this is function definition;
        //   onLocalAudioVideoStates(bool muteState, bool speakerState, bool cameraState,
        // bool screenShareState)
        onLocalAudioVideoStates!.call(LocalAudioVideoStates);
      } else if (mediaType == "video") {
        //forSpeaker

        LocalAudioVideoStates["SpeakerState"] = true;
        LocalAudioVideoStates["CameraState"] = true;
        onLocalAudioVideoStates!.call(LocalAudioVideoStates);
      }
    }
  }

  Future<void> _createOffer(
    Session session,
    String media,
    String callType,
    String sessionType,
    Map<String, dynamic> customData,
  ) async {
    try {
      RTCSessionDescription s =
          await session.pc!.createOffer(media == 'data' ? _dcConstraints : {});
      await session.pc!.setLocalDescription(_fixSdp(s));

      Map<String, dynamic> offerJson;

      offerJson = {
        "from": refID_vdotok,
        "to": session.to,
        "type": "request",
        "requestType": "session_invite",
        "session_type": sessionType,
        "call_type": callType,
        "media_type": media,
        "requestID": _generateMd5(
            DateTime.now().millisecondsSinceEpoch.toString() +
                tenantID +
                refID_vdotok!),
        "sessionUUID": session.sid,
        "mcToken": mcToken,
        "sdpOffer": s.sdp.toString(),
        "data": customData,
        "isPeer": 1
      };

      print("this is json on create offer $offerJson");

      _socket?.send(offerJson);
    } catch (e) {
      print(e.toString());
    }
  }

  RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  Future<void> _closeSession(Session session) async {
    _localStream?.getTracks().forEach((element) async {
      await element.stop();
    });
    await _localStream?.dispose();
    _localStream = null;

    print("this is stream $_localStream");
    await session.pc?.close();
    await session.dc?.close();
    await session.pc?.dispose();
    // if (!WebRTC.platformIsIOS) {
    _senders.clear();
    // }
    _videoSource = VideoSource.Camera;

    //otherRests
    if (_callStatus != CallInProgressStatus.ReInvite) {
      _callStatus = CallInProgressStatus.NotInCall;
      onCallStateChange?.call(session, CallState.CallStateBye);
    }
    LocalAudioVideoStates = {
      "MuteState": true,
      "SpeakerState": false,
      "CameraState": false,
      "ScreenShareState": false
    };
    // _stopForegroundService();
  }

  unRegister() {
    print("here in un register");
    Map<String, dynamic> registerjson = {
      "type": "request",
      "requestType": "un_register",
      "requestID": _generateMd5(
          DateTime.now().millisecondsSinceEpoch.toString() +
              tenantID +
              refID_vdotok!),
      "mcToken": mcToken
    };

    // print("this is json un register $registerjson   $requestIDType");

    _socket?.send(registerjson);
    timer?.cancel();
  }

//********************************************* Common Methods End **********************************************
}
