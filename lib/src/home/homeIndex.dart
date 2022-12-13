import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../src/core/providers/call_provider.dart';
import '../../src/core/providers/contact_provider.dart';
import '../../src/home/home.dart';
import 'package:provider/provider.dart';

class HomeIndex extends StatefulWidget {
 
  @override
  State<HomeIndex> createState() => _HomeIndexState();
}

class _HomeIndexState extends State<HomeIndex> {
   @override
  void initState() {
    super.initState();
     _getPermissions();
  }
   Future<bool> _getPermissions() async {
    PermissionStatus cameraStatus;
    PermissionStatus audioStatus;

   
      cameraStatus = await Permission.camera.request();
      audioStatus = await Permission.microphone.request();
      print(
          "this is camera dn microphone permission $cameraStatus $audioStatus");
      if (cameraStatus.isPermanentlyDenied || audioStatus.isPermanentlyDenied) {
        openAppSettings();
      }
      if (cameraStatus.isGranted && audioStatus.isGranted) {
        return true;
      } else
       { return false;}
    
  }
  @override
  Widget build(BuildContext context) {
 
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => CallProvider()),
      ],
      child: Scaffold(
        body: Home(),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// class HomeIndex extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(body: Text("Homee page"),);
//   }
// }
