import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';
import '../util/Address.dart';
import '../util/Utility.dart';
import '../util/exceptions.dart';

class MappedResponseChangedSourceAddressReflectedFrom extends MessageAttribute {
  int port = 0;
  Address address = Address.withAddressString("0.0.0.0");

  MappedResponseChangedSourceAddressReflectedFrom.withType(super.type)
      : super.withType();
/*  
	 *  0                   1                   2                   3
	 *  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 * |x x x x x x x x|    Family     |           Port                |
	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 * |                             Address                           |
	 * +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
	 */
  MappedResponseChangedSourceAddressReflectedFrom() {}

  int get getPort => port;
  Address get getAddress => address;

  void setPort(int port) {
    if ((port > 65536) || (port < 0)) {
      throw new InvalidEncoding(
          ("Port value " + port.toString()) + " out of range.");
    }
    this.port = port;
  }

  void setAddress(Address address) {
    this.address = address;
  }

  List<int> getBytes() {
    List<int> result = List.filled(12, 0);
    // List.copyRange(
    // Utility.integerToTwoBytes(typeToInteger(type!)), 0, result, 0, 2);
    result.setRange(0, 2, Utility.integerToTwoBytes(typeToInteger(type!)));
    result.setRange(2, 4, Utility.integerToTwoBytes(8));
    // List.copyRange(Utility.integerToTwoBytes(8), 0, result, 2, 2);
    result[5] = Utility.integerToOneByte(1);
    // List.copyRange(Utility.integerToTwoBytes(port), 0, result, 6, 2);
    result.setRange(6, 8, Utility.integerToTwoBytes(port));
    // List.copyRange(address.getBytes(), 0, result, 8, 4);
    result.setRange(8, 12, address.getBytes());
    return result;
  }

  static MappedResponseChangedSourceAddressReflectedFrom parse(
      MappedResponseChangedSourceAddressReflectedFrom ma, List<int> data) {
    try {
      if (data.length < 8) {
        throw InvalidEncoding("Data array too short");
      }
      int family = Utility.oneByteToInteger(data[1]);
      if (family != 1) {
        throw InvalidEncoding("Family $family is not supported");
      }
      List<int> portArray = List.filled(2, 0);
      List.copyRange(portArray, 0, data, 2, 4);
      ma.setPort(Utility.twoBytesToInteger(portArray));
      int firstOctet = Utility.oneByteToInteger(data[4]);
      int secondOctet = Utility.oneByteToInteger(data[5]);
      int thirdOctet = Utility.oneByteToInteger(data[6]);
      int fourthOctet = Utility.oneByteToInteger(data[7]);
      ma.setAddress(Address(firstOctet, secondOctet, thirdOctet, fourthOctet));
      return ma;
    } catch (ue) {
      throw InvalidEncoding("Parsing error");
    }
  }

  String toString() {
    return ("Address $address, Port ") + port.toString();
  }
}
