// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future _ordersFuture;

  Future _obtainOrdersFuture() {
    return Provider.of<Orders>(context, listen: false)
        .fetchAndSetOrders(); //Fututre is return by fetchAndSetOrders()
  }

  @override
  void initState() {
    _ordersFuture =
        _obtainOrdersFuture(); //Future stored in a property before build() is executed
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print('Building Orders Screen');
    // final orderData = Provider.of<Orders>(context);//Not needed because consumer is used, where we need orders data,

    return RefreshIndicator(
      onRefresh: Provider.of<Orders>(context, listen: false).fetchAndSetOrders,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          //Future builder avoids rebuilding of enitre widget tree
          //FutureBuilder gets a future, from which we can know the connection state and work accordingly

          //Note: If by some means the build method executes, then fetchAndSetOrders() is also again executed, which is not efficient.
          //      To avoid this, convert this file to stateful widget and store future is some other variable and is used here
          future:
              _ordersFuture, //This ensures that future is not obtained frequently
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
