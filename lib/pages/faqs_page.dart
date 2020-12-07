import 'dart:math';

import 'package:flutter/material.dart';

class FAQsPage extends StatefulWidget {
  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  double _screenWidth;

  double _screenHeight;

  ////////////////////
  // MAIN CONTAINER
  /// max container width by default
  double _mainContainterWidth;

  double _mainContainerMaxWidth;

  double _mainContainerLateralMargin;

  double _mainContainerTopMargin;

  double _mainContainerHorizontalPadding;

  double _mainContainerVerticalPadding;

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    _mainContainerLateralMargin = 64.0;
    _mainContainerMaxWidth = 1024.0 - _mainContainerLateralMargin * 2;
    _mainContainerHorizontalPadding = 32.0;
    _mainContainterWidth = min(
      _screenWidth - _mainContainerLateralMargin * 2,
      _mainContainerMaxWidth,
    );

    _mainContainerTopMargin = 88.0;
    _mainContainerVerticalPadding = 24.0;

    if (_screenWidth < 1024 && _screenWidth >= 768.0) {
      _mainContainerMaxWidth = 768.0;
      _mainContainterWidth = min(
        _screenWidth - _mainContainerLateralMargin * 2,
        _mainContainerMaxWidth,
      );
    }
    // PHONE
    else if (_screenWidth < 768.0) {
      _mainContainerMaxWidth = 768.0;
      _mainContainerLateralMargin = 32.0;
      _mainContainterWidth = null;
      if (_screenWidth <= 530) {
        _mainContainerLateralMargin = 0.0;
      }
      if (_screenWidth < 425) _mainContainerHorizontalPadding = 16.0;
    }

    return Scaffold(
      body: Stack(
        children: [
          Image.asset(
            "assets/images/home_banner.jpg",
            width: _screenWidth,
            height: _screenHeight,
            fit: BoxFit.cover,
            alignment: Alignment(0.0, -0.45),
          ),
          _buildLogo(),
          Center(child: _buildMainContainer()),
        ],
      ),
    );
  }

  Widget _buildLogo() => Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Image.asset(
            "assets/images/logo.png",
            scale: 6.0,
          ),
        ),
      );

  Widget _buildMainContainer() => SingleChildScrollView(
        child: Container(
          width: _mainContainterWidth,
          margin: EdgeInsets.fromLTRB(
            _mainContainerLateralMargin,
            _mainContainerTopMargin,
            _mainContainerLateralMargin,
            0.0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _mainContainerHorizontalPadding,
            vertical: _mainContainerVerticalPadding,
          ),
          constraints: BoxConstraints(
            maxWidth: _mainContainerMaxWidth,
            minHeight: _screenHeight - 64,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black87,
                spreadRadius: 1,
                blurRadius: 3,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTitle(),
              _buildQuestionField(),
              _buildFAQs(),
            ],
          ),
        ),
      );

  Widget _buildTitle() => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
          SizedBox(width: 16.0),
          Text(
            "¿Tienes alguna duda?",
            style: Theme.of(context).textTheme.headline5,
          ),
        ],
      );

  Widget _buildQuestionField() {
    double textFieldHorizontalPadding = 32.0;
    double buttonHorizontalPadding = 32.0;
    double buttonVerticalPadding = 16.0;
    double buttonTextFontSize = 18.0;

    if (MediaQuery.of(context).size.width <= 768) {
      textFieldHorizontalPadding = 0.0;
      buttonHorizontalPadding = 8.0;
      buttonTextFontSize = 16.0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 16.0,
        horizontal: textFieldHorizontalPadding,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Preguntanos lo que quieras",
              ),
            ),
          ),
          SizedBox(width: 16.0),
          RaisedButton(
            padding: EdgeInsets.symmetric(
              horizontal: buttonHorizontalPadding,
              vertical: buttonVerticalPadding,
            ),
            onPressed: () {
              // TODO IMPLEMENT
            },
            child: Text(
              "Enviar",
              style: TextStyle(fontSize: buttonTextFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQs() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Preguntas frequentes",
            style: Theme.of(context).textTheme.headline4,
          ),
          ExpansionTile(
            title: Text("¿Como realizáis los envíos?",
                style: Theme.of(context).textTheme.headline6),
            children: [],
          ),
          SizedBox(height: 8.0),
          _buildExpansionTile(
            "¿Quién cocina mis platos?",
            "Tus platos son cocinados por cocineros profesionales desde sus casas. Todos los cocineros de Deewi tienen el titulo de manipulador de alimentos, además de que sus cocinas son inspeccionadas semanalmente según las normas de igniéne de la comunidad de Madrid.",
          ),
          SizedBox(height: 8.0),
          _buildExpansionTile(
            "¿Cómo hago un pedido?",
            """Para realizar un pedido, solo tienes que añadir los platos que más te gusten al carrito. Una vez ya tienes todos tus platos, haces click en "Continuar".

Ahora desde la página de confirmación de pedido, te tocará elegir la hora y el día de entrega. Nuestros cocineros necesitan saber la hora del pedido para poder tener tus platos listos.

A continuación introduces la dirección a la que quieres que llegue el pedido. Te aconsejamos que introduzcas el código postal y localidad para que no haya ningún problema con tu pedido.

Para terminar añades tus datos de contacto: nombre, número de teléfono y email.

Una vez introducidos, puedes proceder a realizar el pago de tu pedido haciendo click en "Pagar". Ahí se te ofrecerán los diferentes métodos de pago y deberás introducir la información necesaria para proceder con el pago.

Una vez realizado el pago, recibirás un correo de confirmación de pedido en el que se te mostrarán todos los detalles de tu pedido.""",
          ),
        ],
      );

  Widget _buildExpansionTile(String question, String answer) => ExpansionTile(
        title: Text(
          question,
          style: Theme.of(context).textTheme.headline6,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 4.0,
            ),
            child: Text(
              answer,
              style: Theme.of(context)
                  .textTheme
                  .bodyText2
                  .copyWith(fontSize: 16.0),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 16.0),
        ],
      );
}
