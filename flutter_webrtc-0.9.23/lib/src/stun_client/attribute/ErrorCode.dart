import 'dart:convert';

import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';
import '../util/Utility.dart';
import '../util/exceptions.dart';

class ErrorCode extends MessageAttribute {
  /* 
    *  0                   1                   2                   3
    *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    * |                   0                     |Class|     Number    |
    * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    * |      Reason Phrase (variable)                                ..
    * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    */
  late int responseCode;
  late String reason;

  ErrorCode.withType(super.type) : super.withType();
  ErrorCode() {}

  void setResponseCode(int responseCode) {
    switch (responseCode) {
      case 400:
        reason = "Bad Request";
        break;
      case 401:
        reason = "Unauthorized";
        break;
      case 420:
        reason = "Unkown Attribute";
        break;
      case 430:
        reason = "Stale Credentials";
        break;
      case 431:
        reason = "Integrity Check Failure";
        break;
      case 432:
        reason = "Missing Username";
        break;
      case 433:
        reason = "Use TLS";
        break;
      case 500:
        reason = "Server Error";
        break;
      case 600:
        reason = "Global Failure";
        break;
      default:
        throw InvalidEncoding("Response Code is not valid");
    }
    this.responseCode = responseCode;
  }

  int getResponseCode() {
    return responseCode;
  }

  String getReason() {
    return reason;
  }

  List<int> getBytes() {
    int length = reason.length;
    if ((length % 4) != 0) {
      length += (4 - (length % 4));
    }
    length += 4;
    List<int> result = List.filled(length, 0);
    result.setRange(0, 2, Utility.integerToTwoBytes(typeToInteger(type)));
    result.setRange(2, 4, Utility.integerToTwoBytes(length - 4));
    // List.copyRange(
    //     result, 0, Utility.integerToTwoBytes(typeToInteger(type)), 0, 2);
    // List.copyRange(Utility.integerToTwoBytes(length - 4), 0, result, 2, 2);
    int classHeader = (responseCode ~/ 100).floor();
    result[6] = Utility.integerToOneByte(classHeader);
    result[7] = Utility.integerToOneByte(responseCode % 100);
    List<int> reasonArray = utf8.encode(reason);
    result.setRange(8, reasonArray.length + 8, reasonArray);
    // List.copyRange(reasonArray, 0, result, 8, reasonArray.length);
    return result;
  }

  static ErrorCode parse(List<int> data) {
    try {
      if (data.length < 4) {
        throw InvalidEncoding("Data array too short");
      }
      int classHeaderByte = data[3];
      int classHeader = Utility.oneByteToInteger(classHeaderByte);
      if ((classHeader < 1) || (classHeader > 6)) {
        throw InvalidEncoding("Class parsing error");
      }
      int numberByte = data[4];
      int number = Utility.oneByteToInteger(numberByte);
      if ((number < 0) || (number > 99)) {
        throw InvalidEncoding("Number parsing error");
      }
      int responseCode = ((classHeader * 100) + number);
      ErrorCode result = ErrorCode.withType(MessageAttributeType.ErrorCode);
      result.setResponseCode(responseCode);
      return result;
    } catch (ue) {
      throw InvalidEncoding("Parsing error");
    }
  }
}
