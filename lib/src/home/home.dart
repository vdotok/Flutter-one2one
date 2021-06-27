import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vdotok_stream_example/noContactsScreen.dart';
import 'package:vdotok_stream_example/src/common/customAppBar.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:vdotok_stream/vdotok_stream.dart';

import 'dart:io' show Platform;

import '../../constant.dart';
import '../core/models/contactList.dart';
import '../core/providers/auth.dart';
import '../core/providers/call_provider.dart';
import '../core/providers/contact_provider.dart';

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
  String _pressDuration = "";
  void _updateTimer() {
    final duration = DateTime.now().difference(_time);
    final newDuration = _formatDuration(duration);
    setState(() {
      _pressDuration = newDuration;
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

  SignalingClient signalingClient = SignalingClient.instance;
  RTCPeerConnection _peerConnection;
  RTCPeerConnection _answerPeerConnection;
  MediaStream _localStream;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
  RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
  GlobalKey forsmallView = new GlobalKey();
  GlobalKey forlargView = new GlobalKey();
  GlobalKey forDialView = new GlobalKey();
  var registerRes;
  String incomingfrom;
  // ContactBloc _contactBloc;
  // CallBloc _callBloc;
  // LoginBloc _loginBloc;
  CallProvider _callProvider;
  AuthProvider _auth;
  bool enableCamera = true;
  bool switchMute = true;
  bool switchSpeaker = true;
  String callTo = "";
  List _filteredList = [];
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
  bool remoteVideoFlag = true;
  bool remoteAudioFlag = true;
  ContactProvider _contactProvider;
  bool isSocketConnect = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initRenderers();

    _auth = Provider.of<AuthProvider>(context, listen: false);
    _contactProvider = Provider.of<ContactProvider>(context, listen: false);
    print("this is user data auth ${_auth.getUser}");
    _callProvider = Provider.of<CallProvider>(context, listen: false);
// if(widget.state==true && !isSocketConnect)
// {
//   signalingClient.connect();
//    //if(widget.state==true)
//     signalingClient.onConnect = (res) {
//       print("onConnect $res");
//       setState(() {
//         isSocketConnect = true;
//          print("this is onconnect socket $isSocketConnect");
//       });
//       signalingClient.register(_auth.getUser.toJson());
//       // signalingClient.register(user);
//     };
// }
    // _contactBloc = BlocProvider.of<ContactBloc>(context);
    // _loginBloc = BlocProvider.of<LoginBloc>(context);
    // _callBloc = BlocProvider.of<CallBloc>(context);
    // _contactBloc.add(GetContactEvent(widget.user.auth_token));
    _contactProvider.getContacts(_auth.getUser.auth_token);
    // signalingClient.closeSocket();
    signalingClient.connect();
    //if(widget.state==true)
    signalingClient.onConnect = (res) {
      print("onConnect $res");
      setState(() {
        isSocketConnect = true;
        print("this is onconnect socket $isSocketConnect");
      });
      signalingClient.register(_auth.getUser.toJson());
      // signalingClient.register(user);
    };
    signalingClient.onError = (code, res) {
      print("onError $code $res");
      print("hey i am here");
      if (code == 1002) {
        setState(() {
          isSocketConnect = false;
          print("this is onerror socket $isSocketConnect");
          print("disconnected socket");
        });
      }

      _callProvider.initial();
      final snackBar = SnackBar(content: Text(res));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
      });
      // signalingClient.register(user);
    };
    signalingClient.onRegister = (res) {
      print("onRegister  $res");
      setState(() {
        registerRes = res;
      });
      // signalingClient.register(user);
    };
    signalingClient.onLocalStream = (stream) {
      print("this is local stream id ${stream.id}");
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };
    signalingClient.onRemoteStream = (stream) {
      // final snackBar = SnackBar(content: Text('Yay! A SnackBar!'));

// Find the Scaffold in the widget tree and use it to show a SnackBar.
      // ScaffoldMessenger.of(context).showSnackBar(snackBar);
      // print("this is remote stream id ${stream.id}");
      setState(() {
        _remoteRenderer.srcObject = stream;
        _time = DateTime.now();
        _updateTimer();
        _ticker = Timer.periodic(Duration(seconds: 1), (_) => _updateTimer());
      });
      //here
      // _callBloc.add(CallStartEvent());
      _callProvider.callStart();
    };
    signalingClient.onReceiveCallFromUser = (receivefrom, type) async {
      print("incomming call from user");
      startRinging();

      setState(() {
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
      //here
      // _callBloc.add(CallStartEvent());
      _callProvider.callStart();
    };
    signalingClient.onCallHungUpByUser = () {
      print("call decliend by other user");
      //here
      // _callBloc.add(CallNewEvent());
      _callProvider.initial();
      setState(() {
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
      });
      stopRinging();
    };
    signalingClient.onCallDeclineByYou = () {
      //here
      // _callBloc.add(CallNewEvent());
      _callProvider.initial();
      setState(() {
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
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
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
      });
    };
    signalingClient.onCallRejectedByUser = () {
      print("call decliend by other user");
      //here
      // _callBloc.add(CallNewEvent());
      stopRinging();
      _callProvider.initial();

      setState(() {
        _localRenderer.srcObject = null;
        _remoteRenderer.srcObject = null;
      });
    };

    signalingClient.onAudioVideoStateInfo = (audioFlag, videoFlag) {
      setState(() {
        remoteVideoFlag = videoFlag == 0 ? false : true;
        remoteAudioFlag = audioFlag == 0 ? false : true;
      });
    };
  }

  _startCall(
      List<String> to, String mtype, String callType, String sessionType) {
    setState(() {
      switchMute = true;
      enableCamera = true;
      switchSpeaker = mtype == MediaType.audio ? true : false;
    });
    signalingClient.startCall(
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
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
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
    _localRenderer.dispose();
    _remoteRenderer.dispose();
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
    signalingClient.stopCall(registerRes["mcToken"]);
    //here
    // _callBloc.add(CallNewEvent());
    _callProvider.initial();
    setState(() {
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
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
    if (widget.state == true && !isSocketConnect) {
      signalingClient.connect();
      //if(widget.state==true)
      signalingClient.onConnect = (res) {
        print("onConnect widget build $res");
        setState(() {
          isSocketConnect = true;
          print("this is onconnect socket widget build$isSocketConnect");
        });
        signalingClient.register(_auth.getUser.toJson());
        // signal
      };
    }
    return Consumer<CallProvider>(
      builder: (context, callProvider, child) {
        print("this is callStatus ${callProvider.callStatus}");
        if (callProvider.callStatus == CallStatus.CallReceive)
          return callReceive();

        if (callProvider.callStatus == CallStatus.CallStart) return callStart();
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
                            refreshList: renderList,
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
                    child: RTCVideoView(_localRenderer,
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
                  signalingClient.declineCall(
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
    //   floatingActionButton: Padding(
    //     padding: const EdgeInsets.only(bottom: 70),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: <Widget>[
    //         Container(
    //           // width: 80,
    //           // height: 80,
    //           child: FloatingActionButton(
    //             backgroundColor: redColor,
    //             onPressed: () {
    //               stopRinging();
    //               signalingClient.onDeclineCall(_auth.getUser.ref_id);
    //               // _callBloc.add(CallNewEvent());
    //               _callProvider.initial();
    //               // signalingClient.onDeclineCall(widget.registerUser);
    //               // setState(() {
    //               //   _isCalling = false;
    //               // });
    //             },
    //             child: Icon(Icons.clear),
    //           ),
    //         ),
    //         Container(
    //           // width: 80,
    //           // height: 80,
    //           child: FloatingActionButton(
    //             backgroundColor: Colors.green,
    //             onPressed: () {
    //               stopRinging();
    //               signalingClient.createAnswer(incomingfrom);
    //               // setState(() {
    //               //   _isCalling = true;
    //               //   incomingfrom = null;
    //               // });
    //               // FlutterRingtonePlayer.stop();
    //               // Vibration.cancel();
    //             },
    //             child: Icon(Icons.phone),
    //           ),
    //         )
    //       ],
    //     ),
    //   ),
    //   floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    // );
  }

  Scaffold callDial() {
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
                        child: RTCVideoView(_localRenderer,
                            key: forDialView,
                            mirror: false,
                            objectFit: RTCVideoViewObjectFit
                                .RTCVideoViewObjectFitCover),
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
            // Container(
            //   height: 79,
            //   //width: MediaQuery.of(context).size.width,
            //   padding: EdgeInsets.only(
            //     left: 20,
            //   ),
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         callTo,
            //         style: TextStyle(
            //             fontSize: 14,
            //             decoration: TextDecoration.none,
            //             fontFamily: secondaryFontFamily,
            //             fontWeight: FontWeight.w400,
            //             fontStyle: FontStyle.normal,
            //             color: darkBlackColor),
            //       ),
            //       Container(
            //         padding: EdgeInsets.only(
            //           right: 25,
            //         ),
            //         child: Row(
            //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //           crossAxisAlignment: CrossAxisAlignment.end,
            //           children: [
            //             Text(
            //               'Dialing...',
            //               style: TextStyle(
            //                   fontFamily: primaryFontFamily,
            //                   // background: Paint()..color = yellowColor,
            //                   color: darkBlackColor,
            //                   decoration: TextDecoration.none,
            //                   fontWeight: FontWeight.w700,
            //                   fontStyle: FontStyle.normal,
            //                   fontSize: 24),
            //             ),
            //             // Text(
            //             //   "00:00",
            //             //   style: TextStyle(
            //             //       decoration: TextDecoration.none,
            //             //       fontSize: 14,
            //             //       fontFamily: secondaryFontFamily,
            //             //       fontWeight: FontWeight.w400,
            //             //       fontStyle: FontStyle.normal,
            //             //       color: Colors.black),
            //             // ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
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
                  // _callBloc.add(CallNewEvent());
                  // signalingClient.onDeclineCall(widget.user.ref_id);
                  // setState(() {
                  //   _isCalling = false;
                  // });
                },
              ),
            ),
          ],
        );
      }),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 70),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //     children: <Widget>[
      //       Container(
      //         // width: 80,
      //         // height: 80,
      //         child: FloatingActionButton(
      //           backgroundColor: redColor,
      //           onPressed: () {
      //             signalingClient.onCancelbytheCaller(registerRes["mcToken"]);
      //             _callProvider.initial();
      //             // _callBloc.add(CallNewEvent());
      //             // signalingClient.onDeclineCall(widget.user.ref_id);
      //             // setState(() {
      //             //   _isCalling = false;
      //             // });
      //           },
      //           child: Icon(Icons.clear),
      //         ),
      //       )
      //     ],
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Scaffold callStart() {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Container(
          child: Stack(children: <Widget>[
            // Positioned(
            //     left: 0.0,
            //     right: 0.0,
            //     top: 0.0,
            //     bottom: 0.0,
            //     child: Container(
            //       margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            //       width: MediaQuery.of(context).size.width,
            //       height: MediaQuery.of(context).size.height,
            //       child:
            meidaType == MediaType.video
                ? remoteVideoFlag
                    ? RTCVideoView(_remoteRenderer,
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
                          _pressDuration,
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
                              ? RTCVideoView(_localRenderer,
                                  key: forsmallView,
                                  mirror: false,
                                  objectFit: RTCVideoViewObjectFit
                                      .RTCVideoViewObjectFitCover)
                              : Container(),
                        ),
                      ),
                    ),
                    // Flexible(
                    //   child: new Container(
                    //       key: new Key("local"),
                    //       margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                    //       decoration: new BoxDecoration(color: Colors.black),
                    //       child: new RTCVideoView(_localRenderer)),
                    // ),
                    //     Container(
                    //   width: orientation == Orientation.portrait ? 90.0 : 120.0,
                    //   height: orientation == Orientation.portrait ? 120.0 : 90.0,
                    //   child: RTCVideoView(_localRenderer,
                    //       key: forsmallView, mirror: true),
                    //   decoration: BoxDecoration(color: Colors.red),
                    // ),
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
                  // : Container(),

                  // FloatingActionButton(
                  //   backgroundColor:
                  //       switchSpeaker ? chatRoomColor : Colors.white,
                  //   elevation: 0.0,
                  //   onPressed: () {
                  //     setState(() {
                  //       switchSpeaker = !switchSpeaker;
                  //     });
                  //     signalingClient.switchSpeaker(switchSpeaker);
                  //   },
                  //   child: switchSpeaker
                  //       ? Icon(Icons.volume_up)
                  //       : Icon(
                  //           Icons.volume_off,
                  //           color: chatRoomColor,
                  //         ),
                  // ),
                  // SizedBox(
                  //   width: 20,
                  // ),
                  GestureDetector(
                    child: SvgPicture.asset(
                      'assets/end.svg',
                    ),
                    onTap: () {
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

      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(bottom: 50),
      //   child: Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      //       children: <Widget>[
      //         FloatingActionButton(
      //           backgroundColor: !switchMute ? redColor : Colors.grey,
      //           onPressed: () {
      //             final bool enabled = signalingClient.muteMic();
      //             print("this is enabled $enabled");
      //             setState(() {
      //               switchMute = enabled;
      //             });
      //           },
      //           child: !switchMute ? Icon(Icons.mic_off) : Icon(Icons.mic),
      //         ),
      //         FloatingActionButton(
      //           backgroundColor: switchSpeaker ? redColor : Colors.grey,
      //           onPressed: () {
      //             setState(() {
      //               switchSpeaker = !switchSpeaker;
      //             });
      //             signalingClient.switchSpeaker(switchSpeaker);
      //           },
      //           child: Icon(Icons.volume_up),
      //         ),
      //         FloatingActionButton(
      //           backgroundColor: !enableCamera ? redColor : Colors.grey,
      //           onPressed: () {
      // setState(() {
      //   enableCamera = !enableCamera;
      // });
      // signalingClient.enableCamera(enableCamera);
      //           },
      //           child: Icon(Icons.videocam_off),
      //         ),
      //         FloatingActionButton(
      //           backgroundColor: Colors.grey,
      //           onPressed: () {
      //             signalingClient.switchCamera();
      //           },
      //           child: Icon(Icons.loop),
      //         ),
      //         Container(
      //           // width: 80,
      //           // height: 80,
      //           child: FloatingActionButton(
      //             onPressed: () {
      // stopCall();
      // // setState(() {
      // //   _isCalling = false;
      // // });
      //             },
      //             child: Icon(Icons.phone),
      //           ),
      //         )
      //       ]),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
                        color: widget.state && isSocketConnect? Colors.green : Colors.red,
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
    // return Container(
    //   padding: EdgeInsets.all(10),
    //   child: Column(
    //     children: [
    //       Card(
    //         child: TextFormField(
    //           controller: _searchController,
    //           onChanged: (value) {
    //             onSearch(value);
    //           },
    //           validator: (value) =>
    //               value.isEmpty ? "Field cannot be empty." : null,
    //           decoration: new InputDecoration(
    //             prefixIcon: Icon(Icons.search),
    //             suffixIcon: IconButton(
    //               icon: Icon(Icons.clear),
    //               onPressed: () {
    //                 setState(() {
    //                   _searchController.clear();
    //                 });
    //               },
    //             ),
    //             // contentPadding: EdgeInsets.only(left: 10),
    //             enabledBorder: OutlineInputBorder(
    //               borderSide:
    //                   BorderSide(color: textfieldBorderColor, width: 1.0),
    //             ),
    //             focusedBorder: OutlineInputBorder(
    //               borderSide: BorderSide(color: redColor, width: 2.0),
    //             ),
    //             hintText: "Search... ",
    //             hintStyle: TextStyle(
    //                 fontSize: 14.0,
    //                 fontWeight: FontWeight.w300,
    //                 fontFamily: font_Family,
    //                 fontStyle: FontStyle.normal,
    //                 color: placeholderTextColor),
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: ListView.builder(
    //           cacheExtent: 9999,
    //           itemCount: _searchController.text.isEmpty
    //               ? state.users.length
    //               : _filteredList.length,
    //           itemBuilder: (context, position) {
    //             var element = _searchController.text.isEmpty
    //                 ? state.users[position]
    //                 : _filteredList[position];
    //             return Card(
    //               child: ListTile(
    //                 leading: Container(
    //                   child: Icon(
    //                     Icons.person,
    //                     color: redColor,
    //                     size: 30,
    //                   ),
    //                 ),
    //                 title: Text(element.full_name),
    //                 // subtitle: Text(state.contactList.users[position].ref_id),
    //                 trailing: Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     IconButton(
    //                         icon: Icon(
    //                           Icons.videocam,
    //                           color: redColor,
    //                         ),
    //                         onPressed: () {
    //                           _startCall(element.ref_id, false);
    //                           setState(() {
    //                             callTo = element.full_name;
    //                           });
    //                         }),
    //                     kIsWeb
    //                         ? IconButton(
    //                             icon: Icon(
    //                               Icons.screen_share,
    //                               color: redColor,
    //                             ),
    //                             onPressed: () {
    //                               _startCall(element.ref_id, true);
    //                               setState(() {
    //                                 callTo = element.full_name;
    //                               });
    //                             })
    //                         : !Platform.isIOS
    //                             ? IconButton(
    //                                 icon: Icon(
    //                                   Icons.screen_share,
    //                                   color: redColor,
    //                                 ),
    //                                 onPressed: () {
    //                                   _startCall(element.ref_id, true);
    //                                   setState(() {
    //                                     callTo = element.full_name;
    //                                   });
    //                                 })
    //                             : Container(),
    //                   ],
    //                 ),

    //                 //   IconButton(
    //                 //       icon: Icon(
    //                 //         Icons.videocam,
    //                 //         color: redColor,
    //                 //       ),
    //                 //       onPressed: () {
    //                 //         _startCall(element.ref_id);
    //                 //         setState(() {
    //                 //           callTo = element.username;
    //                 //         });
    //                 //       }),
    //               ),
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }

  // Widget build(BuildContext context) {
  //   return incomingfrom == null
  //       ? Scaffold(
  //           appBar: AppBar(
  //             title: Text("Home"),
  //           ),
  //           body: Container(
  //             child: Column(
  //               children: [
  //                 videoRenderers(),
  //                 RaisedButton(
  //                   onPressed: _startCall,
  //                   child: Text("start call"),
  //                 )
  //                 // offerAndAnswerButtons(),
  //                 // sdpCandidatesTF(),
  //                 // sdpCandidateButtons(),
  //                 // registerUser(),
  //                 // calltoUser(),
  //               ],
  //             ),
  //           ),
  //         )
  //       : Scaffold(
  //           body: OrientationBuilder(builder: (context, orientation) {
  //             return Container(
  //               child: Stack(children: <Widget>[
  //                 Positioned(
  //                     left: 0.0,
  //                     right: 0.0,
  //                     top: 0.0,
  //                     bottom: 0.0,
  //                     child: Container(
  //                       margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
  //                       width: MediaQuery.of(context).size.width,
  //                       height: MediaQuery.of(context).size.height,
  //                       child: RTCVideoView(
  //                         _localRenderer,
  //                         mirror: true,
  //                       ),
  //                       // decoration: BoxDecoration(color: Colors.red[100]),
  //                     )),
  //                 Positioned(
  //                   left: 0.0,
  //                   top: 0.0,
  //                   child: Container(
  //                     width: MediaQuery.of(context).size.width,
  //                     height:
  //                         orientation == Orientation.portrait ? 120.0 : 120.0,
  //                     child: Column(
  //                       mainAxisAlignment: MainAxisAlignment.end,
  //                       children: [
  //                         Text(
  //                           incomingfrom,
  //                           style: TextStyle(
  //                               color: Colors.red,
  //                               fontSize: 30,
  //                               fontWeight: FontWeight.w700),
  //                         ),
  //                         SizedBox(
  //                           height: 10,
  //                         ),
  //                         Text(
  //                           "Calling...",
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                     // decoration: BoxDecoration(color: Colors.black54),
  //                   ),
  //                 ),
  //               ]),
  //             );
  //           }),
  //           floatingActionButton: Padding(
  //             padding: const EdgeInsets.only(bottom: 50),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: <Widget>[
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   child: FloatingActionButton(
  //                     backgroundColor: redColor,
  //                     onPressed: () {
  //                       // signalingClient.onDeclineCall(widget.registerUser);
  //                       // setState(() {
  //                       //   _isCalling = false;
  //                       // });
  //                     },
  //                     child: Icon(Icons.clear),
  //                   ),
  //                 ),
  //                 Container(
  //                   width: 80,
  //                   height: 80,
  //                   child: FloatingActionButton(
  //                     backgroundColor: Colors.green,
  //                     onPressed: () {
  //                       signalingClient.createAnswer(incomingfrom);
  //                       setState(() {
  //                         // _isCalling = true;
  //                         incomingfrom = null;
  //                       });
  //                       // FlutterRingtonePlayer.stop();
  //                       // Vibration.cancel();
  //                     },
  //                     child: Icon(Icons.phone),
  //                   ),
  //                 )
  //               ],
  //             ),
  //           ),
  //         );
  // }

  // SizedBox videoRenderers() => SizedBox(
  //     height: 210,
  //     child: Row(children: [
  //       Flexible(
  //         child: new Container(
  //             key: new Key("local"),
  //             margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
  //             decoration: new BoxDecoration(color: Colors.white),
  //             child: new RTCVideoView(_localRenderer)),
  //       ),
  //       Flexible(
  //         child: new Container(
  //             key: new Key("Remote"),
  //             margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
  //             decoration: new BoxDecoration(color: Colors.white),
  //             child: new RTCVideoView(_remoteRenderer)),
  //       )
  //     ]));
}
