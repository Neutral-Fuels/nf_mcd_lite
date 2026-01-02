import 'dart:async';
import 'dart:convert';
import 'package:McD_NF_UCO_App/models/collection_empty_roc_model.dart';
import 'package:McD_NF_UCO_App/models/collection_roc_model.dart';
import 'package:McD_NF_UCO_App/models/new_collection_record_model.dart';
import 'package:McD_NF_UCO_App/screens/components/buttons.dart';
import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/list_provider.dart';
import 'package:McD_NF_UCO_App/services/record_creators.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:geolocator/geolocator.dart';

import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class CollectPage extends StatefulWidget {
  @override
  _CollectPageState createState() => _CollectPageState();
}

class _CollectPageState extends State<CollectPage> {
  Logger log = getLogger("_CollectPageState");

  ListProvider _listProvider = ListProvider();
  SharedPrefs _sharedPrefs = SharedPrefs();
  RecordCreator _recordCreator = RecordCreator();
  Position _currentPosition;
  var _userInfo;
  Map _data;
  String _token, _tuckNo;
  bool _showData = false, _rocDeliveryFlag = false, _isLoading = true;
  int _index = 0, _previousIndex;
  List _rocs = [],
      _emptyRocsAtStore = [],
      _customerVerificationMethod = [],
      _emptyRocs = [];

  _getSharedPrefs() async {
    final String functionName = "_getSharedPrefs";
    log.i("$functionName | getting required values from shared prefs");

    var token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
    var truckNo = await _sharedPrefs.getStringValueFromSharedPrefs('truckNo');
    var user = await _sharedPrefs.getStringValueFromSharedPrefs('user');
    var userDecoded = jsonDecode(user);
    setState(() {
      _token = token;
      _tuckNo = truckNo;
      _userInfo = userDecoded;
    });
    _getVerificationMethod(token, userDecoded['customerId']);
  }

