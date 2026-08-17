import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quraaa/core/connectivity/connection_status.dart';
import 'package:quraaa/core/connectivity/connectivity_service.dart';
import 'package:quraaa/core/network/http_helper.dart';
import 'package:quraaa/core/services/storage_service.dart';
import 'package:quraaa/features/purchases/data/secure_purchase_book_data_source.dart';
import 'package:quraaa/features/purchases/domain/purchases.dart';

void main() {
  late Directory supportDirectory;
  late _MemoryStorage storage;
  late _RangeHttpHelper http;
  late PurchaseCacheKeyStore keyStore;
  late Uint8List pdfBytes;

  setUp(() async {
    supportDirectory = await Directory.systemTemp.createTemp(
      'quraaa_secure_pdf_test_',
    );
    storage = _MemoryStorage();
    pdfBytes = Uint8List.fromList(
      utf8.encode('%PDF-1.7\nsecure purchased book test bytes\n%%EOF'),
    );
    http = _RangeHttpHelper(pdfBytes, etag: '"book-v1"');
    keyStore = _FixedKeyStore(
      SecretKey(List<int>.generate(32, (int index) => index)),
    );
  });

  tearDown(() async {
    if (await supportDirectory.exists()) {
      await supportDirectory.delete(recursive: true);
    }
  });

  SecurePurchaseBookDataSource source({
    required HttpHelper http,
    required StorageService storage,
    required PurchaseCacheKeyStore keyStore,
    required ConnectionStatus status,
  }) {
    return SecurePurchaseBookDataSource(
      http: http,
      storage: storage,
      connectivity: _FixedConnectivity(status),
      keyStore: keyStore,
      supportDirectoryProvider: () async => supportDirectory,
      blockSize: 8,
      cacheInBackground: false,
    );
  }

  test('streams HTTP ranges and keeps only AES-GCM blocks on disk', () async {
    final SecurePurchaseBookDataSource dataSource = source(
      http: http,
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.connected,
    );

    expect(await dataSource.isAvailableOffline('purchase-1'), isFalse);

    final PurchaseBookSession session = await dataSource.open('purchase-1');
    await session.cacheForOffline();
    expect(await dataSource.isAvailableOffline('purchase-1'), isTrue);

    final Uint8List output = Uint8List(pdfBytes.length);
    expect(await session.read(output, 0, output.length), output.length);
    expect(output, pdfBytes);

    expect(http.paths, everyElement('/purchases/purchase-1/stream'));
    expect(http.ranges.first, 'bytes=0-0');
    expect(http.ranges, contains('bytes=0-7'));

    final List<File> cachedFiles = await supportDirectory
        .list(recursive: true)
        .where((FileSystemEntity entity) => entity is File)
        .cast<File>()
        .toList();
    expect(cachedFiles, isNotEmpty);
    expect(
      cachedFiles,
      everyElement(predicate<File>((File file) => file.path.endsWith('.qpc'))),
    );

    for (final File file in cachedFiles) {
      final Uint8List encrypted = await file.readAsBytes();
      expect(encrypted, isNot(pdfBytes));
      expect(
        encrypted.length >= 4 &&
            utf8.decode(encrypted.sublist(0, 4), allowMalformed: true) ==
                '%PDF',
        isFalse,
      );
    }

    final String metadata = storage.values.values.single as String;
    expect(metadata, contains('"etag":"\\\"book-v1\\\""'));
    expect(
      metadata,
      contains('"lastModified":"Sat, 15 Aug 2026 08:00:00 GMT"'),
    );
    expect(metadata, contains('"complete":true'));
  });

  test('uses If-None-Match and the encrypted cache for 304', () async {
    final SecurePurchaseBookDataSource initial = source(
      http: http,
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.connected,
    );
    final PurchaseBookSession first = await initial.open('purchase-1');
    await first.cacheForOffline();

    final _RangeHttpHelper validatingHttp = _RangeHttpHelper(
      pdfBytes,
      etag: '"book-v1"',
      respondNotModified: true,
    );
    final SecurePurchaseBookDataSource reopened = source(
      http: validatingHttp,
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.connected,
    );

    final PurchaseBookSession session = await reopened.open('purchase-1');
    final Uint8List output = Uint8List(pdfBytes.length);
    await session.read(output, 0, output.length);

    expect(output, pdfBytes);
    expect(validatingHttp.ifNoneMatch, <String?>['"book-v1"']);
    expect(validatingHttp.ranges, <String?>['bytes=0-0']);
  });

  test('opens a complete encrypted copy while offline', () async {
    final SecurePurchaseBookDataSource online = source(
      http: http,
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.connected,
    );
    final PurchaseBookSession first = await online.open('purchase-1');
    await first.cacheForOffline();

    final SecurePurchaseBookDataSource offline = source(
      http: _RangeHttpHelper(pdfBytes, etag: '"book-v1"'),
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.disconnected,
    );
    final PurchaseBookSession session = await offline.open('purchase-1');

    expect(session.isOffline, isTrue);
    final Uint8List output = Uint8List(pdfBytes.length);
    await session.read(output, 0, output.length);
    expect(output, pdfBytes);
    await session.dispose();

    final PreparedPurchaseBook prepared =
        await offline.prepareForNativeReader('purchase-1');
    expect(await File(prepared.path).readAsBytes(), pdfBytes);
    await prepared.dispose();
  });

  test('prepares a private reader file and removes it on dispose', () async {
    final SecurePurchaseBookDataSource dataSource = source(
      http: http,
      storage: storage,
      keyStore: keyStore,
      status: ConnectionStatus.connected,
    );

    final PreparedPurchaseBook prepared =
        await dataSource.prepareForNativeReader('purchase-1');
    final File clearFile = File(prepared.path);

    expect(await clearFile.exists(), isTrue);
    expect(await clearFile.readAsBytes(), pdfBytes);
    expect(clearFile.path.startsWith(supportDirectory.path), isTrue);
    expect(clearFile.path.endsWith('.pdf'), isTrue);

    await prepared.dispose();
    expect(await clearFile.exists(), isFalse);
  });
}

