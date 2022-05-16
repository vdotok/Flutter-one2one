import 'package:json_annotation/json_annotation.dart';
part 'user.g.dart';
 
@JsonSerializable()
class User {
  //final String active;
  final String auth_token;
  final String? authorization_token;
  final String? email;
  final  String full_name;
  final String? message;
  //final String passwordCount;
  final int? process_time;
  final String? ref_id;
  final int? status;
  final int? user_id;
  User(
      {
       required this.auth_token,
       this.authorization_token,
       this.email,
       required this.full_name,
       this.message,
       this.process_time,
       this.ref_id,
       this.status,
       this.user_id,
     });
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}