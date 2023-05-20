import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders_prov.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  const OrdersScreen({Key key}) : super(key: key);

  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).getOrders();
  }

  @override
  Widget build(BuildContext context) {
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder(
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              // if (dataSnapshot.error != null) {
              //   print(dataSnapshot.error);
              //   return const Text('Error loading orders.');
              // } else {
              return RefreshIndicator(
                onRefresh: () => _refreshOrders(ctx),
                child: Consumer<Orders>(
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: ((ctx, index) => OrderItem(
                          orderData.orders[index],
                        )),
                  ),
                ),
              );
            }
            // }
          },
          future: Provider.of<Orders>(context, listen: false).getOrders(),
        ));
  }
}
