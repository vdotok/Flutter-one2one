import 'package:flutter/foundation.dart';
import '../../../src/core/models/user.dart';


class UserProvider with ChangeNotifier {
  User? _user ;

  User? get getuser => _user;

   setUser(User user) {
    print("this is user data1 ${user.full_name}");
    _user = user;
    notifyListeners();
  }
}
