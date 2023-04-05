// ignore_for_file: unused_field

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vdotok_stream/vdotok_stream.dart';
import 'package:vdotok_stream_example/noContactsScreen.dart';
import 'package:vdotok_stream_example/src/common/customAppBar.dart';
import 'package:provider/provider.dart';
import 'package:vdotok_stream_example/src/core/config/config.dart';
import 'package:vdotok_stream_example/src/home/drag.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock/wakelock.dart';

import 'dart:io' show File, Platform;

import '../../constant.dart';
import '../../main.dart';
import '../core/models/contactList.dart';
import '../core/providers/auth.dart';
import '../core/providers/call_provider.dart';
import '../core/providers/contact_provider.dart';

String pressDuration = "";
bool remoteVideoFlag = true;
bool isDeviceConnected = false;

// bool enableCamera = true;
// bool switchMute = true;
// bool switchSpeaker = true;

Map<String, bool> _localAudioVideoStates = {
  "UnMuteState": false,
  "SpeakerState": false,
  "CameraState": false,
  "ScreenShareState": false,
  "isBackCamera": false
};

MediaStream? local;
MediaStream? remote;
bool islogout = false;
GlobalKey forsmallView = new GlobalKey();
GlobalKey forlargView = new GlobalKey();
GlobalKey forDialView = new GlobalKey();
bool noInternetCallHungUp = false;
Map<String, RTCVideoRenderer> renderObj = {};
// AudioPlayer _audioPlayer = AudioPlayer();
bool isRinging = false;
var snackBar;

Session? _session;

class Home extends StatefulWidget {
  // User user;

  // Home({this.user});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver {
  bool notmatched = false;
  bool isConnect = false;

  late DateTime _time;
  late DateTime _callTime;

  Timer? _ticker;
  Timer? _callticker;
  int count = 0;
  bool iscallAcceptedbyuser = false;

  var number;
  var nummm;
  late double upstream;
  late double downstream;
  bool sockett = true;
  bool isSocketregis = false;
  bool isTimer = false;
  bool isResumed = true;
  bool inPaused = false;
  var bottom = 20.0;
  var right = 20.0;
  SignalingClient signalingClient = SignalingClient.instance;

