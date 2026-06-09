class Validators {
  static bool requiredField(String? value) => value != null && value.trim().isNotEmpty;
}
