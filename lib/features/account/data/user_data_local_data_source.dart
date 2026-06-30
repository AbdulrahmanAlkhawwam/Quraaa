import '../../../../core/services/storage_service.dart';

class UserDataLocalDataSource {
  const UserDataLocalDataSource(this._storageService);

  final StorageService _storageService;

  static const String _fullNameKey = 'user_full_name';
  static const String _birthDateKey = 'user_birth_date';
  static const String _countryKey = 'user_country';
  static const String _phoneKey = 'user_phone';
  static const String _themeKey = 'user_theme';
  static const String _languageKey = 'user_language';
  static const String _bookmarksKey = 'user_bookmarks';
  static const String _budgetBalanceKey = 'user_budget_balance';
  static const String _libraryItemsKey = 'user_library_items';
  static const String _operationsKey = 'user_operations';

  Future<UserDataSnapshot> load() async {
    return UserDataSnapshot(
      fullName: _storageService.getString(_fullNameKey) ?? 'Abdulrahman Alkhawwam',
      birthDate: _storageService.getString(_birthDateKey) ?? '2005/04/21',
      country: _storageService.getString(_countryKey) ?? 'United Arab Emirates',
      phone: _storageService.getString(_phoneKey) ?? '+971 500 000 000',
      theme: _storageService.getString(_themeKey) ?? 'Light',
      language: _storageService.getString(_languageKey) ?? 'English',
      bookmarks: _storageService.getStringList(_bookmarksKey) ??
          <String>['Quran recitations', 'Book notes'],
      budgetBalance: _storageService.getString(_budgetBalanceKey) ?? 'AED 250.00',
      libraryItems: _storageService.getStringList(_libraryItemsKey) ??
          <String>['Saved books', 'Listening queue'],
      operations: _storageService.getStringList(_operationsKey) ??
          <String>['Login', 'Bookmark added', 'Budget update'],
    );
  }

  Future<void> saveProfile({
    required String fullName,
    required String birthDate,
    required String country,
    required String phone,
  }) async {
    await _storageService.setString(_fullNameKey, fullName);
    await _storageService.setString(_birthDateKey, birthDate);
    await _storageService.setString(_countryKey, country);
    await _storageService.setString(_phoneKey, phone);
  }

  Future<void> saveAppearance({
    required String theme,
    required String language,
  }) async {
    await _storageService.setString(_themeKey, theme);
    await _storageService.setString(_languageKey, language);
  }

  Future<void> saveBookmarks(List<String> bookmarks) async {
    await _storageService.setStringList(_bookmarksKey, bookmarks);
  }

  Future<void> saveBudgetBalance(String budgetBalance) async {
    await _storageService.setString(_budgetBalanceKey, budgetBalance);
  }

  Future<void> saveLibraryItems(List<String> items) async {
    await _storageService.setStringList(_libraryItemsKey, items);
  }

  Future<void> saveOperations(List<String> operations) async {
    await _storageService.setStringList(_operationsKey, operations);
  }
}

class UserDataSnapshot {
  const UserDataSnapshot({
    required this.fullName,
    required this.birthDate,
    required this.country,
    required this.phone,
    required this.theme,
    required this.language,
    required this.bookmarks,
    required this.budgetBalance,
    required this.libraryItems,
    required this.operations,
  });

  final String fullName;
  final String birthDate;
  final String country;
  final String phone;
  final String theme;
  final String language;
  final List<String> bookmarks;
  final String budgetBalance;
  final List<String> libraryItems;
  final List<String> operations;
}
