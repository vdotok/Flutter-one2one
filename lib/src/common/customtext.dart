import 'package:flutter/material.dart';

import '../../constant.dart';


class CustomText extends StatelessWidget {
  final text;

  const CustomText({Key? key, this.text}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 221,
      //  height: 24,
     // padding: EdgeInsets.only(top: 32),

      child: Text(
        '$text',
        textAlign: TextAlign.center,
        style: TextStyle(
            fontFamily: primaryFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontStyle: FontStyle.normal),
      ),
    );
  }
}
