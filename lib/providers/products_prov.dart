import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filter = filterByUser
        ? {
            'auth': authToken,
            'orderBy': json.encode('creatorId'),
            'equalTo': json.encode(userId)
          }
        : {'auth': authToken};
    var url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "products.json", filter);

    try {
      final response = await http.get(url);
      // print(response.body);
      final productsJSON = json.decode(response.body) as Map<String, dynamic>;

      url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
          "userFavorites/$userId.json", {'auth': authToken});
      final responseFav = await http.get(url);
      final favoriteData = json.decode(responseFav.body);

      final List<Product> loadedProducts = [];
      productsJSON.forEach((prodId, prodData) {
        loadedProducts.add(Product(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageURL'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product product) async {
    final url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "products/$id.json", {'auth': authToken});
    try {
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageURL': product.imageUrl,
            'price': product.price,
          }));
    } catch (error) {
      rethrow;
    }
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
      _items[productIndex] = product;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "products.json", {'auth': authToken});
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageURL': product.imageUrl,
            'price': product.price,
            'creatorId': userId,
          }));

      final result = json.decode(response.body);
      final newProduct = Product(
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
        id: result['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "products/$id.json", {'auth': authToken});
    var existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException('Product deletion failed.');
    }
    existingProduct = null;
    existingProductIndex = null;
    notifyListeners();
  }

  Product findByID(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }
}
