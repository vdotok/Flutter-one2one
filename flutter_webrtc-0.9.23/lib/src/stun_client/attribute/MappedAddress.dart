import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';

class MappedAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  MappedAddress() {
//   // TODO: implement MappedAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.MappedAddress;
  MappedAddress.withType(type) : super.withType(type);
  MappedAddress() {}
  static MessageAttribute parse(List<int> data) {
    MappedAddress ma = MappedAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(ma, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return ma;
  }
}
