import 'dart:async';

import 'connectionManager.dart';
import 'dart:html' as html;
//other imports

class ConnectionManagerForWeb extends ConnectionManager {
  @override
  Stream<bool> internetConnectState() async* {
    StreamController<bool> streamController = new StreamController();
    print("this is userAgent ${html.window.navigator.userAgent}");
    // html.window.navigator.userAgent;
    try {
      html.window.addEventListener('online', (e) {
        print("this is online ${e}");
        // onMessage?.call(true);
        streamController.add(true);
      });
      html.window.addEventListener('offline', (e) {
        print("this is offline $e");
        streamController.add(false);
        // onMessage?.call(false);
      });

      streamController.add(html.window.navigator.onLine!);

      yield* streamController.stream;
    } catch (ex) {
      throw ex;
    }
  }

  @override
  bool internetConnect() {
    return html.window.navigator.onLine!;
  }

  // internetConnectState() {
  //   // html.window.addEventListener('online', (e) {
  //   //   print("this is online ${e}");
  //   //   onMessage?.call(true);
  //   // });
  //   // html.window.addEventListener('offline', (e) {
  //   //   print("this is offline $e");
  //   //   onMessage?.call(false);
  //   // });
  //   // TODO: implement internetConnectState
  //   return html.window.navigator.onLine;
  //   // return html.window.addEventListener(type, (event) => null)
  // }
}

ConnectionManager getConnectionManager() => ConnectionManagerForWeb();
