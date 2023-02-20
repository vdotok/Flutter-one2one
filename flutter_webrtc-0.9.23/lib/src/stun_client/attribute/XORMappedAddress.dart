import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';

class XORMappedAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  XORMappedAddress() {
//   // TODO: implement XORMappedAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.xor_mapped_address;
  XORMappedAddress.withType(type) : super.withType(type);
  XORMappedAddress() {}
  static MessageAttribute parse(List<int> data) {
    XORMappedAddress ma = XORMappedAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(ma, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return ma;
  }
}
