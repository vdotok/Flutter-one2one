import 'dart:async';
import 'dart:io';

import 'package:fluttertoast/fluttertoast.dart';

class ExceptionHandlers {
  getExceptionString(error) {
    print('this is error ${error}');
    if (error is SocketException) {
      print('socket--------');
      Fluttertoast.showToast(msg: 'No Internet Available');
      return 'No internet connection.';
    } else if (error is HttpException) {
      Fluttertoast.showToast(msg: 'HttpException');
      return 'HTTP error occured.';
    } else if (error is FormatException) {
      Fluttertoast.showToast(msg: 'FormatException');
      return 'Invalid data format.';
    } else if (error is TimeoutException) {
      Fluttertoast.showToast(msg: 'TimeoutException');
      return 'Request timedout.';
    } else if (error is BadRequestException) {
      Fluttertoast.showToast(msg: 'BadRequestException');
      return error.message.toString();
    } else if (error is UnAuthorizedException) {
      Fluttertoast.showToast(msg: 'UnAuthorizedException');
      return error.message.toString();
    } else if (error is NotFoundException) {
      Fluttertoast.showToast(msg: 'NotFoundException');
      return error.message.toString();
    } else if (error is FetchDataException) {
      Fluttertoast.showToast(msg: 'No Internet Available');
      return error.message.toString();
    } else {
      return 'Unknown error occured.';
    }
  }
}

class AppException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;

  AppException([this.message, this.prefix, this.url]);
}

class BadRequestException extends AppException {
  BadRequestException([String? message, String? url])
      : super(message, 'Bad request', url);
}

class FetchDataException extends AppException {
  FetchDataException([String? message, String? url])
      : super(message, 'Unable to process the request', url);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException([String? message, String? url])
      : super(message, 'Api not responding', url);
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, String? url])
      : super(message, 'Unauthorized request', url);
}

class NotFoundException extends AppException {
  NotFoundException([String? message, String? url])
      : super(message, 'Page not found', url);
}
