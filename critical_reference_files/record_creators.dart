import 'package:McD_NF_UCO_App/models/new_collection_record_model.dart';
import 'package:McD_NF_UCO_App/models/new_delivery_record_model.dart';
import 'package:McD_NF_UCO_App/models/new_empty_despatch_record.dart';
import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class RecordCreator {
  Logger log = getLogger("RecordCreator");

  SharedPrefs sharedPrefs = SharedPrefs();

  postRequest(
      String header, Uri _uri, String body, String callingFunctionName) async {
    String _head = "Bearer $header";
    String logStartFormat = "postRequest: $callingFunctionName";
    try {
      Response response = await post(
        _uri,
        headers: {
          HttpHeaders.authorizationHeader: _head,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: body,
      );
      log.i("$logStartFormat | POST REQUEST SENT | URI :", _uri);
      log.i("$logStartFormat | POST REQUEST SENT | BODY :", body);
      if (response.statusCode == 200) {
        log.d("$logStartFormat | POST SUCCESSFUL | RESPONSE :", response.body);
        return response.body;
      } else if (response.statusCode == 401) {
        log.w(
            "$logStartFormat | POST FAILED | STATUS CODE: ${response.statusCode} | BODY: ",
            response.body);
        await sharedPrefs.clear();
        return null;
      } else {
        log.w(
            "$logStartFormat | POST FAILED | STATUS CODE: ${response.statusCode} | BODY: ",
            response.body);
        return null;
      }
    } catch (e) {
      log.e("$logStartFormat | TRY CATCH ERROR", e, StackTrace.current);
      return null;
    }
  }

  newDelivery(BuildContext context, String header,
      RcoDeliveryModel rcoDeliveryModel) async {
    final Uri url = Uri.parse("$activeUrl/api/v1/ROCDelivery/newDelivery");
    String body = json.encode(rcoDeliveryModel.toJson());
    var responseBody = await postRequest(header, url, body, "newDelivery");
    return responseBody;
  }

  newCollection(BuildContext context, String header,
      RocCollectionModel rocCollectionModel) async {
    final Uri url = Uri.parse("$activeUrl/api/v1/ROCCollection/newCollection");
    String body = json.encode(rocCollectionModel.toJson());
    var responseBody = await postRequest(header, url, body, "newCollection");
    if (responseBody != null) {
      Navigator.pushReplacementNamed(context, '/');
      return responseBody;
    } else {
      return responseBody;
    }
  }

  newDespatch(BuildContext context, String header,
      EmptyDespatchRecordModel emptyDespatchRecordModel) async {
    final Uri url = Uri.parse("$activeUrl/api/v1/Despatch/newDepatchedEmpty");
    String body = json.encode(emptyDespatchRecordModel.toJson());
    var responseBody = await postRequest(header, url, body, "newDespatch");
    return responseBody;
  }
}
