enum GenderSelection {
  boy('boy'),
  girl('girl');

  const GenderSelection(this.key);

  final String key;

  static GenderSelection? fromKey(String? value) {
    if (value == boy.key) {
      return boy;
    }
    if (value == girl.key) {
      return girl;
    }
    return null;
  }
}
