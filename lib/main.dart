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
//         RaisedButton.icon(
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

import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vdotok_stream/vdotok_stream.dart';
import 'src/core/providers/auth.dart';
import 'src/home/homeIndex.dart';
import 'src/login/SignInScreen.dart';

import 'src/routing/routes.dart';
import 'src/splash/splash.dart';
import 'package:provider/provider.dart';

import 'constant.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
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
  bool state = true;
  bool connectionState = false;
  bool keepShowing = false;
  bool isDeviceConnected = false;
  bool isdev=true;
GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey;

@override
  void initState() {
    super.initState();
    rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
    checkStatus();
    checkConnectivity();
  }
checkStatus() async {
    if (!kIsWeb) {
      bool connectivity = await DataConnectionChecker().hasConnection;
      print("this is for web $connectivity");
      if (connectivity == true) {
        setState(() {
          state = true;
          print("here in state circle");
        });
      } else {
        setState(() {
          state = false;
        });
      }
    }
  }

  void checkConnectivity() async {
     isDeviceConnected = false;
    if (!kIsWeb) {
      DataConnectionChecker().onStatusChange.listen((status) async {
        print("this on listener");
        isDeviceConnected = await DataConnectionChecker().hasConnection;
        print("this is is connected $isDeviceConnected");
        if (isDeviceConnected == true) {
        
          if (state == true)
            state = false;
          else{
          setState(() {
            isdev=true;
          });
            showSnackbar("Internet Connected", whiteColor, Colors.green, false);}
        } else {
          {
            setState(() {
              isdev=false;
            });
          showSnackbar(
              "No Internet Connection", whiteColor, primaryColor, true);
          }
        }
      });
    }
  }

  showSnackbar(text, Color color, Color backgroundColor, bool check) {
    if (check == false) {
      rootScaffoldMessengerKey.currentState
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
      rootScaffoldMessengerKey.currentState
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            '$text',
            style: TextStyle(color: color),
          ),
          backgroundColor: backgroundColor,
          duration: Duration(days: 1),
        ));
    }
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
              return HomeIndex(state:isdev);
            } else
              return SignInScreen();
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
  SignalingClient signalingClient;
  @override
  void initState() {
    // TODO: implement initState

    signalingClient = SignalingClient.instance;
    // signalingClient.methodInvoke();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder(
                stream: signalingClient.numberStream(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.hasData)
                    return Text(snapshot.data.toString());
                  else if (snapshot.hasError)
                    return Text("no data found");
                  else
                    return Text("no data found");
                }),
            RaisedButton(
              onPressed: () {
                // signalingClient.handleLocationChanges();
              },
              child: Text("invoke method"),
            )
          ],
        ),
      ),
    );
  }
}
