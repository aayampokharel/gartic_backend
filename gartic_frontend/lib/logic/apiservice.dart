import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  String httpBody;
  ApiService._(this.httpBody);

  static Future<String> post(String name) async {
    try {
      var response = await http
          .post(
              Uri.parse(
                  "http://localhost:8080/currentcheck"), //!adds the current player in the list and returns the first player ELSE THIS SHOULD BE MADE TO RECEIVE IF ALL ARE IN BREAK, THEN INSTEAD OF NAME I SHOULD GET THE BREAK THING .
              body: json.encode(name))
          .timeout(const Duration(seconds: 10));
      return response.body;
    } catch (_) {
      //! never let the join request hang the UI; the turn stream self-corrects
      //! as soon as /check delivers the real current player.
      return name;
    }
  }
}
//! try to return Apiservice._(-----);