import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:numbers_game/models/fact.dart';
import 'package:numbers_game/providers/theme_provider.dart';
import 'package:numbers_game/utils/connectivity.dart';
import 'package:numbers_game/webapis/services.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

enum ApiType { trivia, year, date, math }

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  ApiType _type = ApiType.trivia;
  List<bool> isSelectedFactTypes = [true, false, false, false];
  List<bool> isSelectedNumberTypes = [true, false];
  TextEditingController controller;
  int _date = 1;
  List<int> year = [0, 0, 0, 0];
  bool buttonClicked = false;
  String factNumberText = "Fact";

  @override
  void initState() {
    super.initState();
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<DynamicTheme>(context);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Center(
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: 80, height: 40),
            children: <Widget>[
              Text(
                "Trivia",
                textScaleFactor: 1.1,
              ),
              Text(
                "Year",
                textScaleFactor: 1.1,
              ),
              Text(
                "Date",
                textScaleFactor: 1.1,
              ),
              Text(
                "Math",
                textScaleFactor: 1.1,
              )
            ],
            selectedColor: Colors.white,
            textStyle: TextStyle(fontFamily: 'Muli'),
            fillColor: themeProvider.getTheme.primaryColor,
            borderRadius: BorderRadius.circular(8.0),
            borderColor: themeProvider.getTheme.primaryColor,
            selectedBorderColor: themeProvider.getTheme.primaryColor,
            isSelected: isSelectedFactTypes,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < isSelectedFactTypes.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    isSelectedFactTypes[buttonIndex] = true;
                    _type = ApiType.values[index];
                  } else {
                    isSelectedFactTypes[buttonIndex] = false;
                  }
                }
              });
            },
          ),
        ),
        Center(
          child: ToggleButtons(
            constraints: BoxConstraints.expand(width: 80, height: 40),
            children: <Widget>[
              Text("Random"),
              Text("Choose"),
            ],
            selectedColor: Colors.white,
            textStyle: TextStyle(fontFamily: 'Muli'),
            fillColor: themeProvider.getTheme.primaryColor,
            borderRadius: BorderRadius.circular(8.0),
            borderColor: themeProvider.getTheme.primaryColor,
            selectedBorderColor: themeProvider.getTheme.primaryColor,
            isSelected: isSelectedNumberTypes,
            onPressed: (int index) {
              setState(() {
                for (int buttonIndex = 0;
                    buttonIndex < isSelectedNumberTypes.length;
                    buttonIndex++) {
                  if (buttonIndex == index) {
                    isSelectedNumberTypes[buttonIndex] = true;
                  } else {
                    isSelectedNumberTypes[buttonIndex] = false;
                  }
                }
              });
            },
          ),
        ),
        AnimatedSize(
          duration: Duration(milliseconds: 500),
          curve: Curves.decelerate,
          vsync: this,
          child: _getInputChild(_type, themeProvider),
        ),
        ButtonTheme(
          minWidth: 200.0,
          height: 45.0,
          child: RaisedButton(
            child: buttonClicked
                ? Container(
                    width: 25.0,
                    height: 25.0,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2.0,
                    ),
                  )
                : Text("Get Facts",
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4)),
            color: themeProvider.getTheme.primaryColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            onPressed: () {
              final snackBar = SnackBar(
                content: Text('Choose a number first ...'),
                duration: Duration(seconds: 3),
                elevation: 5.0,
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    this.setState(() {
                      buttonClicked = false;
                    });
                  },
                ),
                backgroundColor: themeProvider.getTheme.accentColor,
              );
              if (!isSelectedNumberTypes[0] &&
                  !isSelectedFactTypes[1] &&
                  !isSelectedFactTypes[2] &&
                  controller.text == "") {
                Scaffold.of(context).showSnackBar(snackBar);
              } else {
                setState(() {
                  buttonClicked = true;
                  FocusScope.of(context).unfocus();
                });
                _getFact();
              }
            },
          ),
        ),
      ],
    );
  }

  void _getFact() async {
    var isNetworkConnected = await NetworkConnectivity.isNetworkConnected();
    if (isNetworkConnected) {
      switch (_type) {
        case ApiType.trivia:
          if (isSelectedNumberTypes[0]) {
            _showFactBottomSheet(context, getTriviaFact());
          } else {
            _showFactBottomSheet(
                context, getTriviaFact(number: controller.text));
          }
          break;
        case ApiType.year:
          if (isSelectedNumberTypes[0]) {
            _showFactBottomSheet(context, getYearFact());
          } else {
            _showFactBottomSheet(context, getYearFact(year: year.join()));
          }
          break;
        case ApiType.date:
          if (isSelectedNumberTypes[0]) {
            _showFactBottomSheet(context, getDateFact());
          } else {
            _showFactBottomSheet(context, getDateFact(date: _date.toString()));
          }
          break;
        case ApiType.math:
          if (isSelectedNumberTypes[0]) {
            _showFactBottomSheet(context, getMathFact());
          } else {
            _showFactBottomSheet(context, getMathFact(number: controller.text));
          }
          break;
        default:
          break;
      }
    } else {
      _showError('No Internet Connectivity');
    }
  }

  void _showError(String error) {
    final snackBar = SnackBar(
      content: Text(error),
      elevation: 5.0,
      backgroundColor: Theme.of(context).accentColor,
      duration: Duration(seconds: 5),
      action: SnackBarAction(
        label: 'Ok',
        textColor: Colors.white,
        onPressed: () {},
      ),
    );

    Scaffold.of(context).showSnackBar(snackBar);
    setState(() {
      buttonClicked = false;
    });
  }

  void _showFactBottomSheet(BuildContext context, Future<Fact> factFuture) {
    factFuture.then((fact) {
      setState(() {
        buttonClicked = false;
      });
      if (fact.type == 'date' && fact.date == "null") {
        // int dayOfYear = int.parse(fact.number);
        // DateTime dateTime = new DateTime(int.parse(fact.year), 1, 1)
        //     .add(Duration(days: dayOfYear - 1));
        // dateString = new DateFormat.yMMMMd().format(dateTime);
        var dateArray = fact.text.split(" ");
        factNumberText = "${dateArray[0]} ${dateArray[1]}, ${fact.year}";
      } else {
        factNumberText = fact.number;
      }
      showModalBottomSheet(
          context: context,
          elevation: 5.0,
          isDismissible: true,
          backgroundColor: Theme.of(context).cardColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0))),
          builder: (BuildContext bc) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          factNumberText,
                          style: TextStyle(
                              color: Theme.of(context).iconTheme.color,
                              fontFamily: 'Muli',
                              fontSize: 38.0,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.share),
                        padding: EdgeInsets.zero,
                        color: Theme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.pop(context);
                          Share.share(
                              "Check out this awesome fact: \n\n${fact.text}\n\nFor More: https://play.google.com/store/apps/details?id=dev.asdevs.random",
                              subject: 'Awesome Fact by Random Fact App!');
                        },
                      )
                    ],
                  ),
                ),
                SafeArea(
                  minimum: const EdgeInsets.all(16.0),
                  child: Text(
                    fact.text,
                    style: TextStyle(
                        color: Theme.of(context).iconTheme.color,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                        letterSpacing: .5),
                  ),
                )
              ],
            );
          });
    }).catchError((error, stackTrace) {
      _showError(error.toString());
    });
  }

  _getInputChild(ApiType apiType, DynamicTheme themeProvider) {
    if (isSelectedNumberTypes[0]) {
      //return Container(height: 0.0, width: 0.0);
      return SizedBox.shrink();
    } else {
      switch (apiType) {
        case ApiType.trivia:
        case ApiType.math:
          return Container(
            width: 200.0,
            child: TextField(
              style: TextStyle(color: themeProvider.getTheme.iconTheme.color),
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.getTheme.primaryColor,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(10.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: themeProvider.getTheme.primaryColor,
                          width: 2.0),
                      borderRadius: BorderRadius.circular(10.0)),
                  // labelText: 'Enter a number',
                  prefixIcon: Icon(
                    Icons.search,
                    color: themeProvider.getTheme.primaryColor,
                  ),
                  focusColor: themeProvider.getTheme.primaryColor,
                  fillColor: themeProvider.getTheme.primaryColor,
                  hintText: 'Enter Number',
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0)),
              keyboardType: TextInputType.number,
              maxLength: 10,
              textInputAction: TextInputAction.done,
              textAlign: TextAlign.center,
              controller: controller,
            ),
          );
          break;
        case ApiType.date:
          return NumberPicker.integer(
            decoration: BoxDecoration(),
            initialValue: _date,
            minValue: 1,
            maxValue: 365,
            onChanged: (newValue) {
              setState(() {
                _date = newValue;
              });
            },
          );
          break;
        case ApiType.year:
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              for (int index = 0; index < year.length; index++)
                NumberPicker.integer(
                  listViewWidth: 70.0,
                  initialValue: year[index],
                  minValue: 0,
                  maxValue: 9,
                  onChanged: (newValue) {
                    setState(() {
                      year[index] = newValue;
                    });
                  },
                )
            ],
          );
          break;
        default:
          break;
      }
    }
  }
}
