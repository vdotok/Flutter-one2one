import 'package:flutter/material.dart';

import '../../constant.dart';


class PasswordFieldFile extends StatefulWidget {
  String? name;
  bool _autoValidate = true;
  TextEditingController? myController = TextEditingController();
  PasswordFieldFile({Key? key, this.name, this.myController}) : super(key: key);
  @override
  _WidgetHeaderState createState() => _WidgetHeaderState();
}

class _WidgetHeaderState extends State<PasswordFieldFile> {
  get myController => widget.myController;
  @override
  void initState() {
    super.initState();
    //print("this is my header name ${widget.name}");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(0.0),
      width: 335,
      height: 54,
      color: textfieldBackgrounColor,
      child: TextFormField(
        controller: myController,
        validator: (value) =>
            value!.length < 8 ? "Length of Password should be atleast 8" : null,
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(left: 10),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textfieldBorderColor, width: 1.0),
          ),
          hintText: "${widget.name}",
          hintStyle: TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.w300,
              fontFamily: font_Family,
              fontStyle: FontStyle.normal,
              color: placeholderTextColor),
          // suffixIcon: Icon(Icons.access_alarm),
        ),
      ),
    );
  }
}
