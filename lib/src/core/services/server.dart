import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../src/core/config/config.dart';

// The function take will take the user request and verfies it with the api. in this case it will authenticate the user
Future<dynamic> callAPI(datarequest, myurl, authToken) async {
  final url =Uri.parse("${URL + version + myurl}") ;
  URL + version + myurl;
  print("this is api call $datarequest $url  $authToken");
  final response = await http.post(url,
      headers: authToken != null
          ? {
              HttpHeaders.contentTypeHeader: 'application/json',
              HttpHeaders.authorizationHeader: "Bearer $authToken"
            }
          : {HttpHeaders.contentTypeHeader: 'application/json'},
      body: json.encode(datarequest));
  print("this is response of Api call ${json.decode(response.body)}");
  if (response.statusCode == 200) {
    print("${response.statusCode}");
    return json.decode(response.body);
  } else {
    throw Exception("Failed to Load Data");
  }
}

Future<dynamic> getAPI(myurl, authToken) async {
  final url =Uri.parse("${URL + version + myurl}") ;
  print('this is url $url');
  final response = await http.get(
    url,
    headers: authToken != null
        ? {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader: "Bearer $authToken"
          }
        : {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  print("this is response of Api call ${json.decode(response.body)}");
  if (response.statusCode == 200) {
    print("${response.statusCode}");
    return json.decode(response.body);
  } else {
    throw Exception("Failed to Load Data");
  }
}
