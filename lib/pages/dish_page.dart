import 'dart:ui';

import 'package:fake_app_v1/models/dish_model.dart';
import 'package:fake_app_v1/pages/cart_page.dart';
import 'package:fake_app_v1/stores/cart.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

class DishPage extends StatefulWidget {
  final Dish dish;

  const DishPage({
    Key key,
    @required this.dish,
  }) : super(key: key);

  @override
  _DishPageState createState() => _DishPageState();
}

class _DishPageState extends State<DishPage> {
  @override
  void initState() {
    FirebaseAnalytics().logViewItem(
      itemId: widget.dish.id,
      itemName: widget.dish.name,
      itemCategory: widget.dish.cuisineName,
      currency: "EUR",
      value: widget.dish.price,
      price: widget.dish.price,
    );
    FirebaseAnalytics().setCurrentScreen(
      screenName: "Dish Page",
      screenClassOverride: "DishPage",
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _descriptionWidth = 512.0;
    bool isPhone = false;

    // PHONE
    if (_screenWidth <= 768.0) {
      isPhone = true;
      _descriptionWidth = _screenWidth - 64.0;
    }

    return Container(
      constraints: BoxConstraints(maxWidth: 768.0),
      child: Scaffold(
        body: Stack(
          children: [
            OKToast(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 304.0,
                    pinned: true,
                    actions: [isPhone ? _buildCartButton() : Container()],
                    flexibleSpace: FlexibleSpaceBar(
                      title: FittedBox(child: Text("${widget.dish.name}")),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset(
                            widget.dish.thumbnailImagePath ??
                                widget.dish.mainImagePath,
                            fit: BoxFit.cover,
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(0.0, 0.5),
                                end: Alignment(0.0, 0.0),
                                colors: <Color>[
                                  Color(0x60000000),
                                  Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  Color(0x60000000),
                                  Color(0x00000000),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        // Description
                        _buildParagraph(
                          context: context,
                          descriptionWidth: _descriptionWidth,
                          title: "Descripción del plato",
                          text: widget.dish.description,
                        ),
                        // History
                        widget.dish.history != null
                            ? _buildParagraph(
                                context: context,
                                descriptionWidth: _descriptionWidth,
                                title: "Un poco de historia",
                                text: widget.dish.history,
                              )
                            : Container(),
                        // How to eat
                        widget.dish.howToEat != null
                            ? _buildParagraph(
                                context: context,
                                descriptionWidth: _descriptionWidth,
                                title: "Como comer",
                                text: widget.dish.howToEat)
                            : Container(),
                        SizedBox(height: 16.0),
                        _buildDishIngredients(context, _descriptionWidth),
                        SizedBox(height: 24.0),
                        _buildPrice(context),
                        Center(
                          child: _buildAddToCartButton(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            isPhone ? CartPage() : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildParagraph(
          {@required BuildContext context,
          @required double descriptionWidth,
          @required String title,
          @required String text}) =>
      Center(
        child: Column(
          children: [
            SizedBox(height: 16.0),
            Container(
              width: descriptionWidth,
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            SizedBox(height: 16.0),
            Center(
              child: Container(
                width: descriptionWidth,
                child: Text(
                  text,
                  softWrap: true,
                  textAlign: TextAlign.justify,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildDishIngredients(BuildContext context, double descriptionWidth) {
    if (widget.dish.ingredients.isNotEmpty) {
      List<Widget> children = [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Ingredientes",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        SizedBox(height: 16.0),
      ];

      children.addAll(
        widget.dish.ingredients.map(
          (ingredient) => ingredient.allergens != null
              ? ListTile(
                  title: Text(
                    ingredient.name,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                  subtitle: Text(
                    "Alérgenos: ${ingredient.allergens.join(", ")}",
                    style: TextStyle(color: Colors.red[900]),
                  ),
                )
              : ListTile(
                  title: Text(
                    ingredient.name,
                    style: Theme.of(context).textTheme.subtitle1,
                  ),
                ),
        ),
      );

      return Center(
        child: Container(
          width: descriptionWidth,
          child: Column(
            children: children,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  // ignore: unused_element
  Widget _buildDishAllergens(BuildContext context, double descriptionWidth) {
    if (widget.dish.allergens.isNotEmpty) {
      List<Widget> children = [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Alergenos",
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        SizedBox(height: 16.0),
      ];

      children.addAll(
        widget.dish.allergens.map(
          (allergen) => ListTile(
            title: Text(
              allergen,
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
        ),
      );

      return Center(
        child: Container(
          width: descriptionWidth,
          child: Column(
            children: children,
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _buildPrice(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "${widget.dish.priceAsString}€",
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(width: 16.0),
          Text(
            widget.dish.isSoldInUnits ? "Por unidad" : "",
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 16.0),
          ),
        ],
      );

  Widget _buildAddToCartButton(BuildContext context) => StateBuilder<Cart>(
        observe: () => Injector.getAsReactive<Cart>(),
        builder: (context, rmCart) {
          return Column(
            children: [
              _buildUnitSelector(rmCart),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  child: InkWell(
                    onTap: () {
                      rmCart
                          .setState((cart) => cart.addDishToCart(widget.dish));

                      showToast(
                        "Plato añadido al carrito",
                        position: ToastPosition.bottom,
                        backgroundColor: Colors.black54,
                        radius: 8.0,
                        textPadding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        textStyle:
                            TextStyle(fontSize: 18.0, color: Colors.white),
                        animationBuilder: Miui10AnimBuilder(),
                      );

                      // Fluttertoast.showToast(
                      //   msg: "Plato añadido al carrito",
                      //   webPosition: "center",
                      //   toastLength: Toast.LENGTH_LONG,
                      //   gravity: ToastGravity.BOTTOM,
                      //   timeInSecForIosWeb: 2,
                      //   textColor: Colors.white,
                      //   fontSize: 22.0,
                      // );
                    },
                    child: Ink(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 40.0),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            "Añadir al carrito",
                            style: Theme.of(context)
                                .textTheme
                                .headline5
                                .copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );

  Widget _buildCartButton() => StateBuilder<Cart>(
        observe: () => Injector.getAsReactive<Cart>(),
        builder: (_, rmCart) => Stack(
          children: [
            Center(
              child: IconButton(
                icon: Icon(Icons.shopping_cart),
                color: Colors.white,
                onPressed: () =>
                    rmCart.setState((cart) => cart.toggleCartVisibility()),
              ),
            ),
            _buildItemCount(rmCart.state.dishes.length),
          ],
        ),
      );

  Widget _buildItemCount(int cartItems) => cartItems >= 1
      ? Positioned(
          top: 8.0,
          right: 2.0,
          child: Material(
            color: Colors.white,
            elevation: 2,
            shape: CircleBorder(),
            child: Container(
              width: 16.0,
              child: Text(
                "$cartItems",
                textAlign: TextAlign.center,
              ),
            ),
          ),
        )
      : Container();

  Widget _buildUnitSelector(ReactiveModel<Cart> rmCart) {
    double iconSize = 22.0;
    const double iconPadding = 8.0;
    int units = rmCart.state.dishes[widget.dish] ?? 0;

    return units > 0
        ? Column(
            children: [
              SizedBox(height: 8.0),
              Text(
                "Quieres más de uno? Añadelo directamente a la cesta",
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Material(
                    elevation: 3,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: () => rmCart
                          .setState((cart) => cart.addDishToCart(widget.dish)),
                      child: Padding(
                        padding: const EdgeInsets.all(iconPadding),
                        child: Ink(
                          child: Icon(
                            Icons.add,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text("$units"),
                  ),
                  Material(
                    elevation: 3,
                    shape: CircleBorder(),
                    child: InkWell(
                      onTap: () => rmCart.setState(
                          (cart) => cart.removeDishFromCart(widget.dish)),
                      child: Padding(
                        padding: const EdgeInsets.all(iconPadding),
                        child: Ink(
                          child: Icon(
                            Icons.remove,
                            size: iconSize,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }
}
