
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';



class Loc {
  final Locale locale;

  Loc({required this.locale});

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  static Loc? of(BuildContext context) {
    return Localizations.of<Loc>(context, Loc);
  }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<Loc> delegate =
  _AppLocalizationsDelegate();

  Map<String, String> _localizedStrings = Map<String, String>();

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
    await rootBundle.loadString('i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // This method will be called from every widget which needs a localized text
  String tr(String key) {
    return _localizedStrings[key] ?? "empty";
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<Loc> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    // Include all of your supported language codes here
    return ['en', 'cn', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<Loc> load(Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    Loc localizations = new Loc(locale: locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}