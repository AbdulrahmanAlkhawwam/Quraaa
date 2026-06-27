import '../../../../core/architecture/use_case.dart';
import '../entities/pdf_text_note.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class LoadPdfTextNotesParams {
  const LoadPdfTextNotesParams({required this.path});

  final String path;
}

class LoadPdfTextNotesUseCase
    extends UseCase<PdfReaderResult<List<PdfTextNote>>, LoadPdfTextNotesParams> {
  const LoadPdfTextNotesUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<List<PdfTextNote>>> call(
    LoadPdfTextNotesParams params,
  ) {
    return _repository.loadNotes(params.path);
  }
}
