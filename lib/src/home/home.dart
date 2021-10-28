import 'dart:async';

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vdotok_stream_example/noContactsScreen.dart';
import 'package:vdotok_stream_example/src/common/customAppBar.dart';
import 'package:provider/provider.dart';
import 'package:vdotok_stream_example/src/core/config/config.dart';
import 'package:vibration/vibration.dart';
import 'package:vdotok_stream/vdotok_stream.dart';

import 'dart:io' show Platform;

import '../../constant.dart';
import '../core/models/contactList.dart';
import '../core/providers/auth.dart';
import '../core/providers/call_provider.dart';
import '../core/providers/contact_provider.dart';

String pressDuration = "";
bool remoteVideoFlag = true;
bool isDeviceConnected = false;
SignalingClient signalingClient = SignalingClient.instance;
bool enableCamera = true;
bool switchMute = true;
bool switchSpeaker = true;
RTCVideoRenderer localRenderer = new RTCVideoRenderer();
RTCVideoRenderer remoteRenderer = new RTCVideoRenderer();
MediaStream local;
MediaStream remote;

class Home extends StatefulWidget {
  bool state;
  Home(this.state);
  // User user;
  // Home({this.user});
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool notmatched = false;
  bool isConnect = false;
  DateTime _time;
  Timer _ticker;
  var number;
  var nummm;
  double upstream;
  double downstream;
  bool sockett = true;
  bool isSocketregis = false;
  bool isPushed = false;
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
  RTCPeerConnection _peerConnection;
  RTCPeerConnection _answerPeerConnection;
  MediaStream _localStream;

  GlobalKey forsmallView = new GlobalKey();
  GlobalKey forlargView = new GlobalKey();
  GlobalKey forDialView = new GlobalKey();
  var registerRes;
  bool isdev = true;
  String incomingfrom;
  // ContactBloc _contactBloc;
  // CallBloc _callBloc;
  // LoginBloc _loginBloc;
  CallProvider _callProvider;
  AuthProvider _auth;

  String callTo = "";
  List _filteredList = [];
  bool iscalloneto1 = false;
  bool inCall = false;
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
  ContactProvider _contactProvider;

  void checkConnectivity() async {
    isDeviceConnected = false;
    if (!kIsWeb) {
      DataConnectionChecker().onStatusChange.listen((status) async {
        print("this on listener");
        isDeviceConnected = await DataConnectionChecker().hasConnection;
        print("this is is connected in $isDeviceConnected");
        if (isDeviceConnected == true) {
          setState(() {
            isdev = true;
          });
          // showSnackbar("Internet Connected", whiteColor, Colors.green, false);
        } else {
          setState(() {
            isdev = false;
          });
          // showSnackbar(
          //     "No Internet Connection", whiteColor, primaryColor, true);

        }
      });
    }
  }

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
    checkConnectivity();
    initRenderers();
    print("initilization");

    _auth = Provider.of<AuthProvider>(context, listen: false);
    _contactProvider = Provider.of<ContactProvider>(context, listen: false);
    print("this is user data auth ${_auth.getUser}");
    _callProvider = Provider.of<CallProvider>(context, listen: false);

