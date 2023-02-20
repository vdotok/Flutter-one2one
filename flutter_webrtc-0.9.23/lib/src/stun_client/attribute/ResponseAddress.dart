import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';

class ResponseAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  ResponseAddress() {
//   // TODO: implement ResponseAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.ResponseAddress;
  ResponseAddress.withType(type) : super.withType(type);
  ResponseAddress() {}
  static MessageAttribute parse(List<int> data) {
    ResponseAddress ra = ResponseAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(ra, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return ra;
  }
}
