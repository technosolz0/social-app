import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle.loadString('assets/l10n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Common translations
  String get appName => translate('app_name');
  String get login => translate('login');
  String get register => translate('register');
  String get logout => translate('logout');
  String get home => translate('home');
  String get profile => translate('profile');
  String get settings => translate('settings');
  String get chat => translate('chat');
  String get search => translate('search');
  String get notifications => translate('notifications');

  // Auth translations
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get forgotPassword => translate('forgot_password');
  String get loginWithEmail => translate('login_with_email');
  String get createAccount => translate('create_account');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');

  // Error messages
  String get invalidCredentials => translate('invalid_credentials');
  String get networkError => translate('network_error');
  String get somethingWentWrong => translate('something_went_wrong');
  String get fieldRequired => translate('field_required');
  String get invalidEmail => translate('invalid_email');
  String get passwordTooShort => translate('password_too_short');
  String get passwordsDontMatch => translate('passwords_dont_match');

  // Social features
  String get like => translate('like');
  String get comment => translate('comment');
  String get share => translate('share');
  String get follow => translate('follow');
  String get unfollow => translate('unfollow');
  String get followers => translate('followers');
  String get following => translate('following');

  // Chat
  String get typeMessage => translate('type_message');
  String get send => translate('send');
  String get online => translate('online');
  String get offline => translate('offline');
  String get typing => translate('typing');

  // Gamification
  String get points => translate('points');
  String get level => translate('level');
  String get badges => translate('badges');
  String get streak => translate('streak');
  String get leaderboard => translate('leaderboard');
  String get quests => translate('quests');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es', 'fr', 'de', 'hi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Supported locales
const List<Locale> supportedLocales = [
  Locale('en', ''), // English
  Locale('es', ''), // Spanish
  Locale('fr', ''), // French
  Locale('de', ''), // German
  Locale('hi', ''), // Hindi
];
