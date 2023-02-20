import '../attribute/MessgeAttribute.dart';
import '../util/Utility.dart';

class Username extends MessageAttribute {
  String? username;

  Username.withType(super.type) : super.withType();

  Username.empty() {}
  Username(String username) {
    setUsername(username);
  }

  String getUsername() {
    return username!;
  }

  void setUsername(String username) {
    this.username = username;
  }

  List<int> getBytes() {
    int length = username!.length;
    if ((length % 4) != 0) {
      length += (4 - (length % 4));
    }
    length += 4;
    List<int> result = List.filled(length, 0);
    List.copyRange(
        Utility.integerToTwoBytes(typeToInteger(type)), 0, result, 0, 2);
    List.copyRange(Utility.integerToTwoBytes(length - 4), 0, result, 2, 2);
    // List<int> temp = username?.getBytes();
    // List.copyRange(temp, 0, result, 4, temp.length);
    return result;
  }

  static Username parse(List<int> data) {
    Username result = Username.empty();
    // String username =  String(data);
    // result.setUsername(username);
    return result;
  }
}
