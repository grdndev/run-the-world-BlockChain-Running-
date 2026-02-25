class AppConstants {
  AppConstants._();

  // API
  static const String apiBaseUrl =
      'http://10.0.2.2:3000/api'; // Android emulator localhost
  static const String apiVersion = 'v1';

  // Game constants
  static const int rpcConversionRate = 10; // 1 pt = 10 RPC
  static const int idRenewalDays = 10;
  static const double maxRunSpeed = 18.0; // km/h - anti-cheat threshold
  static const double minRunDistance = 2.0; // km - minimum for period rewards
  static const int maxTeamSize = 10;
  static const int maxBoostsPerPeriod = 3;
  static const double boostMultiplier = 1.10; // +10%
  static const int signupBonusRpc = 5000;
  static const int dailyLoginBonusRpc = 50;
  static const int dailyLoginBonusDays = 10;

  // Land costs
  static const int landRentP1 = 5000;
  static const int landRentP2to6 = 4000;
  static const int landRentP7to12 = 3000;
  static const int landPurchaseOzi = 80000;
  static const double landTransactionFee = 0.04; // 4%
  static const double landPassiveRentYield = 0.03; // 3% / month
  static const double landPassiveOwnYield = 0.035; // 3.5% / month
  static const double propertyTaxRate = 0.05; // 5%

  // OZI creation schedule (per day)
  static const Map<String, int> oziCreationSchedule = {
    'P1-P12': 80000,
    'P13-P24': 40000,
    'P25-P36': 20000,
    'P37-P48': 10000,
    'P49-P60': 5000,
    'P61-P72': 2500,
    'P73-P84': 1250,
    'P85-P96': 750,
    'P97-P108': 375,
    'P109+': 187, // 187.5 rounded
  };

  // Grades
  static const List<Map<String, dynamic>> grades = [
    {'name': 'STARTER', 'periods': 1, 'rpc': 8000, 'pts': 200},
    {'name': 'DÉBUTANT', 'periods': 2, 'rpc': 15000, 'pts': 500},
    {'name': 'CONFIRMÉ', 'periods': 3, 'rpc': 20000, 'pts': 800},
    {'name': 'EXPERT', 'periods': 5, 'rpc': 500000, 'pts': 20000},
    {'name': 'PRO', 'periods': 6, 'rpc': 1000000, 'pts': 50000},
    {'name': 'ÉLITE', 'periods': 12, 'rpc': 5000000, 'pts': 100000},
  ];
}
