import './socketManagerStub.dart'
    if (dart.library.io) './socketManagerForIO.dart'
    if (dart.library.html) './socketManagerForWeb.dart';

abstract class SocketManager {
  // static SocketManager? _instance;

  static SocketManager get instance {
    SocketManager _instance = getSocketManager();
    return _instance;
  }

  Future<dynamic> connect(String url);
}
