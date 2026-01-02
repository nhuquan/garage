import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

extension AppLocalizationsContextSugar on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

}
