import 'dart:async';

import 'connectionManager.dart';

//other imports

class ConnectionManagerForIO extends ConnectionManager {
  // String _protocol = "";
  int _timeOutInSec = 10;

  @override
  Stream<bool> internetConnectState() async* {
    StreamController<bool> streamController = new StreamController();
    try {
      // html.window.addEventListener('online', (e) {
      //   print("this is online ${e}");
      //   // onMessage?.call(true);
      //   streamController.add(true);
      // });
      // html.window.addEventListener('offline', (e) {
      //   print("this is offline $e");
      //   streamController.add(false);
      //   // onMessage?.call(false);
      // });

      yield* streamController.stream;
    } catch (ex) {
      throw ex;
    }
  }

  @override
  bool internetConnect() {
    // TODO: implement internetConnect
    return true;
  }

  // @override
  // Future<dynamic> connect(String url) async {
  //   //stuff that uses dart:js
  //   IOWebSocketChannel channel = IOWebSocketChannel.connect(
  //     Uri.parse(url),
  //     // protocols: [_protocol],
  //     pingInterval: Duration(seconds: _timeOutInSec),
  //   );
  //   return channel;
  // }
}

ConnectionManager getConnectionManager() => ConnectionManagerForIO();
