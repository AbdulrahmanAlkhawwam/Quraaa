class AccountUserSnapshot {
  const AccountUserSnapshot({
    required this.fullName,
    this.profileImage,
  });

  final String fullName;
  final String? profileImage;

  String get firstName {
    final String trimmedName = fullName.trim();
    if (trimmedName.isEmpty) return '';
    return trimmedName.split(' ').first;
  }
}