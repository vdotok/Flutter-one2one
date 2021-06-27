import "package:flutter/material.dart";
import '../../src/login/SignInScreen.dart';
import '../../src/register/SignUpScreen.dart';
import '../../src/home/homeIndex.dart';

import '../../src/routing/ErrorRoute.dart';
import 'package:page_transition/page_transition.dart';


class Routers {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    // final args1 = settings.arguments;
    // final args2 = settings.arguments;
    // final args3 = settings.arguments;
    print("these are arguments ${settings.arguments}");
    print("these are arguments ${settings.name}");
    switch (settings.name) {
      case '/register':
        return PageTransition(
            child: SignUpScreen(), type: PageTransitionType.rightToLeft);
        break;
        case '/signin':
       return PageTransition(
            child: SignInScreen(), type: PageTransitionType.rightToLeft);
        break;
      case '/home':
        return PageTransition(
            child: HomeIndex(
              // user: args,
            ),
            type: PageTransitionType.rightToLeft);
        break;
      

      default:
        return MaterialPageRoute(
            builder: (_) => ErrorRoute(routename: settings.name));
    }
  }
}
