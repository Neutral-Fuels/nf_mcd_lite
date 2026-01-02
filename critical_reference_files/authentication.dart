import 'dart:convert';
import 'dart:io';

import 'package:McD_NF_UCO_App/models/user_model.dart';
import 'package:McD_NF_UCO_App/screens/components/constants.dart';
import 'package:McD_NF_UCO_App/services/shared_prefs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:logger/logger.dart';
import 'package:McD_NF_UCO_App/log_printer.dart';

class NFAuthenticationServices {
  SharedPrefs _sharedPrefs = SharedPrefs();
  NFUserModel _nfUserModel;

  Logger log = getLogger("NFAuthenticationServices");

  signInWithUsernameAndPassword(String username, String password) async {
    final String functionName = "signInWithUsernameAndPassword";
    log.i("$functionName | User sign in request");

    final String _grantType = 'password';
    final Uri url = Uri.parse("$activeUrl/api/v1/Token");

    Map body = {
      'grant_type': _grantType,
      'username': username,
      'password': password,
    };

    try {
      Response response = await post(url, body: body);
      if (response.statusCode == 200) {
        log.i("$functionName | Sign in request - response 200");
        var _jsonData = jsonDecode(response.body);
        log.d("$functionName | $_jsonData}");
        _nfUserModel = NFUserModel.fromJson(_jsonData);

        if (_nfUserModel.isMcDUser == 'True') {
          AndroidOptions _getAndroidOptions() => const AndroidOptions(
                encryptedSharedPreferences: true,
                // sharedPreferencesName: 'Test2',
                // preferencesKeyPrefix: 'Test'
              );
          final storage =
              new FlutterSecureStorage(aOptions: _getAndroidOptions());
          await storage.write(key: "e", value: username);
          await storage.write(key: "p", value: password);
          _sharedPrefs.addStringToSharedPrefs(
              'token', _nfUserModel.accessToken);
          _sharedPrefs.addStringToSharedPrefs('user', jsonEncode(_nfUserModel));
          _sharedPrefs.addStringToSharedPrefs(
              'loginTime', DateTime.now().toIso8601String());
          return null;
        } else {
          log.w("$functionName | It is not a McDUser");
          return 'Invalid User';
        }
      } else {
        var _jsonData = jsonDecode(response.body);
        log.w('$functionName | ${_jsonData['error_description']}');
        return (_jsonData['error_description']);
      }
    } catch (e) {
      log.e("$functionName | Login failed", e, StackTrace.current);
      return 'Login Failed';
    }
  }

  signOut() async {
    final String functionName = "signOut";
    log.i("$functionName | User sign out request");
    final Uri url = Uri.parse("$activeUrl/api/v1/Users/Logout");
    String _token = await _sharedPrefs.getStringValueFromSharedPrefs('token');
    String _head = 'Bearer $_token';
    log.d("$functionName | token: $_token");
    log.d("$functionName | head:  $_token");

    Response response =
        await post(url, headers: {HttpHeaders.authorizationHeader: _head});
    if (response.statusCode == 200) {
      log.i("$functionName | signOut request response 200");
      _sharedPrefs.clear();
    } else if (response.statusCode == 401) {
      log.i("$functionName | signOut request response 401");
      _sharedPrefs.clear();
    } else {
      log.w(
          "$functionName | signOut request unexpected response: ${response.statusCode}");
      _sharedPrefs.clear();
    }
  }
}
