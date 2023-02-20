import '../attribute/MessageAttributeInterface.dart';
import '../attribute/MessgeAttribute.dart';
import '../util/Utility.dart';

class Dummy extends MessageAttribute {
  late int lengthValue;

  Dummy.withType(super.type) : super.withType();
  Dummy() {}

  void setLengthValue(int length) {
    this.lengthValue = length;
  }

  List<int> getBytes() {
    List<int> result = List.filled(lengthValue + 4, 0);

    result.setRange(0, 2, Utility.integerToTwoBytes(typeToInteger(type)));
    result.setRange(2, 4, Utility.integerToTwoBytes(lengthValue));
    // System.arraycopy(
    //     Utility.integerToTwoBytes(typeToInteger(type)), 0, result, 0, 2);
    // System.arraycopy(Utility.integerToTwoBytes(lengthValue), 0, result, 2, 2);
    return result;
  }

  static Dummy parse(List<int> data) {
    Dummy dummy = Dummy.withType(MessageAttributeType.Dummy);
    dummy.setLengthValue(data.length);
    return dummy;
  }
}
