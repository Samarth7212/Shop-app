// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:newshop/screens/edit_product_screen.dart';
import 'package:newshop/widgets/app_drawer.dart';
import 'package:newshop/widgets/user_product_item.dart';
import 'package:newshop/providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_products_screen';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
            icon: Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (_, index) => UserProductItem(
            id: productsData.items[index].id,
            imageUrl: productsData.items[index].imageUrl,
            title: productsData.items[index].title,
          ),
          itemCount: productsData.items.length,
        ),
      ),
    );
  }
}
