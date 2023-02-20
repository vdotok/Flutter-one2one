import 'connectionManagerStub.dart'
    if (dart.library.io) './connectionManagerForIO.dart'
    if (dart.library.html) './connectionManagerForWeb.dart';

abstract class ConnectionManager {
  // static ConnectionManager? _instance;

  static ConnectionManager get instance {
    ConnectionManager _instance = getConnectionManager();
    return _instance;
  }

  Stream<bool> internetConnectState();
  bool internetConnect();
}
