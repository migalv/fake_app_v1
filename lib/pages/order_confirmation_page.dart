import 'package:calendar_strip/calendar_strip.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_app_v1/stores/cart.dart';
import 'package:fake_app_v1/widgets/item_tile.dart';
import 'package:fake_app_v1/widgets/my_box_shadow.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import "dart:math";
import 'package:intl/intl.dart';

class OrderConfirmationPage extends StatefulWidget {
  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  DateTime _orderTime;

  final _formKey = GlobalKey<FormState>();
  bool _formHasErrors;

  bool _isContactInfoEventSent;

  final _phoneMaskFormatter = MaskTextInputFormatter(
    mask: '### ## ## ##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  final TextEditingController _nameController = TextEditingController();

  final TextEditingController _phoneController = TextEditingController();

  final TextEditingController _addressController = TextEditingController();

  final TextEditingController _emailController = TextEditingController();

  TextStyle _titleTextStyle;

  // Widget measures

  ////////////////////
  // MAIN CONTAINER
  /// max container width by default
  double _mainContainterWidth;
  double _mainContainerMaxWidth;
  double _mainContainerLateralMargin;
  double _mainContainerTopMargin;
  double _mainContainerHorizontalPadding;
  double _mainContainerVerticalPadding;

  double _columnSeparation;

  double _textFieldMaxWidth;

  double _leftContentLeftPadding;

  double _screenWidth;
  double _screenHeight;

  bool _isWeb;

  @override
  void initState() {
    FirebaseAnalytics().setCurrentScreen(
      screenName: "Order Confirmation Page",
      screenClassOverride: "OrderConfirmationPage",
    );
    FirebaseAnalytics().logBeginCheckout(
      value: Injector.getAsReactive<Cart>().state.totalPrice,
      currency: "EUR",
    );
    _isContactInfoEventSent = false;
    _formHasErrors = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    _isWeb = true;

    _titleTextStyle = Theme.of(context).textTheme.headline4.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        );

    _mainContainerLateralMargin = 64.0;
    _mainContainerMaxWidth = 1024.0 - _mainContainerLateralMargin * 2;
    _mainContainerHorizontalPadding = 32.0;
    _mainContainterWidth = min(
      _screenWidth - _mainContainerLateralMargin * 2,
      _mainContainerMaxWidth,
    );

    _leftContentLeftPadding = 16.0;

    _columnSeparation = 16.0;

    _mainContainerTopMargin = 88.0;
    _mainContainerVerticalPadding = 24.0;

    _textFieldMaxWidth = _mainContainterWidth * 0.6 -
        _leftContentLeftPadding -
        _mainContainerHorizontalPadding -
        48.0;

    // TABLET
    if (_screenWidth < 1024 && _screenWidth >= 768.0) {
      _isWeb = false;
      _mainContainerMaxWidth = 768.0;
      _mainContainterWidth = min(
        _screenWidth - _mainContainerLateralMargin * 2,
        _mainContainerMaxWidth,
      );
      _textFieldMaxWidth = double.infinity;
    }
    // PHONE
    else if (_screenWidth < 768.0) {
      _isWeb = false;
      _mainContainerMaxWidth = 768.0;
      _mainContainerLateralMargin = 32.0;
      _mainContainterWidth = null;
      _textFieldMaxWidth = double.infinity;
      if (_screenWidth <= 530) {
        _mainContainerLateralMargin = 0.0;
        _titleTextStyle = Theme.of(context).textTheme.headline5.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            );
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

  Widget _buildMainContainer() {
    double orderDetailsContainer;

    if (_isWeb) {
      orderDetailsContainer = (_mainContainterWidth -
              _mainContainerHorizontalPadding * 2 -
              _columnSeparation) *
          0.4;
    } else {
      orderDetailsContainer = 768 -
          _mainContainerHorizontalPadding * 2 -
          _mainContainerLateralMargin;
    }

    return SingleChildScrollView(
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
        child: Form(
          key: _formKey,
          child: _isWeb
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftColumn(),
                    SizedBox(width: _columnSeparation),
                    _buildOrderDetailsContainer(
                        containerWidth: orderDetailsContainer),
                  ],
                )
              : Column(
                  children: [
                    _buildTitle(),
                    _buildMobileContent(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildMobileContent() => Container(
        constraints: BoxConstraints(maxWidth: 768.0 / 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            _buildDeliveryTimeSection(),
            SizedBox(height: 16.0),
            _buildLocationSection(),
            _buildOrderDetailsContainer(),
            SizedBox(height: 16.0),
            _buildContactSection(),
          ],
        ),
      );

  Widget _buildLeftColumn() => Container(
        constraints: BoxConstraints(
          maxWidth: (_mainContainterWidth -
                  _mainContainerHorizontalPadding * 2 -
                  _columnSeparation) *
              0.6,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(),
            SizedBox(height: 16.0),
            _buildLeftColumnContent(),
          ],
        ),
      );

  Widget _buildLeftColumnContent() {
    double leftPadding = 64.0;
    _textFieldMaxWidth = _mainContainterWidth * 0.6 -
        leftPadding -
        _mainContainerHorizontalPadding -
        48.0;

    return Padding(
      padding: EdgeInsets.only(left: leftPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeliveryTimeSection(),
          SizedBox(height: 16.0),
          _buildLocationSection(),
          SizedBox(height: 16.0),
          _buildContactSection(),
        ],
      ),
    );
  }

  Widget _buildContactSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeadline("Datos de contacto"),
          _buildTextField(
            controller: _nameController,
            label: "Nombre",
            icon: Icon(Icons.person),
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value.isEmpty) return 'Porfavor introduce un nombre';
              return null;
            },
          ),
          _buildTextField(
            controller: _phoneController,
            label: "Telefono",
            icon: Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            inputFormatters: [_phoneMaskFormatter],
            validator: (value) {
              if (value.isEmpty)
                return 'Porfavor introduce un número de telefono';
              if (_phoneMaskFormatter.getUnmaskedText().length < 9)
                return 'Porfavor introduce un número válido';
              return null;
            },
          ),
          _buildTextField(
            controller: _emailController,
            label: "Email",
            icon: Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value.isEmpty) return 'Porfavor introduce tu email';
              final regExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
              if (!regExp.hasMatch(value))
                return 'Porfavor introduce un email válido';

              return null;
            },
          ),
        ],
      );

  Widget _buildTextField({
    @required String label,
    @required TextEditingController controller,
    @required Icon icon,
    TextInputType keyboardType,
    String Function(String) validator,
    List<TextInputFormatter> inputFormatters = const [],
    String hintText,
    bool obscureText = false,
  }) =>
      Container(
        constraints: BoxConstraints(maxWidth: _textFieldMaxWidth),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            icon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: icon,
            ),
            hintText: hintText,
          ),
          onTap: () {
            if (_isContactInfoEventSent == false) {
              FirebaseAnalytics().logAddPaymentInfo();
              _isContactInfoEventSent = true;
            }
          },
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          keyboardType: keyboardType,
          validator: validator,
        ),
      );

  Widget _buildHeadline(String text) => Text(
        text,
        style: Theme.of(context).textTheme.headline6,
      );

  Widget _buildLocationSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeadline("Elige la dirección de envio"),
          Container(
            constraints: BoxConstraints(maxWidth: _textFieldMaxWidth),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 16.0,
              ),
              child: TextFormField(
                controller: _addressController,
                expands: false,
                decoration: InputDecoration(
                  labelText: "Dirección",
                  hintText: "Calle Hong Kong, num 26, piso 3A",
                  icon: IconButton(
                    padding: const EdgeInsets.all(0.0),
                    onPressed: () {},
                    icon: Icon(Icons.location_on),
                  ),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.streetAddress,
                validator: (value) {
                  if (value.isEmpty) return 'Porfavor introduce una dirección';
                  return null;
                },
              ),
            ),
          ),
        ],
      );

  Widget _buildOrderDetailsContainer({double containerWidth}) => Container(
        width: containerWidth,
        margin: EdgeInsets.symmetric(vertical: 32.0),
        padding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            myBoxShadow,
          ],
        ),
        child: StateBuilder<Cart>(
            observe: () => Injector.getAsReactive<Cart>(),
            initState: (_, rmCart) => Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tu pedido",
                      style: Theme.of(context)
                          .textTheme
                          .headline6
                          .copyWith(fontSize: 26.0),
                    ),
                    Center(child: CircularProgressIndicator()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "TOTAL",
                          style: Theme.of(context).textTheme.headline5,
                        ),
                        Text(
                          "",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ],
                    ),
                  ],
                ),
            builder: (_, rmCart) {
              List<Widget> children = [
                Text(
                  "Tu pedido",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      .copyWith(fontSize: 26.0),
                )
              ];

              // We add the items from the order
              children.addAll(rmCart.state.dishes.entries
                  .map((entry) => ItemTile(
                        dish: entry.key,
                        units: entry.value,
                        isModifyable: false,
                      ))
                  .cast<Widget>());

              // We add the total price of the order
              children.addAll([
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "TOTAL",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    Text(
                      "${rmCart.state.totalPriceString} €",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ],
                ),
                _buildPayButton(rmCart.state),
                _formHasErrors
                    ? _buildErrorText("Porfavor rellena todos los datos")
                    : Container(),
              ]);

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              );
            }),
      );

  Widget _buildPayButton(Cart cart) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Material(
            child: InkWell(
              onTap: () => _pay(cart),
              child: Ink(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.payment,
                      color: Colors.white,
                      size: 24.0,
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      "Pagar",
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
      );

  Widget _buildTitle() => Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back),
          ),
          SizedBox(width: 16.0),
          Text(
            "Resumen del pedido",
            style: _titleTextStyle,
          ),
        ],
      );

  Widget _buildDeliveryTimeSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeadline("Elige tu hora de entrega estimada"),
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 8.0, 16.0, 8.0),
            child: Text(
              "Escoge tu hora de entrega estimada. Un repartidor de Deewi"
              " llegará a esa hora para entregarte tu pedido.",
            ),
          ),
          _buildCalendarStrip(),
        ],
      );

  Widget _buildCalendarStrip() => FormField(
        validator: (val) =>
            val == null ? "Porfavor seleciona un día de entrega" : null,
        builder: (state) {
          final dateFormat = DateFormat.MMMMEEEEd("es_ES").add_Hm();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  border: state.hasError
                      ? Border.all(
                          color: Theme.of(context).colorScheme.error,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: CalendarStrip(
                  startDate: DateTime.now().add(Duration(hours: 24)),
                  endDate: DateTime.now().add(Duration(days: 7)),
                  addSwipeGesture: true,
                  selectedDate:
                      _orderTime ?? DateTime.now().add(Duration(hours: 24)),
                  dateTileBuilder: _buildDateTile,
                  monthNameWidget: _buildMonthNameWidget,
                  onWeekSelected: (DateTime date) {},
                  onDateSelected: (DateTime date) async {
                    TimeOfDay time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(date),
                    );
                    if (time != null) {
                      DateTime selectedDate = DateTime(date.year, date.month,
                          date.day, time.hour, time.minute);

                      FirebaseAnalytics().logEvent(
                        name: "order_date_selected",
                        parameters: {
                          "date": selectedDate.microsecondsSinceEpoch,
                        },
                      );

                      state.didChange(selectedDate);
                      setState(() => _orderTime = selectedDate);
                    }
                  },
                ),
              ),
              _orderTime != null
                  ? Wrap(
                      children: [
                        Text(
                          "Hora de entrega seleccionada:",
                        ),
                        SizedBox(width: 2),
                        Text(
                          dateFormat.format(_orderTime),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  : Container(),
              state.hasError ? _buildErrorText(state.errorText) : Container(),
            ],
          );
        },
      );

  Widget _buildErrorText(String errorText) => Text(
        "$errorText",
        style: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12.0,
        ),
      );

  Widget _buildDateTile(
    DateTime date,
    DateTime selectedDate,
    int rowIndex,
    String dayName,
    bool isDateMarked,
    bool isDateOutOfRange,
  ) {
    // Translation to Spanish
    dayName = dayNamesInSpanish[date.weekday - 1];

    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
    TextStyle normalStyle =
        TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fontColor);
    TextStyle selectedStyle = TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800, color: Colors.black87);
    TextStyle dayNameStyle = TextStyle(fontSize: 14.5, color: fontColor);
    List<Widget> _children = [
      Text(dayName, style: dayNameStyle),
      Text(date.day.toString(),
          style: !isSelectedDate ? normalStyle : selectedStyle),
    ];

    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
      decoration: BoxDecoration(
        color: !isSelectedDate ? Colors.transparent : Colors.amber,
        borderRadius: BorderRadius.all(Radius.circular(60)),
      ),
      child: Column(
        children: _children,
      ),
    );
  }

  Widget _buildMonthNameWidget(String monthString) {
    // We need to reformat the month names to translate them
    final strings = monthString.split(" ");
    String monthLabel = "";

    // If the string is translatable, then we translate it
    for (final string in strings) {
      String translatedMonth;
      translatedMonth = monthNamesInSpanish[string];

      if (translatedMonth != null) {
        monthLabel += "$translatedMonth ";
      } else {
        monthLabel += "$string ";
      }
    }

    return Container(
      child: Text(
        monthLabel,
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      padding: EdgeInsets.only(top: 7, bottom: 3),
    );
  }

  void _pay(Cart cart) {
    if (_formKey.currentState.validate()) {
      List<Map> itemList;

      itemList = cart.dishes.entries
          .map((entry) => {
                "units": entry.value,
                "dish": entry.key.toOrderItem(),
              })
          .toList();

      FirebaseAnalytics().logEcommercePurchase(
        value: cart.totalPrice,
        currency: "EUR",
      );

      FirebaseFirestore.instance.collection("orders").doc().set(
        {
          "items": itemList,
          "client_address": _addressController.text,
          "client_name": _nameController.text,
          "client_email": _emailController.text,
          "client_phone": _phoneController.text,
          "total_price": cart.totalPrice,
          "delivery_time": _orderTime.millisecondsSinceEpoch,
          "created_at": DateTime.now().millisecondsSinceEpoch,
        },
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Gracias por pedir en Deewi"),
            content: Container(
              constraints: BoxConstraints(maxWidth: 300.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Muchas gracias por hacer un pedido a través de Deewi!",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Desgraciadamente Deewi aún no está disponible en tu zona.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    "Por las molestias te regalamos un cupón de 20% en tu primer pedido en Deewi.",
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.0),
                  FittedBox(
                    child: Text(
                      "DEEWILLEGA20",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                  ),
                  Text(
                    "Utilizalo en tu primer pedido cuando Deewi llegue a tu zona.",
                    style: Theme.of(context).textTheme.caption,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            actions: [
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("Cerrar"),
              ),
            ],
          );
        },
      );
    } else
      setState(() => _formHasErrors = true);
  }
}

const List<String> dayNamesInSpanish = [
  "Lun",
  "Mar",
  "Mie",
  "Jue",
  "Vie",
  "Sab",
  "Dom",
];

const Map<String, String> monthNamesInSpanish = {
  "January": "Enero",
  "February": "Febrero",
  "March": "Marzo",
  "April": "Abril",
  "May": "Mayo",
  "June": "Junio",
  "July": "Julio",
  "August": "Agosto",
  "September": "Septiembre",
  "October": "Octubre",
  "November": "Noviembre",
  "December": "Diciembre",
};

List<String> monthLabels = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];
