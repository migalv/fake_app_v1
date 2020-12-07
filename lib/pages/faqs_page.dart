import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FAQsPage extends StatefulWidget {
  @override
  _FAQsPageState createState() => _FAQsPageState();
}

class _FAQsPageState extends State<FAQsPage> {
  bool _showEmailInput;

  bool _questionSent;
  bool _emailSent;

  DocumentReference doc;

  TextEditingController _askQuestionController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

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
  void initState() {
    _showEmailInput = false;
    _questionSent = false;
    _emailSent = false;
    FirebaseAnalytics().setCurrentScreen(
      screenName: "FAQs Page",
      screenClassOverride: "FAQsPage",
    );
    super.initState();
  }

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
              _showEmailInput ? _buildEmailInput() : Container(),
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
          FittedBox(
            child: Text(
              "¿Tienes alguna duda?",
              style: Theme.of(context).textTheme.headline5,
            ),
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
              controller: _askQuestionController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Preguntanos lo que quieras",
              ),
            ),
          ),
          SizedBox(width: 16.0),
          Column(
            children: [
              RaisedButton(
                padding: EdgeInsets.symmetric(
                  horizontal: buttonHorizontalPadding,
                  vertical: buttonVerticalPadding,
                ),
                onPressed: _sendQuestion,
                child: Text(
                  "Enviar",
                  style: TextStyle(fontSize: buttonTextFontSize),
                ),
              ),
              _questionSent
                  ? Column(
                      children: [
                        SizedBox(height: 8.0),
                        Text(
                          "Pregunta enviada",
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontSize: 14.0, color: Colors.green),
                        ),
                      ],
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput() {
    double textFieldHorizontalPadding = 32.0;
    double buttonHorizontalPadding = 32.0;
    double buttonVerticalPadding = 16.0;
    double buttonTextFontSize = 18.0;
    double maxButtonWidth = double.infinity;

    if (MediaQuery.of(context).size.width <= 768) {
      textFieldHorizontalPadding = 0.0;
      buttonHorizontalPadding = 8.0;
      buttonVerticalPadding = 12.0;
      buttonTextFontSize = 16.0;
      maxButtonWidth = 128.0;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: textFieldHorizontalPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Escribe tu email si quieres recibir una respuesta.",
            style:
                Theme.of(context).textTheme.bodyText1.copyWith(fontSize: 16.0),
          ),
          Text(
            "Contestaremos en menos de 24 horas.",
            style: Theme.of(context).textTheme.caption.copyWith(fontSize: 15.0),
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    hintText: "email@gmail.com",
                  ),
                ),
              ),
              SizedBox(width: 16.0),
              Column(
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: maxButtonWidth),
                    child: RaisedButton(
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonHorizontalPadding,
                        vertical: buttonVerticalPadding,
                      ),
                      onPressed: _sendEmail,
                      child: Text(
                        "Quiero recibir contestación",
                        style: TextStyle(fontSize: buttonTextFontSize),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  _emailSent
                      ? Column(
                          children: [
                            SizedBox(height: 8.0),
                            Text(
                              "Email enviado",
                              style: Theme.of(context)
                                  .textTheme
                                  .caption
                                  .copyWith(
                                      fontSize: 14.0, color: Colors.green),
                            ),
                          ],
                        )
                      : Container(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQs() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            child: Text(
              "Preguntas frequentes",
              style: Theme.of(context).textTheme.headline4,
            ),
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Cómo hago un pedido?",
            """Para realizar un pedido, solo tienes que añadir los platos que más te gusten al carrito. Una vez ya tienes todos tus platos, haces click en "Continuar".

Ahora desde la página de confirmación de pedido, te tocará elegir la hora y el día de entrega. Nuestros cocineros necesitan saber la hora del pedido para poder tener tus platos listos.

A continuación introduces la dirección a la que quieres que llegue el pedido. Te aconsejamos que introduzcas el código postal y localidad para que no haya ningún problema con tu pedido.

Para terminar añades tus datos de contacto: nombre, número de teléfono y email.

Una vez introducidos, puedes proceder a realizar el pago de tu pedido haciendo click en "Pagar". Ahí se te ofrecerán los diferentes métodos de pago y deberás introducir la información necesaria para proceder con el pago.

Una vez realizado el pago, recibirás un correo de confirmación de pedido en el que se te mostrarán todos los detalles de tu pedido.""",
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Cómo programo un pedido y cambio los detalles de mi pedido programado?",
            """Para programar un pedido solo tienes que dirigirte a la página de confirmación de pedido. Allí se te pedirá que introduzcas los detalles de tu pedido. Tanto la fecha y la hora a la que te gustaría recibir tu pedido, como la dirección y tus datos de contacto.

Una vez realizado el pedido, se te enviará un correo de confirmación, en el que podrás ver los detalles de tu pedido. En el correo también incluiremos un enlace en el que te permite modificar los detalles de tu pedido. La modificación de los detalles de tu pedido solo se puede realizar hasta 24 horas antes de la hora a la indicaste que te gustaría recibir el pedido.""",
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Cuántos platos puedo pedir?",
            """Puedes pedir tantos platos como quieras y de los países que quieras! Realiza las combinaciones más extravagantes que se te puedan ocurrir y asombra a tus amigos y familiares con una gran variedad de sabores diferentes y únicos.""",
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Qué medidas anti-COVID estáis aplicando?",
            """Medidas Anti-Covid:
-Uso de mascarilla. Tanto los cocineros como los repartidores trabajan con mascarilla todo el tiempo.

-Uso de guantes. Se ha instaurado el uso de guantes en los cocineros y repartidores para así evitar cualquier contagio.

-Lavado de manos. Exigimos el lavado de manos antes, durante y después de la preparación de los platos.

-Desinfección. Las cocinas son desinfectadas antes y después de la creación de cada pedido.

-Entrega sin contacto. Los repartidores colocarán el pedido donde se les indique, para evitar el contacto directo entre consumidor y repartidor. """,
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Puedo pedir platos de diferentes países?",
            """No solo puedes pedir platos de diferentes países, ¡si no que os invitamos a ello! Os abrimos las puertas a una experiencia única con comidas auténticas y caseras de diferentes culturas. Puedes disfrutar de tus platos japoneses, mexicanos, marroquís, griegos, etc. desde el comfort de tu casa.""",
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "He tenido un problema, ¿qué hago?",
            """Si ha experimentado algún tipo de problema, ya sea con el pago, la comida, el reparto, etc. puede contactarnos a:
-Nuestra dirección de correo electrónico: info@deewi.com 
-Nuestro teléfono móvil de atención al cliente: +34618228731
Tan solo explíquenos amablemente la incidencia y nosotros se la solucionaremos.""",
          ),
          SizedBox(height: 16.0),
          _buildExpansionTile(
            "¿Quién realiza los envíos?",
            """Los envíos son realizados por mensajeros profesionales e independientes conectados a nuestra plataforma. Junto con un teléfono inteligente, su propio vehículo y una mochila isotérmica, ellos te entregan la comida de manera rápida y fácil.""",
          ),
        ],
      );

  Widget _buildExpansionTile(String question, String answer) => Column(
        children: [
          ExpansionTile(
            title: Text(
              question,
              style: Theme.of(context).textTheme.headline6,
            ),
            childrenPadding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 4.0,
            ),
            onExpansionChanged: (isExpanding) {
              if (isExpanding) {
                FirebaseAnalytics().logEvent(
                  name: "question_view",
                  parameters: {
                    "question": question,
                  },
                );
              }
            },
            children: [
              Text(
                answer,
                style: Theme.of(context)
                    .textTheme
                    .bodyText2
                    .copyWith(fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ],
      );

  void _sendQuestion() {
    String question = _askQuestionController.text;
    if (doc == null) {
      doc = FirebaseFirestore.instance.collection("recieved_questions").doc();
    }

    FirebaseAnalytics().logEvent(name: "send_question");

    doc.set({
      "question": question,
      "created_at": FieldValue.serverTimestamp(),
      "created_by": FirebaseAuth.instance?.currentUser?.uid,
    });

    setState(() {
      _showEmailInput = true;
      _questionSent = true;
    });
  }

  void _sendEmail() {
    doc.set(
      {"email": _emailController.text},
      SetOptions(merge: true),
    );

    setState(() {
      _emailSent = true;
    });
  }
}
