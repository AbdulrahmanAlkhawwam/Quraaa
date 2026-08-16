import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/connectivity/connection_status.dart';
import '../../../core/connectivity/connectivity_service.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/http_helper.dart';
import '../../../core/services/storage_service.dart';
import '../domain/purchases.dart';

typedef ApplicationSupportDirectoryProvider = Future<Directory> Function();

abstract class PurchaseCacheKeyStore {
  Future<SecretKey> readOrCreateKey();
}

class FlutterSecurePurchaseCacheKeyStore implements PurchaseCacheKeyStore {
  FlutterSecurePurchaseCacheKeyStore(this._storage);

  static const String _keyName = 'quraaa.secure-purchases.aes-key.v1';

  final FlutterSecureStorage _storage;

  @override
  Future<SecretKey> readOrCreateKey() async {
    final String? encoded = await _storage.read(key: _keyName);
    if (encoded != null && encoded.isNotEmpty) {
      final List<int> bytes = base64Url.decode(encoded);
      if (bytes.length != 32) {
        throw const FormatException('Invalid secure book cache key.');
      }
      return SecretKey(bytes);
    }

    final math.Random random = math.Random.secure();
    final Uint8List bytes = Uint8List.fromList(
      List<int>.generate(32, (_) => random.nextInt(256), growable: false),
    );
    await _storage.write(key: _keyName, value: base64UrlEncode(bytes));
    return SecretKey(bytes);
  }
}

/// Provides authenticated random-access ranges for purchased PDFs.
///
/// Each range is cached as an independent AES-256-GCM block under
/// [getApplicationSupportDirectory]. PDF bytes are only clear-text in RAM.
class SecurePurchaseBookDataSource {
  SecurePurchaseBookDataSource({
    required HttpHelper http,
    required StorageService storage,
    required ConnectivityService connectivity,
    required PurchaseCacheKeyStore keyStore,
    ApplicationSupportDirectoryProvider? supportDirectoryProvider,
    AesGcm? cipher,
    this.blockSize = 256 * 1024,
    this.cacheInBackground = true,
  })  : assert(blockSize > 0),
        _http = http,
        _storage = storage,
        _connectivity = connectivity,
        _keyStore = keyStore,
        _supportDirectoryProvider =
            supportDirectoryProvider ?? getApplicationSupportDirectory,
        _cipher = cipher ?? AesGcm.with256bits();

  static const int _cacheSchemaVersion = 1;
  static const int _encryptedBlockVersion = 1;

  final HttpHelper _http;
  final StorageService _storage;
  final ConnectivityService _connectivity;
  final PurchaseCacheKeyStore _keyStore;
  final ApplicationSupportDirectoryProvider _supportDirectoryProvider;
  final AesGcm _cipher;
  final int blockSize;
  final bool cacheInBackground;

  final Map<String, Future<Uint8List>> _pendingBlocks =
      <String, Future<Uint8List>>{};
  Future<SecretKey>? _secretKey;