class _RangeHttpHelper extends HttpHelper {
  _RangeHttpHelper(
    this.bytes, {
    required this.etag,
    this.respondNotModified = false,
  }) : super(Dio());

  final Uint8List bytes;
  final String etag;
  final bool respondNotModified;
  final List<String> paths = <String>[];
  final List<String?> ranges = <String?>[];
  final List<String?> ifNoneMatch = <String?>[];

  @override
  Future<Response<dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    paths.add(path);
    final Map<String, dynamic> headers = Map<String, dynamic>.from(
      options?.headers ?? const {},
    );
    final String? range = headers[HttpHeaders.rangeHeader]?.toString();
    final String? validator =
        headers[HttpHeaders.ifNoneMatchHeader]?.toString();
    ranges.add(range);
    ifNoneMatch.add(validator);

    final RequestOptions request = RequestOptions(path: path);
    if (respondNotModified && validator == etag) {
      return Response<dynamic>(
        requestOptions: request,
        statusCode: HttpStatus.notModified,
        headers: _headers(),
      );
    }

    final RegExpMatch? match = RegExp(
      r'^bytes=(\d+)-(\d+)$',
    ).firstMatch(range ?? '');
    if (match == null) {
      return Response<dynamic>(
        requestOptions: request,
        statusCode: HttpStatus.ok,
        data: bytes,
        headers: _headers(),
      );
    }

    final int start = int.parse(match.group(1)!);
    final int end = int.parse(match.group(2)!);
    return Response<dynamic>(
      requestOptions: request,
      statusCode: HttpStatus.partialContent,
      data: Uint8List.fromList(bytes.sublist(start, end + 1)),
      headers: _headers(contentRange: 'bytes $start-$end/${bytes.length}'),
    );
  }

  Headers _headers({String? contentRange}) {
    return Headers.fromMap(<String, List<String>>{
      HttpHeaders.etagHeader: <String>[etag],
      HttpHeaders.lastModifiedHeader: <String>['Sat, 15 Aug 2026 08:00:00 GMT'],
      if (contentRange != null)
        HttpHeaders.contentRangeHeader: <String>[contentRange],
    });
  }
}

class _FixedConnectivity implements ConnectivityService {
  const _FixedConnectivity(this.status);

  final ConnectionStatus status;

  @override
  Future<ConnectionStatus> currentStatus() async => status;

  @override
  Stream<ConnectionStatus> watchStatus() => Stream.value(status);
}

class _FixedKeyStore implements PurchaseCacheKeyStore {
  const _FixedKeyStore(this.key);

  final SecretKey key;

  @override
  Future<SecretKey> readOrCreateKey() async => key;
}

class _MemoryStorage implements StorageService {
  final Map<String, Object> values = <String, Object>{};

  @override
  bool contains(String key) => values.containsKey(key);

  @override
  bool? getBool(String key) => values[key] as bool?;

  @override
  int? getInt(String key) => values[key] as int?;

  @override
  String? getString(String key) => values[key] as String?;

  @override
  List<String>? getStringList(String key) => values[key] as List<String>?;

  @override
  Future<bool> remove(String key) async => values.remove(key) != null;

  @override
  Future<bool> setBool(String key, bool value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setString(String key, String value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> setStringList(String key, List<String> value) async {
    values[key] = value;
    return true;
  }

  @override
  Future<bool> clearAll() async {
    values.clear();
    return true;
  }
}
