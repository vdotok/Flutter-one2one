import 'dart:convert';

import 'socketManager/socketManager.dart';

typedef void OnMessageCallback(dynamic msg);
typedef void OnCloseCallback(int code, String? reason);
typedef void OnOpenCallback();

class WebSocketConnection {
  String? url;
  var _socket;
  String? _protocol;
  int _timeOutInSec = 10;
  static final WebSocketConnection _instance =
      WebSocketConnection._privateConstructor();
  static WebSocketConnection get instance => _instance;
  WebSocketConnection._privateConstructor();
  WebSocketConnection({required this.url});
  OnOpenCallback? onOpen;
  OnMessageCallback? onMessage;
  OnCloseCallback? onClose;

  connect() async {
    try {
      //_socket = await WebSocket.connect(_url);
      _connectForSelfSignedCert(url).then((socket) {
        if (socket.runtimeType == String) {
          print(socket.runtimeType);
          onClose?.call(500, "some thing went wrong");
        } else {
          _socket = socket;
          onOpen?.call();
          socket.stream.listen((data) {
            onMessage?.call(data);
          }, onDone: () {
            if (socket?.closeReason == null) {
              onClose?.call(socket?.closeCode, "no reason");
            } else {
              onClose?.call(socket?.closeCode, socket!.closeReason);
            }
          });
        }
      }).catchError((onError) {});

      // onOpen?.call();
      // _socket.stream.listen((data) {
      //   onMessage?.call(data);
      // }, onDone: () {
      //   if (_socket!.closeReason == null) {
      //     onClose?.call(_socket!.closeCode, "no reason");
      //   } else {
      //     onClose?.call(_socket!.closeCode, _socket!.closeReason);
      //   }
      // });
    } catch (e) {
      print("this is exception $e");
      onClose?.call(500, e.toString());
    }
  }

  send(Map<String, dynamic> data) {
    if (_socket != null) {
      _socket.sink.add(json.encode(data));
    }
  }

  close() {
    if (_socket != null) _socket.sink.close();
  }

  Future<dynamic> _connectForSelfSignedCert(url) async {
    try {
      dynamic channel = await SocketManager.instance.connect(url);
      return channel;
    } catch (e) {
      print("this is exception $e");
      onClose?.call(500, e.toString());
    }
  }
}
