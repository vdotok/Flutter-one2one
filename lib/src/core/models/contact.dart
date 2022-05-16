import 'package:json_annotation/json_annotation.dart';
part 'contact.g.dart';
 
@JsonSerializable()
class Contact {
  int? user_id;
  dynamic? email;
  String? ref_id;
  String full_name;
  bool? isSelected = false;
 
  Contact({this.user_id, this.ref_id, required this.full_name,this.email, this.isSelected = false});
  factory Contact.fromJson(Map<String, dynamic> json) =>
      _$ContactFromJson(json);
}