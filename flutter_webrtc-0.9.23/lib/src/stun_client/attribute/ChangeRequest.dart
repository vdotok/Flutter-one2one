import '../attribute/MessgeAttribute.dart';
import '../util/Utility.dart';
import '../util/exceptions.dart';

class ChangeRequest extends MessageAttribute {
  bool changeIP = false;
  bool changePort = false;

  ChangeRequest.withType(super.type) : super.withType();
  // ChangeRequest.withType(super.type)
  //     : super.withType(MessageAttributeType.ChangeRequest);
// MessageAttributeType type = MessageAttributeType.ChangeRequest;
//   ChangeRequest.withType(type) : super.withType(type);

  ChangeRequest() {}

  bool isChangeIP() {
    return changeIP;
  }

  bool isChangePort() {
    return changePort;
  }

  void setChangeIP() {
    changeIP = true;
  }

  void setChangePort() {
    changePort = true;
  }

  List<int> getBytes() {
    List<int> result = List.filled(8, 0);

    result.setRange(0, 2, Utility.integerToTwoBytes(typeToInteger(type)));
    result.setRange(2, 4, Utility.integerToTwoBytes(4));
    // System.arraycopy(
    //     Utility.integerToTwoBytes(typeToInteger(type)), 0, result, 0, 2);
    // System.arraycopy(Utility.integerToTwoBytes(4), 0, result, 2, 2);
    if (changeIP) {
      result[7] = Utility.integerToOneByte(4);
    }
    if (changePort) {
      result[7] = Utility.integerToOneByte(2);
    }
    if (changeIP && changePort) {
      result[7] = Utility.integerToOneByte(6);
    }
    return result;
  }

  static ChangeRequest parse(List<int> data) {
    try {
      if (data.length < 4) {
        throw InvalidEncoding("Data array too short");
      }
      ChangeRequest cr = ChangeRequest();
      int status = Utility.oneByteToInteger(data[3]);
      switch (status) {
        case 0:
          break;
        case 2:
          cr.setChangePort();
          break;
        case 4:
          cr.setChangeIP();
          break;
        case 6:
          cr.setChangeIP();
          cr.setChangePort();
          break;
        default:
          throw InvalidEncoding("Status parsing error");
      }
      return cr;
    } catch (ue) {
      throw InvalidEncoding("Parsing error");
    }
  }
}
