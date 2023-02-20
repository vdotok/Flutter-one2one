


import 'InternetManagerStub.dart'
  if (dart.library.io) './InternetManagerForIO.dart'
    if (dart.library.html) './InternetManagerForWeb.dart';


 abstract class InternetManager {
  
static InternetManager get instance {
    InternetManager _instance = getInternetManager() as InternetManager;
    return _instance;
  }

Stream<bool> internetConnectState();
Future<bool> getInternetStatus();
 





}

