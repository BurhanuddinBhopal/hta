// ignore_for_file: prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';

import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'bottom_navigation_page.dart';

class AddCustomerPage extends StatefulWidget {
  State<AddCustomerPage> createState() => _AddCustomerPageState();
}

class _AddCustomerPageState extends State<AddCustomerPage> {
  // ignore: unused_field
  var _organization;
  PhoneContact? _phoneContact;

  final organisationName = TextEditingController();
  final name = TextEditingController();
  final lastName = TextEditingController();
  final mobileNumber = TextEditingController();
  final address = TextEditingController(text: 'India');
  final _formKey = GlobalKey<FormState>();

  // final addressController = TextEditingController(text: 'India');

  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
  ];

  Future<void> addCustomer() async {
    if (_formKey.currentState!.validate()) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      var token = sharedPreferences.getString('token');
      var organisation = sharedPreferences.getString('organisation');

      final url = Uri.parse(
          'https://hta.hatimtechnologies.in/api/customer/addCustomer');

      final body = {
        "organisationName": organisationName.text,
        "name": name.text,
        "lastName": lastName.text,
        "mobileNumber": mobileNumber.text,
        "address": address.text,
        "location": address.text,
        "userType": "costomer",
        "organisation": organisation,
      };
      final header = {
        'Authorization': 'Bearer $token',
      };
      print('print body: $body');

      final response = await http.post(url, body: body, headers: header);
      final responseData = jsonDecode(response.body.toString());
      print("print responseData: $responseData");
      if (responseData['code'] == 1) {
        _showSuccesDialog();
      } else {
        _showErrorDialog(responseData);
      }
    }
  }

  void _showSuccesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Customer Added Successfully'),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                'Okay',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BottomNavigationPage()));
              },
            ),
          )
        ],
      ),
    );
  }

  void _showErrorDialog(responseData) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(responseData['message']),
        actions: <Widget>[
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(62, 13, 59, 1),
              ),
              child: Text(
                'Okay',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
    );
  }

  Future<bool> _onBackButtonPressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Exit"),
            content: Text("Are you sure you want to exit?"),
            actions: <Widget>[
              TextButton(
                child: Text("YES"),
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
              TextButton(
                child: Text("NO"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          );
        }) as bool;
    return exitApp;
  }

  @override
  void initState() {
    _focusNodes.forEach((node) {
      node.addListener(() {
        setState(() {});
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: (() {
              Navigator.pop(context);
            }),
            icon: Icon(
              Icons.arrow_back_ios,
              size: 18.0,
            )),
        backgroundColor: Color.fromRGBO(62, 13, 59, 1),
        centerTitle: true,
        title: Text(
          'Add Customer',
          style: TextStyle(
            fontSize: 16.0,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Material(
          child: Form(
            key: _formKey,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 16.0),
                        child: ElevatedButton(
                          onPressed: () async {
                            final PhoneContact contact =
                                await FlutterContactPicker.pickPhoneContact();

                            setState(() {
                              _phoneContact = contact;
                              name.text = _phoneContact!.fullName.toString();
                              mobileNumber.text =
                                  _phoneContact!.phoneNumber!.number.toString();
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            minimumSize: Size(250, 40),
                          ),
                          child: Text(
                            "Select from PhoneBook",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: organisationName,
                          focusNode: _focusNodes[0],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Organization Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Organization Name",
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintStyle: TextStyle(
                                color: _focusNodes[0].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: name,
                          focusNode: _focusNodes[1],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Name",
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintStyle: TextStyle(
                                color: _focusNodes[1].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: lastName,
                          focusNode: _focusNodes[2],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Last Name cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Last Name",
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintStyle: TextStyle(
                                color: _focusNodes[2].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          focusNode: _focusNodes[3],
                          controller: mobileNumber,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Phone Number cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Phone Number",
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintStyle: TextStyle(
                                color: _focusNodes[3].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
                        child: TextFormField(
                          controller: address,
                          focusNode: _focusNodes[4],
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Address cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                              hintText: "Address",
                              contentPadding: EdgeInsets.only(left: 10.0),
                              hintStyle: TextStyle(
                                color: _focusNodes[4].hasFocus
                                    ? Color.fromRGBO(62, 13, 59, 1)
                                    : Colors.grey,
                                fontSize: 14.0,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Color.fromRGBO(62, 13, 59, 1)))),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        color: Color.fromRGBO(62, 13, 59, 1),
                        height: 70.0,
                        width: 420.0,
                        child: ElevatedButton(
                          onPressed: () {
                            addCustomer();
                          },
                          child: Text("Save"),
                          style: TextButton.styleFrom(
                            backgroundColor: Color.fromRGBO(62, 13, 59, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
        ),
      ),
    );
  }
}
