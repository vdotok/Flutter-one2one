import 'package:flutter/material.dart';

import '../../constant.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator(
        valueColor:AlwaysStoppedAnimation<Color>(greenColor),
       // backgroundColor:  greenColor,
      )),
    );
  }
}
