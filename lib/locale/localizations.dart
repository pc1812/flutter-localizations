import 'dart:async' show Completer, Future;
import 'dart:convert';
// import 'dart:io';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:path_provider/path_provider.dart';


class DeLocalizations {
  final Locale _locale;
  final Map<String, String> _localizedValues;

  DeLocalizations(this._locale, this._localizedValues);

  static String of(BuildContext context, String key) {
    return Localizations.of<DeLocalizations>(context, 
      DeLocalizations).translate(key);
  }

  String translate(String key) {
    return _localizedValues[key];
  }

  String replace(key, value, replacement) {
    return _localizedValues[key]
        .replaceAll('{{$value}}', replacement);
  }
}

class DeLocalizationsDelegate extends LocalizationsDelegate<DeLocalizations> {
  final List<String> _supportedLanguages;
  final Map<String, Map<String, String>> _localizedValues;

  DeLocalizationsDelegate(this._supportedLanguages, this._localizedValues);

  @override
  bool isSupported(Locale locale) => _supportedLanguages.contains(locale.languageCode);

  // @override
  // Future<DeLocalizations> load(Locale locale) {
  //   print(locale != null ? 'has locale' : 'no locale');
  //   print('delegate load '+locale.languageCode);
  //   var de = DeLocalizations(locale, _localizedValues);

  //   var completer = new Completer<DeLocalizations>();
  //   completer.complete(de);
  //   return completer.future;
  //   // return SynchronousFuture<DeLocalizations>(
  //       // DeLocalizations(locale, _localizedValues));
  //   // return Future<DeLocalizations>(DeLocalizations(locale, _localizedValues));
  // }
  @override
  Future<DeLocalizations> load(Locale locale) {
    return SynchronousFuture<DeLocalizations>
      (DeLocalizations(locale, _localizedValues[locale.languageCode]));
  }


  @override
  bool shouldReload(DeLocalizationsDelegate old) => false;
}

Future<String> loadJsonFromAsset(language) async {
  try {
    return await rootBundle.loadString('assets/i18n/' + language + '.json');
  }
  catch (e) {
    print(e);
    throw e;
  }
}

Map<String, String> convertValueToString(obj) {
  Map<String, String> result = {};
  obj.forEach((key, value) {
    result[key] = value.toString();
  });
  return result;
}

Future<Map<String, Map<String, String>>> initializeI18n(List<String> supportedLanguages) async {
  Map<String, Map<String, String>> values = {};
  for (String language in supportedLanguages) {
    Map<String, dynamic> translation =
        json.decode(await loadJsonFromAsset(language));
    values[language] = convertValueToString(translation);
  }
  return values;
}

Future<List<String>> initializeSupportedLanguages() async {
  var files = <String>[];
  Completer<List<String>> completer = new Completer();
  // Directory dir = await getApplicationDocumentsDirectory();
  // var lister = new Directory(dir.path+'assets/i18n').list(recursive: false);
  // lister.listen ( 
  //   (file) => files.add(file.path.substring(0, file.path.indexOf('.json'))),
  //   onError: (err) { print(err); },
  //   onDone: () => completer.complete(files)
  // );
  files.add('en');
  files.add('fr');
  completer.complete(files);
  return completer.future;
}