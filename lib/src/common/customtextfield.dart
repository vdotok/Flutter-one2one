import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../constant.dart';

//class customTextField extends
class CustomTextField extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final bool checkFocus;
  CustomTextField(this.text, this.controller, this.checkFocus);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  final String error = '';
  Size? size;

  RegExp emailRegex = new RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
  RegExp userNameRegex = new RegExp(r"^[a-zA-Z0-9_]+$");
  RegExp allowNumber = new RegExp(r"^[0-9]*$");
  String email = '';

  String password = '';

  get myController => widget.controller;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    print("The height: ${size!.height}");

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 17),
      // width: 260,
      //  height: 38,
      child: TextFormField(
          // inputFormatters: this.widget.text == "Username"
          //     ? [
          //         FilteringTextInputFormatter(RegExp("[0-9a-zA-Z_]"),
          //             allow: true)
          //       ]
          //     : [],
          controller: myController,
          // maxLines: null,
          textInputAction: widget.checkFocus == true
              ? TextInputAction.next
              : TextInputAction.done,
          obscureText: (widget.text == "Password") ? true : false,
          //textInputAction: TextInputAction.next,
          style: TextStyle(color: textTypeColor),
          decoration: InputDecoration(
              filled: true,
              isDense: true,
              fillColor: chatRoomBackgroundColor,
              hoverColor: greycolor,
              hintText: this.widget.text,
              hintStyle: TextStyle(
                  fontSize: 14.0,
                  color: tileGreenColor,
                  fontFamily: secondaryFontFamily),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: lightgreycolor)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15.0),
                borderSide: BorderSide(
                  color: lightGreyColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: BorderSide(color: focusedBorderColor))),
          validator: (value) {
            if (value!.isEmpty) {
              print("The value:${value}");
              return "Field cannot be empty";
            }
            if (widget.text == "Username" && value.length < 4)
              return "Min 4 to 20 characters ";
            if (widget.text == "Username" && (!userNameRegex.hasMatch(value)))
              return "Just alphanumeric characters are allowed.";
            if (widget.text == "Username" && (allowNumber.hasMatch(value)))
              return "Just numeric values are not allowed.";
            if (widget.text == "Username" && value.length > 20)
              return "Maximum 20 characters";
            if (widget.text == "Password" && value.length < 8)
              return "Minimum 8 characters";
            if (widget.text == "Password" && value.length > 14)
              return "Maximum 14 characters";
            if (value.indexOf(' ') >= 0)
              return "Field cannot contain blank spaces";
            if ((this.widget.text == "Email Address") &&
                (!emailRegex.hasMatch(value)))
              return 'Please enter a valid email';
            else
              return null;
          }),
    );
    // // return Container(
    // //   padding: EdgeInsets.symmetric(horizontal: 15),
    // //   width: 260,
    // //   height: size.height / 22.7,
    // //   child: TextFormField(
    // //       textInputAction: TextInputAction.next,
    // //       controller: myController,
    // //       maxLines: 1,
    // //       autofocus: true,
    // //       decoration: new InputDecoration(
    // //         //   errorText: error,
    // //         hoverColor: greycolor,
    // //         filled: true,
    // //         fillColor: greycolor,

    // //         // focusedBorder: OutlineInputBorder(
    // //         //   borderRadius: BorderRadius.all(Radius.circular(15.0)),
    // //         //   borderSide: BorderSide(
    // //         //     color: lightgreycolor,
    // //         //     width: 1.0,
    // //         //   ),
    // //         // ),

    // //         border: OutlineInputBorder(
    // //           borderRadius: BorderRadius.circular(15.0),
    // //           borderSide: BorderSide(
    // //             color: lightgreycolor,
    // //           ),
    // //         ),
    // //         hintText: this.widget.text,
    // //         contentPadding: const EdgeInsets.only(
    // //           top: 11.0,
    // //           left: 15,
    // //         ),
    //         hintStyle: TextStyle(
    //             fontSize: 14.0,
    //             color: darkIndigoColor,
    //             fontFamily: secondaryFontFamily),
    //         enabledBorder: OutlineInputBorder(
    //           borderRadius: BorderRadius.circular(15.0),
    //           borderSide: BorderSide(
    //             color: lightGreyColor,
    //           ),
    //         ),
    //       ),
    // validator: (value) {
    //   if (value.isEmpty) return "Field cannot be empty";
    //   if (widget.text == "Your name" && value.length < 6)
    //     return "Entry should be at least 6 characters long";
    //   if (widget.text == "Create Password" && value.length < 6)
    //     return "Entry should be at least 6 characters long";
    //   if (widget.text == "Your name" && value.length > 14)
    //     return "Entry should not exceed 14 characters";
    //   if (widget.text == "Create Password" && value.length > 14)
    //     return "Entry should not exceed 14 characters";
    //   if (value.indexOf(' ') >= 0)
    //     return "Field cannot contain blank spaces";
    //   if (this.widget.text == "Your email" && !emailRegex.hasMatch(value))
    //     return 'Please enter a valid email';
    //   else
    //     return null;
    // }),
    // );
  }
}
