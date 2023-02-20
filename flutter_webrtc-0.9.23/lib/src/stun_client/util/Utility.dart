import 'dart:math';

import 'package:flutter/foundation.dart';
import '../util/exceptions.dart';

class Utility {
  static int integerToOneByte(int value) {
    if ((value > pow(2, 15)) || (value < 0)) {
      throw InvalidEncoding(
          ("Integer value " + value.toString()) + " is larger than 2^15");
    }

    return ByteData.sublistView(Uint8List.fromList([value & 0xFF])).getInt8(0);
  }

  static List<int> integerToTwoBytes(int value) {
    List<int> result = List.filled(2, 0);
    if ((value > pow(2, 31)) || (value < 0)) {
      throw InvalidEncoding(
          ("Integer value " + value.toString()) + " is larger than 2^31");
    }

    // result[0] = ((value >>> 8) & 0xFF);
    // result[1] = (value & 0xFF);

    result[0] = ByteData.sublistView(Uint8List.fromList([(value >>> 8) & 0xFF]))
        .getInt8(0);
    result[1] =
        ByteData.sublistView(Uint8List.fromList([value & 0xFF])).getInt8(0);

    return result;
  }

  static List<int> integerToFourBytes(int value) {
    List<int> result = []..length = 4;
    if ((value > pow(2, 63)) || (value < 0)) {
      throw InvalidEncoding(
          ("Integer value " + value.toString()) + " is larger than 2^63");
    }
    result[0] =
        ByteData.sublistView(Uint8List.fromList([((value >> 24) & 0xFF)]))
            .getInt8(0);
    result[1] =
        ByteData.sublistView(Uint8List.fromList([((value >> 16) & 0xFF)]))
            .getInt8(0);
    result[2] =
        ByteData.sublistView(Uint8List.fromList([((value >> 8) & 0xFF)]))
            .getInt8(0);
    result[3] =
        ByteData.sublistView(Uint8List.fromList([(value & 0xFF)])).getInt8(0);
    return result;
  }

  static int oneByteToInteger(int value) {
    return value & 0xFF;
  }

  static int twoBytesToInteger(List<int> value) {
    if (value.length < 2) {
      throw InvalidEncoding("Byte array too short!");
    }
    int temp0 = (value[0] & 0xFF);
    int temp1 = (value[1] & 0xFF);
    return (temp0 << 8) + temp1;
  }

  static int fourBytesToLong(List<int> value) {
    if (value.length < 4) {
      throw InvalidEncoding("Byte array too short!");
    }
    int temp0 = (value[0] & 0xFF);
    int temp1 = (value[1] & 0xFF);
    int temp2 = (value[2] & 0xFF);
    int temp3 = (value[3] & 0xFF);
    return (((temp0 << 24) + (temp1 << 16)) + (temp2 << 8)) + temp3;
  }
}
