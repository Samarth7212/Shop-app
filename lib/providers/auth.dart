// ignore_for_file: unused_local_variable, unused_field

import 'dart:convert';
import 'dart:async'; //To use timer

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:newshop/models/http_exceptions.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

//We need return/await here to wait till the function is executed
  Future<void> signup(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signin(String email, String password) async {
    await _authenticate(email, password, 'signInWithPassword');
  }

  void logout() {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel(); //Cancel existing timer if available
      _authTimer = null;
    }
    notifyListeners();
  }

  //To logout auttomatically when the token expires
  void autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel(); //Cancel existing timer if available
    }
    var timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
    // _authTimer = Timer(const Duration(seconds: 6), logout);
  }

  bool get isAuth {
    //If a token is there and is not expired, the user is validated.
    return token != null;
  }

  String get userId {
    return _userId;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }
    return null;
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
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      autoLogout();
      notifyListeners();
      // print(jsonDecode(response.body));
      return response;
    } on Exception catch (_) {
      rethrow;
    }
  }
}
