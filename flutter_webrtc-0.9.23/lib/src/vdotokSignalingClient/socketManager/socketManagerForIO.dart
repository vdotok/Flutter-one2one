import 'dart:io';

import './socketManager.dart';
import 'package:web_socket_channel/io.dart';
//other imports

class SocketManagerForIO extends SocketManager {
  // String _protocol = "";
  int _timeOutInSec = 10;
  @override
  Future<dynamic> connect(String url) async {
    //stuff that uses dart:js
    try {
      IOWebSocketChannel channel = IOWebSocketChannel.connect(
        Uri.parse(url),
        // protocols: [_protocol],
        pingInterval: Duration(seconds: _timeOutInSec),
      );
      return channel;
    } catch (e) {
      return "error";
    }
  }
}

SocketManager getSocketManager() => SocketManagerForIO();
