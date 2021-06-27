// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    auth_token: json['auth_token'] as String,
    authorization_token: json['authorization_token'] as String,
    email: json['email'] as String,
    full_name: json['full_name'] as String,
    message: json['message'] as String,
    process_time: json['process_time'] as int,
    ref_id: json['ref_id'] as String,
    status: json['status'] as int,
    user_id: json['user_id'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'auth_token': instance.auth_token,
      'authorization_token': instance.authorization_token,
      'email': instance.email,
      'full_name': instance.full_name,
      'message': instance.message,
      'process_time': instance.process_time,
      'ref_id': instance.ref_id,
      'status': instance.status,
      'user_id': instance.user_id,
    };
