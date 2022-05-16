import 'package:flutter/material.dart';

import '../../constant.dart';

class CustomTextButton extends StatelessWidget {
  final handlePress;
  final String? text;

  CustomTextButton({this.text, @required this.handlePress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        handlePress();
        // if (text == "SIGN IN") {
        //   Navigator.pushNamed(context, '/signin');
        // } else if (text == "SIGN UP") {
        //   Navigator.pushNamed(context, '/register');
        // }
      },
      child: Text(
        "$text",
        style: TextStyle(
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w700,
          fontSize: 14.0,
          fontFamily: primaryFontFamily,
          color: darkGreyColor,
        ),
      ),
    );
    // Padding(
    //   padding: EdgeInsets.symmetric(horizontal: 117),
    //   child:
    //   TextButton(
    //       onPressed: handlePress,
    //       child: Text(
    //         this.text,
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           fontStyle: FontStyle.normal,
    //           fontWeight: FontWeight.w700,
    //           fontSize: 14.0,
    //           fontFamily: primaryFontFamily,
    //           color: darkGreyColor,
    //         ),
    //       ),
    //    // ),

    // );
  }
}
