import '../attribute/MappedResponseChangedSourceAddressReflectedFrom.dart';
import '../attribute/MessageAttributeInterface.dart';
import './MessgeAttribute.dart';

class ChangedAddress extends MappedResponseChangedSourceAddressReflectedFrom {
//  ChangedAddress() {
//   // TODO: implement ChangedAddress
//   throw UnimplementedError();
// }
  @override
  MessageAttributeType type = MessageAttributeType.ChangedAddress;
  ChangedAddress.withType(type) : super.withType(type);
  ChangedAddress() {}
  static MessageAttribute parse(List<int> data) {
    ChangedAddress ca = ChangedAddress();
    MappedResponseChangedSourceAddressReflectedFrom.parse(ca, data);
    // LOGGER.debug(("Message Attribute: Mapped Address parsed: " + ma.toString()) + ".");
    return ca;
  }
}
