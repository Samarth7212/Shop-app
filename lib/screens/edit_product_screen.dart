// ignore_for_file: use_key_in_widget_constructors, avoid_print, prefer_void_to_null
/*
https://st.depositphotos.com/1815808/1538/i/950/depositphotos_15389295-stock-photo-stacked-books-background.jpg

 */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:newshop/providers/product.dart';
import 'package:newshop/providers/products.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/user_product_screen';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: null,
    title: '',
    description: '',
    price: 0,
    imageUrl: '',
  );

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
              !_imageUrlController.text.startsWith('https')) ||
          (!_imageUrlController.text.endsWith('.png') &&
              !_imageUrlController.text.endsWith('.jpg') &&
              !_imageUrlController.text.endsWith('.jpeg'))) {
        return;
      }
      setState(() {});
    }
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    //Cannot use this in initState()
    // final args = ModalRoute.of(context).settings.arguments;
    super.initState();
  }

  var _isInit = true;
  var _isLoading = false;
  var _isInitValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments;
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
        _isInitValues = {
          'title': _editedProduct.title,
          'price': _editedProduct.price.toString(),
          'description': _editedProduct.description,
          // 'imageUrl': _editedProduct.imageUrl,
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    //Disposing otherwise will lead to memory leaks
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();

    super.dispose();
  }

  void _saveForm() {
    final _isValid =
        _form.currentState.validate(); //Will trigger all the validators
    if (!_isValid) {
      return;
    }
    _form.currentState
        .save(); //Will save that form, trigger a method to every textform field to take value entered in input
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id != null) {
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      setState(() {
        _isLoading = false;
      });
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .catchError((error) {
        return showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('Error Occurred'),
                  content: const Text('Something went wrong!'),
                  actions: <Widget>[
                    TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Okay')),
                  ],
                ));
      }).then((_) {
        //This then block is after catchError(), so this block will always be executed
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      });
    }
    // print(_editedProduct.title);
    // print(_editedProduct.description);
    // print(_editedProduct.price);
  }

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: <Widget>[
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    titleTextFormField(context),
                    priceTextFormField(context),
                    descriptionTextFormField(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        imageContainer(deviceWidth),
                        SizedBox(
                          width: deviceWidth * 60 / 100,
                          child: imageTextFormField(),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }

  Container imageContainer(double deviceWidth) {
    return Container(
      width: deviceWidth * 30 / 100,
      height: deviceWidth * 30 / 100,
      margin: const EdgeInsets.only(top: 8, right: 10),
      decoration:
          BoxDecoration(border: Border.all(width: 1, color: Colors.grey)),
      child: _imageUrlController.text.isEmpty
          ? const Text('Enter a URL')
          : FittedBox(
              child: Image.network(
                _imageUrlController.text,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  TextFormField imageTextFormField() {
    return TextFormField(
      //We cannot use both initialValue and controller here
      // controller: _imageUrlController,
      initialValue: _isInitValues['imageUrl'],

      validator: (value) {
        // if (_imageUrlController.text.isEmpty ||
        //     (!_imageUrlController.text.startsWith('http') &&
        //             !_imageUrlController.text.startsWith('https')) &&
        //         (!_imageUrlController.text.endsWith('.jpg') &&
        //             !_imageUrlController.text.endsWith('.jpeg') &&
        //             !_imageUrlController.text.endsWith('.png'))) {
        //   // if (_isInitValues['imageUrl'].isEmpty ||
        //   //     (!_isInitValues['imageUrl'].startsWith('http') &&
        //   //             !_isInitValues['imageUrl'].startsWith('https')) &&
        //   //         (!_isInitValues['imageUrl'].endsWith('.jpg') &&
        //   //             !_isInitValues['imageUrl'].endsWith('.jpeg') &&
        //   //             !_isInitValues['imageUrl'].endsWith('.png'))) {
        //   return 'Probably not an image';
        // }
        // return null;
        if (value.isEmpty) {
          return 'Please enter an image URL.';
        }
        if (!value.startsWith('http') && !value.startsWith('https')) {
          return 'Please enter a valid URL.';
        }
        if (!value.endsWith('.png') &&
            !value.endsWith('.jpg') &&
            !value.endsWith('.jpeg')) {
          return 'Please enter a valid image URL.';
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Image URL',
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      focusNode: _imageUrlFocusNode,
      onFieldSubmitted: (_) {
        _saveForm();
      },
      onSaved: (value) {
        _editedProduct = Product(
          title: _editedProduct.title,
          description: _editedProduct.description,
          price: _editedProduct.price,
          imageUrl: value,

          //This is done so as the favorite status is not lost for items that we edit
          id: _editedProduct.id,
          isFavorite: _editedProduct.isFavorite,
        );
      },
    );
  }

  TextFormField descriptionTextFormField() {
    return TextFormField(
      initialValue: _isInitValues['description'],
      validator: (value) {
        if (value.length < 10) {
          return 'Description is too small';
        }
        return null;
      },
      onSaved: (value) {
        _editedProduct = Product(
          title: _editedProduct.title,
          description: value,
          price: _editedProduct.price,
          imageUrl: _editedProduct.imageUrl,
          //This is done so as the favorite status is not lost for items that we edit
          id: _editedProduct.id,
          isFavorite: _editedProduct.isFavorite,
        );
      },
      decoration: const InputDecoration(labelText: 'Description'),
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      focusNode: _descriptionFocusNode,
    );
  }

  TextFormField priceTextFormField(BuildContext context) {
    return TextFormField(
      initialValue: _isInitValues['price'],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        if (value.isEmpty) {
          return 'Please enter a number';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid price';
        }
        if (double.parse(value) <= 0) {
          return 'Cannot be negative';
        }
        return null;
      },
      decoration: const InputDecoration(labelText: 'Price'),
      textInputAction: TextInputAction.next,
      keyboardType: TextInputType.number,
      focusNode: _priceFocusNode,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_descriptionFocusNode);
      },
      onSaved: (value) {
        _editedProduct = Product(
          //This is done so as the favorite status is not lost for items that we edit
          id: _editedProduct.id,
          isFavorite: _editedProduct.isFavorite,
          title: _editedProduct.title,
          description: _editedProduct.description,
          price: double.parse(value),
          imageUrl: _editedProduct.imageUrl,
        );
      },
    );
  }

  TextFormField titleTextFormField(BuildContext context) {
    return TextFormField(
      initialValue: _isInitValues['title'],
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (value) {
        //Returning null -> correct input
        if (value.isEmpty) {
          return 'Provide some value';
          //The error can be decorated in inputDecoration
        }
        return null;
      },
      decoration: const InputDecoration(
        labelText: 'Title',
        // errorBorder:
      ),
      textInputAction: TextInputAction.next,
      onFieldSubmitted: (_) {
        FocusScope.of(context).requestFocus(_priceFocusNode);
      },
      onSaved: (value) {
        _editedProduct = Product(
          //This is done so as the favorite status is not lost for items that we edit
          id: _editedProduct.id,
          isFavorite: _editedProduct.isFavorite,
          title: value,
          description: _editedProduct.description,
          price: _editedProduct.price,
          imageUrl: _editedProduct.imageUrl,
        );
      },
    );
  }
}
