import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 68,
      // height: 50.36,
       padding: EdgeInsets.fromLTRB(0, 60, 0, 0),

      child: Image.asset(
        'assets/logo.png',
        width: 68,
        height: 50.36,
      ),
    );
  }
}