  Future<PurchaseBookSession> open(String purchaseId) async {
    final String normalizedId = purchaseId.trim();
    if (normalizedId.isEmpty) {
      throw ArgumentError.value(purchaseId, 'purchaseId', 'Cannot be empty.');
    }

    final Directory directory = await _purchaseDirectory(normalizedId);
    final _PurchaseCacheMetadata? cached = _loadMetadata(normalizedId);
    final bool hasCompleteCache = cached != null &&
        cached.schemaVersion == _cacheSchemaVersion &&
        cached.blockSize == blockSize &&
        await _hasAllBlocks(directory, cached);

    final ConnectionStatus connectionStatus =
        await _connectivity.currentStatus();
    if (connectionStatus == ConnectionStatus.disconnected) {
      if (hasCompleteCache) {
        return _session(
          metadata: cached,
          directory: directory,
          remoteEnabled: false,
          isOffline: true,
        );
      }
      throw const SocketException(
        'This book is not available offline yet. Connect to the internet once '
        'to cache it securely.',
      );
    }

    try {
      Response<dynamic> response = await _probe(normalizedId, cached);
      if (response.statusCode == HttpStatus.notModified) {
        if (hasCompleteCache) {
          return _session(
            metadata: cached,
            directory: directory,
            remoteEnabled: false,
            isOffline: false,
          );
        }
        response = await _probe(normalizedId, null);
      }

      _PurchaseCacheMetadata remote = _metadataFromResponse(
        normalizedId,
        response,
      );
      final List<int> probeBytes = _responseBytes(response);

      if (response.statusCode == HttpStatus.ok) {
        if (probeBytes.isEmpty) {
          throw const FormatException('The server returned an empty PDF.');
        }
        remote = remote.copyWith(fileSize: probeBytes.length);
        if (cached == null || !_sameVersion(cached, remote)) {
          await _resetDirectory(directory);
        }
        await _saveMetadata(remote.copyWith(complete: false));
        await _writeFullResponse(remote, directory, probeBytes);
        final _PurchaseCacheMetadata complete = remote.copyWith(complete: true);
        await _saveMetadata(complete);
        return _session(
          metadata: complete,
          directory: directory,
          remoteEnabled: false,
          isOffline: false,
        );
      }

      if (response.statusCode != HttpStatus.partialContent) {
        throw HttpException(
          'Unexpected PDF stream response: ${response.statusCode}.',
        );
      }

      final bool sameVersion = cached != null && _sameVersion(cached, remote);
      if (sameVersion && hasCompleteCache) {
        return _session(
          metadata: cached,
          directory: directory,
          remoteEnabled: false,
          isOffline: false,
        );
      }

      if (!sameVersion) {
        await _resetDirectory(directory);
      } else {
        await _ensureBlocksDirectory(directory);
      }

      remote = remote.copyWith(complete: false);
      await _saveMetadata(remote);
      final _SecurePurchaseBookSession session = _session(
        metadata: remote,
        directory: directory,
        remoteEnabled: true,
        isOffline: false,
      );
      if (cacheInBackground) {
        unawaited(
          session.cacheForOffline().catchError((Object _) {
            // The reader still has range access. A later open resumes caching.
          }),
        );
      }
      return session;
    } on DioException {
      if (hasCompleteCache) {
        return _session(
          metadata: cached,
          directory: directory,
          remoteEnabled: false,
          isOffline: true,
        );
      }
      rethrow;
    } on SocketException {
      if (hasCompleteCache) {
        return _session(
          metadata: cached,
          directory: directory,
          remoteEnabled: false,
          isOffline: true,
        );
      }
      rethrow;
    }
  }

  Future<PreparedPurchaseBook> prepareForNativeReader(String purchaseId) async {
    final PurchaseBookSession session = await open(purchaseId);
    File? clearFile;
    try {
      if (session.fileSize <= 0) {
        throw const FormatException('The PDF stream is empty.');
      }

      await session.cacheForOffline();

      final Directory supportDirectory = await _supportDirectoryProvider();
      final Directory runtimeDirectory = Directory(
        '${supportDirectory.path}${Platform.pathSeparator}quraaa'
        '${Platform.pathSeparator}secure-purchases'
        '${Platform.pathSeparator}runtime',
      );
      await runtimeDirectory.create(recursive: true);
      await _removeStaleRuntimeFiles(runtimeDirectory);

      final String encodedId = base64UrlEncode(
        utf8.encode(purchaseId.trim()),
      ).replaceAll('=', '');
      clearFile = File(
        '${runtimeDirectory.path}${Platform.pathSeparator}'
        '$encodedId-${DateTime.now().microsecondsSinceEpoch}.pdf',
      );

      final RandomAccessFile output = await clearFile.open(
        mode: FileMode.write,
      );
      final Uint8List buffer = Uint8List(math.min(blockSize, session.fileSize));
      try {
        int position = 0;
        while (position < session.fileSize) {
          final int requested = math.min(
            buffer.length,
            session.fileSize - position,
          );
          final int bytesRead = await session.read(buffer, position, requested);
          if (bytesRead <= 0) {
            throw const FormatException('The PDF stream ended unexpectedly.');
          }
          await output.writeFrom(buffer, 0, bytesRead);
          buffer.fillRange(0, bytesRead, 0);
          position += bytesRead;
        }
        await output.flush();
      } finally {
        buffer.fillRange(0, buffer.length, 0);
        await output.close();
      }

      final File preparedFile = clearFile;
      return PreparedPurchaseBook(
        path: preparedFile.path,
        release: () async {
          if (await preparedFile.exists()) {
            await preparedFile.delete();
          }
        },
      );
    } catch (_) {
      if (clearFile != null && await clearFile.exists()) {
        await clearFile.delete();
      }
      rethrow;
    } finally {
      await session.dispose();
    }
  }