  bool isInternetConnected = false;
  void _getTimer() {
    final duration = DateTime.now().difference(_time);
    final newDuration = _formatDuration(duration);
    setState(() {
      pressDuration = newDuration;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitHours = twoDigits(duration.inHours);
    if (twoDigitHours == "00")
      return "$twoDigitMinutes:$twoDigitSeconds";
    else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    ;
  }

  // SignalingClient signalingClient = SignalingClient.instance;
  RTCPeerConnection? _peerConnection;
  RTCPeerConnection? _answerPeerConnection;
  MediaStream? _localStream;
  bool isConnected = true;
  var registerRes;
  // bool isdev = true;
  Map<String, dynamic>? customData;
  // late String incomingfrom;
  // ContactBloc _contactBloc;
  // CallBloc _callBloc;
  // LoginBloc _loginBloc;
  CallProvider? _callProvider;
  late AuthProvider _auth;
  bool isRegisteredAlready = false;
  String callTo = "";
  List _filteredList = [];
  bool iscalloneto1 = false;
  bool inCall = false;
  bool inInactive = false;
  bool onRemoteStream = false;
  final _searchController = new TextEditingController();
  List<int> vibrationList = [
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000,
    500,
    1000
  ];
  String mediaType = MediaType.video;

  bool remoteAudioFlag = true;
  ContactProvider? _contactProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }

  @override
  void initState() {
    print("here in home init");

    // TODO: implement initState

    super.initState();

    WidgetsBinding.instance?.addObserver(this);

    print("initilization");

    _auth = Provider.of<AuthProvider>(context, listen: false);
    _contactProvider = Provider.of<ContactProvider>(context, listen: false);
    print("this is user data auth ${_auth.getUser}");
    _callProvider = Provider.of<CallProvider>(context, listen: false);

    signalingClient.connect(
        project_id,
        _auth.completeAddress,
        _auth.getUser.ref_id.toString(),
        _auth.getUser.authorization_token.toString(),
        _auth.StungIP,
        int.parse(_auth.StungPort));

    //if(widget.state==true)
    signalingClient.onConnect = (res) {
      print("onConnect $res");
      setState(() {
        sockett = true;
      });
      print("here in init state register0");
      // signalingClient.register();
      // signalingClient.register(user);
    };

    signalingClient.unRegisterSuccessfullyCallBack = () {
      _auth.logout();
    };
    signalingClient.onLocalAudioVideoStates =
        (Map<String, bool> localAudioVideoStates) {
      setState(() {
        _localAudioVideoStates = localAudioVideoStates;
      });
    };
    signalingClient.onInfoCallback = (type, msg) {
      Fluttertoast.showToast(msg: msg);
      if (type == "AllowPermissions") {
        openAppSettings();
      }
    };
    signalingClient.onError = (code, reason) async {
      print("this is socket error $code $reason");

      if (!mounted) {
        return;
      }
      setState(() {
        sockett = false;
      });
    };

    signalingClient.internetConnectivityCallBack = (mesg) {
      if (mesg == "Connected") {
        setState(() {
          if (inCall == true) {
            isTimer = true;
          }
          isConnected = true;
          //  sockett = true;
        });
        Fluttertoast.showToast(
            msg: "Internet Connected.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0);

        //  showSnackbar("Internet Connected", whiteColor, Colors.green, false);
        //signalingClient.sendPing(registerRes["mcToken"]);
        print("khdfjhfj $isTimer");
        if (sockett == false) {
          // signalingClient.connect(project_id, _auth.completeAddress);
          print("I am in Re Reregister ");
          remoteVideoFlag = true;
          print("here in init state register");
          // if (noInternetCallHungUp == true) {
          //   print('this issussus $noInternetCallHungUp');
          //   //signalingClient.closeSession();
          //    stopCall();
          // }
          // signalingClient.register(_auth.getUser.toJson(), project_id);
        }
      } else {
        print("onError no internet connection");
        setState(() {
          isConnected = false;
          sockett = false;
        });
        Fluttertoast.showToast(
            msg: "No Internet Connection.",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP_RIGHT,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 14.0);
        // showSnackbar("No Internet Connection", whiteColor, primaryColor, true);
        // if (Platform.isIOS) {
        print("uyututuir");
        signalingClient.closeSocket();
        //}
      }
    };

    signalingClient.onRegister = (res) {
      print("onregister  $res");
      setState(() {
        registerRes = res;
        print("this is mc token in register ${registerRes["mcToken"]}");
        if (noInternetCallHungUp == true) {
          print('this issussus $noInternetCallHungUp');
          //3
          // signalingClient.closeSession(true);
        }
      });
      if (_contactProvider!.contactState != ContactStates.Success) {
        _contactProvider!.getContacts(_auth.getUser.auth_token);
      }
    };

    signalingClient.onLocalStream = (stream) async {
      // if (renderObj["local"] != null) {
      //   renderObj["local"]!.dispose();
      //   renderObj["local"] = await initRenderers(new RTCVideoRenderer());

      //   print("this is local stream id ${stream.id}");
      //   setState(() {
      //     renderObj["local"]!.srcObject = stream;
      //   });
      // } else {
      renderObj["local"] = await initRenderers(new RTCVideoRenderer());

      print("this is local stream id ${stream.id}");
      setState(() {
        renderObj["local"]!.srcObject = stream;
      });
      // }
    };
    signalingClient.onAddRemoteStream = (session) async {
      setState(() {
        mediaType = session.mediaType!;
        renderObj["remote"] = session.remoteRenderer;
        // renderObj["remote"]!.srcObject = stream;
      });
    };
    signalingClient.onCallBusy = () {
      print("user is busy");
      Fluttertoast.showToast(
          msg: "User is busy.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP_RIGHT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0);
    };
    signalingClient.onCallStateChange =
        (Session? session, CallState state) async {
      print("this is call State $state");

      switch (state) {
        case CallState.CallStateNew:
          break;
        case CallState.CallSession:
          setState(() {
            _session = session;
            mediaType = session!.mediaType!;
          });

          break;
        case CallState.CallStateRinging:
          {
            setState(() {
              _session = session;
              mediaType = session!.mediaType!;
            });
            _callProvider!.callReceive();
          }
          break;
        case CallState.CallStateBye:
          {
            _callProvider!.initial();
            setState(() {
              renderObj["local"]?.dispose();
              renderObj["remote"]?.dispose();
              renderObj.clear();
              _session = null;
              _ticker?.cancel();
              pressDuration = "";
              inCall = false;
            });
          }
          break;
        case CallState.CallStateInvite:
          _callProvider!.callDial();
          break;
        case CallState.CallStateConnected:
          {
            // _callticker?.cancel();
            _time = DateTime.now();
            print(
                "this is current time......... $_time......this is calll start time");
            _ticker = Timer.periodic(Duration(seconds: 1), (_) => _getTimer());
            print("ticker is $_ticker");

            _callProvider!.callStart();
          }

          break;
      }
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("this is changeapplifecyclestate $state");

    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");

        isResumed = true;
        inPaused = false;
        inInactive = false;

        if (_auth.loggedInStatus == Status.LoggedOut) {
          print("this is auth ");
        } else {
          try {
            bool status = await signalingClient.getInternetStatus();

            print("sttatttusss $status");

            if (sockett == false && status == true) {
              // signalingClient.connect(project_id, _auth.completeAddress);
            }

            // signalingClient.sendPing(registerResponse["mcToken"]);
          } catch (e) {
            print("this is send ping catch error in demo app $e");
          }
        }

        break;

      case AppLifecycleState.inactive:
        {
          print("app in inactive");

          inInactive = true;

          isResumed = false;

          inPaused = false;
        }

        break;

      case AppLifecycleState.paused:
        print("app in paused");

        inPaused = true;

        isResumed = false;

        inInactive = false;

        //   signalingClient.closeSocket();

        break;

      case AppLifecycleState.detached:
        print("app in detached");

        break;
    }
  }

  _callcheck() {
    _hangUp();
  }

  Future<bool> _onWillPop() async {
    if (inCall) {
      MoveToBackground.moveTaskToBack();
      return true;
    } else {
      return true;
    }
  }

  _startCall(List<String> to, String mtype, String callType,
      String sessionType) async {
    setState(() {
      inCall = true;
    });
    setState(() {
      Wakelock.toggle(enable: true);
      // inCall = true;
      pressDuration = "";
      onRemoteStream = false;
      // switchMute = true;
      // enableCamera = true;
      // switchSpeaker = mtype == MediaType.audio ? true : false;
    });
    // final file = new File('${(await getTemporaryDirectory()).path}/music.mp3');
    // await file.writeAsBytes(
    //     (await rootBundle.load("assets/audio.mp3")).buffer.asUint8List());
    // // int res = await _audioPlayer.earpieceOrSpeakersToggle();
    // print("thogh $res");
    // if (res == 1) {
    //await _audioPlayer.play(file.path, isLocal: true);
    customData = {
      "calleName": callTo,
      "groupName": "",
      "groupAutoCreatedValue": ""
    };
    signalingClient.startCallonetoone(
        customData: customData,
        from: _auth.getUser.ref_id,
        to: to,
        mediaType: mtype,
        callType: callType,
        sessionType: sessionType);
    // if (_localStream != null) {
    //here
    // _callBloc.add(CallDialEvent());
    // print("this is switch speaker $switchSpeaker");
    // _callticker = Timer.periodic(Duration(seconds: 40), (_) => _callcheck());
    print("here in start call");
    // _callProvider!.callDial();
    // }
  }

  Future<RTCVideoRenderer> initRenderers(RTCVideoRenderer renderer) async {
    // print("this is localRenderer $localRenderer");
    await renderer.initialize();
    return renderer;
  }

  startRinging() async {
    if (Platform.isAndroid) {
      // if (await Vibration.hasVibrator()) {
      //   Vibration.vibrate(pattern: vibrationList);
      // }
    }
    FlutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: 1.0, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  stopRinging() {
    print("this is on rejected ");
    if (kIsWeb) {
    }
    // startRinging();
    else {
      vibrationList.clear();
      // });
      Vibration.cancel();
      FlutterRingtonePlayer.stop();
    }

    // setState(() {
  }

  showSnackbar(text, Color color, Color backgroundColor, bool check) {
    if (check == false) {
      rootScaffoldMessengerKey!.currentState!
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            '$text',
            style: TextStyle(color: color),
          ),
          backgroundColor: backgroundColor,
          duration: Duration(seconds: 2),
        ));
    } else if (check == true) {
      rootScaffoldMessengerKey?.currentState?.showSnackBar(SnackBar(
        content: Text(
          '$text',
          style: TextStyle(color: color),
        ),
        backgroundColor: backgroundColor,
        duration: Duration(days: 365),
      ));
    }
  }

  @override
  dispose() {
    // localRenderer.dispose();
    // remoteRenderer.dispose();
    // if (_ticker != null) {
    //   _ticker.cancel();
    // }
    // FlutterRingtonePlayer.stop();
    // Vibration.cancel();
    // sdpController.dispose();
    print("this is disposeee");
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  Future<Null> refreshList() async {
    setState(() {
      renderList();
      // rendersubscribe();
    });
    return;
  }

  renderList() {
    if (!sockett) {
      signalingClient.reConnectSocketConnectTimer();
    }
    _contactProvider!.getContacts(_auth.getUser.auth_token);
  }

  _accept() {
    if (_session != null) {
      signalingClient.accept(_session!.sid);
    }
    _callProvider!.callStart();
  }

  _reject() {
    if (_session != null) {
      signalingClient.reject(_session!.sid);
    }
  }

  _hangUp() {
    // if (_callticker?.isActive == true) {
    //   _callticker?.cancel();
    // }
    if (_session != null) {
      signalingClient.bye(_session!.sid);
    }
  }

  _muteMic() {
    signalingClient.muteMic(!_localAudioVideoStates["UnMuteState"]!);
  }

  _switchCamera() {
    if (_localAudioVideoStates["CameraState"] == true) {
      signalingClient.switchCamera(!_localAudioVideoStates["isBackCamera"]!);
    } else {
      Fluttertoast.showToast(msg: "First enable camera");
    }
  }

  _switchSpeaker() {
    signalingClient.switchSpeaker(!_localAudioVideoStates["SpeakerState"]!);
  }

  _enableCamera() {
    signalingClient.enableCamera(!_localAudioVideoStates["CameraState"]!);
  }

//   stopCall() {
//     print("this is mc token in stop call home ${registerRes["mcToken"]}");
// //6
//     // signalingClient.stopCall(registerRes["mcToken"]);

//     //here
//     // _callBloc.add(CallNewEvent());
//     _callProvider!.initial();
//     setState(() {
//       _callticker.cancel();
//       _ticker.cancel();
//       inCall = false;
//       pressDuration = "";
//       localRenderer.srcObject = null;
//       remoteRenderer.srcObject = null;
//     });
//     if (!kIsWeb) stopRinging();
//   }

  Future buildShowDialog(
      BuildContext context, String mesg, String errorMessage) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            Future.delayed(Duration(seconds: 2), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
                title: Center(
                    child: Text(
                  "${mesg}",
                  style: TextStyle(color: counterColor),
                )),
                content: Text("$errorMessage"),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0)),
                elevation: 0,
                actions: <Widget>[
                  Container(
                    height: 50,
                    width: 319,
                  )
                ]);
          });
        });
  }

  bool _isPressed = false;
  // bool isRadioButtonEnabble = false;
  void _myCallback() {
    setState(() {
      _isPressed = true;
      print("tap me");
    });
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar color
      statusBarBrightness: Brightness.light, //status bar brigtness
      statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
    ));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Consumer3<CallProvider, AuthProvider, ContactProvider>(
        builder: (context, callProvider, authProvider, contactProvider, child) {
          if (callProvider.callStatus == CallStatus.CallReceive)
            return callReceive();
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => MultiProvider(
          //         providers: [
          //           ChangeNotifierProvider<AuthProvider>(
          //               create: (context) => AuthProvider()),
          //           ChangeNotifierProvider(
          //               create: (context) => ContactProvider()),
          //           ChangeNotifierProvider(create: (context) => CallProvider()),
          //         ],
          //         child: CallReceiveScreen(
          //           //  rendererListWithRefID:rendererListWithRefID,
          //           mediaType: mediaType,

          //           incomingfrom: incomingfrom,
          //           cllProvider: _callProvider,
          //           registerRes: registerRes,
          //           authProvider: authProvider,
          //           from: authProvider.getUser.ref_id,
          //           stopRinging: stopRinging,
          //           authtoken: authProvider.getUser.auth_token,
          //           contactList: contactProvider.contactList,
          //         )),
          //   ),
          // );

          if (callProvider.callStatus == CallStatus.CallStart) {
            print("here in call provider status");
            // if (isPushed == false) {
            //   isPushed = true;
            //   WidgetsBinding.instance.addPostFrameCallback((_) {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //         builder: (BuildContext context) => MultiProvider(
            //             providers: [
            //               ChangeNotifierProvider<AuthProvider>(
            //                   create: (context) => AuthProvider()),
            //               ChangeNotifierProvider(
            //                   create: (context) => ContactProvider()),
            //               ChangeNotifierProvider(
            //                   create: (context) => CallProvider()),
            //             ],
            //             child: CallStartScreen(
            //               // onSpeakerCallBack: onSpeakerCallBack,
            //               // onCameraCallBack: onCameraCallBack,
            //               // onMicCallBack: onMicCallBack,
            //               //  rendererListWithRefID:rendererListWithRefID,
            //               //  onRemoteStream:onRemoteStream,
            //               mediaType: mediaType,
            //               localRenderer: localRenderer,
            //               remoteRenderer: remoteRenderer,
            //               incomingfrom: incomingfrom,
            //               registerRes: registerRes,
            //               stopCall: stopCall,
            //               callTo: callTo,
            //               // signalingClient: signalingClient,
            //               callProvider: _callProvider,
            //               authProvider: _auth,
            //               contactProvider: _contactProvider,
            //               mcToken: registerRes["mcToken"],

            //               contactList: _contactProvider.contactList,
            //               //  popCallBAck: screenPopCallBack
            //             )),
            //       ),
            //     );
            //   });
            // }
            return callStart();
          }
          if (callProvider.callStatus == CallStatus.CallDial)
            return callDial();
          // Navigator.of(context).push(
          //   MaterialPageRoute(
          //     builder: (BuildContext context) => MultiProvider(
          //         providers: [
          //           ChangeNotifierProvider<AuthProvider>(
          //               create: (context) => AuthProvider()),
          //           ChangeNotifierProvider(
          //               create: (context) => ContactProvider()),
          //           ChangeNotifierProvider(create: (context) => CallProvider()),
          //         ],
          //         child: CallDialScreen(
          //           //  rendererListWithRefID:rendererListWithRefID,

          //           mediaType: mediaType,
          //           callTo: callTo,
          //           //  incomingfrom: incomingfrom,
          //           callProvider: _callProvider,
          //           registerRes: registerRes,
          //           // authProvider: authProvider,
          //           // stopRinging: stopRinging,

          //           // authtoken: authProvider.getUser.auth_token,
          //           // contactList: contactProvider.contactList,
          //         )),
          //   ),
          // );
          else if (callProvider.callStatus == CallStatus.Initial)
            return SafeArea(
              child: GestureDetector(
                onTap: () {
                  FocusScopeNode currentFous = FocusScope.of(context);
                  if (!currentFous.hasPrimaryFocus) {
                    return currentFous.unfocus();
                  }
                },
                child: Scaffold(
                    backgroundColor: chatRoomBackgroundColor,
                    appBar: CustomAppBar(authProvider: _auth),
                    body: Consumer<ContactProvider>(
                      builder: (context, contact, child) {
                        if (contact.contactState == ContactStates.Loading)
                          return Center(
                              child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(chatRoomColor),
                          ));
                        else if (contact.contactState ==
                            ContactStates.Success) {
                          if (contact.contactList.users == null)
                            return NoContactsScreen(
                              state: isConnected,
                              isSocketConnect: sockett,
                              refreshList: renderList,
                              authProvider: _auth,
                            );
                          else
                            return contactList(contact.contactList);
                        } else
                          return Container(
                            child: Text("no contacts found"),
                          );
                      },
                    )),
              ),
            );
          return Container(
            child: Text("test"),
          );
        },
      ),
    );
  }

  Scaffold callReceive() {
    return Scaffold(body: OrientationBuilder(builder: (context, orientation) {
      return Stack(children: <Widget>[
        // mediaType == MediaType.video
        //     ? Container(
        //         child: RTCVideoView(localRenderer,
        //             key: forlargView,
        //             mirror: false,
        //             objectFit:
        //                 RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
        //       )
        //     :
        Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [
              backgroundAudioCallDark,
              backgroundAudioCallLight,
              backgroundAudioCallLight,
              backgroundAudioCallLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment(0.0, 0.0),
          )),
          child: Center(
            child: SvgPicture.asset(
              'assets/userIconCall.svg',
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(top: 120),
          alignment: Alignment.center,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Incoming Call from",
                style: TextStyle(
                    fontSize: 14,
                    decoration: TextDecoration.none,
                    fontFamily: secondaryFontFamily,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    color: darkBlackColor),
              ),
              SizedBox(
                height: 8,
              ),
              Consumer<ContactProvider>(
                builder: (context, contact, child) {
                  if (contact.contactState == ContactStates.Success) {
                    int index = contact.contactList.users!.indexWhere(
                        (element) => element!.ref_id == _session!.to[0]);
                    print("callto is $callTo");
                    print(
                        "incoming ${index == -1 ? _session!.to : contact.contactList.users![index]!.full_name}");
                    return Text(
                      index == -1
                          ? _session!.to.toString()
                          : contact.contactList.users![index]!.full_name,
                      style: TextStyle(
                          fontFamily: primaryFontFamily,
                          color: darkBlackColor,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                          fontSize: 24),
                    );
                  } else
                    return Container();
                },
              ),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            bottom: 56,
          ),
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/end.svg',
                ),
                onTap: () {
                  stopRinging();
                  _reject();
                  //6
                  // signalingClient.declineCall(
                  //     _auth.getUser.ref_id, registerRes["mcToken"]);

                  // _callBloc.add(CallNewEvent());
                  // _callProvider!.initial();
                  //  inCall = false;
                  // signalingClient.onDeclineCall(widget.registerUser);
                  // setState(() {
                  //   _isCalling = false;
                  // });
                },
              ),
              SizedBox(
                width: 20,
              ),
              // SizedBox(width: 64),qasa
              GestureDetector(
                  child: SvgPicture.asset(
                    'assets/Accept.svg',
                  ),
                  onTap:
                      // _isPressed == false
                      //     ?
                      () {
                    print("this is pressed accept");
                    stopRinging();
                    _accept();

                    setState(() {
                      _isPressed = true;
                      print("tap me");
                    });

                    // setState(() {
                    //   inCall = true;
                    // });

                    // setState(() {
                    //   _isCalling = true;
                    //   incomingfrom = null;
                    // });
                    // FlutterRingtonePlayer.stop();
                    // Vibration.cancel();
                  })
            ],
          ),
        ),
      ]);
    }));
  }

  Scaffold callDial() {
    // return Scaffold(
    //       body: Container(height: 70,
    //       width:70,
    //     child: Text("hello")),
    // );

    print(
        "ths is width ${MediaQuery.of(context).size.height}, ${MediaQuery.of(context).size.width}");
    return Scaffold(
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              // mediaType == MediaType.video
              //     ? Container(
              //         // color: Colors.red,
              //         //margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              //         width: MediaQuery.of(context).size.width,
              //         height: MediaQuery.of(context).size.height,
              //         child: RTCVideoView(localRenderer,
              //             key: forDialView,
              //             mirror: false,
              //             objectFit:
              //                 RTCVideoViewObjectFit.RTCVideoViewObjectFitContain))
              //     :
              Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: [
                    backgroundAudioCallDark,
                    backgroundAudioCallLight,
                    backgroundAudioCallLight,
                    backgroundAudioCallLight,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment(0.0, 0.0),
                )),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/userIconCall.svg',
                  ),
                ),
              ),
              Container(
                  padding: EdgeInsets.only(top: 120),
                  alignment: Alignment.center,
                  child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isRinging ? "Ringing" : "Calling",
                          style: TextStyle(
                              fontSize: 14,
                              decoration: TextDecoration.none,
                              fontFamily: secondaryFontFamily,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              color: darkBlackColor),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          callTo,
                          style: TextStyle(
                              fontFamily: primaryFontFamily,
                              color: darkBlackColor,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.normal,
                              fontSize: 24),
                        )
                      ])),
              Container(
                padding: EdgeInsets.only(bottom: 56),
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  child: SvgPicture.asset(
                    'assets/end.svg',
                  ),
                  onTap: () {
                    _hangUp();
                    // _callProvider!.initial();
                    // inCall = false;
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Scaffold callStart() {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          child: Stack(children: <Widget>[
            mediaType == MediaType.video
                ? remoteVideoFlag
                    ? renderObj["remote"] != null
                        ? RTCVideoView(renderObj["remote"]!,
                            mirror: false,
                            objectFit:
                                // kIsWeb
                                //  ?
                                RTCVideoViewObjectFit
                                    .RTCVideoViewObjectFitContain
                            //  : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
                            )
                        : Container()
                    : Container(
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: [
                            backgroundAudioCallDark,
                            backgroundAudioCallLight,
                            backgroundAudioCallLight,
                            backgroundAudioCallLight,
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment(0.0, 0.0),
                        )),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/userIconCall.svg',
                          ),
                        ),
                      )
                : Container(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: [
                        backgroundAudioCallDark,
                        backgroundAudioCallLight,
                        backgroundAudioCallLight,
                        backgroundAudioCallLight,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment(0.0, 0.0),
                    )),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/userIconCall.svg',
                      ),
                    ),
                  ),

            //decoration: BoxDecoration(color: Colors.black54),
            //),
            //  ),
            // Positioned(
            //   top: 55,
            //   child:
            Container(
              padding: EdgeInsets.only(top: 55, left: 20),
              //height: 79,
              //width: MediaQuery.of(context).size.width,

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (mediaType == MediaType.video)
                        ? 'You are video calling with'
                        : 'You are audio calling with',
                    style: TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration.none,
                        fontFamily: secondaryFontFamily,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.normal,
                        color: darkBlackColor),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      right: 25,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // (callTo == "")
                        // ?
                        Consumer<ContactProvider>(
                            builder: (context, contact, child) {
                          if (contact.contactState == ContactStates.Success) {
                            int index = contact.contactList.users!.indexWhere(
                                (element) =>
                                    element!.ref_id == _session!.to[0]);
                            print("i am here-");
                            return Text(
                              contact.contactList.users![index]!.full_name,
                              style: TextStyle(
                                  fontFamily: primaryFontFamily,
                                  color: darkBlackColor,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.normal,
                                  fontSize: 24),
                            );
                          } else {
                            return Container();
                          }
                        }),
                        // : Text(
                        //     _session!.to.toString(),
                        //     style: TextStyle(
                        //         fontFamily: primaryFontFamily,
                        //         // background: Paint()..color = yellowColor,
                        //         color: darkBlackColor,
                        //         decoration: TextDecoration.none,
                        //         fontWeight: FontWeight.w700,
                        //         fontStyle: FontStyle.normal,
                        //         fontSize: 24),
                        //   ),

                        Text(
                          pressDuration,
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              fontFamily: secondaryFontFamily,
                              fontWeight: FontWeight.w400,
                              fontStyle: FontStyle.normal,
                              color: darkBlackColor),
                        ),
                      ],
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     //SizedBox(width: 10),
                  //     number != null
                  //         ? Text(
                  //             "DownStream $number UpStream $nummm",
                  //             style: TextStyle(
                  //                 decoration: TextDecoration.none,
                  //                 fontSize: 14,
                  //                 fontFamily: secondaryFontFamily,
                  //                 fontWeight: FontWeight.w400,
                  //                 fontStyle: FontStyle.normal,
                  //                 color: darkBlackColor),
                  //           )
                  //         : Text(
                  //             "DownStream 0   UpStream 0",
                  //             style: TextStyle(
                  //                 decoration: TextDecoration.none,
                  //                 fontSize: 14,
                  //                 fontFamily: secondaryFontFamily,
                  //                 fontWeight: FontWeight.w400,
                  //                 fontStyle: FontStyle.normal,
                  //                 color: darkBlackColor),
                  //           ),
                  //   ],
                  //),
                  SizedBox(
                    height: 20,
                  ),
                  // Draggable(
                  //   childWhenDragging: Container(),
                  //   feedback: Container(),
                  //   child: DragTarget(
                  //       onAccept: (Color color) {
                  //         // caughtColor = color;
                  //       },
                  //       builder: (
                  //         BuildContext context,
                  //         List<dynamic> accepted,
                  //         List<dynamic> rejected,
                  //       ) =>
                  //           Draggable(
                  //             feedback: Container(),
                  //             child: Container(),
                  //           )),
                  // ),
                ],
              ),
            ),
            !kIsWeb
                ? mediaType == MediaType.video
                    ? Container(
                        child: Align(
                          alignment: Alignment.topRight,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.fromLTRB(
                                    0.0, 120.33, 20, 27),
                                child: GestureDetector(
                                  child: SvgPicture.asset(
                                    'assets/switch_camera.svg',
                                  ),
                                  onTap: () {
                                    _switchCamera();
                                  },
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  child: _localAudioVideoStates["SpeakerState"]!
                                      ? SvgPicture.asset('assets/VolumnOn.svg')
                                      : SvgPicture.asset(
                                          'assets/VolumeOff.svg'),
                                  onTap: () {
                                    _switchSpeaker();
                                    // setState(() {
                                    //   switchSpeaker = !switchSpeaker;
                                    // });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        // color: Colors.red,
                        child: Align(
                        alignment: Alignment.topRight,
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                  0.0, 120.33, 20, 27),
                              child: GestureDetector(
                                child: _localAudioVideoStates["SpeakerState"]!
                                    ? SvgPicture.asset('assets/VolumnOn.svg')
                                    : SvgPicture.asset('assets/VolumeOff.svg'),
                                onTap: () {
                                  //  if  (!kIsWeb){

                                  _switchSpeaker();

                                  // setState(() {
                                  //   switchSpeaker = !switchSpeaker;
                                  // });
                                },
                              ),
                            ),
                          ],
                        ),
                      ))
                : SizedBox(),
            //),
