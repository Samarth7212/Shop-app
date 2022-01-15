// import 'package:flutter/material.dart';

class HttpException implements Exception {
  final String msg;
  HttpException(this.msg);

  @override
  String toString() {
    return msg;
    // return super.toString();//Returns instance of HttpException
  }
}
