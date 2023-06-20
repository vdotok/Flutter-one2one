import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:vdotok_stream_example/src/core/config/config.dart';
import 'package:vdotok_stream_example/src/core/qrocde/qrcode.dart';
import '../../../src/core/services/server.dart';
import '../models/user.dart';
import '../../shared_preference/shared_preference.dart';

enum Status {
  NotLoggedIn,
  NotRegistered,
  LoggedIn,
  Registered,
  Authenticating,
  LoggedOut,
  Failure,
  Loading
}

class AuthProvider with ChangeNotifier {
  Status _loggedInStatus = Status.Authenticating;
  Status _registeredInStatus = Status.NotRegistered;

  Status get loggedInStatus => _loggedInStatus;
  Status get registeredInStatus => _registeredInStatus;

  User _user = new User(full_name: '', auth_token: '');
  User get getUser => _user;

  late String _completeAddress;
  String get completeAddress => _completeAddress;

  String _projectId="";
  String get projectId => _projectId;
  String _tenantUrl = "";
  String get tenantUrl => _tenantUrl;
  String? _deviceId;
  String? get deviceId => _deviceId;
  SharedPref _sharedPref = SharedPref();
  late String _loginErrorMsg;
  String get loginErrorMsg => _loginErrorMsg;

  late String _registerErrorMsg;
  String get registerErrorMsg => _registerErrorMsg;

  Future<bool> register(String email, username, password) async {
    _registeredInStatus = Status.Loading;
    notifyListeners();

    var version;
    var model;

    if (kIsWeb) {
      version = "web";
      model = "web";
    } else {
      if (Platform.isAndroid) {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        version = androidInfo.version.release;
        model = androidInfo.model;
        // Android 9 (SDK 28), Xiaomi Redmi Note 7
      }

      if (Platform.isIOS) {
        var iosInfo = await DeviceInfoPlugin().iosInfo;
        version = iosInfo.systemName;
        model = iosInfo.model;
        // iOS 13.1, iPhone 11 Pro Max iPhone
      }
    }
    Map<String, dynamic> jsonData = {
      "email": email,
      "full_name": username,
      "password": password,
      "device_type": kIsWeb
          ? "web"
          : Platform.isAndroid
              ? "android"
              : "ios",
      "device_model": model,
      "device_os_ver": version,
      "app_version": "1.1.5",
      "project_id": project == ""? project_id:project
    };
    print("json data of signup  $jsonData");
    final response = await callAPI(jsonData, "SignUp", null);
    print("this is response of sign up $response");
    if (response['status'] != 200) {
      _registeredInStatus = Status.Failure;
      _registerErrorMsg = response['message'];
      notifyListeners();
      return false;
    } else {
        final now = DateTime.now();
      _deviceId = now.microsecondsSinceEpoch.toString();
      _completeAddress = response['media_server_map']['complete_address'];
      _projectId = project == ""? project_id:project;
      _tenantUrl = url == ""?tenant_url:url;
      SharedPref sharedPref = SharedPref();
      sharedPref.save("authUser", response);
       sharedPref.save("deviceId", deviceId);
      sharedPref.save("project_id", projectId);
      sharedPref.save("tenant_url", tenantUrl);
      _registeredInStatus = Status.Registered;
      _loggedInStatus = Status.LoggedIn;
      _user = User.fromJson(response);
      notifyListeners();
      return true;
    }
  }

  login(String username, password) async {
    _loggedInStatus = Status.Loading;
    notifyListeners();

    Map<String, dynamic> jsonData = {
      "email": username,
      "password": password,
      "project_id": project == ""? project_id:project
    };
    final response = await callAPI(jsonData, "Login", null);
    print("this is response $response");
    if (response['status'] != 200) {
      _loggedInStatus = Status.Failure;
      _loginErrorMsg = response['message'];
      notifyListeners();
    } else {
       final now = DateTime.now();
      _deviceId = now.microsecondsSinceEpoch.toString();
      _completeAddress = response['media_server_map']['complete_address'];
       _projectId = project == ""? project_id:project;
      _tenantUrl =url == ""?tenant_url:url;
      print("this is complete address ${_completeAddress}");
      SharedPref sharedPref = SharedPref();
      sharedPref.save("authUser", response);
      sharedPref.save("deviceId", deviceId);
      sharedPref.save("project_id", projectId);
      sharedPref.save("tenant_url", tenantUrl);

      _loggedInStatus = Status.LoggedIn;
      _user = User.fromJson(response);
      notifyListeners();
    }
  }