///////qasim
            // /////////////// this is local stream

            !kIsWeb
                ?
                // mediaType == MediaType.video
                //     ?
                //     // GestureDetector(
                //     //     child:
                //     Positioned(
                //         // right: right,
                //         // bottom: bottom,
                //         left: 225,
                //         bottom: 145,
                //         right: 20,
                //         child: Align(
                //           alignment: Alignment.bottomRight,
                //           child: Container(
                //             height: 100,
                //             width: 100,
                //             decoration: BoxDecoration(
                //               borderRadius: BorderRadius.circular(10.0),
                //             ),
                //             child: ClipRRect(
                //               borderRadius: BorderRadius.circular(10.0),
                //               child: enableCamera
                //                   ? RTCVideoView(localRenderer,
                //                       key: forsmallView,
                //                       mirror: false,
                //                       objectFit: RTCVideoViewObjectFit
                //                           .RTCVideoViewObjectFitCover)
                //                   : Container(),
                //             ),
                //           ),
                //         ),
                //       )
                //     // onVerticalDragUpdate: (DragUpdateDetails dd) {
                //     //   print(dd);
                //     //   setState(() {
                //     //     bottom = dd.localPosition.dy;
                //     //     right = dd.localPosition.dx;
                //     //   });
                //     //})
                //     : Container(),
                mediaType == MediaType.video
                    ? DragBox(
                        localAudioVideoStates: _localAudioVideoStates,
                      )
                    : Container()
                : Positioned(
                    left: 225,
                    bottom: 145,
                    right: 20,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: _localAudioVideoStates["CameraState"]!
                              ? renderObj["local"]?.srcObject == null
                                  ? Container()
                                  : RTCVideoView(renderObj["local"]!,
                                      key: forsmallView,
                                      mirror: false,
                                      objectFit: RTCVideoViewObjectFit
                                          .RTCVideoViewObjectFitCover)
                              : Container(),
                        ),
                      ),
                    ),
                  ),

            //Container(),

            Container(
              padding: EdgeInsets.only(
                bottom: 56,
              ),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  mediaType == MediaType.video
                      ? Row(
                          children: [
                            GestureDetector(
                              child: _localAudioVideoStates["CameraState"]!
                                  ? SvgPicture.asset('assets/video.svg')
                                  : SvgPicture.asset('assets/video_off.svg'),
                              onTap: () {
                                // setState(() {
                                //   enableCamera = !enableCamera;
                                // });

                                // signalingClient.audioVideoState(
                                //     audioFlag: switchMute ? 1 : 0,
                                //     videoFlag: enableCamera ? 1 : 0,
                                //     mcToken: registerRes["mcToken"]);
                                _enableCamera();
                              },
                            ),
                            SizedBox(
                              width: 20,
                            )
                          ],
                        )
                      : SizedBox(),

                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/end.svg',
                    ),
                    onTap: () {
                      if (isConnected == false) {
                        setState(() {
                          noInternetCallHungUp = true;
                        });

                        _callProvider!.initial();
                      } else {
                        _hangUp();
                      }
                      remoteVideoFlag = true;

                      // inCall = false;

                      // setState(() {
                      //   _isCalling = false;
                      // });
                    },
                  ),

                  // SvgPicture.asset('assets/images/end.svg'),

                  SizedBox(width: 20),
                  GestureDetector(
                    child: _localAudioVideoStates["UnMuteState"]!
                        ? SvgPicture.asset('assets/microphone.svg')
                        : SvgPicture.asset('assets/mute_microphone.svg'),
                    onTap: () {
                      _muteMic();
                      // print("this is enabled $enabled");
                      // setState(() {
                      //   switchMute = enabled;
                      // });
                    },
                  ),
                  // SizedBox(width: 20),
                  // Platform.isAndroid
                  //     ? GestureDetector(
                  //         child: Icon(
                  //           Icons.switch_camera,
                  //           color: Colors.red,
                  //           size: 30,
                  //         ),
                  //         onTap: () {
                  //           signalingClient.switchToScreenSharing();
                  //           // _muteMic();
                  //           // print("this is enabled $enabled");
                  //           // setState(() {
                  //           //   switchMute = enabled;
                  //           // });
                  //         },
                  //       )
                  //     : SizedBox()
                ],
              ),
            )
          ]),
        );
      }),
    );
  }

  Scaffold contactList(ContactList state) {
    onSearch(value) {
      print("this is here $value");
      List temp;
      temp = state.users!
          .where((element) =>
              element!.full_name.toLowerCase().startsWith(value.toLowerCase()))
          .toList();
      print("this is filtered list $_filteredList");
      setState(() {
        if (temp.isEmpty) {
          notmatched = true;
          print("Here in true not matched");
        } else {
          print("Here in false matched");
          notmatched = false;
          _filteredList = temp;
        }
        //_filteredList = temp;
      });
    }

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: refreshList,
        child: Container(
          child: Column(
            children: [
              Container(
                height: 50,
                padding: EdgeInsets.only(left: 21, right: 21),
                child: TextFormField(
                  //textAlign: TextAlign.center,
                  controller: _searchController,
                  onChanged: (value) {
                    onSearch(value);
                  },
                  validator: (value) =>
                      value!.isEmpty ? "Field cannot be empty." : null,
                  decoration: InputDecoration(
                    fillColor: refreshTextColor,
                    filled: true,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SvgPicture.asset(
                        'assets/SearchIcon.svg',
                        width: 20,
                        height: 20,
                        fit: BoxFit.fill,
                      ),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(color: searchbarContainerColor)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                      borderSide: BorderSide(
                        color: searchbarContainerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        borderSide: BorderSide(color: searchbarContainerColor)),
                    // border: InputBorder.none,
                    // focusedBorder: InputBorder.none,
                    // enabledBorder: InputBorder.none,
                    // errorBorder: InputBorder.none,
                    // disabledBorder: InputBorder.none,
                    //contentPadding: EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 10.0),
                    // contentPadding: EdgeInsets.only(
                    //   top: 15,
                    // ),
                    // contentPadding:
                    //   EdgeInsets.symmetric(vertical: 20, horizontal: 20),

                    // isDense: true,
                    hintText: "Search",
                    hintStyle: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w400,
                        color: searchTextColor,
                        fontFamily: secondaryFontFamily),
                  ),
                ),
                //),
              ),
              SizedBox(height: 30),
              Expanded(
                child: Scrollbar(
                  child: notmatched == true
                      ? Text("No data Found")
                      : ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(8),
                          cacheExtent: 9999,
                          scrollDirection: Axis.vertical,
                          itemCount: _searchController.text.isEmpty
                              ? state.users!.length
                              : _filteredList.length,
                          itemBuilder: (context, position) {
                            var element = _searchController.text.isEmpty
                                ? state.users![position]
                                : _filteredList[position];

                            return Container(
                              //width: screenwidth,
                              height: 50,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 11.5, right: 13.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: SvgPicture.asset('assets/User.svg'),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${element.full_name}",
                                      style: TextStyle(
                                        color: contactNameColor,
                                        fontSize: 16,
                                        fontFamily: primaryFontFamily,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // width: 32,
                                    // height: 32,
                                    child: IconButton(
                                        icon:
                                            SvgPicture.asset('assets/call.svg'),
                                        onPressed: !isConnected
                                            ? (!isRegisteredAlready)
                                                ? () {
                                                    // buildShowDialog(
                                                    //     context,
                                                    //     "No Internet Connection",
                                                    //     "Make sure your device has internet.");
                                                  }
                                                : () {}
                                            : isRegisteredAlready
                                                ? () {}
                                                : () {
                                                    print(
                                                        "here in connected start call $isConnected");
                                                    _startCall(
                                                        [element.ref_id],
                                                        MediaType.audio,
                                                        CAllType.one2one,
                                                        SessionType.call);
                                                    setState(() {
                                                      callTo =
                                                          element.full_name;
                                                      mediaType =
                                                          MediaType.audio;
                                                      print(
                                                          "this is callTo $callTo");
                                                    });
                                                    print(
                                                        "three dot icon pressed");

// if(!isRegisteredAlready)
//                                                 {snackBar = SnackBar(
//                                                     content: Text(
//                                                         'Make sure your device has internet connection'));
//                                                 ScaffoldMessenger.of(context)
//                                                     .showSnackBar(snackBar);}
                                                  }),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 5.9),
                                    // width: 35,
                                    // height: 35,
                                    child: IconButton(
                                        icon: SvgPicture.asset(
                                            'assets/videocallicon.svg'),
                                        onPressed: !isConnected
                                            ? (!isRegisteredAlready)
                                                ? () {
                                                    // buildShowDialog(
                                                    //     context,
                                                    //     "No Internet Connection",
                                                    //     "Make sure your device has internet.");
                                                  }
                                                : () {}
                                            : isRegisteredAlready
                                                ? () {}
                                                : () {
                                                    _startCall(
                                                        [element.ref_id],
                                                        MediaType.video,
                                                        CAllType.one2one,
                                                        SessionType.call);
                                                    setState(() {
                                                      callTo =
                                                          element.full_name;
                                                      mediaType =
                                                          MediaType.video;
                                                      print(
                                                          "this is callTo $callTo");
                                                    });
                                                    print(
                                                        "three dot icon pressed");
                                                  }),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.only(left: 14.33, right: 19),
                              child: Divider(
                                thickness: 1,
                                color: listdividerColor,
                              ),
                            );
                          },
                        ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    child: TextButton(
                      onPressed: () {
                        if (!inCall) {
                          islogout = true;
                          if (isRegisteredAlready) {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            isRegisteredAlready = false;
                          }

                          signalingClient.unRegister();
                        }
                      },
                      child: Text(
                        "LOG OUT",
                      ),
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontFamily: primaryFontFamily,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.90),
                      ),
                    ),
                  ),
                  Container(
                    height: 10,
                    width: 10,
                    decoration: BoxDecoration(
                        color: isConnected && sockett == true
                            ? Colors.green
                            : Colors.red,
                        shape: BoxShape.circle),
                  )
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Text(_auth.getUser.full_name))
            ],
          ),
        ),
      ),
    );
  }
}
