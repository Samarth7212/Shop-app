import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token) async {
    final url = Uri.parse(
        'https://shopapp-90d19-default-rtdb.firebaseio.com/products/$id.json?auth=$token');

    final oldStatus = isFavorite;
    isFavorite = !isFavorite;

    try {
      final response = await http.patch(
        url,
        body: jsonEncode({
          'isFavorite': isFavorite,
        }),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite != isFavorite;
      notifyListeners();
    }
  }
}
