import 'package:flutter/material.dart';

import '../../constant.dart';

class ReusableButton extends StatefulWidget {
  final String text;
  final handlePress;

  ReusableButton({required this.text, this.handlePress});

  @override
  _ReusableButtonState createState() => _ReusableButtonState();
}

class _ReusableButtonState extends State<ReusableButton> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 65),
      child: Container(
        height: 48,
        width: 160,
        // padding: EdgeInsets.symmetric(horizontal: 65),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
             primary: greenColor,
             shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(5.0),
          ),
           ),
          // elevation: 10.0,
        
          onPressed: () {
            widget.handlePress();
          },
          

          // child: Container(
          //   constraints: BoxConstraints(maxWidth: 400.0, minHeight: 50.0),
          //   alignment: Alignment.center,
          child: Text(
            this.widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
              fontSize: 14.0,
              fontFamily: primaryFontFamily,
              color: Colors.white,
            ),
          ),
          //  ),
          //)
        ),
      ),
    );
    //});
  }
}
