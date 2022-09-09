// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:vdotok_stream/vdotok_stream.dart';
// import 'package:vdotok_stream_example/constant.dart';
// import 'package:vdotok_stream_example/sample.dart';
// import 'package:vdotok_stream_example/src/landingScreen.dart';
// import 'package:vdotok_stream_example/src/login/bloc/login_bloc.dart';
// import 'package:vdotok_stream_example/src/login/loginIndex.dart';
// import 'package:vdotok_stream_example/src/routing/routes.dart';
//
// class MyHttpOverrides extends HttpOverrides {
//   @override
//   HttpClient createHttpClient(SecurityContext context) {
//     return super.createHttpClient(context)
//       ..badCertificateCallback =
//           (X509Certificate cert, String host, int port) => true;
//   }
// }
//
// void main() {
//   HttpOverrides.global = new MyHttpOverrides();
//   runApp(App());
// }
//
// class App extends StatefulWidget {
//   @override
//   _AppState createState() => _AppState();
// }
//
// class _AppState extends State<App> {
//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<LoginBloc>(
//           create: (BuildContext context) => LoginBloc()..add(InitialEvent()),
//         )
//       ],
//       child: MaterialApp(
//         theme: ThemeData(
//             accentColor: primaryColor,
//             primaryColor: primaryColor,
//             scaffoldBackgroundColor: Colors.white,
//             textTheme: TextTheme(
//               bodyText1: TextStyle(color: secondaryColor),
//               bodyText2: TextStyle(color: secondaryColor), //Text
//             )),
//         onGenerateRoute: Routers.generateRoute,
//         home: LoginIndex(),
//         // home: GetUserMediaSample(),
//         // BlocProvider(
//         //   create: (context) => LoginBloc()..add(InitialEvent()),
//         //   child: LoginIndex(),
//         // ),
//       ),
//     );
//   }
// }
//
// class TestingNative extends StatefulWidget {
//   @override
//   _TestingNativeState createState() => _TestingNativeState();
// }
//
// class _TestingNativeState extends State<TestingNative> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("from native"),
//       ),
//       body: TextView(),
//     );
//   }
// }
//
// class MyApp extends StatefulWidget {
//   @override
//   _MyAppState createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   SignalingClient signalingClient = SignalingClient.instance;
//   RTCVideoRenderer _localRenderer = new RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = new RTCVideoRenderer();
//
//   TextEditingController _registerController = TextEditingController();
//   TextEditingController _callController = TextEditingController();
//   @override
//   void initState() {
//     super.initState();
//     initRenderers();
//     // Listeners
//     signalingClient.connect();
//     signalingClient.onConnect = (res) {
//       print("onConnect $res");
//       // signalingClient.register("thisusername123");
//     };
//     // signalingClient.onRegister = (res) {
//     //   print("onRegister $res");
//     // };
//     signalingClient.onError = (e, m) {
//       print("on Error $e, $m");
//     };
//     signalingClient.onLocalStream = (stream) {
//       print("this is stream id ${stream.id}");
//       setState(() {
//         _localRenderer.srcObject = stream;
//       });
//     };
//     // signalingClient.onRemoteStream = (stream) {
//     //   print("this is stream id ${stream.id}");
//     //   setState(() {
//     //     _remoteRenderer.srcObject = stream;
//     //   });
//     // };
//   }
//
//   initRenderers() async {
//     await _localRenderer.initialize();
//     await _remoteRenderer.initialize();
//   }
//
//   register() {
//     // signalingClient.register(_registerController.text);
//   }
//
//   startCall() {
//     print("this is on call");
//     signalingClient.startCall(
//         from: _registerController.text, to: _callController.text);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//           primaryColor: primaryColor,
//           scaffoldBackgroundColor: Colors.white,
//           textTheme: TextTheme(
//             bodyText1: TextStyle(color: secondaryColor),
//             bodyText2: TextStyle(color: secondaryColor), //Text
//           )),
//       home: LandingPage(),
//
//       //   home: Scaffold(
//       //     appBar: AppBar(
//       //       title: const Text('Plugin example app'),
//       //     ),
//       //     body: Column(
//       //       children: [
//       //         Center(
//       //           child: Text('Running on:'),
//       //         ),
//       //         registerRow(),
//       //         callRow(),
//       //         ElevatedButton(onPressed: startCall, child: Text("Start call")),
//       //         Flexible(
//       //           child: new Container(
//       //               key: new Key("local"),
//       //               margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//       //               decoration: new BoxDecoration(color: Colors.black),
//       //               child: new RTCVideoView(_localRenderer)),
//       //         ),
//       //         Flexible(
//       //           child: new Container(
//       //               key: new Key("local"),
//       //               margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
//       //               decoration: new BoxDecoration(color: Colors.black),
//       //               child: new RTCVideoView(_remoteRenderer)),
//       //         ),
//       //       ],
//       //     ),
//       //   ),
//     );
//   }
//
//   Row registerRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _registerController,
//             decoration: const InputDecoration(
//               icon: Icon(Icons.person),
//               labelText: 'Peer user name',
//             ),
//           ),
//         ),
//         ElevatedButton.icon(
//           onPressed: () {
//             register();
//           },
//           label: Text("Make Video call"),
//           icon: Icon(Icons.camera),
//         )
//       ],
//     );
//   }
//
//   Row callRow() {
//     return Row(
//       children: [
//         Expanded(
//           child: TextFormField(
//             controller: _callController,
//             decoration: const InputDecoration(
//               icon: Icon(Icons.person),
//               labelText: 'Call to',
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   @override
//   dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:jada/pages/dashboard.dart';
// import 'package:jada/pages/login.dart';
// import 'package:jada/pages/register.dart';
// import 'package:jada/pages/welcome.dart';
// import 'package:jada/providers/auth.dart';
// import 'package:jada/providers/user_provider.dart';
// import 'package:jada/util/shared_preference.dart';
// import 'package:provider/provider.dart';
//
// import 'domain/user.dart';
//
// void main() {
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//      // UserPreferences().setUser();
//     Future<User> getUserData() => UserPreferences().getUser();
//
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//       ],
//       child: MaterialApp(
//           title: 'Flutter Demo',
//           theme: ThemeData(
//             primarySwatch: Colors.blue,
//             visualDensity: VisualDensity.adaptivePlatformDensity,
//           ),
//           home: FutureBuilder(
//               future: getUserData(),
//               builder: (context, snapshot) {
//                 switch (snapshot.connectionState) {
//                   case ConnectionState.none:
//                   case ConnectionState.waiting:
//                     return CircularProgressIndicator();
//                   default:
//                     if (snapshot.hasError)
//                       return Text('Error: ${snapshot.error}');
//                     else if (snapshot.data.token == null)
//                       return Login();
//                     else
//                       UserPreferences().removeUser();
//                     return Welcome(user: snapshot.data);
//                 }
//               }),
//           routes: {
//             '/dashboard': (context) => DashBoard(),
//             '/login': (context) => Login(),
//             '/register': (context) => Register(),
//           }),
//     );
//   }
// }

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vdotok_stream/vdotok_stream.dart';
import 'package:vdotok_stream_example/src/home/home.dart';
import 'src/core/providers/auth.dart';
import 'src/home/homeIndex.dart';
import 'src/login/SignInScreen.dart';