    _contactProvider.getContacts(_auth.getUser.auth_token);
    // signalingClient.closeSocket();
    signalingClient.connect(project_id, _auth.completeAddress);
    //if(widget.state==true)
    signalingClient.onConnect = (res) {
      print("onConnect $res");
      setState(() {
        sockett = true;
      });
      signalingClient.register(_auth.getUser.toJson(), project_id);
      // signalingClient.register(user);
    };
    signalingClient.onError = (code, res) {
      print("onError $code $res");
      // print(
      //     "hey i am here, this is localStream on Error ${local.id} remotestream ${remote.id}");
      if (code == 1002 || code == 1001) {
        setState(() {
          sockett = false;
          isSocketregis = false;
          isPushed = false;
          isdev = false;

          print("disconnected socket");
        });
      } else {
        print("ffgfffff $res");
        // snackBar = SnackBar(content: Text(res));
      }

      if (code == 1005) {
        sockett = false;
        isSocketregis = false;
        isPushed = false;
        isdev = false;
      }
    };
    signalingClient.onRegister = (res) {
      print("onRegister  $res");
      setState(() {
        registerRes = res;
        print("this is mc token in register ${registerRes["mcToken"]}");
      });
      // signalingClient.register(user);
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
      print("this is home page on remote stream ${stream.id} $refid");
      setState(() {
        remoteRenderer.srcObject = stream;
        remote = stream;
        print("this is remote ${stream.id}");
        if (isSocketregis) {
          print("here after call restart");
          _time = pressDuration as DateTime;
          _updateTimer();
          _ticker = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
        } else {
          _time = DateTime.now();
          _updateTimer();
          _ticker = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
        }
        onRemoteStream = true;
        if (inCall == true) {
          print("here in in call true");
          // _callProvider.initial();
        }
      });
      // signalingClient.onCallStatsuploads = (uploadstats) {
      //   nummm = uploadstats;
      //   // String dddi = nummm.toString();
      //   // print("DFKMDKSDF//MNKSDFMDKS 0000000$dddi");

      //   // double myDouble = double.parse(dddi);
      //   // assert(myDouble is double);

      //   // print("dfddfdfdfffffffffffffffff ${myDouble / 1024}"); // 123.45
      //   // upstream = double.parse((myDouble/1024).toStringAsFixed(2));
      // };
      // signalingClient.onCallstats = (timeStatsdownloads, timeStatsuploads) {
      //   print("NOT NULL  $timeStatsdownloads");
      //   number = timeStatsdownloads;
      //   // String ddd = number.toString();
      //   // print("DFKMDKSDFMNKSDFMDKS $ddd");

      //   // double myDouble = double.parse(ddd);
      //   // assert(myDouble is double);

      //   // print("dfddfdfdf ${myDouble / 1024}"); // 123.45
      //   // downstream = double.parse((myDouble/1024).toStringAsFixed(2));
      // };
      //here
      // _callBloc.add(CallStartEvent());
      _callProvider.callStart();
    };
    signalingClient.onParticipantsLeft = (refID) async {
      print("call callback on call left by participant");

      // on participants left
      if (refID == _auth.getUser.ref_id) {
      } else {}
    };
    signalingClient.onReceiveCallFromUser =
        (receivefrom, type, isonetone) async {
      print("incomming call from user");
      startRinging();
      inCall = true;

      setState(() {
        onRemoteStream = false;
        iscalloneto1 = isonetone;
        incomingfrom = receivefrom;
        meidaType = type;
        switchMute = true;
        enableCamera = true;
        switchSpeaker = type == MediaType.audio ? true : false;
        remoteVideoFlag = true;
        remoteAudioFlag = true;
      });
      //here
      // _callBloc.add(CallReceiveEvent());
      _callProvider.callReceive();
    };
    signalingClient.onCallAcceptedByUser = () async {
      inCall = true;
      signalingClient.onCallStatsuploads = (uploadstats) {
        var nummm = uploadstats;
        // String dddi = nummm.toString();
        // print("DFKMDKSDF//MNKSDFMDKS 0000000$dddi");

        // double myDouble = double.parse(dddi);
        // assert(myDouble is double);

        // print("dfddfdfdfffffffffffffffff ${myDouble / 1024}"); // 123.45
        // upstream = double.parse((myDouble / 1024).toStringAsFixed(2));
      };
      signalingClient.onCallstats = (timeStatsdownloads, timeStatsuploads) {
        print("NOT NULL  $timeStatsdownloads");
        number = timeStatsdownloads;
        // String ddd = number.toString();
        // print("DFKMDKSDFMNKSDFMDKS $ddd");

        // double myDouble = double.parse(ddd);
        // assert(myDouble is double);

        // print("dfddfdfdf ${myDouble / 1024}"); // 123.45
        // downstream = double.parse((myDouble / 1024).toStringAsFixed(2));
      };
      _callProvider.callStart();
    };
    signalingClient.onCallHungUpByUser = (isLocal) {
      print("call decliend by other user");
      //here
      // _callBloc.add(CallNewEvent());
      _callProvider.initial();
      setState(() {
        localRenderer.srcObject = null;
        remoteRenderer.srcObject = null;
      });
      stopRinging();
    };
    signalingClient.onCallDeclineByYou = () {
      //here
      // _callBloc.add(CallNewEvent());
      _callProvider.initial();
      setState(() {
        localRenderer.srcObject = null;
        remoteRenderer.srcObject = null;
      });
      stopRinging();
    };
    signalingClient.onCallBusyCallback = () {
      print("hey i am here");
      _callProvider.initial();
      final snackBar =
          SnackBar(content: Text('User is busy with another call.'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        localRenderer.srcObject = null;
        remoteRenderer.srcObject = null;
      });
    };
    signalingClient.onCallRejectedByUser = () {
      print("call decliend by other user");
      //here
      // _callBloc.add(CallNewEvent());
      stopRinging();
      _callProvider.initial();

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

  _startCall(
      List<String> to, String mtype, String callType, String sessionType) {
    setState(() {
      onRemoteStream = false;
      switchMute = true;
      enableCamera = true;
      switchSpeaker = mtype == MediaType.audio ? true : false;
    });
    signalingClient.startCallonetoone(
        from: _auth.getUser.ref_id,
        to: to,
        mcToken: registerRes["mcToken"],
        meidaType: mtype,
        callType: callType,
        sessionType: sessionType);
    // if (_localStream != null) {
    //here
    // _callBloc.add(CallDialEvent());

    _callProvider.callDial();
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
      if (await Vibration.hasVibrator()) {
        Vibration.vibrate(pattern: vibrationList);
      }
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
    // startRinging();
    vibrationList.clear();
    // });
    Vibration.cancel();
    FlutterRingtonePlayer.stop();

    // setState(() {
  }

  @override
  dispose() {
    // localRenderer.dispose();
    // remoteRenderer.dispose();
     _ticker.cancel();
    // FlutterRingtonePlayer.stop();
    // Vibration.cancel();
    // sdpController.dispose();
    super.dispose();
  }

  Future<Null> refreshList() async {
    setState(() {
      renderList();
      // rendersubscribe();
    });
    return;
  }

  renderList() {
    _contactProvider.getContacts(_auth.getUser.auth_token);
  }

  stopCall() {
    print("this is mc token in stop call home ${registerRes["mcToken"]}");
    signalingClient.stopCall(registerRes["mcToken"]);
    //here
    // _callBloc.add(CallNewEvent());
    _callProvider.initial();
    setState(() {
      localRenderer.srcObject = null;
      remoteRenderer.srcObject = null;
    });
    if (!kIsWeb) stopRinging();
  }

  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar color
      statusBarBrightness: Brightness.light, //status bar brigtness
      statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
    ));
    print("jee i am here");
    if (isdev == true && sockett == false) {
      print("i am here in widget build");

      if (isSocketregis == false) {
        isSocketregis = true;

        print("IN WIODGET TRUE AND SOCKET FALSE");
        signalingClient.connect(project_id, _auth.completeAddress);
        print("I am in Re Reregister");
        remoteVideoFlag = true;
        signalingClient.register(_auth.getUser.toJson(), project_id);
        isPushed = false;
        signalingClient.onRegister = (res) {
          print("onRegister after reconnection $res");
          setState(() {
            registerRes = res;
          });
        };
      }
    }
    return Consumer<CallProvider>(
      builder: (context, callProvider, child) {
        print("this is callStatus ${callProvider.callStatus}");
        if (callProvider.callStatus == CallStatus.CallReceive)
          return callReceive();

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
                      else if (contact.contactState == ContactStates.Success) {
                        if (contact.contactList.users == null)
                          return NoContactsScreen(
                            state: widget.state,
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
    );
  }

  Scaffold callReceive() {
    return Scaffold(body: OrientationBuilder(builder: (context, orientation) {
      return Stack(children: <Widget>[
        kIsWeb
            ? Container()
            : meidaType == MediaType.video
                ? Container(
                    child: RTCVideoView(localRenderer,
                        key: forlargView,
                        mirror: false,
                        objectFit:
                            RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
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
        kIsWeb
            ? Container(
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
            : SizedBox(),
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
                    int index = contact.contactList.users.indexWhere(
                        (element) => element.ref_id == incomingfrom);
                    print("callto is $callTo");
                    print(
                        "incoming ${index == -1 ? incomingfrom : contact.contactList.users[index].full_name}");
                    return Text(
                      index == -1
                          ? incomingfrom
                          : contact.contactList.users[index].full_name,
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
                  signalingClient.onDeclineCall(
                      _auth.getUser.ref_id, registerRes["mcToken"]);

                  // _callBloc.add(CallNewEvent());
                  _callProvider.initial();
                  // signalingClient.onDeclineCall(widget.registerUser);
                  // setState(() {
                  //   _isCalling = false;
                  // });
                },
              ),
              SizedBox(width: 64),
              GestureDetector(
                child: SvgPicture.asset(
                  'assets/Accept.svg',
                ),
                onTap: () {
                  stopRinging();
                  signalingClient.createAnswer(incomingfrom);
                  // setState(() {
                  //   _isCalling = true;
                  //   incomingfrom = null;
                  // });
                  // FlutterRingtonePlayer.stop();
                  // Vibration.cancel();
                },
              ),
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
    print("remoteVideoFlag is $remoteVideoFlag");
    print(
        "ths is width ${MediaQuery.of(context).size.height}, ${MediaQuery.of(context).size.width}");
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            !kIsWeb
                ? meidaType == MediaType.video
                    ? Container(
                        // color: Colors.red,
                        //margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: RTCVideoView(localRenderer,
                            key: forDialView,
                            mirror: false,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover))
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
            Container(
                padding: EdgeInsets.only(top: 120),
                alignment: Alignment.center,
                child: Column(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Calling",
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
                  signalingClient.onCancelbytheCaller(registerRes["mcToken"]);
                  _callProvider.initial();
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  Scaffold callStart() {
    print("this is media type $meidaType $remoteVideoFlag ");
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          child: Stack(children: <Widget>[
            meidaType == MediaType.video
                ? remoteVideoFlag
                    ? RTCVideoView(remoteRenderer,
                        mirror: false,
                        objectFit: kIsWeb
                            ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain
                            : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover)
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
                        //            Consumer<ContactProvider>(
                        //   builder: (context, contact, child) {
                        //     if (contact.contactState == ContactStates.Success) {
                        //       int index = contact.contactList.users.indexWhere(
                        //           (element) => element.ref_id == incomingfrom);
                        //       return Text(
                        //         contact.contactList.users[index].full_name,
                        //         style: TextStyle(
                        //             fontFamily: primaryFontFamily,
                        //             color: darkBlackColor,
                        //             decoration: TextDecoration.none,
                        //             fontWeight: FontWeight.w700,
                        //             fontStyle: FontStyle.normal,
                        //             fontSize: 24),
                        //       );
                        //     }
                        //   },
                        // ),
                        (callTo == "")
                            ? Consumer<ContactProvider>(
                                builder: (context, contact, child) {
                                if (contact.contactState ==
                                    ContactStates.Success) {
                                  int index = contact.contactList.users
                                      .indexWhere((element) =>
                                          element.ref_id == incomingfrom);
                                  print("i am here-");
                                  return Text(
                                    contact.contactList.users[index].full_name,
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
                ],
              ),
            ),
            !kIsWeb
                ? meidaType == MediaType.video
                    ? Container(
                        // color: Colors.red,
                        child: Column(
                          children: [
                            Padding(
                              // height: 500,
                              // width: 500,
                              // padding: EdgeInsets.zero,
                              padding: const EdgeInsets.fromLTRB(
                                  327.0, 120.0, 25.0, 8.0),
                              child: Align(
                                alignment: Alignment.topRight,
                                child: GestureDetector(
                                  child: SvgPicture.asset(
                                      'assets/switch_camera.svg'),
                                  onTap: () {
                                    signalingClient.switchCamera();
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              // padding: EdgeInsets.zero,
                              // height: 500,
                              // width: 500,
                              padding: const EdgeInsets.fromLTRB(
                                  327.0, 10.0, 20.0, 8.0),
                              child: Align(
                                alignment: Alignment.topRight,
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
                            ),
                          ],
                        ),
                      )
                    : Container(
                        // color: Colors.red,
                        child: Column(
                          children: [
                            Padding(
                              // padding: EdgeInsets.zero,
                              // height: 500,
                              // width: 500,
                              padding: const EdgeInsets.fromLTRB(
                                  327.0, 120.0, 20.0, 8.0),
                              child: Align(
                                alignment: Alignment.topRight,
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
                            ),
                          ],
                        ),
                      )
                : SizedBox(),
            //),

            // /////////////// this is local stream
            meidaType == MediaType.video
                ? Positioned(
                    left: 225.0,
                    bottom: 145.0,
                    right: 20,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        height: 170,
                        width: 130,
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
                  )
                : Container(),

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
                      remoteVideoFlag = true;
                      stopCall();

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
      temp = state.users
          .where((element) => element.full_name.toLowerCase().startsWith(value))
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
                      value.isEmpty ? "Field cannot be empty." : null,
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
                              ? state.users.length
                              : _filteredList.length,
                          itemBuilder: (context, position) {
                            var element = _searchController.text.isEmpty
                                ? state.users[position]
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
                                      icon: SvgPicture.asset('assets/call.svg'),
                                      onPressed: () {
                                        _startCall(
                                            [element.ref_id],
                                            MediaType.audio,
                                            CAllType.one2one,
                                            SessionType.call);
                                        setState(() {
                                          callTo = element.full_name;
                                          meidaType = MediaType.audio;
                                          print("this is callTo $callTo");
                                        });
                                        print("three dot icon pressed");
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.only(right: 5.9),
                                    // width: 35,
                                    // height: 35,
                                    child: IconButton(
                                      icon: SvgPicture.asset(
                                          'assets/videocallicon.svg'),
                                      onPressed: () {
                                        _startCall(
                                            [element.ref_id],
                                            MediaType.video,
                                            CAllType.one2one,
                                            SessionType.call);
                                        setState(() {
                                          callTo = element.full_name;
                                          meidaType = MediaType.video;
                                          print("this is callTo $callTo");
                                        });
                                        print("three dot icon pressed");
                                      },
                                    ),
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
                        _auth.logout();
                        signalingClient.unRegister(registerRes["mcToken"]);
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
                        color: sockett && isdev ? Colors.green : Colors.red,
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
