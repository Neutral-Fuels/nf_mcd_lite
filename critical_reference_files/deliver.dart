import 'dart:convert';

import 'package:McD_NF_UCO_App/models/delivery_roc_model.dart';
import 'package:McD_NF_UCO_App/models/despatch_empty_roc_model.dart';
import 'package:McD_NF_UCO_App/models/new_delivery_record_model.dart';
import 'package:McD_NF_UCO_App/models/new_empty_despatch_record.dart';
import 'package:McD_NF_UCO_App/screens/components/buttons.dart';
import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/list_provider.dart';
import 'package:McD_NF_UCO_App/services/record_creators.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';

import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class DeliverPage extends StatefulWidget {
  @override
  _DeliverPageState createState() => _DeliverPageState();
}

class _DeliverPageState extends State<DeliverPage> {
  Logger log = getLogger("_DeliverPageState");

  SharedPrefs _sharedPrefs = SharedPrefs();
  ListProvider _listProvider = ListProvider();
  RecordCreator _recordCreator = RecordCreator();
  String _token, _truckNo, _title = 'Deliver Oil', _previousTitle;
  List _nfStaff,
      _pendingRocs,
      _newDelivery = [],
      _showButtons = [],
      _rocLabels = [],
      _rocDespatch = [];
  var _user;
  int _index = 0,
      _previousIndex = 0,
      _currentDeliverIndex,
      _containersConfirmed = 0;
  Map _data;
  Map<dynamic, dynamic> _siteDetails, _currentDelivery;
  bool _pendingDespatch = false, _pendingListPopulated = false;

  _getSharedPrefs() async {
    final String functionName = "_getSharedPrefs";
    log.i("$functionName | getting required values from shared prefs");

    var token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
    var truckNo = await _sharedPrefs.getStringValueFromSharedPrefs('truckNo');
    var user = await _sharedPrefs.getStringValueFromSharedPrefs('user');
    var userDecoded = jsonDecode(user);
    setState(() {
      _token = token;
      _truckNo = truckNo;
      _user = userDecoded;
    });
    _getStaffList(token, userDecoded['siteId']);
    _getSiteInfo(token, userDecoded['siteId']);
  }

  _getStaffList(String token, String siteId) async {
    final String functionName = "_getStaffList";
    log.i("$functionName | getting staff list");

    List staff = await _listProvider.getNfStaffListBySite(token, siteId);
    if (staff != null) {
      log.d("$functionName | successfully recieved staff list");
      setState(() {
        _nfStaff = staff;
      });
    }
  }

  _getSiteInfo(String token, String siteId) async {
    final String functionName = "_getSiteInfo";
    log.i("$functionName | getting site info");

    Map<dynamic, dynamic> siteDetails =
        await _listProvider.getNfSiteBySiteId(token, siteId);

    if (siteDetails != null) {
      log.d("$functionName | successfuly recieved site info");
      setState(() {
        _siteDetails = siteDetails;
      });
    }
  }

