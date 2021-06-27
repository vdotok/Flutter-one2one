// import 'dart:io';

// import 'package:device_info/device_info.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// import '../../src/common/Header_file.dart';
// import '../../src/common/Passwordfield.dart';
// import '../../src/common/SignIn_Button.dart';
// import '../../src/common/TextField_file.dart';
// import '../../src/common/loadingButton.dart';
// import '../../src/core/providers/auth.dart';
// import 'package:provider/provider.dart';

// class RegisterScreen extends StatefulWidget {
//   @override
//   _RegisterScreenState createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final GlobalKey<FormState> _registerformkey = GlobalKey<FormState>();
//   bool _autoValidate = false;
//   final _emailController = new TextEditingController();
//   final _passwordController = new TextEditingController();
//   String errorMsg = "";
//   // LoginBloc _loginBloc;
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // _loginBloc = BlocProvider.of<LoginBloc>(context);
//   }

//   handlePress() async {
//     if (_registerformkey.currentState.validate()) {
//       AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
//       bool res = await auth.register(_emailController.text, _passwordController.text);
//       if(res)
//         Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);

//       // _loginBloc
//       //     .add(RegisterEvent(_emailController.text, _passwordController.text));
//     } else {
//       // setState(() {
//       //   errorMsg =
//       //       "Fields cannot be empty and password length should be 8 or greater";
//       // });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Register user"),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           //color: screenbackgroundColor,
//           child: Form(
//             key: _registerformkey,
//             autovalidate: true,
//             child: Column(
//               children: <Widget>[
//                 SizedBox(height: 20),
//                 HeaderFile(
//                     headername: 'Create a user',
//                     textname: 'Register with username and password.'),
//                 SizedBox(height: 30),
//                 TextFieldFile(
//                     name: "User Name", myController: _emailController),
//                 SizedBox(height: 10),
//                 PasswordFieldFile(
//                     name: "Password", myController: _passwordController),
//                 SizedBox(height: 15),
//                 Text(
//                   errorMsg,
//                   style: TextStyle(color: Colors.red, fontSize: 12),
//                 ),
//                 SizedBox(height: 50),
//                 // SingnInGoogle_Button(
//                 //   onPressed: handleGoogleLogin,
//                 //   name: "Sign In with Google",
//                 // ),
//                 // SizedBox(height: 15),
//                 Consumer<AuthProvider>(
//                   builder: (context, auth, child) {
//                     if (auth.registeredInStatus == Status.Failure)
//                       return Text(auth.errorMsg, style: TextStyle(color: Colors.red),);
//                     else
//                       return Container();
//                   },
//                 ),
//                 SizedBox(height: 15),
//                 Consumer<AuthProvider>(
//                   builder: (context, auth, child) {
//                     if (auth.registeredInStatus == Status.Loading)
//                       return LoadingButton();
//                     else
//                       return  SignInButtonFile(
//                         name: "Register",
//                         handlePress: handlePress,
//                       );
//                   },
//                 ),


//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
