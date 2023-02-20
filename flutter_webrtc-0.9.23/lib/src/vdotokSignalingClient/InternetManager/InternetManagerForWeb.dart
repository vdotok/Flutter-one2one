import 'dart:async';

import 'InternetManager.dart';
import 'dart:html' as html;
//other imports

class InternetManagerForWeb extends InternetManager {
  @override
  Stream<bool> internetConnectState() async* {
    StreamController<bool> streamController = new StreamController();
    print("this is userAgent ${html.window.navigator.userAgent}");
    // html.window.navigator.userAgent;
    try {
      html.window.addEventListener('online', (e) {
        print("this is online ${e}");
       
        streamController.add(true);
      });
      html.window.addEventListener('offline', (e) {
        print("this is offline $e");
        streamController.add(false);
        
      });

      streamController.add(html.window.navigator.onLine!);

      yield* streamController.stream;
    } catch (ex) {
      throw ex;
    }
  }

  @override
  Future<bool> getInternetStatus()async {
    return  html.window.navigator.onLine!;
  }
  
 
  
  
}

InternetManager getInternetManager() => InternetManagerForWeb();