import 'src/routing/routes.dart';
import 'src/splash/splash.dart';
import 'package:provider/provider.dart';

import 'constant.dart';

GlobalKey<ScaffoldMessengerState>? rootScaffoldMessengerKey;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() {
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..isUserLogedIn()),
      ],
      child: MaterialApp(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        title: 'Vdotok Video',
        theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.grey,
            ).copyWith(),
            accentColor: primaryColor,
            primaryColor: primaryColor,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              bodyText1: TextStyle(color: secondaryColor),
              bodyText2: TextStyle(color: secondaryColor), //Text
            )),
        onGenerateRoute: Routers.generateRoute,
        home: Consumer<AuthProvider>(
          builder: (context, auth, child) {
            if (auth.loggedInStatus == Status.Authenticating)
              return SplashScreen();
            else if (auth.loggedInStatus == Status.LoggedIn) {
              print("here before home index");
              // return Test();
              return HomeIndex();
            } else {
              // return Test();
              return SignInScreen();
            }
          },
        ),
      ),
    );
  }
}

class Test extends StatefulWidget {
  @override
  _TestState createState() => _TestState();
}

class _TestState extends State<Test> {
  SignalingClient? signalingClient;
  MediaStream? _localStream;
  RTCVideoRenderer _localRenderer = new RTCVideoRenderer();

  @override
  void initState() {
    // TODO: implement initState

    initRenderers();

    signalingClient = SignalingClient.instance;
    // signalingClient.methodInvoke();
    super.initState();

    signalingClient!.onLocalStream = (stream) {
      print("this is local stream ${stream.id}");
      setState(() {
        _localRenderer.srcObject = stream;
      });
    };
    // signalingClient.getPermissions();
  }

  initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 200,
              height: 300,
              child: RTCVideoView(_localRenderer,
                  mirror: false,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover),
            ),
            ElevatedButton(
              onPressed: () {
                signalingClient!.getNumber();
              },
              child: Text("Create peerConnection"),
            ),
            ElevatedButton(
              onPressed: () {
                //signalingClient.creteOffermannual();
              },
              child: Text("createOffer"),
            ),
            ElevatedButton(
              onPressed: () {
                signalingClient!.getMedia();
              },
              child: Text("getUserMedia"),
            ),
            ElevatedButton(
              onPressed: () {
                // signalingClient.getDisplay();
              },
              child: Text("getUserDisplayMedia"),
            ),
            ElevatedButton(
              onPressed: () {
                // signalingClient.getinternal();
              },
              child: Text("getInternalAudio"),
            )
          ],
        ),
      ),
    );
  }
}