  _getPendingCollectionList(
      String token, String truckNo, String boolval) async {
    final String functionName = "_getPendingCollectionList";
    log.i("$functionName | getting pending collecton list method");

    List result = await _listProvider.getCollectionListPendingForCleint(
        token, truckNo, boolval);

    if (result != null) {
      log.d("$functionName | successfuly got pending collection list");
      setState(() {
        _pendingRocs = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
  }

  List<Color> colors = [
    Colors.grey,
    Colors.pinkAccent,
    Color.fromARGB(255, 45, 205, 143),
  ];

  @override
  Widget build(BuildContext context) {
    final String functionName = "build";
    log.v("$functionName | widget build for deliver");

    return Container(
      child: IndexedStack(
        index: _index,
        children: [
          _deliveryOptionSelction(),
          _deliveryFromAnotherTruck(),
          _deliveryFromStore(),
          _bulkDelivery(),
          _collectEmptyRocs(),
          _pendingROCView(),
        ],
      ),
    );
  }

  despatchErrorDialog(BuildContext context) {
    final String functionName = "despatchErrorDialog";
    log.v("$functionName | dialog for despatch error");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.amber,
              ),
              Text(
                'Alert!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ],
          ),
          content: Text('Please make sure you check the ROC before adding it.'),
          actions: [
            ElevatedButton(
              style: colored18PointButton(Colors.amber),
              child: Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  addDespatchRoc() {
    final String functionName = "addDespatchRoc";
    log.v("$functionName | dialog for adding despatch roc");

    final _formKey = GlobalKey<FormState>();
    int containertypeid = 1;
    String containernumber, containerstate = 'Good';
    bool containerchecked = false;
    DespatchEmptyContainer despatchEmptyContainer;
    showDialog(
      context: (context),
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  15,
                ),
              ),
            ),
            title: Text(
              'New ROC Record',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 36, 200, 248),
              ),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        containernumber = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter ROC number';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      cursorColor: Color.fromARGB(255, 36, 200, 248),
                      maxLength: 4,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'ROC Number',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 36, 200, 248),
                        ),
                        hintText: 'ROC Number',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC State
                    TextFormField(
                      onChanged: (value) {
                        containerstate = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter current ROC state';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      cursorColor: Color.fromARGB(255, 36, 200, 248),
                      initialValue: containerstate,
                      decoration: InputDecoration(
                        labelText: 'Current State',
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 36, 200, 248),
                        ),
                        hintText: 'Current State',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    CheckboxListTile(
                      title: Text(
                        "ROC Checked",
                        style: TextStyle(
                          color: Color.fromARGB(255, 36, 200, 248),
                          fontSize: 16,
                        ),
                      ),
                      value: containerchecked,
                      checkColor: Colors.white,
                      activeColor: Color.fromARGB(255, 36, 200, 248),
                      onChanged: (newValue) {
                        setState(() {
                          containerchecked = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .trailing, //  <-- leading Checkbox
                    )
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: colored18PointButton(Color.fromARGB(255, 36, 200, 248)),
                child: Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    if (containerchecked) {
                      despatchEmptyContainer = DespatchEmptyContainer(
                        containertypeid: containertypeid,
                        containerchecked: containerchecked,
                        containernumber: containernumber,
                        containerstate: containerstate,
                      );
                      setState(() {
                        _rocDespatch.add(despatchEmptyContainer.toJson());
                        _pendingDespatch = true;
                      });

                      Navigator.pop(context);
                      addDespatchRoc();
                    } else {
                      despatchErrorDialog(context);
                    }
                  }
                },
              ),
              ElevatedButton(
                style: colored18PointButton(secondaryColor),
                child: Text(
                  'Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
      },
    );
  }

  //Collect empty ROCs
  _collectEmptyRocs() {
    final String functionName = "_collectEmptyRocs";
    log.v("$functionName | container for collecting empty rocs");

    try {
      return Container(
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
            elevation: 4.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: primaryColor,
            leading: _index != 0
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _index = 0;
                      });
                    })
                : Container(),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/180.png',
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Collect ROCs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        style: colored18PointButton(
                          Color.fromARGB(255, 36, 200, 248),
                        ),
                        onPressed: () {
                          addDespatchRoc();
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              'Add ROC',
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _pendingDespatch
                          ? SizedBox(
                              width: 10,
                            )
                          : SizedBox(
                              width: 0,
                            ),
                      _pendingDespatch
                          ? ElevatedButton(
                              style: colored15PointButton(secondaryColor),
                              onPressed: () {
                                verifyDesptchTransAction();
                              },
                              child: Text(
                                'Confirm',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10),
                    child: Divider(
                      height: 25,
                      thickness: 3,
                      color: Color.fromARGB(255, 36, 200, 248),
                    ),
                  ),
                  _rocDespatch.length > 0
                      ? Container(
                          height: MediaQuery.of(context).size.height * 0.8,
                          padding: EdgeInsets.only(
                            bottom: AppBar().preferredSize.height + 30,
                          ),
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              Map<String, dynamic> roc = _rocDespatch[index];
                              return Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(
                                      15,
                                    ),
                                  ),
                                ),
                                color: Color.fromRGBO(255, 255, 255, 0.8),
                                child: Padding(
                                  padding: EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'ROC #${roc['containernumber']}',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromARGB(
                                                  255, 36, 200, 248),
                                              fontSize: 16,
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                _rocDespatch.removeAt(index);
                                                if (_rocDespatch.length == 0) {
                                                  _pendingDespatch = false;
                                                }
                                              });
                                            },
                                            icon: Icon(
                                              Icons.remove_circle,
                                              color: Colors.red,
                                            ),
                                            label: Text('Remove'),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ROC State: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: secondaryColor,
                                            ),
                                          ),
                                          Text(roc['containerstate']),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            'ROC Checked: ',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: secondaryColor,
                                            ),
                                          ),
                                          roc['containerchecked']
                                              ? Text("Yes")
                                              : Text("No"),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            itemCount: _rocDespatch.length,
                          ),
                        )
                      : Container(
                          child: Center(
                            child: Text(
                              'Please add an empty ROC to continue the transaction.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      log.w("$functionName | error showing container for collecting empty rocs",
          e);
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SpinKitCircle(
            color: Colors.blue,
            size: 80.0,
          ),
        ),
      );
    }
  }

  //Verify the Despatch Transaction
  verifyDesptchTransAction() {
    final String functionName = "verifyDesptchTransAction";
    log.v("$functionName | dialog for verifying despatch");

    final _formKey = GlobalKey<FormState>();
    var _authID;
    String _error, comments;
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  15,
                ),
              ),
            ),
            title: Text(
              'Despatch Authorization',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 36, 200, 248)),
            ),
            content: isLoading
                ? Container(
                    height: 80,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Loading....',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                      child: Column(
                        children: [
                          Text(
                            'To be filled by an authorized Neutral Fuels Staff Member',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              _authID = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a staff ID';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Staff ID',
                              fillColor: Colors.white,
                              errorText: _error,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              comments = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a comment';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: 'Comments',
                              fillColor: Colors.white,
                              errorText: _error,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      key: _formKey,
                    ),
                  ),
            actions: [
              ElevatedButton(
                style: colored18PointButton(Color.fromARGB(255, 36, 200, 248)),
                child: Text(
                  'Confirm Despatch',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    bool matchFound = false;
                    Map<dynamic, dynamic> nfStaffMember;
                    for (var staff in _nfStaff) {
                      String id = staff['employeeid'].toString();
                      if (_authID == id) {
                        matchFound = true;
                        nfStaffMember = staff;
                        break;
                      }
                    }
                    if (!matchFound) {
                      invalidStaffId(context);
                    } else {
                      setState(() {
                        isLoading = true;
                      });

                      EmptyDespatchRecordModel emptyDespatchRecordModel =
                          EmptyDespatchRecordModel(
                        truckrego: _truckNo,
                        siteid: _siteDetails['siteid'],
                        userid: _user['id'],
                        datetimeofdespatch: DateTime.now().toIso8601String(),
                        containers: _rocDespatch,
                        comments: comments,
                        staffid: nfStaffMember['staffid'],
                      );
                      var val = await _recordCreator.newDespatch(
                          context, _token, emptyDespatchRecordModel);

                      if (val == null) {
                        setState(() {
                          isLoading = false;
                        });
                        Navigator.pop(context);
                        transactionErrorDialog(context);
                      } else {
                        setState(() {
                          _index = _previousIndex;
                          _showButtons.clear();
                          _newDelivery.clear();
                        });
                        Navigator.pop(context);
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }
                  }
                },
              )
            ],
          );
        });
      },
    );
  }

  //Verify the Delivery Transaction
  verifyTransAction() {
    final String functionName = "verifyTransAction";
    log.v("$functionName | dialog for delivery authorization");

    final _formKey = GlobalKey<FormState>();
    var _authID;
    String _error, comments = 'None';
    bool isLoading = false;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  15,
                ),
              ),
            ),
            title: Text(
              'Delivery Authorization',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 36, 200, 248)),
            ),
            content: isLoading
                ? Container(
                    height: 80,
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SpinKitCircle(
                            size: 50,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Loading....',
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                      child: Column(
                        children: [
                          Text(
                            'To be filled by an authorized Neutral Fuels Staff Member',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              _authID = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a staff ID';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            maxLines: 1,
                            decoration: InputDecoration(
                              labelText: 'Staff ID',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  fontSize: 14),
                              hintText: 'Staff ID',
                              fillColor: Colors.white,
                              errorText: _error,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          TextFormField(
                            onChanged: (value) {
                              comments = value;
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a comment';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            initialValue: comments,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Comments',
                              labelStyle: TextStyle(
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  fontSize: 14),
                              hintText: 'Comments',
                              fillColor: Colors.white,
                              errorText: _error,
                              filled: true,
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: Color.fromARGB(255, 36, 200, 248),
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      key: _formKey,
                    ),
                  ),
            actions: [
              ElevatedButton(
                style: colored18PointButton(Color.fromARGB(255, 36, 200, 248)),
                child: Text(
                  'Confirm Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState.validate()) {
                          bool matchFound = false;
                          Map<dynamic, dynamic> nfStaffMember;
                          for (var staff in _nfStaff) {
                            String id = staff['employeeid'].toString();
                            if (_authID == id) {
                              matchFound = true;
                              nfStaffMember = staff;
                              break;
                            }
                          }
                          if (!matchFound) {
                            invalidStaffId(context);
                          } else {
                            setState(() {
                              isLoading = true;
                            });
                            RcoDeliveryModel rcoDeliveryModel =
                                RcoDeliveryModel(
                              containers: _newDelivery,
                              comments: comments,
                              staffid: nfStaffMember['staffid'],
                              datetimeofdelivery:
                                  DateTime.now().toIso8601String(),
                              truckrego: _truckNo,
                              userid: _user['id'],
                            );

                            var val = await _recordCreator.newDelivery(
                                context, _token, rcoDeliveryModel);

                            if (val != null) {
                              Navigator.pop(context);
                              changeScreens();
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                              Navigator.pop(context);
                              transactionErrorDialog(context);
                            }
                          }
                        }
                      },
              )
            ],
          );
        });
      },
    );
  }

  changeScreens() {
    setState(() {
      _pendingRocs.removeAt(_currentDeliverIndex);
      // _rocDespatch.clear();
      _index = _previousIndex;
      _rocLabels.clear();
      _newDelivery.clear();
      _currentDeliverIndex = null;
      _pendingListPopulated = false;
      _containersConfirmed = 0;
    });
  }

  //Transaction Error Dialog
  transactionErrorDialog(BuildContext context) {
    final String functionName = "transactionErrorDialog";
    log.v("$functionName | dialog for showing transaction errors");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Text(
                'ERROR!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          content: Text(
              'Your transaction was not completed. Please try again or contact the support team.'),
          actions: [
            ElevatedButton(
              style: colored18PointButton(Colors.red[400]),
              child: Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  //Invalid Staff ID
  invalidStaffId(BuildContext context) {
    final String functionName = "invalidStaffId";
    log.v("$functionName | dialog for invalid staff id");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
              ),
              Text(
                'WARNING!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
          content: Text(
              'You have entered an invalid Authorization ID. Please try again to confirm the transaction.'),
          actions: [
            ElevatedButton(
              style: colored18PointButton(Colors.red[400]),
              child: Text(
                'Try again',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  //Deliver from another truck page
  _deliveryFromAnotherTruck() {
    final String functionName = "_deliveryFromAnotherTruck";
    log.v("$functionName | container for delivery from another truck");

    try {
      return Container(
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
            elevation: 4.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Color.fromARGB(255, 37, 138, 255),
            leading: _index != 0
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _index = 0;
                        _pendingRocs.clear();
                      });
                    })
                : Container(),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/180.png',
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Truck Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: _pendingRocs.length > 0
              ? Container(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12),
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: ListView.builder(
                    itemCount: _pendingRocs.length,
                    itemBuilder: (context, index) {
                      Map<dynamic, dynamic> collection = _pendingRocs[index];
                      int numOfRocs = collection['containers'].length;
                      DateFormat dateFormat = DateFormat('hh:ss dd-MMM-yyyy');
                      DateTime dateTime =
                          DateTime.parse(collection['datetimeofcollection']);
                      String _dateTime = dateFormat.format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentDeliverIndex = index;
                            _previousIndex = _index;
                            _currentDelivery = collection;
                            _previousTitle = 'Truck Delivery';
                            _index = 5;
                          });
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    Color.fromARGB(255, 36, 200, 248),
                                child: Text(
                                  '${collection['ucocollectionid']}',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${collection['store_name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Number of ROC\'s pending: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${numOfRocs.toString()}\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Timestamp: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$_dateTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Oops!\n',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                'There are no deliveries pending for this truck!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      );
    } catch (e) {
      log.w(
          "$functionName | error creating dialog for delivery from another truck",
          e);
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SpinKitCircle(
            color: Colors.blue,
            size: 80.0,
          ),
        ),
      );
    }
  }

  //Add Roc Delivery Dialog
  rocDisputeDialog(int recordIndex) {
    final String functionName = "newDeliverRecordDialog";
    log.v("$functionName | dialog for adding new roc for delivery");

    final _formKey = GlobalKey<FormState>();
    String quantity = _newDelivery[recordIndex]['quantity'].toString();
    String state = _newDelivery[recordIndex]['state'].toString();
    bool isMissing = _newDelivery[recordIndex]['ismissing'];
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(
                  15,
                ),
              ),
            ),
            title: Text(
              'ROC #${_newDelivery[recordIndex]['rocnumber']} Dispute',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 36, 200, 248)),
            ),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        quantity = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the quantity';
                        }
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      maxLength: 4,
                      maxLines: 1,
                      initialValue: quantity,
                      decoration: InputDecoration(
                        hintText: 'Quantity',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    TextFormField(
                      onChanged: (value) {
                        state = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter current ROC state';
                        }
                        return null;
                      },
                      initialValue: state,
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Current State',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: Color.fromARGB(255, 36, 200, 248),
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    CheckboxListTile(
                      title: Text(
                        "ROC Missing",
                        style: TextStyle(
                          color: Color.fromARGB(255, 36, 200, 248),
                          fontSize: 16,
                        ),
                      ),
                      value: isMissing,
                      checkColor: Colors.white,
                      activeColor: Color.fromARGB(255, 36, 200, 248),
                      onChanged: (newValue) {
                        setState(() {
                          isMissing = newValue;
                        });
                      },
                      controlAffinity: ListTileControlAffinity
                          .trailing, //  <-- leading Checkbox
                    )
                  ],
                ),
              ),
            ),
            actions: [
              ElevatedButton(
                style: colored18PointButton(Color.fromARGB(255, 36, 200, 248)),
                child: Text(
                  'Accept',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: () {
                  if (_rocLabels[recordIndex] == "Pending") {
                    setState(() {
                      _containersConfirmed++;
                    });
                  }

                  setState(() {
                    _newDelivery[recordIndex]["ismissing"] = isMissing;
                    _newDelivery[recordIndex]["quantity"] =
                        double.parse(quantity);
                    _newDelivery[recordIndex]["state"] = state;

                    _rocLabels[recordIndex] = "Disputed";
                  });

                  Navigator.pop(context);
                },
              )
            ],
          );
        });
      },
    );
  }

  addMissingRecord(DeliveryRocModel rocModel, int recordIndex) {
    final String functionName = "addMissingRecord";
    log.i("$functionName | adding missing record");

    setState(() {
      _newDelivery.add(rocModel);
      _showButtons[recordIndex] = true;
    });
  }

  //Roc Delivery Added Alert
  duplicateDeliveryAlert(String rocNo) {
    final String functionName = "duplicateDeliveryAlert";
    log.v("$functionName | dialog for duplicate delivery alert");

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.amber,
              ),
              Text(
                'Alert!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.amber),
              ),
            ],
          ),
          content: Text(
              'This ROC #$rocNo has already been added to the delivery record.'),
          actions: [
            ElevatedButton(
              style: colored18PointButton(Colors.amber),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  _pendingROCView() {
    final String functionName = "_pendingROCView";
    log.v("$functionName | ROC pending for collection view");

    try {
      if (_currentDeliverIndex != null) {
        String siteName = _siteDetails['sitename'];
        List _containers = _currentDelivery['containers'];
        if (!_pendingListPopulated) {
          for (var i = 0; i < _currentDelivery['containers'].length; i++) {
            setState(() {
              _rocLabels.add("Pending");
              _newDelivery.add(_containers[i]);
              _newDelivery[i]['ismissing'] = false;
              _pendingListPopulated = true;
            });
          }
        }

        return Container(
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
              elevation: 4.0,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              backgroundColor: Color.fromARGB(255, 37, 138, 255),
              actions: [
                _newDelivery.length == _containersConfirmed
                    ? TextButton.icon(
                        onPressed: () {
                          verifyTransAction();
                        },
                        icon:
                            Icon(Icons.check_circle, color: Colors.greenAccent),
                        label: Text(
                          'Confirm',
                          style: TextStyle(color: Colors.greenAccent),
                        ),
                      )
                    : Container(),
              ],
              leading: _index != 0
                  ? IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _index = _previousIndex;
                          _title = _previousTitle;
                          _rocLabels.clear();
                          _newDelivery.clear();
                          _currentDeliverIndex = null;
                          _pendingListPopulated = false;
                          _containersConfirmed = 0;
                        });
                      })
                  : Container(),
              automaticallyImplyLeading: true,
              centerTitle: true,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/180.png',
                    height: 40,
                    width: 40,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            body: Container(
              padding: EdgeInsets.all(16.0),
              height: MediaQuery.of(context).size.height * 0.85,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Color.fromRGBO(255, 255, 255, 0.9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          15,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Site Name: ',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                siteName,
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Row(
                            children: [
                              Text(
                                'Collection ID: ',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Text(
                                _currentDelivery['ucocollectionid'].toString(),
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 3,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Store Name: ',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                child: Text(
                                  _currentDelivery['store_name'].toString(),
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.9,
                    color: Colors.black12,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  _pendingListPopulated
                      ? Flexible(
                          child: ListView.builder(
                            itemBuilder: (context, index) {
                              Map<String, dynamic> roc = _newDelivery[index];
                              Color color;
                              if (_rocLabels[index] == "Pending") {
                                color = Colors.amber;
                              } else if (_rocLabels[index] == "Disputed") {
                                color = Colors.orange;
                              } else if (_rocLabels[index] == "Confirmed") {
                                color = Colors.green;
                              } else if (_rocLabels[index] == "Missing") {
                                color = Colors.red;
                              }
                              return GestureDetector(
                                child: Card(
                                  elevation: 3.5,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(
                                        15,
                                      ),
                                    ),
                                  ),
                                  color: Colors.white,
                                  child: Padding(
                                    padding: EdgeInsets.all(12),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                rocDisputeDialog(index);
                                              },
                                              child: Icon(
                                                Icons.edit,
                                                color: Colors.amber,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // If the previous state of the label was pending, then increment number of containers confirmed
                                                if (_rocLabels[index] ==
                                                    "Pending") {
                                                  setState(() {
                                                    _containersConfirmed++;
                                                  });
                                                }
                                                roc['ismissing'] = false;
                                                setState(() {
                                                  _rocLabels[index] =
                                                      "Confirmed";
                                                });
                                              },
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.green,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                // If the previous state of the label was pending, then increment number of containers confirmed
                                                if (_rocLabels[index] ==
                                                    "Pending") {
                                                  setState(() {
                                                    _containersConfirmed++;
                                                  });
                                                }
                                                roc["ismissing"] = true;
                                                setState(() {
                                                  _rocLabels[index] = "Missing";
                                                });
                                              },
                                              child: Icon(
                                                Icons.cancel,
                                                color: Colors.red,
                                                size: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.06,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              backgroundColor: primaryColor,
                                              child: Text(
                                                roc['rocnumber'],
                                                style: TextStyle(
                                                  color: Colors.yellow,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 15),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  '${roc['quantity'].toString()}0 Litres',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: primaryColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'State: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            '${roc['state'].toString()}\n',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'Type: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'ROC\n',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: 'Status: ',
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: _rocLabels[index],
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: color,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            itemCount: _newDelivery.length,
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    } catch (e) {
      log.e(e.toString());
      return Container();
    }
  }

  //Store Delivery Page
  _deliveryFromStore() {
    try {
      return Container(
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
            elevation: 4.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Color.fromARGB(255, 37, 138, 255),
            leading: _index != 0
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _index = 0;
                        _pendingRocs.clear();
                      });
                    })
                : Container(),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/180.png',
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Store Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: _pendingRocs.length > 0
              ? Container(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12),
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: ListView.builder(
                    itemCount: _pendingRocs.length,
                    itemBuilder: (context, index) {
                      Map<dynamic, dynamic> collection = _pendingRocs[index];
                      int numOfRocs = collection['containers'].length;
                      DateFormat dateFormat = DateFormat('hh:ss dd-MMM-yyyy');
                      DateTime dateTime =
                          DateTime.parse(collection['datetimeofcollection']);
                      String _dateTime = dateFormat.format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentDeliverIndex = index;
                            _previousIndex = _index;
                            _currentDelivery = collection;
                            _previousTitle = 'Store Delivery';
                            _index = 5;
                          });
                        },
                        child: Card(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    Color.fromARGB(255, 36, 200, 248),
                                child: Text(
                                  '${collection['ucocollectionid']}',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${collection['store_name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Store No: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${collection['storenumber']}\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Number of ROC\'s pending: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${numOfRocs.toString()}\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Timestamp: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$_dateTime',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Oops!\n',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text:
                                'There are no deliveries pending for the current truck!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      );
    } catch (e) {
      print(e.toString());
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SpinKitCircle(
            color: Colors.blue,
            size: 80.0,
          ),
        ),
      );
    }
  }

  //Bulk Delivery Page
  _bulkDelivery() {
    final String functionName = "_bulkDelivery";
    log.v("$functionName | container for bulk delivery");
    try {
      return Container(
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
            elevation: 4.0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            backgroundColor: Color.fromARGB(255, 37, 138, 255),
            leading: _index != 0
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _index = 0;
                        _pendingRocs.clear();
                        _showButtons.clear();
                        _newDelivery.clear();
                      });
                    })
                : Container(),
            automaticallyImplyLeading: true,
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/180.png',
                  height: 40,
                  width: 40,
                ),
                SizedBox(width: 10),
                Text(
                  'Bulk Delivery',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          body: _pendingRocs.length > 0
              ? Container(
                  padding: EdgeInsets.only(left: 12.0, right: 12.0, top: 12),
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: ListView.builder(
                    itemCount: _pendingRocs.length,
                    itemBuilder: (context, index) {
                      Map<dynamic, dynamic> collection = _pendingRocs[index];
                      int numOfRocs = collection['containers'].length;
                      DateFormat dateFormat = DateFormat('hh:ss dd-MMM-yyyy');
                      DateTime dateTime =
                          DateTime.parse(collection['datetimeofcollection']);
                      String _dateTime = dateFormat.format(dateTime);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentDeliverIndex = index;
                            _previousIndex = _index;
                            _currentDelivery = collection;
                            _previousTitle = 'Bulk Delivery';
                            _index = 5;
                          });
                        },
                        child: Card(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                radius: 30,
                                backgroundColor:
                                    Color.fromARGB(255, 36, 200, 248),
                                child: Text(
                                  '${collection['ucocollectionid']}',
                                  style: TextStyle(
                                    color: Colors.yellow,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                              title: Text(
                                '${collection['store_name']}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Store No: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${collection['storenumber']}\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Number of ROC\'s pending: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${numOfRocs.toString()}\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Timestamp: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '$_dateTime\n',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Truck Rego: ',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${collection['truckrego']}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Oops!\n',
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: 'There are no deliveries pending!',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
        ),
      );
    } catch (e) {
      log.w("$functionName | error creating container for bulk delivery", e);
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(
                'assets/bg.jpg',
              ),
              fit: BoxFit.cover),
        ),
        child: Center(
          child: SpinKitCircle(
            color: Colors.blue,
            size: 80.0,
          ),
        ),
      );
    }
  }

  //Deliver options selction page
  _deliveryOptionSelction() {
    final String functionName = "_deliveryOptionSelction";
    log.v("$functionName | container for delivery option selection page");

    return Container(
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
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                15,
              ),
            ),
          ),
          elevation: 4.0,
          systemOverlayStyle: SystemUiOverlayStyle.light,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/180.png',
                height: 40,
                width: 40,
              ),
              SizedBox(width: 10),
              Text(
                'Deliver Oil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () async {
                      if (_user['isthirdpartyuser'].toString() == 'True') {
                        dynamic result = await Navigator.pushNamed(
                            context, '/selectTruck3PLDelivery');
                        setState(() {
                          _data = {
                            'truckNo': result['truckNo'],
                          };
                          _title = 'Truck Delivery';
                          _index = 1;
                          _previousIndex = 0;
                          _previousTitle = 'Deliver Oil';
                        });
                        _getPendingCollectionList(
                            _token, _data['truckNo'], 'FALSE');
                      } else {
                        dynamic result = await Navigator.pushNamed(
                            context, '/selectNewTruck');
                        setState(() {
                          _data = {
                            'truckNo': result['truckNo'],
                          };
                          _title = 'Truck Delivery';
                          _index = 1;
                          _previousIndex = 0;
                          _previousTitle = 'Deliver Oil';
                        });
                        _getPendingCollectionList(
                            _token, _data['truckNo'], 'FALSE');
                      }
                    },
                    child: Card(
                      color: widgetGrey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: Colors.white,
                              size: 60,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Delivery from another truck',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _title = 'Store Delivery';
                        _index = 2;
                        _previousIndex = 0;
                        _previousTitle = 'Deliver Oil';
                      });
                      _getPendingCollectionList(_token, _truckNo, 'FLASE');
                    },
                    child: Card(
                      color: widgetPink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.store,
                              color: Colors.white,
                              size: 60,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Delivery from stores',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _title = 'Bulk Delivery';
                        _previousIndex = 0;
                        _previousTitle = 'Deliver Oil';
                        _index = 3;
                      });
                      _getPendingCollectionList(_token, _truckNo, 'TRUE');
                    },
                    child: Card(
                      color: widgetBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.storage,
                              color: Colors.white,
                              size: 60,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Bulk Delivery',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _title = 'Collect Empty ROCs';
                        _previousIndex = 0;
                        _previousTitle = 'Deliver Oil';
                        _index = 4;
                      });
                    },
                    child: Card(
                      color: widgetOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            30,
                          ),
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(20, 30, 0, 30),
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.more,
                              color: Colors.white,
                              size: 60,
                            ),
                            SizedBox(
                              width: 15,
                            ),
                            Text(
                              'Collect Empty ROCs',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
