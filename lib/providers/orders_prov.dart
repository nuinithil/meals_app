import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import './cart_prov.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.amount,
    @required this.dateTime,
    this.id,
    @required this.products,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    if (cartProducts.isNotEmpty) {
      final url = Uri.https(
          "learning-flutter-541cc-default-rtdb.firebaseio.com",
          "orders/$userId.json",
          {'auth': authToken});

      final orderTimestamp = DateTime.now();
      final body = json.encode(
        {
          'amount': total,
          'dateTime': orderTimestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        },
      );

      try {
        final response = await http.post(url, body: body);

        final result = json.decode(response.body);
        _orders.insert(
            0,
            OrderItem(
              amount: total,
              dateTime: orderTimestamp,
              id: result['name'],
              products: cartProducts,
            ));
        notifyListeners();
      } catch (error) {
        rethrow;
      }
    }
  }

  Future<void> getOrders() async {
    final url = Uri.https("learning-flutter-541cc-default-rtdb.firebaseio.com",
        "orders/$userId.json", {'auth': authToken});
    try {
      final response = await http.get(url);
      final result = json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      if (result == null) {
        return;
      }
      result.forEach((orderId, orderData) {
        loadedOrders.add(OrderItem(
          id: orderId,
          dateTime: DateTime.parse(orderData['dateTime']),
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList(),
        ));
      });
      _orders = loadedOrders.reversed;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
