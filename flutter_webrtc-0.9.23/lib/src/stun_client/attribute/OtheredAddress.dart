import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';

class OtheredAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  OtheredAddress() {
//   // TODO: implement OtheredAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.otheraddress;
  OtheredAddress.withType(type) : super.withType(type);
  OtheredAddress() {}
  static MessageAttribute parse(List<int> data) {
    OtheredAddress ma = OtheredAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(ma, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return ma;
  }
}
