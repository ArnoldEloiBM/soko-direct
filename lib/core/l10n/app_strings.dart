/// Central place for every user-facing string in Kinyarwanda and English.
/// Screens NEVER hardcode text — they call AppStrings.of(languageCode).
///
/// To add a string: add the same key to BOTH maps below.
class AppStrings {
  final String languageCode; // 'rw' or 'en'

  const AppStrings(this.languageCode);

  static const Map<String, String> _rw = {
    'appName': 'SOKO DIRECT',
    'tagline': "Guhuza abahinzi n'abaguzi",
    'chooseLanguage': 'Hitamo ururimi',
    'kinyarwanda': 'Kinyarwanda',
    'english': 'English',
    'chooseRole': 'Uri nde?',
    'farmer': 'Umuhinzi',
    'buyer': 'Umuguzi',
    'farmerSubtitle': 'Gurisha umusaruro wawe',
    'buyerSubtitle': 'Gura ku bahinzi',
    'continueLabel': 'Komeza',
    'marketPrices': "Ibiciro by'isoko",
    'dashboardTitle': 'Ikaze',
    'perKg': 'ku kilo',
    'listings': 'ibicuruzwa',
    'avgPrice': 'Igiciro rusange',
    'noPrices': 'Nta biciro birahari',
    'errorGeneric': 'Habaye ikibazo. Ongera ugerageze.',
    'retry': 'Ongera ugerageze',
  };

  static const Map<String, String> _en = {
    'appName': 'SOKO DIRECT',
    'tagline': 'Connecting Farmers to Buyers',
    'chooseLanguage': 'Choose your language',
    'kinyarwanda': 'Kinyarwanda',
    'english': 'English',
    'chooseRole': 'Who are you?',
    'farmer': 'Farmer',
    'buyer': 'Buyer',
    'farmerSubtitle': 'Sell your harvest',
    'buyerSubtitle': 'Buy from farmers',
    'continueLabel': 'Continue',
    'marketPrices': 'Market Prices',
    'dashboardTitle': 'Welcome',
    'perKg': 'per kg',
    'listings': 'listings',
    'avgPrice': 'Average price',
    'noPrices': 'No market prices yet',
    'errorGeneric': 'Something went wrong. Please try again.',
    'retry': 'Retry',
  };

  String get(String key) {
    final map = languageCode == 'rw' ? _rw : _en;
    return map[key] ?? key;
  }
}
