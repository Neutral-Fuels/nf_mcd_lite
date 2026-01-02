import 'package:flutter/material.dart';

String mobileAppCode = 'MCDUCO';
String mobileAppVersion = '1.3.1';
String androidAppId = 'inc.o3shx.neutralfuels';
String iOSAppId = '1528951231';
String currentTestVersion = "1.4.0 (32)";
bool isTestEnv = true;

String testEnv = 'https://nf-test-ucoapi.neutralfuels.net';
// String testEnv = 'https://nf-prod-ucoapi.neutralfuels.net/'; // TEMP PROD ENV
// String prodEnv = 'https://api.myneutralfuels.com';
String prodEnv = 'https://ucoapi.neutralfuels.net'; // NEW UCO API

String activeUrl = isTestEnv ? testEnv : prodEnv;

Color primaryColor = Color.fromARGB(255, 37, 138, 255);
Color secondaryColor = Color.fromARGB(255, 82, 203, 0);

Color widgetOrange = Color.fromRGBO(244, 152, 35, 0.7);
Color widgetPink = Color.fromRGBO(212, 97, 210, 0.7);
Color widgetBlue = Color.fromRGBO(36, 200, 248, 0.7);
Color widgetGrey = Color.fromRGBO(133, 155, 144, 0.3);
