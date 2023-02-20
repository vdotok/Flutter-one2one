import './socketManager.dart';
import 'package:web_socket_channel/html.dart';
//other imports

class SocketManagerForWeb extends SocketManager {
  @override
  Future<dynamic> connect(String url) async {
    HtmlWebSocketChannel channel = HtmlWebSocketChannel.connect(
      Uri.parse(url),
    );
    return channel;

    // return "this is from web";
    //stuff that uses dart:js
  }
}

SocketManager getSocketManager() => SocketManagerForWeb();
