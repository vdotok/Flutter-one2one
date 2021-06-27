// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';



// import '../common/Header_file.dart';
// import '../common/Passwordfield.dart';
// import '../common/SignIn_Button.dart';
// import '../common/TextField_file.dart';
// import '../common/loadingButton.dart';
// import '../core/providers/auth.dart';


// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final GlobalKey<FormState> _loginformkey = GlobalKey<FormState>();
//   bool _autoValidate = false;
//   final _emailController = new TextEditingController();
//   final _passwordController = new TextEditingController();

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     // _loginBloc = BlocProvider.of<LoginBloc>(context);
//   }

//   handlePress() async {
//     if (_loginformkey.currentState.validate()) {
//       AuthProvider auth = Provider.of<AuthProvider>(context, listen: false);
//       auth.login(_emailController.text, _passwordController.text);

//       // _loginBloc
//       //     .add(LoginEvent(_emailController.text, _passwordController.text));
//     }
//     // _authBloc.add(LoadingEvent());
//     // Navigator.of(context).pushNamed("/register");
//     // _loginBloc.add(LoginLoadingEvent());
//   }

//   handleRegister() {
//     // _loginBloc.add(RegisterScreenEvent());
//     // // Navigator.pushNamed(context, "/register");
//     // Navigator.of(context).pushNamed("/register");
//     Navigator.pushNamed(context, "/register");
//   }

//   @override
//   Widget build(BuildContext context) {
//     // return
//     // BlocListener<LoginBloc, LoginBlocState>(listener: (context, state) {
// //       if (state is RegisterFailurState) {
// //         final snackBar = SnackBar(content: Text(state.error));
// //
// // // Find the Scaffold in the widget tree and use it to show a SnackBar.
// //         Scaffold.of(context).showSnackBar(snackBar);
// //       }
// //       if (state is LoginFailurState) {
// //         final snackBar = SnackBar(content: Text(state.error));
// //
// // // Find the Scaffold in the widget tree and use it to show a SnackBar.
// //         Scaffold.of(context).showSnackBar(snackBar);
// //       }
//     // TODO: implement listener
//     // }, child:
//     // BlocBuilder<LoginBloc, LoginBlocState>(
//     //   builder: (context, state) {
//     // if (state is RegisterState) {
//     //   return RegisterScreen();
//     // }
//     // if (state is LoginLoading)
//     //   return Center(
//     //     child: CircularProgressIndicator(),
//     //   );
//     // else
//     //   return BlocBuilder<LoginBloc, LoginBlocState>(
//     //     builder: (context, state) {
//     return Scaffold(
//       body: SingleChildScrollView(
//         child: Container(
//           //color: screenbackgroundColor,
//           child: Form(
//             key: _loginformkey,
//             autovalidate: true,
//             child: Column(
//               children: <Widget>[
//                 SizedBox(height: 100),
//                 HeaderFile(
//                     headername: 'Welcome Back!',
//                     textname: 'Login with username and password.'),
//                 SizedBox(height: 30),
//                 TextFieldFile(
//                     name: "User Name", myController: _emailController),
//                 SizedBox(height: 10),
//                 PasswordFieldFile(
//                     name: "Password", myController: _passwordController),
//                 SizedBox(height: 50),
//                 // SingnInGoogle_Button(
//                 //   onPressed: handleGoogleLogin,
//                 //   name: "Sign In with Google",
//                 // ),

//                 Consumer<AuthProvider>(
//                   builder: (context, auth, child) {
//                     if (auth.loggedInStatus == Status.Failure)
//                       return Text(
//                         auth.errorMsg,
//                         style: TextStyle(color: Colors.red),
//                       );
//                     else
//                       return Container();
//                   },
//                 ),
//                 SizedBox(height: 15),
//                 Consumer<AuthProvider>(
//                   builder: (context, auth, child) {
//                     if (auth.loggedInStatus == Status.Loading)
//                       return LoadingButton();
//                     else
//                       return SignInButtonFile(
//                         name: "Sign In",
//                         handlePress: handlePress,
//                       );
//                   },
//                 ),

//                 SizedBox(height: 30),
//                 SignInButtonFile(
//                   name: "Sign UP",
//                   handlePress: handleRegister,
//                 ),
//                 SizedBox(height: 10),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//     //   },
//     // );
//     //   },
//     // )
//     // );
//   }
// }
