import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';

class SourceAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  SourceAddress() {
//   // TODO: implement SourceAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.SourceAddress;
  SourceAddress.withType(type) : super.withType(type);
  SourceAddress() {}
  static MessageAttribute parse(List<int> data) {
    SourceAddress sa = SourceAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(sa, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return sa;
  }
}
