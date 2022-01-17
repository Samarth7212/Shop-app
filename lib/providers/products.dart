// ignore_for_file: prefer_final_fields

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:newshop/models/http_exceptions.dart';

import './product.dart';

class Products with ChangeNotifier {
  final String authToken;
  List<Product> _items;
  Products(this.authToken, this._items);
  // List<Product> _items = [
  //Dummy Products
  // Product(
  //   id: 'p1',
  //   title: 'Red Shirt',
  //   description: 'A red shirt - it is pretty red!',
  //   price: 29.99,
  //   imageUrl:
  //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
  // ),
  // Product(
  //   id: 'p2',
  //   title: 'Trousers',
  //   description: 'A nice pair of trousers.',
  //   price: 59.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
  // ),
  // Product(
  //   id: 'p3',
  //   title: 'Yellow Scarf',
  //   description: 'Warm and cozy - exactly what you need for the winter.',
  //   price: 19.99,
  //   imageUrl:
  //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
  // ),
  // Product(
  //   id: 'p4',
  //   title: 'A Pan',
  //   description: 'Prepare any meal you want.',
  //   price: 49.99,
  //   imageUrl:
  //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
  // ),
// ];
  // var _showFavoritesOnly = false;

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // }
    if (_items == null) return [];
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  Future<void> fetchAndSetProducts() async {
    final url = Uri.parse(
        'https://shopapp-90d19-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    try {
      final response = await http.get(url);
      // print(jsonDecode(response.body));
      final List<Product> loadedProducts = [];
      final extractedData = jsonDecode(response.body)
          as Map<String, dynamic>; //Dynamic==Map of <String,value>
      extractedData.forEach(
        (prodId, prodData) {
          loadedProducts.add(Product(
            id: prodId,
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite'],
            description: prodData['description'],
            price: prodData['price'],
            title: prodData['title'],
          ));
        },
      );
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      // print(error);
      // rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    //Using async, below code is wrapped in future and that future is returned automatically, so we don't have to return e.g. return http
    final url = Uri.parse(
        'https://shopapp-90d19-default-rtdb.firebaseio.com/products.json');
    // final url = Uri.https('flutter-update.firebaseio.com', '/products.json')
    // return http

    //With await, till the post request is not finished, further code is not executed,
    //the code in next lines will be in then block implicitly,
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'isFavorite': product.isFavorite,
          },
        ),
      );
      final newProduct = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      // print(error);
      rethrow;
      // throw error;
    }
    // .then((response) {

    //After the http post is done, this is executed i.e. product is added locally
    //The response gives a unique key

    // print(jsonDecode(response.body));

    // _items.add(value);
    // final newProduct = Product(
    //     id: jsonDecode(response.body)['name'],
    //     title: product.title,
    //     description: product.description,
    //     price: product.price,
    //     imageUrl: product.imageUrl);
    // _items.add(newProduct);

    // notifyListeners();
    // }).catchError((error) {
    //   print(error);
    //   throw error;
    // });
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://shopapp-90d19-default-rtdb.firebaseio.com/products/$id.json');

    ///$id.json

    final existingProductIndex = _items.indexWhere(
        (element) => element.id == id); //Index of product to be deleted

    var existingProduct = _items[
        existingProductIndex]; //Pointer of the product about to be deleted

    _items.removeAt(
        existingProductIndex); //Removing it locally, but it does not gets deleted from memory since existingProduct is pointing at it

    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >=
        400) //i.e. error has occurred but it won't be shown
    {
      //If the deletion fails, we'll roll back the deletion
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    //If deletion succeeds, we'll be no longer interested in it.
    existingProduct = null;
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://shopapp-90d19-default-rtdb.firebaseio.com/products/$id.json');
      await http.patch(
        url,
        body: jsonEncode({
          'title': newProduct.title,
          'description': newProduct.description,
          'price': newProduct.price,
          'imageUrl': newProduct.imageUrl,
        }),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      //Not needed
    }
  }
}
