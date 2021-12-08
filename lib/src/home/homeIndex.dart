import 'package:flutter/material.dart';
import '../../src/core/providers/call_provider.dart';
import '../../src/core/providers/contact_provider.dart';
import '../../src/home/home.dart';
import 'package:provider/provider.dart';

class HomeIndex extends StatelessWidget {
 
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