  logout() {
    SharedPref sharedPref = SharedPref();
    sharedPref.remove("authUser");
    sharedPref.remove("project_id");
    sharedPref.remove("tenant_url");
    sharedPref.remove("deviceId");
    _loggedInStatus = Status.LoggedOut;
    _projectId;
    _tenantUrl;
    _user;
    notifyListeners();
  }

  // Future<Map<String, dynamic>> login(String email, String password) async {
  //   var result;
  //
  //   final Map<String, dynamic> loginData = {
  //     'user': {'email': email, 'password': password}
  //   };
  //
  //   _loggedInStatus = Status.Authenticating;
  //   notifyListeners();
  //
  //   Response response = await post(
  //     AppUrl.login,
  //     body: json.encode(loginData),
  //     headers: {'Content-Type': 'application/json'},
  //   );
  //
  //   if (response.statusCode == 200) {
  //     final Map<String, dynamic> responseData = json.decode(response.body);
  //
  //     var userData = responseData['data'];
  //
  //     User authUser = User.fromJson(userData);
  //
  //     UserPreferences().saveUser(authUser);
  //
  //     _loggedInStatus = Status.LoggedIn;
  //     notifyListeners();
  //
  //     result = {'status': true, 'message': 'Successful', 'user': authUser};
  //   } else {
  //     _loggedInStatus = Status.NotLoggedIn;
  //     notifyListeners();
  //     result = {
  //       'status': false,
  //       'message': json.decode(response.body)['error']
  //     };
  //   }
  //   return result;
  // }

  // Future<Map<String, dynamic>> register(
  //     String email, String password, String passwordConfirmation) async {
  //   final Map<String, dynamic> registrationData = {
  //     'user': {
  //       'email': email,
  //       'password': password,
  //       'password_confirmation': passwordConfirmation
  //     }
  //   };
  //   return await post(AppUrl.register,
  //           body: json.encode(registrationData),
  //           headers: {'Content-Type': 'application/json'})
  //       .then(onValue)
  //       .catchError(onError);
  // }

//   static Future<FutureOr> onValue(Response response) async {
//     var result;
//     final Map<String, dynamic> responseData = json.decode(response.body);
//
//     print(response.statusCode);
//     if (response.statusCode == 200) {
//       var userData = responseData['data'];
//
//       User authUser = User.fromJson(userData);
//
//       UserPreferences().saveUser(authUser);
//       result = {
//         'status': true,
//         'message': 'Successfully registered',
//         'data': authUser
//       };
//     } else {
// //      if (response.statusCode == 401) Get.toNamed("/login");
//       result = {
//         'status': false,
//         'message': 'Registration failed',
//         'data': responseData
//       };
//     }
//
//     return result;
//   }

  isUserLogedIn() async {
    final authUser = await _sharedPref.read("authUser");
    final projId = await _sharedPref.read("project_id");
    final tenantURL = await _sharedPref.read("tenant_url");
    final deviceId = await _sharedPref.read("deviceId");
    print("this is authUser $authUser $projId $tenantURL ");
    if (authUser == null) {
      _loggedInStatus = Status.NotLoggedIn;
      notifyListeners();
    } else {
      _completeAddress =
          jsonDecode(authUser)['media_server_map']['complete_address'];
      _projectId = jsonDecode(projId.toString());
      _tenantUrl = jsonDecode(tenantURL.toString());
       _deviceId = deviceId;
      _loggedInStatus = Status.LoggedIn;
      _user = User.fromJson(jsonDecode(authUser));
      notifyListeners();
    }
  }

  // static onError(error) {
  //   print("the error is $error.detail");
  //   return {'status': false, 'message': 'Unsuccessful Request', 'data': error};
  // }
}
