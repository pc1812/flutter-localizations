import 'dart:async' show Completer, Future;
import 'dart:convert';
import 'package:flutter/foundation.dart' show SynchronousFuture;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class DeLocalizations {
  final Map<String, String> _localizedValues;

  DeLocalizations(this._localizedValues);

  static String of(BuildContext context, String key) {
    return Localizations.of<DeLocalizations>(context, 
      DeLocalizations).translate(key);
  }

  String translate(String key) {
    return _localizedValues[key];
  }

  String translateWithReplacements(key, Map<String, String> replacements) {
    String origin = _localizedValues[key];
    replacements.forEach((key, value) {
      origin = origin.replaceAll('{{$key}}', value);
    });
    return origin;
  }
}

class DeLocalizationsDelegate extends LocalizationsDelegate<DeLocalizations> {
  final List<Locale> _supportedLanguages;
  final Map<String, Map<String, String>> _localizedValues;

  DeLocalizationsDelegate(this._supportedLanguages, this._localizedValues);

  @override
  bool isSupported(Locale locale) => _supportedLanguages.contains(locale);

  @override
  Future<DeLocalizations> load(Locale locale) {
    return SynchronousFuture<DeLocalizations>
      (DeLocalizations(_localizedValues[locale.languageCode]));
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

Map<String, String> convertValueToString(String root, Map<String, dynamic> objs) {
  Map<String, String> result = {};
  objs.forEach((key, value) {
    var newKey = root!=null ? root+'.'+key : key;
    if (value is String) {
      result[newKey] = value.toString();
      print(newKey+' => '+value);
    }
    else if (value is Map) {
      Map<String, String> subResult = convertValueToString(newKey, value);
      result.addAll(subResult);
    }
    else {
      print('unknown type of value '+value.runtimeType.toString());
    }
  });
  return result;
}

Future<Map<String, Map<String, String>>> initializeI18n(List<Locale> supportedLanguages) async {
  Map<String, Map<String, String>> values = {};
  for (Locale locale in supportedLanguages) {
    Map<String, dynamic> translation =
        json.decode(await loadJsonFromAsset(locale.languageCode));
    values[locale.languageCode] = convertValueToString(null, translation);
  }
  return values;
}

Future<List<Locale>> initializeSupportedLanguages() async {
  var locales = <Locale>[];
  Completer<List<Locale>> completer = new Completer();
  Map<String, dynamic> all = json.decode(await rootBundle.loadString('assets/i18n/all.json'));
  List<dynamic> supportedLanguages = all['supported_languages'];
  supportedLanguages.forEach((language) {
    locales.add(Locale(language['code'], language['country']));
    print(language.toString());
  });
  completer.complete(locales);

  // Directory dir = await getApplicationDocumentsDirectory();
  // var lister = new Directory(dir.path+'/assets/i18n').list(recursive: false);
  // lister.listen ( 
  //   (file) {
  //     print('loaded i18n file : ' + file.path);
  //     files.add(file.path.substring(0, file.path.indexOf('.json')));
  //   },
  //   onError: (err) { print(err); },
  //   onDone: () {
  //     completer.complete(files);
  //   }
  // );

  // files.add('en');
  // files.add('fr');
  // completer.complete(files);

  return completer.future;
}