import 'package:flutter/material.dart';
import '../../constant.dart';

class TextFieldFile extends StatefulWidget {
  String? name;
  bool? _autoValidate = true;
  TextEditingController? myController = TextEditingController();
  TextFieldFile({Key? key, this.name, this.myController}) : super(key: key);
  @override
  _WidgetHeaderState createState() => _WidgetHeaderState();
}

class _WidgetHeaderState extends State<TextFieldFile> {
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
        validator: (value) => value!.isEmpty ? "Field cannot be empty." : null,
        decoration: new InputDecoration(
          contentPadding: EdgeInsets.only(left: 10),
          // contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
        ),
      ),
    );
  }
}
