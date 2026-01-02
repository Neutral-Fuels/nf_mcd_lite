import 'dart:convert';

import 'package:McD_NF_UCO_App/screens/components/app_bars.dart';
import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/list_provider.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class SelectStore extends StatefulWidget {
  @override
  _SelectStoreState createState() => _SelectStoreState();
}

class _SelectStoreState extends State<SelectStore> {
  Logger log = getLogger("_SelectStoreState");

  SharedPrefs _sharedPrefs = SharedPrefs();
  ListProvider _listProvider = ListProvider();
  TextEditingController _textEditingController = TextEditingController();
  List _stores, filteredStoreList;
  bool _dataLoaded = false;

  _getSharedPrefs() async {
    final String functionName = "_getSharedPrefs";
    log.i("$functionName | getting required values from shared prefs");

    var token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
    var user = await _sharedPrefs.getStringValueFromSharedPrefs('user');
    var userDecoded = jsonDecode(user);
    _getStoreList(token, userDecoded['customerId']);
  }

  _getStoreList(String token, String customerId) async {
    final String functionName = "_getStoreList";
    log.i("$functionName | getting store list | customerId: $customerId");

    List stores = await _listProvider.getStoreList(token, customerId);
    if (stores != null) {
      log.d("$functionName | successfully recieved store list");
      setState(() {
        _stores = stores;
        filteredStoreList = List.from(_stores);
        _dataLoaded = true;
      });
    }
  }

  onItemChanged(String value) {
    final String functionName = "onItemChanged";
    log.d("$functionName | when searching for store");

    setState(() {
      filteredStoreList.clear();
      for (var store in _stores) {
        if (store['store_name']
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase()) ||
            store['storenumber']
                .toString()
                .toLowerCase()
                .contains(value.toLowerCase())) {
          log.v(
              "$functionName | found store added to list | store name: ${store['store_name']} - store number: ${store['storernumber']}");

          filteredStoreList.add(store);
        }
      }
      return filteredStoreList.toList();
    });
  }

  _returnSite(index) {
    Navigator.pop(context, {
      'storeid': filteredStoreList[index]['storeid'],
      'store_name': filteredStoreList[index]['store_name'],
      'countryid': filteredStoreList[index]['countryid'],
      'storenumber': filteredStoreList[index]['storenumber'],
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
    log.v("$functionName | widget build for select store");

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
              appBar: nfAppBar('Choose a Store', context),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      controller: _textEditingController,
                      cursorColor: primaryColor,
                      decoration: InputDecoration(
                        hintText: 'Search here...',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                      onChanged: onItemChanged,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 14.0, right: 14),
                      child: ListView.builder(
                        itemCount:
                            _stores != null ? filteredStoreList.length : 0,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 1.0,
                              horizontal: 4.0,
                            ),
                            child: Card(
                              color: Color.fromRGBO(255, 255, 255, 0.8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(
                                    30,
                                  ),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  onTap: () {
                                    _returnSite(index);
                                  },
                                  title: Text(
                                    '${filteredStoreList[index]['store_name']} (${filteredStoreList[index]['storenumber']})',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Text(
                                      'Country ID: ${filteredStoreList[index]['countryid']}'),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.red,
                                    radius: 25,
                                    backgroundImage:
                                        AssetImage('assets/mcd_logo.png'),
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
                color: primaryColor,
                size: 80.0,
              ),
            ),
          );
  }
}