  Future<void> _removeStaleRuntimeFiles(Directory directory) async {
    final DateTime cutoff = DateTime.now().subtract(const Duration(days: 1));
    await for (final FileSystemEntity entity in directory.list()) {
      if (entity is! File) continue;
      try {
        if ((await entity.lastModified()).isBefore(cutoff)) {
          await entity.delete();
        }
      } on FileSystemException {
        // Best-effort cleanup; an active reader may still own the file.
      }
    }
  }

  _SecurePurchaseBookSession _session({
    required _PurchaseCacheMetadata metadata,
    required Directory directory,
    required bool remoteEnabled,
    required bool isOffline,
  }) {
    return _SecurePurchaseBookSession(
      source: this,
      metadata: metadata,
      directory: directory,
      remoteEnabled: remoteEnabled,
      isOffline: isOffline,
    );
  }

  Future<Response<dynamic>> _probe(
    String purchaseId,
    _PurchaseCacheMetadata? cached,
  ) {
    return _http.get(
      ApiEndpoints.purchaseStream(purchaseId),
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, Object?>{
          HttpHeaders.acceptHeader: 'application/pdf',
          HttpHeaders.rangeHeader: 'bytes=0-0',
          if (cached?.etag.isNotEmpty ?? false)
            HttpHeaders.ifNoneMatchHeader: cached!.etag,
          if ((cached?.etag.isEmpty ?? true) &&
              (cached?.lastModified.isNotEmpty ?? false))
            HttpHeaders.ifModifiedSinceHeader: cached!.lastModified,
        },
        validateStatus: (int? status) =>
            status == HttpStatus.ok ||
            status == HttpStatus.partialContent ||
            status == HttpStatus.notModified,
      ),
    );
  }

  _PurchaseCacheMetadata _metadataFromResponse(
    String purchaseId,
    Response<dynamic> response,
  ) {
    final int fileSize = response.statusCode == HttpStatus.ok
        ? _responseBytes(response).length
        : _totalSize(response.headers.value(HttpHeaders.contentRangeHeader));
    if (fileSize <= 0) {
      throw const FormatException(
        'The PDF stream did not provide a valid content length.',
      );
    }

    return _PurchaseCacheMetadata(
      schemaVersion: _cacheSchemaVersion,
      purchaseId: purchaseId,
      etag: response.headers.value(HttpHeaders.etagHeader)?.trim() ?? '',
      lastModified:
          response.headers.value(HttpHeaders.lastModifiedHeader)?.trim() ?? '',
      fileSize: fileSize,
      blockSize: blockSize,
      complete: false,
    );
  }

  int _totalSize(String? contentRange) {
    if (contentRange == null) return 0;
    final RegExpMatch? match = RegExp(
      r'^bytes\s+\d+-\d+/(\d+)$',
      caseSensitive: false,
    ).firstMatch(contentRange.trim());
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  List<int> _responseBytes(Response<dynamic> response) {
    final Object? data = response.data;
    if (data == null) return const <int>[];
    if (data is Uint8List) return data;
    if (data is List<int>) return data;
    throw const FormatException('Invalid PDF byte response.');
  }

  bool _sameVersion(
    _PurchaseCacheMetadata local,
    _PurchaseCacheMetadata remote,
  ) {
    if (local.fileSize != remote.fileSize ||
        local.blockSize != remote.blockSize) {
      return false;
    }
    if (local.etag.isNotEmpty && remote.etag.isNotEmpty) {
      return local.etag == remote.etag;
    }
    if (local.lastModified.isNotEmpty && remote.lastModified.isNotEmpty) {
      return local.lastModified == remote.lastModified;
    }
    return false;
  }

  Future<int> _read(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    bool remoteEnabled,
    Uint8List buffer,
    int position,
    int requestedSize,
  ) async {
    if (position < 0 || requestedSize < 0) {
      throw RangeError('PDF byte ranges cannot be negative.');
    }
    if (position >= metadata.fileSize || requestedSize == 0) return 0;

    final int size = math.min(requestedSize, metadata.fileSize - position);
    if (buffer.length < size) {
      throw RangeError.range(buffer.length, size, null, 'buffer.length');
    }

    final int firstBlock = position ~/ metadata.blockSize;
    final int lastBlock = (position + size - 1) ~/ metadata.blockSize;
    int copied = 0;

    for (int blockIndex = firstBlock; blockIndex <= lastBlock; blockIndex++) {
      final Uint8List block = await _readBlock(
        metadata,
        directory,
        remoteEnabled,
        blockIndex,
      );
      final int blockStart = blockIndex * metadata.blockSize;
      final int sourceStart = math.max(0, position - blockStart);
      final int sourceEnd = math.min(
        block.length,
        position + size - blockStart,
      );
      final int count = sourceEnd - sourceStart;
      buffer.setRange(copied, copied + count, block, sourceStart);
      copied += count;
    }
    return copied;
  }

  Future<Uint8List> _readBlock(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    bool remoteEnabled,
    int blockIndex,
  ) async {
    final File file = _blockFile(directory, blockIndex);
    if (await file.exists()) {
      try {
        return await _decryptBlock(metadata, blockIndex, file);
      } catch (_) {
        if (!remoteEnabled) rethrow;
        await file.delete();
      }
    }

    if (!remoteEnabled) {
      throw const SocketException(
        'A required encrypted PDF block is not available offline.',
      );
    }

    final String pendingKey =
        '${metadata.purchaseId}|${metadata.validator}|$blockIndex';
    final Future<Uint8List>? pending = _pendingBlocks[pendingKey];
    if (pending != null) return pending;

    final Future<Uint8List> download =
        _downloadBlock(metadata, directory, blockIndex).whenComplete(() {
      _pendingBlocks.remove(pendingKey);
    });
    _pendingBlocks[pendingKey] = download;
    return download;
  }

  Future<Uint8List> _downloadBlock(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    int blockIndex,
  ) async {
    final int start = blockIndex * metadata.blockSize;
    final int end = math.min(
      metadata.fileSize - 1,
      start + metadata.blockSize - 1,
    );
    final Response<dynamic> response = await _http.get(
      ApiEndpoints.purchaseStream(metadata.purchaseId),
      options: Options(
        responseType: ResponseType.bytes,
        headers: <String, Object?>{
          HttpHeaders.acceptHeader: 'application/pdf',
          HttpHeaders.rangeHeader: 'bytes=$start-$end',
          if (metadata.etag.isNotEmpty) 'If-Range': metadata.etag,
          if (metadata.etag.isEmpty && metadata.lastModified.isNotEmpty)
            'If-Range': metadata.lastModified,
        },
        validateStatus: (int? status) =>
            status == HttpStatus.ok || status == HttpStatus.partialContent,
      ),
    );
    final List<int> bytes = _responseBytes(response);

    if (response.statusCode == HttpStatus.ok) {
      if (bytes.length != metadata.fileSize) {
        throw const FormatException(
          'The server ignored the range with an incomplete PDF response.',
        );
      }
      await _writeFullResponse(metadata, directory, bytes);
      await _saveMetadata(metadata.copyWith(complete: true));
      return Uint8List.fromList(bytes.sublist(start, end + 1));
    }

    _verifyVersion(metadata, response.headers);
    final int expectedLength = end - start + 1;
    if (bytes.length != expectedLength) {
      throw FormatException(
        'Invalid PDF range length: expected $expectedLength, '
        'received ${bytes.length}.',
      );
    }

    final Uint8List block = Uint8List.fromList(bytes);
    await _writeEncryptedBlock(metadata, directory, blockIndex, block);
    return block;
  }

  void _verifyVersion(_PurchaseCacheMetadata metadata, Headers headers) {
    final String remoteEtag =
        headers.value(HttpHeaders.etagHeader)?.trim() ?? '';
    final String remoteModified =
        headers.value(HttpHeaders.lastModifiedHeader)?.trim() ?? '';
    if (metadata.etag.isNotEmpty &&
        remoteEtag.isNotEmpty &&
        metadata.etag != remoteEtag) {
      throw StateError('The PDF changed while it was being read. Reopen it.');
    }
    if (metadata.etag.isEmpty &&
        metadata.lastModified.isNotEmpty &&
        remoteModified.isNotEmpty &&
        metadata.lastModified != remoteModified) {
      throw StateError('The PDF changed while it was being read. Reopen it.');
    }
  }

  Future<void> _cacheForOffline(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    bool remoteEnabled,
  ) async {
    final int blockCount =
        (metadata.fileSize + metadata.blockSize - 1) ~/ metadata.blockSize;
    for (int index = 0; index < blockCount; index++) {
      await _readBlock(metadata, directory, remoteEnabled, index);
    }
    await _saveMetadata(metadata.copyWith(complete: true));
  }

  Future<void> _writeFullResponse(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    List<int> bytes,
  ) async {
    await _ensureBlocksDirectory(directory);
    int blockIndex = 0;
    for (int offset = 0; offset < bytes.length; offset += metadata.blockSize) {
      final int end = math.min(bytes.length, offset + metadata.blockSize);
      await _writeEncryptedBlock(
        metadata,
        directory,
        blockIndex,
        Uint8List.fromList(bytes.sublist(offset, end)),
      );
      blockIndex++;
    }
  }

  Future<void> _writeEncryptedBlock(
    _PurchaseCacheMetadata metadata,
    Directory directory,
    int blockIndex,
    Uint8List bytes,
  ) async {
    final File target = _blockFile(directory, blockIndex);
    if (await target.exists()) return;

    await _ensureBlocksDirectory(directory);
    final SecretBox secretBox = await _cipher.encrypt(
      bytes,
      secretKey: await _readSecretKey(),
      aad: _aad(metadata, blockIndex, bytes.length),
    );
    final Uint8List encrypted = Uint8List.fromList(<int>[
      _encryptedBlockVersion,
      ...secretBox.concatenation(),
    ]);
    final File temporary = File(
      '${target.path}.${DateTime.now().microsecondsSinceEpoch}.part',
    );
    await temporary.writeAsBytes(encrypted, flush: true);
    if (await target.exists()) {
      await temporary.delete();
      return;
    }
    await temporary.rename(target.path);
  }

  Future<Uint8List> _decryptBlock(
    _PurchaseCacheMetadata metadata,
    int blockIndex,
    File file,
  ) async {
    final Uint8List encrypted = await file.readAsBytes();
    if (encrypted.isEmpty || encrypted.first != _encryptedBlockVersion) {
      throw const FormatException('Unsupported encrypted PDF block.');
    }
    final Uint8List concatenated = Uint8List.sublistView(encrypted, 1);
    final SecretBox secretBox = SecretBox.fromConcatenation(
      concatenated,
      nonceLength: _cipher.nonceLength,
      macLength: _cipher.macAlgorithm.macLength,
      copy: false,
    );
    final int clearLength = secretBox.cipherText.length;
    final List<int> clear = await _cipher.decrypt(
      secretBox,
      secretKey: await _readSecretKey(),
      aad: _aad(metadata, blockIndex, clearLength),
    );
    return Uint8List.fromList(clear);
  }

  List<int> _aad(
    _PurchaseCacheMetadata metadata,
    int blockIndex,
    int clearLength,
  ) {
    return utf8.encode(
      '${metadata.purchaseId}|${metadata.validator}|'
      '$blockIndex|$clearLength',
    );
  }

  Future<SecretKey> _readSecretKey() {
    return _secretKey ??= _keyStore.readOrCreateKey();
  }

  Future<Directory> _purchaseDirectory(String purchaseId) async {
    final Directory support = await _supportDirectoryProvider();
    final String safeId = base64UrlEncode(
      utf8.encode(purchaseId),
    ).replaceAll('=', '');
    return Directory(
      '${support.path}${Platform.pathSeparator}quraaa'
      '${Platform.pathSeparator}secure-purchases'
      '${Platform.pathSeparator}$safeId',
    );
  }

  Directory _blocksDirectory(Directory purchaseDirectory) =>
      Directory('${purchaseDirectory.path}${Platform.pathSeparator}blocks');

  File _blockFile(Directory purchaseDirectory, int index) {
    final String name = index.toString().padLeft(8, '0');
    return File(
      '${_blocksDirectory(purchaseDirectory).path}'
      '${Platform.pathSeparator}$name.qpc',
    );
  }

  Future<void> _ensureBlocksDirectory(Directory directory) =>
      _blocksDirectory(directory).create(recursive: true);

  Future<void> _resetDirectory(Directory directory) async {
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    await _ensureBlocksDirectory(directory);
  }

  Future<bool> _hasAllBlocks(
    Directory directory,
    _PurchaseCacheMetadata metadata,
  ) async {
    if (!metadata.complete) return false;
    final int blockCount =
        (metadata.fileSize + metadata.blockSize - 1) ~/ metadata.blockSize;
    for (int index = 0; index < blockCount; index++) {
      if (!await _blockFile(directory, index).exists()) return false;
    }
    return true;
  }

  String _metadataKey(String purchaseId) =>
      'secure_purchase_pdf.metadata.v1.$purchaseId';

  _PurchaseCacheMetadata? _loadMetadata(String purchaseId) {
    final String? encoded = _storage.getString(_metadataKey(purchaseId));
    if (encoded == null || encoded.isEmpty) return null;
    try {
      return _PurchaseCacheMetadata.fromJson(
        Map<String, dynamic>.from(jsonDecode(encoded) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveMetadata(_PurchaseCacheMetadata metadata) async {
    await _storage.setString(
      _metadataKey(metadata.purchaseId),
      jsonEncode(metadata),
    );
  }
}

class _SecurePurchaseBookSession implements PurchaseBookSession {
  const _SecurePurchaseBookSession({
    required SecurePurchaseBookDataSource source,
    required _PurchaseCacheMetadata metadata,
    required Directory directory,
    required bool remoteEnabled,
    required this.isOffline,
  })  : _source = source,
        _metadata = metadata,
        _directory = directory,
        _remoteEnabled = remoteEnabled;

  final SecurePurchaseBookDataSource _source;
  final _PurchaseCacheMetadata _metadata;
  final Directory _directory;
  final bool _remoteEnabled;

  @override
  final bool isOffline;

  @override
  int get fileSize => _metadata.fileSize;

  @override
  String get sourceName =>
      'purchase:${_metadata.purchaseId}:${_metadata.validator}';

  @override
  Future<int> read(Uint8List buffer, int position, int size) {
    return _source._read(
      _metadata,
      _directory,
      _remoteEnabled,
      buffer,
      position,
      size,
    );
  }

  @override
  Future<void> cacheForOffline() {
    return _source._cacheForOffline(_metadata, _directory, _remoteEnabled);
  }

  @override
  Future<void> dispose() async {
    // No clear-text file handle is kept open. Encrypted caching may continue.
  }
}

class _PurchaseCacheMetadata {
  const _PurchaseCacheMetadata({
    required this.schemaVersion,
    required this.purchaseId,
    required this.etag,
    required this.lastModified,
    required this.fileSize,
    required this.blockSize,
    required this.complete,
  });

  factory _PurchaseCacheMetadata.fromJson(Map<String, dynamic> json) {
    return _PurchaseCacheMetadata(
      schemaVersion: json['schemaVersion'] as int? ?? 0,
      purchaseId: json['purchaseId'] as String? ?? '',
      etag: json['etag'] as String? ?? '',
      lastModified: json['lastModified'] as String? ?? '',
      fileSize: json['fileSize'] as int? ?? 0,
      blockSize: json['blockSize'] as int? ?? 0,
      complete: json['complete'] as bool? ?? false,
    );
  }

  final int schemaVersion;
  final String purchaseId;
  final String etag;
  final String lastModified;
  final int fileSize;
  final int blockSize;
  final bool complete;

  String get validator => etag.isNotEmpty ? etag : lastModified;

  _PurchaseCacheMetadata copyWith({int? fileSize, bool? complete}) {
    return _PurchaseCacheMetadata(
      schemaVersion: schemaVersion,
      purchaseId: purchaseId,
      etag: etag,
      lastModified: lastModified,
      fileSize: fileSize ?? this.fileSize,
      blockSize: blockSize,
      complete: complete ?? this.complete,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
        'schemaVersion': schemaVersion,
        'purchaseId': purchaseId,
        'etag': etag,
        'lastModified': lastModified,
        'fileSize': fileSize,
        'blockSize': blockSize,
        'complete': complete,
      };
}
