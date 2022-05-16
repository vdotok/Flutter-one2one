import 'contact.dart';
import 'package:json_annotation/json_annotation.dart';
part 'contactList.g.dart';

@JsonSerializable()
class ContactList {
  final List<Contact?>? users;
  ContactList({this.users});
  factory ContactList.fromJson(Map<String, dynamic> json) =>
      _$ContactListFromJson(json);
  Map<String, dynamic> toJson() => _$ContactListToJson(this);
}