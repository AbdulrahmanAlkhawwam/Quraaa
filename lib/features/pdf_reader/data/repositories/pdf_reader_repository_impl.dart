import 'dart:typed_data';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/pdf_text_layer.dart';
import '../../domain/entities/pdf_text_note.dart';
import '../../domain/repositories/pdf_reader_repository.dart';
import '../../domain/value_objects/pdf_reader_result.dart';
import '../datasources/local/pdf_note_datasource.dart';
import '../datasources/local/pdf_render_datasource.dart';

class PdfReaderRepositoryImpl implements PdfReaderRepository {
  const PdfReaderRepositoryImpl({
    required PdfRenderDataSource renderDataSource,
    required PdfNoteDataSource noteDataSource,
  })  : _renderDataSource = renderDataSource,
        _noteDataSource = noteDataSource;

  final PdfRenderDataSource _renderDataSource;
  final PdfNoteDataSource _noteDataSource;

  @override
  Future<PdfReaderResult<int>> pageCount(String path) {
    return _guard(() => _renderDataSource.pageCount(path));
  }

  @override
  Future<PdfReaderResult<Uint8List>> renderPage({
    required String path,
    required int pageIndex,
    required int width,
  }) {
    return _guard(
      () => _renderDataSource.renderPage(
        path: path,
        pageIndex: pageIndex,
        width: width,
      ),
    );
  }

  @override
  Future<PdfReaderResult<PdfPageTextLayer>> textLayer({
    required String path,
    required int pageIndex,
  }) {
    return _guard(
      () => _renderDataSource.textLayer(
        path: path,
        pageIndex: pageIndex,
      ),
    );
  }

  @override
  Future<PdfReaderResult<bool>> shareText(String text) async {
    try {
      await _renderDataSource.shareText(text);
      return const PdfReaderSuccess<bool>(true);
    } catch (error) {
      return PdfReaderFailure<bool>(_failureFrom(error));
    }
  }

  @override
  Future<PdfReaderResult<List<PdfTextNote>>> loadNotes(String path) {
    return _guard(() => _noteDataSource.loadNotes(path));
  }

  @override
  Future<PdfReaderResult<PdfTextNote>> saveNote(PdfTextNote note) {
    return _guard(() => _noteDataSource.saveNote(note));
  }

  @override
  Future<PdfReaderResult<bool>> deleteNote(PdfTextNote note) {
    return _guard(() => _noteDataSource.deleteNote(note));
  }

  Future<PdfReaderResult<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return PdfReaderSuccess<T>(await action());
    } catch (error) {
      return PdfReaderFailure<T>(_failureFrom(error));
    }
  }

  Failure _failureFrom(Object error) {
    if (error is UnsupportedError || error is StateError) {
      return OperationFailedFailure(message: error.toString());
    }

    return UnknownFailure(message: error.toString());
  }
}
