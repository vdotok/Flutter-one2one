import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:vdotok_stream_example/src/core/providers/auth.dart';
import 'dart:convert';
import '../../../src/core/config/config.dart';
import '../qrcode/qrcode.dart';

// The function take will take the user request and verfies it with the api. in this case it will authenticate the user
Future<dynamic> callAPI(
  datarequest,
  myurl,
  authToken,
) async {
  final urlLink = Uri.parse("${AuthProvider.tenantUrl + myurl}");

  print(
      "this is api call $datarequest $urlLink $tenant_url $project $project_id");
  final response = await http.post(urlLink,
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

Future<dynamic> getAPI(myurl, authToken, url) async {
  final urlLink = Uri.parse("${url + myurl}");
  print('this is url $url');
  final response = await http.get(
    urlLink,
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