  _getVerificationMethod(String token, String customerId) async {
    final String functionName = "_getVerificationMethod";
    log.i("$functionName | getting verification method");

    var res =
        await _listProvider.getCustomerVerificationMethod(customerId, token);
    if (res != null && mounted) {
      log.d(
          "$functionName | successfully got verification method and is mounted");
      setState(() {
        _customerVerificationMethod = res;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getSharedPrefs();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final String functionName = "build";
    log.v("$functionName | Building widget for collection");

    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
            image: AssetImage(
              'assets/bg.jpg',
            ),
            fit: BoxFit.cover),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(
                15,
              ),
            ),
          ),
          backgroundColor: primaryColor,
          elevation: _index == 0
              ? 4.0
              : 0.0, // no elevation on the collect screen to blend in
          systemOverlayStyle: SystemUiOverlayStyle.light,
          actions: [
            _rocs.length > 0 || _emptyRocs.length > 0
                ? TextButton.icon(
                    onPressed: () async {
                      await _listProvider.customerVerificationRequest(
                        _token,
                        _userInfo['customerId'],
                        _customerVerificationMethod[0]['verificationtypecode'],
                        _customerVerificationMethod[0]['mobileappcode'],
                        _customerVerificationMethod[0]['verificationtypecode'],
                      );
                      verifyTransAction(context);
                    },
                    icon: Icon(Icons.check_circle, color: Colors.greenAccent),
                    label: Text(
                      'Verify',
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
                      _previousIndex = 0;
                    });
                  })
              : Container(
                  width: 10,
                ),
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
                'Collect Oil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        body: IndexedStack(
          index: _index,
          children: [selectStoreInfo(), rocTabs()],
        ),
      ),
    );
  }

  deliverEmptyDialog(BuildContext context) {
    final String functionName = "deliverEmptyDialog";
    log.v("$functionName | dialog for delivering empty containers");

    final _formKey = GlobalKey<FormState>();
    String emptyRoc;
    CollectionEmptyRocModel emptyRocModel;
    showDialog(
      context: (context),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Text(
            'New Empty ROC Delivery',
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
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
                      emptyRoc = value;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        emptyRoc = '';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    maxLines: 1,
                    decoration: InputDecoration(
                      labelText: 'Empty ROC Number',
                      labelStyle: TextStyle(
                        color: primaryColor,
                        fontSize: 14,
                      ),
                      hintText: 'Empty ROC Number',
                      fillColor: Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: primaryColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: primaryColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(100.0),
                        borderSide: BorderSide(
                          width: 2.0,
                          color: primaryColor,
                          style: BorderStyle.solid,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
              child: Text("Confirm"),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  if (checkEmptyRocNumber(emptyRoc)) {
                    emptyRocModel =
                        CollectionEmptyRocModel(rocNumber: emptyRoc);

                    setState(() {
                      _emptyRocs.add(emptyRocModel.toJson());
                    });
                    Navigator.pop(context);
                  }
                }
              },
            )
          ],
        );
      },
    );
  }

  //Remove Roc  Warning
  removeRocAlert(BuildContext context, int index) {
    final String functionName = "removeRocAlert";
    log.v("$functionName | alert for removing roc from transaction");

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
                color: primaryColor,
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                'Alert!',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                    fontSize: 22),
              ),
            ],
          ),
          content: Text(
              'Are you sure you want to remove this ROC from the transaction?'),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
              child: Text(
                'Yes',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                double qty = _rocs[index]['quantity'];

                setState(() {
                  _rocs.removeAt(index);
                });
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              style: colored18PointButton(Colors.grey),
              child: Text(
                'No',
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

  //Transaction Error Dialog
  transactionErrorDialog(BuildContext context) {
    final String functionName = "transactionErrorDialog";
    log.v("$functionName | dialog for transaction error");
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
                color: primaryColor,
              ),
              Text(
                'ERROR!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          content: Text(
              'Your transaction was not completed. Please try again or contact the support team.'),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
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
              style: primaryColorButton(),
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

  //Verify Transaction dialog
  verifyTransAction(BuildContext context) {
    final String functionName = "verifyTransAction";
    log.v("$functionName | dialog for verifying transaction");

    final _formKey = GlobalKey<FormState>();
    var _authID;
    bool isLoading = false;
    String _error;
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
              'Collection Authorization',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
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
                            color: primaryColor,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Loading....',
                            style: TextStyle(
                              color: primaryColor,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'To be filled by an authorized McDonald\'s Staff Member',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10,
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
                                  color: primaryColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: primaryColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: primaryColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100.0),
                                borderSide: BorderSide(
                                  width: 2.0,
                                  color: primaryColor,
                                  style: BorderStyle.solid,
                                ),
                              ),
                            ),
                            obscureText: true,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
            actions: [
              ElevatedButton(
                style: primaryColorButton(),
                child: Text(
                  'Confirm Collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          Map<dynamic, dynamic> mcdStaffMember;

                          var authId = int.parse(_authID);
                          String _id = authId.toString();

                          List mcdStaff = await _listProvider
                              .getMcDStaffWithStaffID(_token, _id);
                          if (mcdStaff.isEmpty) {
                            invalidStaffId(context);
                            setState(() {
                              isLoading = false;
                            });
                          } else {
                            mcdStaffMember = mcdStaff[0];
                            setState(() {
                              isLoading = true;
                            });

                            RocCollectionModel rocCollectionModel =
                                RocCollectionModel(
                                    containers: _rocs,
                                    emptyROCsSupplied: _emptyRocs,
                                    truckrego: _tuckNo,
                                    storeid: _data['storeid'],
                                    supervisorname:
                                        mcdStaffMember['employeename'],
                                    supervisorid: mcdStaffMember['mcdstaffid'],
                                    datetimeofcollection:
                                        DateTime.now().toIso8601String(),
                                    latitude: _currentPosition != null
                                        ? _currentPosition.latitude
                                        : 0.0,
                                    longitude: _currentPosition != null
                                        ? _currentPosition.longitude
                                        : 0.0,
                                    verifycode: _id);

                            var val = await _recordCreator.newCollection(
                                context, _token, rocCollectionModel);
                            if (val == null) {
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

  //Edit Roc record dialog
  editRocRecrodDialog(BuildContext context, int index) {
    final String functionName = "editRocRecrodDialog";
    log.v("$functionName | dialog for editing roc record details");

    final _formKey = GlobalKey<FormState>();
    String _initRocNum = _rocs[index]['rocnumber'];
    String _initRocState = _rocs[index]['state'];
    String _initQuantity = _rocs[index]['quantity'].toString();
    String _initEmptyRocNumber = _emptyRocs[index]['rocnumber'];
    double _oldQty = _rocs[index]['quantity'];
    CollectRocModel rocModel;
    CollectionEmptyRocModel emptyRocModel;
    showDialog(
      context: (context),
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                15,
              ),
            ),
          ),
          title: Text(
            'Edit ROC Record',
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: StatefulBuilder(builder: (context, setState2) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                          color: primaryColor,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      child: DropdownButton(
                          value: _initRocNum,
                          hint: Text('ROC Number'),
                          items: _emptyRocsAtStore.map((e) {
                            return DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (mounted)
                              setState2(() {
                                _initRocNum = value;
                              });
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC State
                    TextFormField(
                      onChanged: (value) {
                        _initRocState = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter current ROC state';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      initialValue: _initRocState,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        labelText: 'Current State',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Current State',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC Qunatity
                    TextFormField(
                      onChanged: (value) {
                        _initQuantity = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the oil quantity';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      maxLength: 5,
                      maxLines: 1,
                      initialValue: _initQuantity,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Quantity',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC Qunatity
                    TextFormField(
                      onChanged: (value) {
                        _initEmptyRocNumber = value;
                      },
                      keyboardType: TextInputType.numberWithOptions(
                          signed: true, decimal: true),
                      initialValue: _initEmptyRocNumber,
                      maxLength: 4,
                      maxLines: 1,
                      decoration: InputDecoration(
                        labelText: 'Empty ROC Number',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Empty ROC Number',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            );
          }),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
              child: Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  double _qty = double.parse(_initQuantity);
                  rocModel = CollectRocModel(
                      quantity: _qty,
                      state: _initRocState,
                      rocNumber: _initRocNum,
                      containerTypeId: 1);

                  emptyRocModel = CollectionEmptyRocModel(
                      rocNumber: _initEmptyRocNumber != null
                          ? _initEmptyRocNumber
                          : "");
                  setState(() {
                    _rocs.add(rocModel.toJson());
                    _emptyRocs.add(emptyRocModel.toJson());
                    _rocs.removeAt(index);
                    _emptyRocs.removeAt(index);
                  });
                  Navigator.pop(context);
                }
              },
            )
          ],
        );
      },
    );
  }

  //New Roc record dialog
  newRocRecordDialog(BuildContext context) {
    final String functionName = "newRocRecordDialog";
    log.v("$functionName | dialog for new roc record");

    final _formKey = GlobalKey<FormState>();
    String rocNum, rocState = "Ok", quantity;
    CollectRocModel rocModel;
    showDialog(
      context: (context),
      builder: (context) {
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
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
          content: StatefulBuilder(builder: (context, setState2) {
            return SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(12, 5, 12, 5),
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 2.0,
                          color: primaryColor,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(100),
                        ),
                      ),
                      child: DropdownButton(
                          value: rocNum,
                          hint: Text('ROC Number'),
                          items: _emptyRocsAtStore.map((e) {
                            return DropdownMenuItem(
                              child: Text(e),
                              value: e,
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (mounted)
                              setState2(() {
                                rocNum = value;
                              });
                          }),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC State
                    TextFormField(
                      onChanged: (value) {
                        rocState = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter current ROC state';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      textCapitalization: TextCapitalization.sentences,
                      initialValue: rocState,
                      decoration: InputDecoration(
                        labelText: 'Current State',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Current State',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    //ROC Qunatity
                    TextFormField(
                      onChanged: (value) {
                        quantity = value;
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter the oil quantity';
                        }
                        return null;
                      },
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      maxLines: 1,
                      maxLength: 3,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                          color: primaryColor,
                          fontSize: 14,
                        ),
                        hintText: 'Quantity',
                        fillColor: Colors.white,
                        filled: true,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(100.0),
                          borderSide: BorderSide(
                            width: 2.0,
                            color: primaryColor,
                            style: BorderStyle.solid,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            );
          }),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
              child: Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              onPressed: () {
                if (_formKey.currentState.validate() && rocNum != null) {
                  double _qty = double.parse(quantity);
                  bool check = checkROCNumber(rocNum);
                  rocModel = CollectRocModel(
                      quantity: _qty,
                      state: rocState,
                      rocNumber: rocNum,
                      containerTypeId: 1);

                  if (check) {
                    setState(() {
                      _rocs.add(rocModel.toJson());
                    });
                    Navigator.pop(context);
                  }
                }
              },
            )
          ],
        );
      },
    );
  }

  bool checkROCNumber(String rocNum) {
    final String functionName = "checkROCNumber";
    log.i("$functionName | checking roc number");

    if (_rocs.isNotEmpty) {
      for (var roc in _rocs) {
        if (rocNum == roc['rocnumber']) {
          log.d("$functionName | match found $rocNum");
          rocDuplicateError(context);
          return false;
        }
      }
      log.d("$functionName | match not found $rocNum");
      return true;
    } else {
      log.i("$functionName | _rocs is empty");
      return true;
    }
  }

  bool checkEmptyRocNumber(String rocNum) {
    final String functionName = "checkROCNumber";
    log.i("$functionName | checking roc number");

    if (_emptyRocs.isNotEmpty) {
      for (var roc in _emptyRocs) {
        if (rocNum == roc['rocnumber']) {
          log.d("$functionName | match found $rocNum");
          rocDuplicateError(context);
          return false;
        }
      }
      log.d("$functionName | match not found $rocNum");
      return true;
    } else {
      log.i("$functionName | _emptyRocs is empty");
      return true;
    }
  }

  rocDuplicateError(BuildContext context) {
    final String functionName = "rocDuplicateError";
    log.v("$functionName | dialog for duplicate roc error");

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
                color: primaryColor,
              ),
              Text(
                'ERROR!',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
              ),
            ],
          ),
          content: Text('You have already entered this ROC.'),
          actions: [
            ElevatedButton(
              style: primaryColorButton(),
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

  rocDeliveredError(BuildContext context) {
    final String functionName = "rocDeliveredError";
    log.v("$functionName | dialog for roc delivered error");

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
          content: Text('This ROC number has already been delivered.'),
          actions: [
            ElevatedButton(
              style: colored18PointButton(Colors.red),
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

  //ROC List Populator
  rocTabs() {
    final String functionName = "rocTabs";
    log.v("$functionName | container for rocTabs");
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(kToolbarHeight),
            child: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(
                    15,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
              backgroundColor: primaryColor,
              bottom: const TabBar(
                indicatorSize: TabBarIndicatorSize.label,
                indicatorColor: Colors.green,
                indicatorWeight: 5,
                tabs: [
                  Text(
                    'Empty ROCs',
                    style: TextStyle(fontSize: 18),
                  ),
                  Text('Full ROCs', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          body: TabBarView(
            children: [
              deliverEmptyROCs(context),
              collectFullROCs(context),
            ],
          ),
        ));
  }

  deliverEmptyROCs(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _showData
                ? Card(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Store Number: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '${_data['storenumber']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Store Name: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '${_data['store_name']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.grey[18],
              thickness: 2.0,
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    deliverEmptyDialog(context);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: Color.fromARGB(255, 82, 203, 0), //primaryGreen,
                  ),
                  label: Text(
                    'Add Empty ROC',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            _emptyRocs.length > 0
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        Map<String, dynamic> emptyContainers =
                            _emptyRocs[index];
                        return Card(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Empty ROC No: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text('${emptyContainers['rocnumber']}'),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: primaryColor,
                                          ),
                                          onPressed: () async {
                                            if (mounted) {
                                              setState(() {
                                                _emptyRocs.removeAt(index);
                                              });
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: _emptyRocs.length,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Please add an empty ROC to proceed with the transaction',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // Tab UI for displaying the ROC infomration for the full ROCs collected a ROCSystem Supplier
  collectFullROCs(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _showData
                ? Card(
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Store Number: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '${_data['storenumber']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'Store Name: ',
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  '${_data['store_name']}',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            Divider(
              color: Colors.grey[18],
              thickness: 2.0,
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    newRocRecordDialog(context);
                  },
                  icon: Icon(
                    Icons.add_circle,
                    color: Color.fromARGB(255, 82, 203, 0), //primaryGreen,
                  ),
                  label: Text(
                    'Add Full ROC',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            _rocs.length > 0
                ? Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        Map<String, dynamic> container = _rocs[index];
                        return Card(
                          color: Color.fromRGBO(255, 255, 255, 0.8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(
                                15,
                              ),
                            ),
                          ),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${container['rocnumber']}',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: primaryColor,
                                          ),
                                          onPressed: () async {
                                            removeRocAlert(context, index);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'ROC State: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text('${container['state']}')
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'Quantity: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                      ),
                                    ),
                                    Text('${container['quantity']}')
                                  ],
                                ),
                                // new feild to display the captured empty ROC number only for ROC records
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: _rocs.length,
                    ),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height * 0.55,
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        'Please add a full ROC to proceed with the transaction',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  _getCurrentLocation() {
    final String functionName = "_getCurrentLocation";
    log.v("$functionName | getting current location");

    Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      _currentPosition = position;
      log.d("$functionName | current position: ${position.toString()}");
    }).catchError((e) {
      log.w("$functionName | getting current location failed", e,
          StackTrace.current);
    });
  }

  //Store Data Page
  selectStoreInfo() {
    final String functionName = "selectStoreInfo";
    log.v("$functionName | select store data");

    if (!_isLoading) {
      return Container(
        margin: EdgeInsets.only(top: AppBar().preferredSize.height + 60),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 60,
                  margin: EdgeInsets.only(top: 10, right: 16, left: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 5), // changes position of shadow
                      ),
                    ],
                    color: Color.fromRGBO(255, 255, 255, 0.8),
                  ),
                  child: TextButton.icon(
                    onPressed: () async {
                      dynamic result =
                          await Navigator.pushNamed(context, '/stores');
                      // Getting the list of empty ROC's that are currently available at the store.
                      List returnedList = await _listProvider.getEmptyROCList(
                          result['storeid'], _token);
                      setState(() {
                        _data = {
                          'storeid': result['storeid'],
                          'store_name': result['store_name'],
                          'countryid': result['countryid'],
                          'storenumber': result['storenumber'],
                        };
                        _emptyRocsAtStore = returnedList;
                        _showData = true;
                      });
                    },
                    icon: Icon(
                      Icons.search,
                      size: 20.0,
                      color: primaryColor,
                    ),
                    label: Text(
                      'Search Store',
                      style: TextStyle(fontSize: 20.0, color: Colors.grey[800]),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
            !_showData
                ? Container()
                : Card(
                    color: Colors.white70,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          30,
                        ),
                      ),
                    ),
                    elevation: 7,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            'Store No: ',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_data['storenumber']}',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(
                            height: 5.0,
                          ),
                          Text(
                            'Store Name: ',
                            style: TextStyle(
                              fontSize: 20.0,
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_data['store_name']}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(
                            height: 10.0,
                          ),
                          ElevatedButton(
                            style: primaryColorButton(),
                            child: Text(
                              'Continue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _getSharedPrefs();
                                _previousIndex = _index;
                                _index = 1;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      );
    } else {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: SpinKitCircle(
            color: primaryColor,
            size: 80,
          ),
        ),
      );
    }
  }
}
