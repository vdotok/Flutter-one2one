import 'package:flutter/foundation.dart';
import '../../../src/core/models/contactList.dart';
import '../../../src/core/services/server.dart';

enum ContactStates { Loading, Success }

class ContactProvider with ChangeNotifier {
  late ContactList _contactList;
  ContactList get contactList => _contactList;
  ContactStates _contactStates = ContactStates.Loading;
  ContactStates get contactState => _contactStates;

  getContacts(String authToken) async {
    if (_contactStates != ContactStates.Loading) {
      _contactStates = ContactStates.Loading;
      notifyListeners();
    }
    Map<String, dynamic> jsonData = {
      "search_field": "email",
      "search_value": "",
      "condition": "contains",
      "sorting": "ORDER BY username ASC",
      "start_row": 0
    };
    final response = await callAPI(jsonData, "AllUsers", authToken);
    final json = {"users": response["users"]};
    _contactList = ContactList.fromJson(json);
    print("this is list $_contactList");
    _contactStates = ContactStates.Success;
    notifyListeners();
  }
}
