// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:newshop/screens/edit_product_screen.dart';
import 'package:newshop/widgets/app_drawer.dart';
import 'package:newshop/widgets/user_product_item.dart';
import 'package:newshop/providers/products.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user_products_screen';

  Future<void> _refreshProducts(BuildContext context) async {
    //await automatically return a future
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
    //Here listening to changes is not needed, we just want to call function fetchAndSetProducts()
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
    // print('Rebuilding.....');
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
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? CircularProgressIndicator()
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (context, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, index) => productsData.items == null
                              ? CircularProgressIndicator()
                              : UserProductItem(
                                  id: productsData.items[index].id,
                                  imageUrl: productsData.items[index].imageUrl,
                                  title: productsData.items[index].title,
                                ),
                          itemCount: productsData.items.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
