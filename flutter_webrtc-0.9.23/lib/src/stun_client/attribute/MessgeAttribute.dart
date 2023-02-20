import '../attribute/ChangeRequest.dart';
import '../attribute/ChangedAddress.dart';
import '../attribute/Dummy.dart';
import '../attribute/ErrorCode.dart';
import '../attribute/MappedAddress.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/OtheredAddress.dart';
import '../attribute/ResponseAddress.dart';
import '../attribute/SourceAddress.dart';
import '../attribute/Username.dart';
import '../attribute/XORMappedAddress.dart';
import '../util/Utility.dart';
import '../util/exceptions.dart';

abstract class MessageAttribute {
  late MessageAttributeType type;
  MessageAttribute() {}
  MessageAttribute.withType(MessageAttributeType type) {
    setType(type);
  }

  void setType(MessageAttributeType type) {
    this.type = type;
  }

  MessageAttributeType get getType => type;

  int typeToInteger(MessageAttributeType type) {
    if (type == MessageAttributeType.MappedAddress) return MAPPEDADDRESS;
    if (type == MessageAttributeType.xor_mapped_address)
      return XOR_MAPPED_ADDRESS;
    if (type == MessageAttributeType.otheraddress) return OTHERADDRESS;
    if (type == MessageAttributeType.ResponseAddress) return RESPONSEADDRESS;
    if (type == MessageAttributeType.ChangeRequest) return CHANGEREQUEST;
    if (type == MessageAttributeType.SourceAddress) return SOURCEADDRESS;
    if (type == MessageAttributeType.ChangedAddress) return CHANGEDADDRESS;
    if (type == MessageAttributeType.Username) return USERNAME;
    if (type == MessageAttributeType.Password) return PASSWORD;
    if (type == MessageAttributeType.MessageIntegrity) return MESSAGEINTEGRITY;
    if (type == MessageAttributeType.ErrorCode) return ERRORCODE;
    if (type == MessageAttributeType.UnknownAttribute) return UNKNOWNATTRIBUTE;
    if (type == MessageAttributeType.ReflectedFrom) return REFLECTEDFROM;
    if (type == MessageAttributeType.Dummy) return DUMMY;
    return -1;
  }

  MessageAttributeType? intToType(type) {
    if (type == MAPPEDADDRESS) return MessageAttributeType.MappedAddress;
    if (type == XOR_MAPPED_ADDRESS)
      return MessageAttributeType.xor_mapped_address;
    if (type == OTHERADDRESS) return MessageAttributeType.otheraddress;
    if (type == RESPONSEADDRESS) return MessageAttributeType.ResponseAddress;
    if (type == CHANGEREQUEST) return MessageAttributeType.ChangeRequest;
    if (type == SOURCEADDRESS) return MessageAttributeType.SourceAddress;
    if (type == CHANGEDADDRESS) return MessageAttributeType.ChangedAddress;
    if (type == USERNAME) return MessageAttributeType.Username;
    if (type == PASSWORD) return MessageAttributeType.Password;
    if (type == MESSAGEINTEGRITY) return MessageAttributeType.MessageIntegrity;
    if (type == ERRORCODE) return MessageAttributeType.ErrorCode;
    if (type == UNKNOWNATTRIBUTE) return MessageAttributeType.UnknownAttribute;
    if (type == REFLECTEDFROM) return MessageAttributeType.ReflectedFrom;
    if (type == DUMMY) return MessageAttributeType.Dummy;
    return null;
  }

  List<int> getBytes();

  int getLength() {
    int length = getBytes().length;
    return length;
  }

  static MessageAttribute parseCommonHeader(List<int> data) {
    try {
      List<int> typeArray = List.filled(2, 0);
      // System.arraycopy(data, 0, typeArray, 0, 2);
      List.copyRange(typeArray, 0, data, 0, 2);
      int type = Utility.twoBytesToInteger(typeArray);
      List<int> lengthArray = List.filled(2, 0);
      List.copyRange(lengthArray, 0, data, 2, 4);
      int lengthValue = Utility.twoBytesToInteger(lengthArray);
      List<int> valueArray = List.filled(lengthValue, 0);
      List.copyRange(valueArray, 0, data, 4, lengthValue + 4);
      MessageAttribute? ma;
      switch (type) {
        case MAPPEDADDRESS:
          ma = MappedAddress.parse(valueArray);
          break;
        case RESPONSEADDRESS:
          ma = ResponseAddress.parse(valueArray);
          break;
        case CHANGEREQUEST:
          ma = ChangeRequest.parse(valueArray);
          break;
        case SOURCEADDRESS:
          ma = SourceAddress.parse(valueArray);
          break;
        case CHANGEDADDRESS:
          ma = ChangedAddress.parse(valueArray);
          break;
        case OTHERADDRESS:
          ma = OtheredAddress.parse(valueArray);
          break;
        case USERNAME:
          ma = Username.parse(valueArray);
          break;
        case PASSWORD:
          // ma = Password.parse(valueArray);
          print("this is password type");
          break;
        case MESSAGEINTEGRITY:
          // ma = MessageIntegrity.parse(valueArray);
          print("this is MESSAGEINTEGRITY type");
          break;
        case ERRORCODE:
          ma = ErrorCode.parse(valueArray);
          break;
        case UNKNOWNATTRIBUTE:
          // ma = UnknownAttribute.parse(valueArray);
          print("this is UNKNOWNATTRIBUTE type");
          break;
        case REFLECTEDFROM:
          // ma = ReflectedFrom.parse(valueArray);
          print("this is REFLECTEDFROM type");

          break;
        case XOR_MAPPED_ADDRESS:
          ma = XORMappedAddress.parse(valueArray);
          break;
        default:
          if (type <= 2047) {
            throw InvalidEncoding("Unkown mandatory message attribute");
          } else {
            // LOGGER.debug(("MessageAttribute with type " + type) + " unkown.");
            ma = Dummy.parse(valueArray);
            break;
          }
      }
      return ma!;
    } catch (ue) {
      throw new InvalidEncoding("Parsing error");
    }
  }
}
