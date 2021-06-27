// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Contact _$ContactFromJson(Map<String, dynamic> json) {
  return Contact(
    user_id: json['user_id'] as int,
    ref_id: json['ref_id'] as String,
    full_name: json['full_name'] as String,
    email: json['email'],
    isSelected: json['isSelected'] as bool,
  );
}

Map<String, dynamic> _$ContactToJson(Contact instance) => <String, dynamic>{
      'user_id': instance.user_id,
      'email': instance.email,
      'ref_id': instance.ref_id,
      'full_name': instance.full_name,
      'isSelected': instance.isSelected,
    };
