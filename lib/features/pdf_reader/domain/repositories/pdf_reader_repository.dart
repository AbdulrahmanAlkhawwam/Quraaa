import 'dart:typed_data';

import '../entities/pdf_text_layer.dart';
import '../entities/pdf_text_note.dart';
import '../value_objects/pdf_reader_result.dart';

abstract class PdfReaderRepository {
  Future<PdfReaderResult<int>> pageCount(String path);

  Future<PdfReaderResult<Uint8List>> renderPage({
    required String path,
    required int pageIndex,
    required int width,
  });

  Future<PdfReaderResult<PdfPageTextLayer>> textLayer({
    required String path,
    required int pageIndex,
  });

  Future<PdfReaderResult<bool>> shareText(String text);

  Future<PdfReaderResult<List<PdfTextNote>>> loadNotes(String path);

  Future<PdfReaderResult<PdfTextNote>> saveNote(PdfTextNote note);

  Future<PdfReaderResult<bool>> deleteNote(PdfTextNote note);
}
