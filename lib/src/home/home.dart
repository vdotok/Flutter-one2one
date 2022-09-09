// ignore_for_file: unused_field

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vdotok_stream/vdotok_stream.dart';
import 'package:vdotok_stream_example/noContactsScreen.dart';
import 'package:vdotok_stream_example/src/common/customAppBar.dart';
import 'package:provider/provider.dart';
import 'package:vdotok_stream_example/src/core/config/config.dart';
import 'package:vdotok_stream_example/src/home/drag.dart';
import 'package:vibration/vibration.dart';
import 'package:vdotok_stream/flutter_webrtc.dart';
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
SignalingClient signalingClient = SignalingClient.instance..checkConnectivity();
bool enableCamera = true;
bool switchMute = true;
bool switchSpeaker = true;
RTCVideoRenderer localRenderer = new RTCVideoRenderer();
RTCVideoRenderer remoteRenderer = new RTCVideoRenderer();
MediaStream? local;
MediaStream? remote;
bool islogout = false;
GlobalKey forsmallView = new GlobalKey();
GlobalKey forlargView = new GlobalKey();
GlobalKey forDialView = new GlobalKey();
bool noInternetCallHungUp = false;
// AudioPlayer _audioPlayer = AudioPlayer();
bool isRinging = false;
var snackBar;

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
  late Timer _ticker;
  late Timer _callticker;
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

  bool isInternetConnected = false;
  void _updateTimer() {
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
  late String incomingfrom;
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
  String meidaType = MediaType.video;

  bool remoteAudioFlag = true;
  ContactProvider? _contactProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    print('this is local $localRenderer');
  }

  @override
  void initState() {
    print("here in home init");

    // TODO: implement initState

    super.initState();

    WidgetsBinding.instance?.addObserver(this);
    // checkConnectivity();
    initRenderers();
    print("initilization");

    _auth = Provider.of<AuthProvider>(context, listen: false);
    _contactProvider = Provider.of<ContactProvider>(context, listen: false);
    print("this is user data auth ${_auth.getUser}");
    _callProvider = Provider.of<CallProvider>(context, listen: false);

    _contactProvider!.getContacts(_auth.getUser.auth_token);

    signalingClient.connect(project_id, _auth.completeAddress);

    //if(widget.state==true)
    signalingClient.onConnect = (res) {
      print("onConnect $res");
      setState(() {
        sockett = true;
      });
      print("here in init state register0");
      signalingClient.register(_auth.getUser.toJson(), project_id);
      // signalingClient.register(user);
    };

    signalingClient.unRegisterSuccessfullyCallBack = () {
      _auth.logout();
    };
    signalingClient.onError = (code, res) async {
      print("onError  $code $res $isResumed");
      // if (isConnected == false) {
      //   setState(() {
      //     isConnected = false;
      //     //sockett = false;
      //   });
      // }
      // else{
      //   setState(() {
      //     isConnected = true;
      //     //sockett = false;
      //   });
      // }
      if (code == 1001 || code == 1002) {
        
      
        setState(() {
          sockett = false;

          isRegisteredAlready = false;
        });
          bool connectionFlag = await signalingClient.checkInternetConnectivity();
        if (connectionFlag) {
          signalingClient.connect(project_id, _auth.completeAddress);
        }
        // }
      } else if (code == 401) {
        print("here in 401");
        setState(() {
          sockett = false;
          isRegisteredAlready = true;

          snackBar = SnackBar(
            content: Text('$res'),
            duration: Duration(days: 365),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
      } else {
        if (_auth.loggedInStatus == Status.LoggedOut) {
        } else {
          setState(() {
            sockett = false;
            // isRegisteredAlready=false;
          });
          if (isResumed) {
            print(
                "this is isreesumedd $isConnected $sockett $isRegisteredAlready");
        bool connectionFlag =
                await signalingClient.checkInternetConnectivity();
            if (connectionFlag && sockett == false && !isRegisteredAlready) {
              print("i am in connect in 1005");
              signalingClient.connect(project_id, _auth.completeAddress);

              // signalingClient.register(_auth.getUser.toJson(), project_id);

              // sockett = true;
            } else {
              //  sockett = false;
            }
            //}
          } else {}
        }
      }
      // print(
      //     "hey i am here, this is localStream on Error ${local.id} remotestream ${remote.id}");
      // if (code == 1001 || code == 1002) {
      //   setState(() {
      //     sockett = false;
      //     isConnected = false;
      //     print("disconnected socket");
      //   });
      // } else {
      //   setState(() {
      //     sockett = false;
      //   });

      //   if (_auth.loggedInStatus == Status.LoggedOut) {
      //   } else {
      //     if (isConnected == true && sockett == false) {
      //       print("here in");
      //       signalingClient.connect(project_id, _auth.completeAddress);
      //       print("i am in connect in 1005");
      //       signalingClient.register(_auth.getUser.toJson(), project_id);
      //     }
      //   }
      // }
    };
    signalingClient.internetConnectivityCallBack = (mesg) {
      if (mesg == "Connected") {
        setState(() {
          if (inCall == true) {
            print("fdjhfjd");
            isTimer = true;
          }
          isConnected = true;
          //  sockett = true;
        });

        showSnackbar("Internet Connected", whiteColor, Colors.green, false);
        //signalingClient.sendPing(registerRes["mcToken"]);
        print("khdfjhfj $isTimer");
        if (sockett == false) {
          signalingClient.connect(project_id, _auth.completeAddress);
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

        showSnackbar("No Internet Connection", whiteColor, primaryColor, true);
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
          signalingClient.closeSession(true);
        }
      });
    };

    signalingClient.onLocalStream = (stream) {
      print("this is local stream id ${stream.id}");
      setState(() {
        localRenderer.srcObject = stream;
        local = stream;
        print("this is local $local");
      });
    };
    signalingClient.onRemoteStream = (stream, refid) async {
      print("khdfjhfj1 $isTimer");
      print(
          "this is home page on remote stream ${stream.id} $refid $inCall $isTimer");
      setState(() {
        remoteRenderer.srcObject = stream;
        remote = stream;
        print("this is remote ${stream.id}");
        if (isTimer == false) {
          print("dhdjhdjs");
          _time = DateTime.now();
          _callTime = DateTime.now();
        } else {
          print("djhdjdhhfd");
          _ticker.cancel();
          _time = _callTime;
          isTimer = false;
        }
        _updateTimer();
        _ticker = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
        onRemoteStream = true;
        if (_callticker != null) {
          _callticker.cancel();
          count = 0;
          iscallAcceptedbyuser = true;
        }
        // _audioPlayer.stop();
        _callProvider!.callStart();
      });
    };
    signalingClient.onParticipantsLeft = (refID, receive, istrue) async {
      print("call callback on call left by participant");

      // on participants left
      if (refID == _auth.getUser.ref_id) {
      } else {}
    };
    signalingClient.insufficientBalance = (res) {
      print("here in insufficient balance");
      snackBar = SnackBar(content: Text('$res'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    };
    signalingClient.onReceiveCallFromUser = (res, ismultisession) async {
      print("incomming call from user");
      startRinging();

      setState(() {
        inCall = true;
        pressDuration = "";
        onRemoteStream = false;
        iscalloneto1 = res["call_type"] == "one_to_one" ? true : false;
        incomingfrom = res["from"];
        Wakelock.toggle(enable: true);
        meidaType = res["media_type"];
        switchMute = true;
        enableCamera = true;
        switchSpeaker = res["media_type"] == MediaType.audio ? true : false;
        remoteVideoFlag = true;
        remoteAudioFlag = true;
      });
      //here
      _callticker = Timer.periodic(Duration(seconds: 1), (_) => _callcheck());
      // _callBloc.add(CallReceiveEvent());
      _callProvider!.callReceive();
    };
    signalingClient.onCallAcceptedByUser = () async {
      print("this is call accepted");
      inCall = true;
      iscallAcceptedbyuser = true;
      pressDuration = "";

      // _audioPlayer.stop();
      // if (isTimer == false) {
      //   _time = DateTime.now();
      //   _callTime = DateTime.now();
      // } else {
      //   _ticker.cancel();
      //   _time = _callTime;
      //   isTimer = false;
      // }
      // _updateTimer();
      // _ticker = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
      // signalingClient.onCallStatsuploads = (uploadstats) {
      //   var nummm = uploadstats;
      // };
      // signalingClient.onCallstats = (timeStatsdownloads, timeStatsuploads) {
      //   print("NOT NULL  $timeStatsdownloads");
      //   number = timeStatsdownloads;
      // };
      _callProvider!.callStart();
    };
    signalingClient.onCallHungUpByUser = (isLocal) {
      print("call decliend by other user $inPaused");

      if (inPaused) {
        print("here in paused");
      }
      if (kIsWeb) {
      } else {
        if (Platform.isIOS) {
          if (inInactive) {
            print("here in paused");
            signalingClient.closeSocket();
          }
        }
      }

      print("call end check ");

      // if (_callticker != null) {
      //   print("in Function");

      //   _callticker.cancel();
      // }
      print("toiuidhud");
       if (inCall) {
      if (_callticker != null) {
        print("in Function");

        _callticker.cancel();
      }
       }
      // here
      // _callBloc.add(CallNewEvent());
      _callProvider!.initial();
      print("this is call statussss ${_callProvider!.callStatus}");
      setState(() {
        _isPressed = false;
        inCall = false;
        isTimer = false;
        callTo = "";
        count = 0;
        iscallAcceptedbyuser = false;
        isRinging = false;
        Wakelock.toggle(enable: false);
        iscallAcceptedbyuser = false;
        pressDuration = "";
        localRenderer.srcObject = null;
        remoteRenderer.srcObject = null;
        // Navigator.pop(context);
      });
      stopRinging();
    };
    signalingClient.onTargetAlerting = () {
      setState(() {
        isRinging = true;
      });
    };

    signalingClient.onCallBusyCallback = () {
      print("hey i am here");
      _callProvider!.initial();
      snackBar = SnackBar(content: Text('User is busy with another call.'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        localRenderer.srcObject = null;
        remoteRenderer.srcObject = null;
      });
    };

    signalingClient.onAudioVideoStateInfo = (audioFlag, videoFlag, refID) {
      setState(() {
        remoteVideoFlag = videoFlag == 0 ? false : true;
        remoteAudioFlag = audioFlag == 0 ? false : true;
      });
    };
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("this is changeapplifecyclestate");
    switch (state) {
      case AppLifecycleState.resumed:
        print("app in resumed");
        isResumed = true;
        inPaused = false;
        inInactive = false;
        if (_auth.loggedInStatus == Status.LoggedOut) {
        } else {
          print("this is variable for resume $sockett $isConnected $isResumed");
          //     //signalingClient.sendPing();
          signalingClient.sendPing(registerRes["mcToken"]);
        }
        //   if (_auth.loggedInStatus == Status.LoggedOut) {
        //   } else {
        //     //signalingClient.sendPing();

        // print("here in resume");
        //       signalingClient.connect(project_id, _auth.completeAddress);
        //       signalingClient.register(_auth.getUser.toJson(), project_id);

        //   }

        break;
      case AppLifecycleState.inactive:
        print("app in inactive");
        inInactive = true;
        isResumed = false;
        inPaused = false;
        if (Platform.isIOS) {
          if (inCall == true) {
            print("incall true");
          } else {
            print("here in ininactive");
            signalingClient.closeSocket();
          }
        }

        break;
      case AppLifecycleState.paused:
        print("app in paused");
        inPaused = true;
        isResumed = false;
        inInactive = false;
        if (inCall == true) {
          print("incall true");
        } else {
          print("incall false");
          signalingClient.closeSocket();
        }
        break;
      case AppLifecycleState.detached:
        print("app in detached");
        break;
    }
    // super.didChangeAppLifecycleState(state);
    // _isInForeground = state == AppLifecycleState.resumed;
  }

  _callcheck() {
    print("i am here in call chck function $count");

    count = count + 1;

    if (count == 30 && iscallAcceptedbyuser == false) {
      print("I am here in stopcall if");

      _callticker.cancel();

      count = 0;

      signalingClient.stopCall(registerRes["mcToken"]);

      _callProvider!.initial();

      iscallAcceptedbyuser = false;
    } else if (count == 30 && iscallAcceptedbyuser == true) {
      _callticker.cancel();

      count = 0;

      print("I am here in stopcall call accept true");

      iscallAcceptedbyuser = false;
    } else if (iscallAcceptedbyuser == true) {
      _callticker.cancel();

      print("I am here in emptyyyyyyyyyy stopcall call accept true");

      count = 0;

      iscallAcceptedbyuser = false;
    } else {}
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
      Wakelock.toggle(enable: true);
      inCall = true;
      pressDuration = "";
      onRemoteStream = false;
      switchMute = true;
      enableCamera = true;
      switchSpeaker = mtype == MediaType.audio ? true : false;
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
        mcToken: registerRes["mcToken"],
        meidaType: mtype,
        callType: callType,
        sessionType: sessionType);
    // if (_localStream != null) {
    //here
    // _callBloc.add(CallDialEvent());
    print("this is switch speaker $switchSpeaker");
    _callticker = Timer.periodic(Duration(seconds: 1), (_) => _callcheck());
    print("here in start call");
    _callProvider!.callDial();
    // }
  }

  initRenderers() async {
    print("this is localRenderer $localRenderer");
    await localRenderer
        .initialize()
        .then((value) => null)
        .catchError((onError) {
      print("this is error on initialize $onError");
    });
    print("after initialixxation");
    await remoteRenderer.initialize();
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
    if (_ticker != null) {
      _ticker.cancel();
    }
    // FlutterRingtonePlayer.stop();
    // Vibration.cancel();
    // sdpController.dispose();
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
    _contactProvider!.getContacts(_auth.getUser.auth_token);
  }

  stopCall() {
    print("this is mc token in stop call home ${registerRes["mcToken"]}");

    signalingClient.stopCall(registerRes["mcToken"]);

    //here
    // _callBloc.add(CallNewEvent());
    _callProvider!.initial();
    setState(() {
      _callticker.cancel();
      _ticker.cancel();
      inCall = false;
      pressDuration = "";
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    });
    if (!kIsWeb) stopRinging();
  }

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
          print("this is callStatus ${callProvider.callStatus} $inCall");
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
          //           mediaType: meidaType,

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
            //               mediaType: meidaType,
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

          //           mediaType: meidaType,
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
        meidaType == MediaType.video
            ? Container(
                child: RTCVideoView(localRenderer,
                    key: forlargView,
                    mirror: false,
                    objectFit:
                        RTCVideoViewObjectFit.RTCVideoViewObjectFitContain),
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
                        (element) => element!.ref_id == incomingfrom);
                    print("callto is $callTo");
                    print(
                        "incoming ${index == -1 ? incomingfrom : contact.contactList.users![index]!.full_name}");
                    return Text(
                      index == -1
                          ? incomingfrom
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
                  signalingClient.declineCall(
                      _auth.getUser.ref_id, registerRes["mcToken"]);

                  // _callBloc.add(CallNewEvent());
                  _callProvider!.initial();
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
                  onTap: _isPressed == false
                      ? () {
                          print("this is pressed accept");
                          stopRinging();
                          signalingClient.createAnswer(incomingfrom);
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
                        }
                      : null)
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
    print("remoteVideoFlag is $localRenderer");
    print(
        "ths is width ${MediaQuery.of(context).size.height}, ${MediaQuery.of(context).size.width}");
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            meidaType == MediaType.video
                ? Container(
                    // color: Colors.red,
                    //margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: RTCVideoView(localRenderer,
                        key: forDialView,
                        mirror: false,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain))
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
                  signalingClient.stopCall(registerRes["mcToken"]);
                  _callProvider!.initial();
                  // inCall = false;
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Scaffold callStart() {
    //  inCall = true;
    print("this is media type $meidaType $remoteVideoFlag $localRenderer");
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          child: Stack(children: <Widget>[
            meidaType == MediaType.video
                ? remoteVideoFlag
                    ? RTCVideoView(remoteRenderer,
                        mirror: false,
                        objectFit:
                            // kIsWeb
                            //  ?
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                        //  : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
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
                    (meidaType == MediaType.video)
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
                        (callTo == "")
                            ? Consumer<ContactProvider>(
                                builder: (context, contact, child) {
                                if (contact.contactState ==
                                    ContactStates.Success) {
                                  int index = contact.contactList.users!
                                      .indexWhere((element) =>
                                          element!.ref_id == incomingfrom);
                                  print("i am here-");
                                  return Text(
                                    contact
                                        .contactList.users![index]!.full_name,
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
                              })
                            : Text(
                                callTo,
                                style: TextStyle(
                                    fontFamily: primaryFontFamily,
                                    // background: Paint()..color = yellowColor,
                                    color: darkBlackColor,
                                    decoration: TextDecoration.none,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.normal,
                                    fontSize: 24),
                              ),
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
                ? meidaType == MediaType.video
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
                                    signalingClient.switchCamera();
                                  },
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.only(right: 20),
                                child: GestureDetector(
                                  child: !switchSpeaker
                                      ? SvgPicture.asset('assets/VolumnOn.svg')
                                      : SvgPicture.asset(
                                          'assets/VolumeOff.svg'),
                                  onTap: () {
                                    signalingClient
                                        .switchSpeaker(switchSpeaker);
                                    setState(() {
                                      switchSpeaker = !switchSpeaker;
                                    });
                                  },
                                ),
                              ),
                              // ),
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
                                child: !switchSpeaker
                                    ? SvgPicture.asset('assets/VolumnOn.svg')
                                    : SvgPicture.asset('assets/VolumeOff.svg'),
                                onTap: () {
                                  //  if  (!kIsWeb){
                                  signalingClient.switchSpeaker(switchSpeaker);

                                  setState(() {
                                    switchSpeaker = !switchSpeaker;
                                  });
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
                // meidaType == MediaType.video
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
                meidaType == MediaType.video
                    ? DragBox()
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
                          child: enableCamera
                              ? RTCVideoView(localRenderer,
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
                  meidaType == MediaType.video
                      ? Row(
                          children: [
                            GestureDetector(
                              child: !enableCamera
                                  ? SvgPicture.asset('assets/video_off.svg')
                                  : SvgPicture.asset('assets/video.svg'),
                              onTap: () {
                                setState(() {
                                  enableCamera = !enableCamera;
                                });
                                signalingClient.audioVideoState(
                                    audioFlag: switchMute ? 1 : 0,
                                    videoFlag: enableCamera ? 1 : 0,
                                    mcToken: registerRes["mcToken"]);
                                signalingClient.enableCamera(enableCamera);
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
                        stopCall();
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
                    child: !switchMute
                        ? SvgPicture.asset('assets/mute_microphone.svg')
                        : SvgPicture.asset('assets/microphone.svg'),
                    onTap: () {
                      final bool enabled = signalingClient.muteMic();
                      print("this is enabled $enabled");
                      setState(() {
                        switchMute = enabled;
                      });
                    },
                  ),
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
                                                      meidaType =
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
                                                      meidaType =
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
                        islogout = true;
                        if (isRegisteredAlready) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          isRegisteredAlready = false;
                        }

                        signalingClient.unRegister(registerRes["mcToken"]);
                        // _auth.logout();
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
