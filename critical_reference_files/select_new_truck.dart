import 'dart:convert';

import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/list_provider.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class SelectNewTruck extends StatefulWidget {
  @override
  _SelectNewTruckState createState() => _SelectNewTruckState();
}

class _SelectNewTruckState extends State<SelectNewTruck> {
  Logger log = getLogger("_SelectNewTruckState");

  SharedPrefs _sharedPrefs = SharedPrefs();
  ListProvider _listProvider = ListProvider();
  TextEditingController _textEditingController = TextEditingController();
  List _trucks, _filteredTruckList;
  bool _dataLoaded = false;

  _getSharedPrefs() async {
    final String functionName = "_getSharedPrefs";
    log.i("$functionName | getting required values from shared prefs");

    var token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
    var user = await _sharedPrefs.getStringValueFromSharedPrefs('user');
    var userDecoded = jsonDecode(user);
    _getTruckList(token, userDecoded['customerId']);
  }

  _getTruckList(String token, String clientId) async {
    final String functionName = "_getTruckList";
    log.i("$functionName | getting new truck list | clientId: $clientId");
    List trucks = await _listProvider.getTruckList(token, clientId);
    if (trucks != null) {
      log.d("$functionName | successfully recieved new truck list");
      setState(() {
        _trucks = trucks;
        _filteredTruckList = List.from(_trucks);
        _dataLoaded = true;
      });
    }
  }

  onItemChanged(String value) {
    final String functionName = "onItemChanged";
    log.d("$functionName | when searching new trucks");

    setState(() {
      _filteredTruckList.clear();
      for (var truck in _trucks) {
        if (truck.toString().toLowerCase().contains(value.toLowerCase()) ||
            truck.toString().toLowerCase().contains(value.toLowerCase())) {
          log.v("$functionName | found truck added to list: $truck}");

          _filteredTruckList.add(truck);
        }
      }
      return _filteredTruckList.toList();
    });
  }

  _returnTruck(String truckNo) {
    Navigator.pop(context, {
      'truckNo': truckNo,
    });
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String functionName = "build";
    log.v("$functionName | widget build for select new truck");

    return _dataLoaded
        ? Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/bg.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(
                      15,
                    ),
                  ),
                ),
                systemOverlayStyle: SystemUiOverlayStyle.light,
                automaticallyImplyLeading: false,
                backgroundColor: Color.fromARGB(255, 37, 138, 255),
                centerTitle: true,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                title: Text(
                  'Select a Truck',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _textEditingController,
                      cursorColor: primaryColor,
                      decoration: InputDecoration(
                        hintText: 'Search truck rego here...',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Colors.white,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      onChanged: onItemChanged,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        left: 14.0,
                        right: 14.0,
                      ),
                      child: ListView.builder(
                        itemCount:
                            _trucks != null ? _filteredTruckList.length : 0,
                        itemBuilder: (context, index) {
                          return Card(
                            color: Colors.white70,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(
                                  25,
                                ),
                              ),
                            ),
                            elevation: 4,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 12, bottom: 12, left: 12),
                              child: ListTile(
                                onTap: () async {
                                  await _returnTruck(_filteredTruckList[index]);
                                },
                                title: Text(
                                  _filteredTruckList[index],
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                  ),
                                ),
                                leading: CircleAvatar(
                                  radius: 30,
                                  backgroundColor:
                                      Color.fromARGB(255, 82, 203, 0),
                                  child: Icon(
                                    Icons.local_shipping,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'assets/bg.jpg',
                  ),
                  fit: BoxFit.cover),
            ),
            child: Center(
              child: SpinKitCircle(
                color: Color.fromARGB(255, 37, 138, 255),
                size: 80.0,
              ),
            ),
          );
  }
}
