import 'package:flutter/material.dart'; 
class ErrorRoute extends StatelessWidget {
  final routename;
  ErrorRoute({Key key, @required this.routename}):assert(routename!=null);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
                  body: Center(
                      child: Text('No route defined for $routename')),
                );
  }
}