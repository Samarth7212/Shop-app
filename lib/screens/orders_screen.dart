// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';
  @override
  Widget build(BuildContext context) {
    // print('Building Orders Screen');
    // final orderData = Provider.of<Orders>(context);//Not needed because consumer is used, where we need orders data,
    //This screen now need not to be stateful widget
    return RefreshIndicator(
      onRefresh: Provider.of<Orders>(context, listen: false).fetchAndSetOrders,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          //FutureBuilder gets a future, from which we can know the connection state and work accordingly
          future: Provider.of<Orders>(context, listen: false)
              .fetchAndSetOrders(), //Fututre is return by fetchAndSetOrders()
          builder: (ctx, dataSnapShot) {
            //Based on that fututre, async snapShot is provide, based on which we can check state
            if (dataSnapShot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else {
              if (dataSnapShot.error != null) {
                //Do error handling
                return const Center(
                  child: Text('Error occurred'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (ctx, orderData, _) => ListView.builder(
                    itemCount: orderData.orders.length,
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}
