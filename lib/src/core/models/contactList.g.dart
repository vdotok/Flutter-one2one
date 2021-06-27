// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contactList.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContactList _$ContactListFromJson(Map<String, dynamic> json) {
  return ContactList(
    users: (json['users'] as List)
        ?.map((e) =>
            e == null ? null : Contact.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$ContactListToJson(ContactList instance) =>
    <String, dynamic>{
      'users': instance.users,
    };
