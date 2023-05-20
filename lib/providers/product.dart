import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  void _setFavoriteError(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "userFavorites/$userId/$id.json", {'auth': authToken});
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final body = json.encode(isFavorite);
    try {
      final response = await http.put(url, body: body);
      print(response.body);
      if (response.statusCode >= 400) {
        _setFavoriteError(oldStatus);
      }
    } catch (error) {
      _setFavoriteError(oldStatus);
    }
  }
}
