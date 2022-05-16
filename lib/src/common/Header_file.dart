import 'package:flutter/material.dart';

import '../../constant.dart';


class HeaderFile extends StatelessWidget {
  String? textname;
  String? headername;
  HeaderFile({Key? key, this.headername, this.textname}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Container(
          // height: 150,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        Center(
            child: Image.asset(
          "assets/logo_main.png",
          width: 150,
        )
            // Text(
            //   "VdoTok",
            //   style: TextStyle(
            //       fontSize: 50, fontWeight: FontWeight.w700, color: redColor),
            // ),
            // SvgPicture.asset("assets/images/logofinal.svg"),
            )
      ])),
      SizedBox(height: 20),
      Text("$headername",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 28,
              fontFamily: font_Family,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              color: secondaryColor)),
      SizedBox(height: 5),
      Text("$textname",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 14,
              fontFamily: font_Family,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w400,
              color: textColor))
    ]);
  }
}
