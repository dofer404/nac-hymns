/*
 * Copyright (C) 2018, Pirani E. Fernando <feremp.i+dev@gmail.com>
 *
 *   This program is free software: you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation, either version 3 of the License, or
 *   (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

library l10n;

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class L10n {
  Locale _locale;
  Map<String, String> _localizedValues;

  L10n(Locale locale) {
    _locale = locale;
  }

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n);
  }

  ///
  /// Generates the list of supported Locales
  ///
  static Iterable<Locale> supportedLocales() =>
      _supportedLanguages.map<Locale>((lang) => new Locale(lang, ''));

  ///
  /// Returns the localized string corresponding to the [key]
  ///
  String text(String key) {
    // Return the requested string
    return (_localizedValues == null || _localizedValues[key] == null)
        ? '** $key not found'
        : _localizedValues[key];
  }

  get l10nStrings => _localizedValues;

  ///
  /// Current language code
  ///
  get currentLanguageCode => _locale == null ? '' : _locale.languageCode;

  ///
  /// Current Locale
  ///
  get locale => _locale;

  Future<bool> load() async {
    String data = await rootBundle
        .loadString('resources/lang/${_locale.languageCode}.json');
    Map<String, dynamic> _result = json.decode(data);

    this._localizedValues = new Map();
    _result.forEach((String key, dynamic value) {
      this._localizedValues[key] = value.toString();
    });

    return true;
  }
}

const List<String> _supportedLanguages = ['es'];

class L10nDelegate extends LocalizationsDelegate<L10n> {
  const L10nDelegate();

  @override
  bool isSupported(Locale locale) =>
      _supportedLanguages.contains(locale.languageCode);

  @override
  Future<L10n> load(Locale locale) async {
    L10n localizations = new L10n(locale);
    await localizations.load();

    print("Loaded language file: '${locale.languageCode}'");

    return localizations;
  }

  @override
  bool shouldReload(L10nDelegate old) => false;
}
