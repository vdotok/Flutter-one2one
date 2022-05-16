import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../src/common/logo.dart';
import '../../src/common/custombutton.dart';
import '../../src/common/customtext.dart';
import '../../src/common/customtextbutton.dart';
import '../../src/common/customtextfield.dart';
import '../../src/common/loadingButton.dart';
import '../../src/core/providers/auth.dart';
import 'package:provider/provider.dart';

import '../../constant.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _registerformkey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoValidate = false;
  bool emailvalidate = false;
  bool passwordvalidate = false;
  bool namevalidate = false;
  Size? size;

  handlePress() async {
    if (_registerformkey.currentState!.validate()) {
      AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
      bool res = await auth.register(_emailController.text,
          _nameController.text, _passwordController.text);
      if (auth.getUser.auth_token == null) {
        setState(() {
          _autoValidate = true;
        });
      }
      if (res) {
        Navigator.pop(context);
      }
      ;
    } else {
      setState(() {
        _autoValidate = true;
      });
    }
  }

  handleButton() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar color
      statusBarBrightness: Brightness.light, //status bar brigtness
      statusBarIconBrightness: Brightness.dark, //status barIcon Brightness
    ));

    size = MediaQuery.of(context).size;
    print("The size is : ${size!.height * 1.08}");
    return GestureDetector(
        onTap: () {
          FocusScopeNode currentFous = FocusScope.of(context);
          if (!currentFous.hasPrimaryFocus) {
            currentFous.unfocus();
          }
        },
        child: Container(
            // width: 375,
            // height: size.height * 1.08,
            decoration: BoxDecoration(
                gradient: LinearGradient(
              colors: [
                backgroundGradientColor,
                backgroundGradientColor2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )),
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.transparent,
                //backgroundColor: Colors.amber,
                body: SingleChildScrollView(
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(left: 42, right: 42),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,

                        // mainAxisSize: MainAxisSize.min,
                        children: [
                          Logo(),
                          SizedBox(height: 39.64),
                          // CardView(text:"Sign Up to your account"),
                          //    Expanded(
                          Form(
                           autovalidateMode: AutovalidateMode.always,
                            key: _registerformkey,

                            child: Container(
                              width: 290,
                              height: 510,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    child: Column(
                                      children: [
                                        SizedBox(height: 32),
                                        CustomText(
                                            text: "Sign Up to your account"),
                                        SizedBox(height: 34),
                                        CustomTextField(
                                            "Username", _nameController, true),

                                        SizedBox(
                                          height: 16,
                                        ),
                                        CustomTextField("Email Address",
                                            _emailController, true),
                                        SizedBox(
                                          height: 16,
                                        ),
                                        CustomTextField("Password",
                                            _passwordController, false),
                                        // SizedBox(height: 82),

                                        Consumer<AuthProvider>(
                                          builder: (context, auth, child) {
                                            if (auth.registeredInStatus ==
                                                Status.Failure)
                                              return Text(
                                                auth.registerErrorMsg,
                                                style: TextStyle(
                                                    color: Colors.red),
                                              );
                                            else
                                              return Container();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Consumer<AuthProvider>(
                                            builder: (context, auth, child) {
                                          if (auth.registeredInStatus ==
                                              Status.Loading)
                                            return LoadingButton();
                                          else
                                            return ReusableButton(
                                                text: "SIGN UP",
                                                handlePress: handlePress);
                                        }),

                                        SizedBox(height: 38),
                                        // Text("hello")
                                        CustomTextButton(
                                          text: "SIGN IN",
                                          handlePress: handleButton,
                                        ),
                                        SizedBox(height: 36),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //),

                            // SizedBox(
                            //   height: 127,
                            // )
                          ),
                        ]),
                  ),
                ),
              ),
              // ),
            )));
  }
}

class CustomButton {}
