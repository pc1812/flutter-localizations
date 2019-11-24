// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// A simple "rough and ready" example of localizing a Flutter app.
// Spanish and English (locale language codes 'en' and 'es') are
// supported.

// The pubspec.yaml file must include flutter_localizations in its
// dependencies section. For example:
//
// dependencies:
//   flutter:
//   sdk: flutter
//  flutter_localizations:
//    sdk: flutter

// If you run this app with the device's locale set to anything but
// English or Spanish, the app's locale will be English. If you
// set the device's locale to Spanish, the app's locale will be
// Spanish.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(DemoApp());
}

class DemoApp extends StatefulWidget {
  @override
  DemoAppState createState() => DemoAppState();
  
  static void setLocale(BuildContext context, Locale locale) {
    DemoAppState state = context.ancestorStateOfType(TypeMatcher<DemoAppState>());

    state.setState((){
      state._locale = locale;
      print('setState : '+locale.languageCode);
    });
  }

}

class DemoAppState extends State<DemoApp> {

  Locale _locale;
  bool isLocaleLoaded;

  @override
  void initState() {
    super.initState();
    print('initState');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: [
        MyLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('en', ''),
        const Locale('ar', ''),
      ],
      // Watch out: MaterialApp creates a Localizations widget
      // with the specified delegates. DemoLocalizations.of()
      // will only find the app's Localizations widget if its
      // context is a child of the app.
      home: DemoHome(),
    );
  }
}

class DemoHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(MyLocalizations.of(context, 'bar')),
          onTap: () => _switchLocale(context),
        )
      ),
      body: Center(
        child: Text(MyLocalizations.of(context, 'foo')),
      ),
    );
  }

  _switchLocale(context) async {
    // var mylocale = Localizations.localeOf(context);
    // print(mylocale.languageCode);
    // var next = mylocale.languageCode=='en'?'ar':'en';
    // print('next:'+next);
    // MyLocalizations.load(Locale((next)));

    var prefs = await SharedPreferences.getInstance();

    print('current : '+prefs.getString('language_code'));
    var next = prefs.getString('language_code')=='en'?'ar':'en';
    await prefs.setString('language_code', next);
    await prefs.setString('country_code', '');
    DemoApp.setLocale(context, new Locale(next, ''));
  }
}

class MyLocalizations {
  MyLocalizations(this.locale);

  final Locale locale;

  static Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'foo': 'Foo',
      'bar': 'Bar'
    },
    'ar': {
      'foo': 'فو',
      'bar': 'بار'
    }
  };

  String translate(key) {
    return _localizedValues[locale.languageCode][key];
  }

  static String of(BuildContext context, String key) {
    return Localizations.of<MyLocalizations>(context, 
      MyLocalizations).translate(key);
  }
}

class MyLocalizationsDelegate extends 
  LocalizationsDelegate<MyLocalizations> {
  
  const MyLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => 
    ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>
      (MyLocalizations(locale));
  }

  @override
  bool shouldReload(MyLocalizationsDelegate old) => false;
}
