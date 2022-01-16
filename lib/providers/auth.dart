// ignore_for_file: unused_local_variable, unused_field

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:newshop/models/http_exceptions.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

//We need return/await here to wait till the function is executed
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    await _authenticate(email, password, 'signInWithPassword');
  }

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBV8rYGykrUHFfIgjTMGvR0wbavfbSN8Mw');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );
      final responseata = jsonDecode(response.body);
      if (responseata['error'] != null) {
        throw HttpException(responseata['error']['message']);
      }
      // print(jsonDecode(response.body));
      return response;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
