// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:newshop/screens/products_overview_screen.dart';
import 'package:provider/provider.dart';

import './providers/products.dart';
import './providers/auth.dart';
import './providers/cart.dart';
import './providers/orders.dart';

import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/auth_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        //Auth is needed first in the list
        ChangeNotifierProvider.value(value: Auth()),
        // ChangeNotifierProvider(create: (_) => Products()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(
              null, null, null), //Here create is must, otherwise won't work
          update: (
            context,
            auth, //This is Auth object, when changed rebuilds this widget
            previous, //This stores the previous object of the class
          ) =>
              Products(
            auth.token,
            auth.userId,
            previous.items ?? [],
          ),
        ),
        ChangeNotifierProvider(create: (_) => Cart()),
        // ChangeNotifierProvider(create: (_) => Orders()),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (ctx) => Orders(null, null, null),
          update: (context, value, previous) =>
              Orders(value.token, value.userId, previous.orders ?? []),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'MyShop',
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                .copyWith(secondary: Colors.deepOrange),
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
            CartScreen.routeName: (ctx) => CartScreen(),
            OrdersScreen.routeName: (ctx) => OrdersScreen(),
            UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
            EditProductScreen.routeName: (ctx) => EditProductScreen(),
            AuthScreen.routeName: (ctx) => AuthScreen(),
            ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
          },
        ),
      ),
    );
  }
}
