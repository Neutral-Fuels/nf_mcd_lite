import 'dart:convert';
import 'dart:io';

import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class ListProvider {
  Logger log = getLogger("ListProvider");

  SharedPrefs sharedPrefs = SharedPrefs();

  getRequest(String header, Uri _uri, String callingFunctionName) async {
    String _head = "Bearer $header";
    String logStartFormat = "getRequest: $callingFunctionName";
    try {
      Response response = await get(
        _uri,
        headers: {HttpHeaders.authorizationHeader: _head},
      );
      log.i("$logStartFormat | GET REQUEST SENT | URI :", _uri);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        log.d("$logStartFormat | GET SUCCESSFUL | BODY :", jsonData);
        return jsonData;
      } else if (response.statusCode == 401) {
        log.w(
            "$logStartFormat | GET FAILED | STATUS CODE: ${response.statusCode} | BODY: ",
            response.body);
        await sharedPrefs.clear();
        return null;
      } else {
        log.w(
            "$logStartFormat | GET FAILED | STATUS CODE: ${response.statusCode} | BODY: ",
            response.body);
        return null;
      }
    } catch (e) {
      log.e("$logStartFormat | TRY CATCH ERROR", e, StackTrace.current);
      return null;
    }
  }

  getTruckList(String header, String clientId) async {
    final String _url = "$activeUrl/api/v1/Customer/Trucks";
    Uri _uri = Uri.parse("$_url?customerid=$clientId");
    var jsonData = await getRequest(header, _uri, "getTruckList");
    if (jsonData != null) {
      List trucks = jsonData;
      return trucks;
    } else {
      return null;
    }
  }

  get3plTruckList(String header, String clientId) async {
    final String _url = "$activeUrl/api/v1/Customer/ThirdPartyTrucks";
    Uri _uri = Uri.parse("$_url?customerid=$clientId");
    var jsonData = await getRequest(header, _uri, "get3plTruckList");
    if (jsonData != null) {
      List trucks = jsonData;
      return trucks;
    } else {
      return null;
    }
  }

  getClientStaffList(String header, String storeId) async {
    final String _url = "$activeUrl/api/v1/McdStaff/StaffByStore";
    Uri _uri = Uri.parse("$_url?storeId=$storeId");
    var jsonData = await getRequest(header, _uri, "getClientStaffList");
    if (jsonData != null) {
      List staff = jsonData['staff'];
      return staff;
    } else {
      return null;
    }
  }

  getClientStaffListByCountry(String header, String countryId) async {
    final String _url = "$activeUrl/api/v1/MCDStaff/StaffByCountry";
    Uri _uri = Uri.parse("$_url?countryid=$countryId");
    var jsonData =
        await getRequest(header, _uri, "getClientStaffListByCountry");
    if (jsonData != null) {
      List staff = jsonData['staff'];
      return staff;
    } else {
      return null;
    }
  }

  getStoreList(String header, String clientId) async {
    final String _url = "$activeUrl/api/v1/Customer/Stores";
    Uri _uri = Uri.parse("$_url?customerid=$clientId");
    var jsonData = await getRequest(header, _uri, "getStoreList");
    if (jsonData != null) {
      List stores = jsonData['stores'];
      return stores;
    } else {
      return null;
    }
  }

  getNfStaffListBySite(String header, String siteId) async {
    final String _url = "$activeUrl/api/v1/NFStaff/StaffBySite";
    Uri _uri = Uri.parse("$_url?siteId=$siteId");
    var jsonData = await getRequest(header, _uri, "getNfStaffListBySite");
    if (jsonData != null) {
      List staff = jsonData['staff'];
      return staff;
    } else {
      return null;
    }
  }

  getNfSiteBySiteId(String header, String siteId) async {
    final String _url = "$activeUrl/api/v1/Sites/Site";
    Uri _uri = Uri.parse("$_url?siteId=$siteId");
    var jsonData = await getRequest(header, _uri, "getNfSiteBySiteId");
    if (jsonData != null) {
      Map<dynamic, dynamic> siteInfo = jsonData;
      return siteInfo;
    } else {
      return null;
    }
  }

  getCollectionListPendingForCleint(
      String header, String truckRego, String boolVal) async {
    final String _url =
        "$activeUrl/api/v1/ROCCollection/CollectionsPendingByTruckRego";
    Uri _uri =
        Uri.parse("$_url?truckrego=$truckRego&isallclientcollections=$boolVal");
    var jsonData =
        await getRequest(header, _uri, "getCollectionListPendingForCleint");
    if (jsonData != null) {
      List pendingRocs = jsonData['Collections'];
      return pendingRocs;
    } else {
      return null;
    }
  }

  getEmptyROCList(String storeid, String header) async {
    final String _url = "$activeUrl/api/v1/ROCCollection/EmptyRocsAtStore";
    Uri _uri = Uri.parse("$_url?storeid=$storeid");
    var jsonData = await getRequest(header, _uri, "getEmptyROCList");
    if (jsonData != null) {
      List emptyROCList = jsonData;
      return emptyROCList;
    } else {
      return null;
    }
  }

  getCustomerVerificationMethod(String customerid, String header) async {
    final String _url = "$activeUrl/api/v1/Customer/VerificationMethods";
    Uri _uri = Uri.parse("$_url?customerid=$customerid");
    var jsonData =
        await getRequest(header, _uri, "getCustomerVerificationMethod");
    if (jsonData != null) {
      return jsonData;
    } else {
      return null;
    }
  }

  customerVerificationRequest(String header, String customerid,
      String verifytypecode, String mobileappcode, String identifier) async {
    final String _url = "$activeUrl/api/v1/Customer/VerificationRequest";
    Uri _uri = Uri.parse(
        "$_url?customerid=$customerid&verifytypecode=$verifytypecode&mobileappcode=$mobileappcode&identifier=$identifier");
    var jsonData =
        await getRequest(header, _uri, "customerVerificationRequest");
    if (jsonData != null) {
      return jsonData;
    } else {
      return null;
    }
  }

  getMcDStaffWithStaffID(String header, String employeeId) async {
    final String _url = "$activeUrl/api/v1/McdStaff/StaffMemberByEmployeeId";
    Uri _uri = Uri.parse("$_url?employeeid=$employeeId");
    var jsonData = await getRequest(header, _uri, "getMcDStaffWithStaffID");
    if (jsonData != null) {
      List mcdStaffMember = jsonData['staff'];
      return mcdStaffMember;
    } else {
      return null;
    }
  }

  getCurrentMobileVersionInPROD(String header) async {
    final String _url = "$activeUrl/api/v1/System/MobileApps";
    Uri _uri = Uri.parse("$_url");
    var jsonData =
        await getRequest(header, _uri, "getCurrentMobileVersionInPROD");
    return jsonData;
  }
}
