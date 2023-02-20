import 'dart:async';

import 'package:simple_connection_checker/simple_connection_checker.dart';

import 'InternetManager.dart';

//other imports

class InternetManagerForIO extends InternetManager {
  final SimpleConnectionChecker _simpleConnectionChecker =
      SimpleConnectionChecker()..setLookUpAddress('pub.dev');
  StreamSubscription? subscription;

  @override
  Stream<bool> internetConnectState() async* {
    print("simple connection checker $_simpleConnectionChecker");
    StreamController<bool> streamController = new StreamController();
    subscription =
        _simpleConnectionChecker.onConnectionChange.listen((connected) {
      print("this is connected $connected");
      if (connected) {
        streamController.add(true);
      } else {
        streamController.add(false);
      }
    });
    yield* streamController.stream;
  }

  @override
  Future<bool> getInternetStatus() async {
    print(
        "this is connected to internet ${SimpleConnectionChecker.isConnectedToInternet()}");
    return await SimpleConnectionChecker.isConnectedToInternet();
  }
}

InternetManager getInternetManager() => InternetManagerForIO();
