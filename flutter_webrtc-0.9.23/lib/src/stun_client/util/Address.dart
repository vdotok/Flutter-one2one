import 'dart:io';

import '../util/Utility.dart';
import '../util/exceptions.dart';

class Address {
  late int firstOctet;
  late int secondOctet;
  late int thirdOctet;
  late int fourthOctet;

  Address(int firstOctet, int secondOctet, int thirdOctet, int fourthOctet) {
    if ((((((((firstOctet < 0) || (firstOctet > 255)) || (secondOctet < 0)) ||
                        (secondOctet > 255)) ||
                    (thirdOctet < 0)) ||
                (thirdOctet > 255)) ||
            (fourthOctet < 0)) ||
        (fourthOctet > 255)) {
      throw InvalidEncoding("Address is malformed.");
    }
    this.firstOctet = firstOctet;
    this.secondOctet = secondOctet;
    this.thirdOctet = thirdOctet;
    this.fourthOctet = fourthOctet;
  }

  Address.withAddressString(String address) {
    List<String> st = address.split(".");
    if (st.length != 4) {
      throw InvalidEncoding("4 octets in address string are required.");
    }
    int i = 0;
    while (i < st.length) {
      int temp = int.parse(st[i]);
      if ((temp < 0) || (temp > 255)) {
        throw InvalidEncoding("Address is in incorrect format.");
      }
      switch (i) {
        case 0:
          firstOctet = temp;
          ++i;
          break;
        case 1:
          secondOctet = temp;
          ++i;
          break;
        case 2:
          thirdOctet = temp;
          ++i;
          break;
        case 3:
          fourthOctet = temp;
          ++i;
          break;
      }
    }
  }

  Address.withBytesList(List<int> address) {
    if (address.length < 4) {
      throw new InvalidEncoding("4 bytes are required.");
    }
    firstOctet = Utility.oneByteToInteger(address[0]);
    secondOctet = Utility.oneByteToInteger(address[1]);
    thirdOctet = Utility.oneByteToInteger(address[2]);
    fourthOctet = Utility.oneByteToInteger(address[3]);
  }

  String toString() {
    return ("$firstOctet.$secondOctet.$thirdOctet.") + fourthOctet.toString();
  }

  List<int> getBytes() {
    List<int> result = List.filled(4, 0);
    result[0] = Utility.integerToOneByte(firstOctet);
    result[1] = Utility.integerToOneByte(secondOctet);
    result[2] = Utility.integerToOneByte(thirdOctet);
    result[3] = Utility.integerToOneByte(fourthOctet);
    return result;
  }

  // InternetAddress getInetAddress() {
  //   List<int> address = []..length = 4;
  //   address[0] = Utility.integerToOneByte(firstOctet);
  //   address[1] = Utility.integerToOneByte(secondOctet);
  //   address[2] = Utility.integerToOneByte(thirdOctet);
  //   address[3] = Utility.integerToOneByte(fourthOctet);
  //   return InternetAddress.getByAddress(address);
  // }

  // bool equals(Object obj) {
  //   if (obj == null) {
  //     return false;
  //   }
  //   try {
  //     List<int> data1 = this.getBytes();
  //     List<int> data2 = obj.getBytes();
  //     if ((((data1[0] == data2[0]) && (data1[1] == data2[1])) &&
  //             (data1[2] == data2[2])) &&
  //         (data1[3] == data2[3])) {
  //       return true;
  //     }
  //     return false;
  //   } on UtilityException catch (ue) {
  //     return false;
  //   }
  // }

}
