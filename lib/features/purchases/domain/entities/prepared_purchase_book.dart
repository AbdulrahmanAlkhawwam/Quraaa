/// A short-lived clear-text file required by the existing native PDF renderer.
///
/// The file lives only inside the application sandbox and [dispose] removes it
/// as soon as the reader route is closed. The durable offline cache remains
/// encrypted.
class PreparedPurchaseBook {
  PreparedPurchaseBook({
    required this.path,
    required Future<void> Function() release,
  }) : _release = release;

  final String path;
  final Future<void> Function() _release;
  bool _released = false;

  Future<void> dispose() async {
    if (_released) return;
    _released = true;
    await _release();
  }
}
