import 'package:flutter/foundation.dart';

enum CallStatus { Initial, CallReceive, CallStart, CallDial }

class CallProvider with ChangeNotifier {
  CallStatus _callStatus = CallStatus.Initial;

  CallStatus get callStatus => _callStatus;
  initial() {
    print("this call initaitestate");
    _callStatus = CallStatus.Initial;
    notifyListeners();
  }

  callReceive() {
    _callStatus = CallStatus.CallReceive;
    notifyListeners();
  }

  callStart() {
    _callStatus = CallStatus.CallStart;
    notifyListeners();
  }

  callDial() {
    _callStatus = CallStatus.CallDial;
    notifyListeners();
  }
}
