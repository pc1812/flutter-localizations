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
import 'package:localizations/locale/localizations.dart';

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
  List<String> _supportedLanguages;
  Map<String, Map<String, String>> _localizedValues;

  @override
  void initState() {
    super.initState();
    print('initState');
    this._fetchLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (this._localizedValues == null) {
      return CircularProgressIndicator();
    }
    else {
      return MaterialApp(
        locale: _locale,
        localizationsDelegates: [
          DeLocalizationsDelegate(this._supportedLanguages, this._localizedValues),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''),
          const Locale('fr', ''),
        ],
        // Watch out: MaterialApp creates a Localizations widget
        // with the specified delegates. DemoLocalizations.of()
        // will only find the app's Localizations widget if its
        // context is a child of the app.
        home: DemoHome(),
      );
    }
    // return MaterialApp(
    //   locale: _locale,
    //   localizationsDelegates: [
    //     MyLocalizationsDelegate(),
    //     GlobalMaterialLocalizations.delegate,
    //     GlobalWidgetsLocalizations.delegate,
    //   ],
    //   supportedLocales: [
    //     const Locale('en', ''),
    //     const Locale('ar', ''),
    //   ],
    //   // Watch out: MaterialApp creates a Localizations widget
    //   // with the specified delegates. DemoLocalizations.of()
    //   // will only find the app's Localizations widget if its
    //   // context is a child of the app.
    //   home: DemoHome(),
    // );
  }

  _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    this._supportedLanguages = await initializeSupportedLanguages();
    this._localizedValues = await initializeI18n(this._supportedLanguages);
    return Locale(prefs.getString('language_code'), 
      prefs.getString('country_code'));
  }
}

class DemoHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          child: Text(DeLocalizations.of(context, 'bar')),
          onTap: () => _switchLocale(context),
        )
      ),
      body: Center(
        child: Text(DeLocalizations.of(context, 'hello')),
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
    var next = prefs.getString('language_code')=='en'?'fr':'en';
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
