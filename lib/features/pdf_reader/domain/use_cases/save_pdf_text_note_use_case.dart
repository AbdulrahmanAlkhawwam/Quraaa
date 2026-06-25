import '../../../../core/architecture/use_case.dart';
import '../entities/pdf_text_note.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class SavePdfTextNoteParams {
  const SavePdfTextNoteParams({required this.note});

  final PdfTextNote note;
}

class SavePdfTextNoteUseCase
    extends UseCase<PdfReaderResult<PdfTextNote>, SavePdfTextNoteParams> {
  const SavePdfTextNoteUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<PdfTextNote>> call(SavePdfTextNoteParams params) {
    return _repository.saveNote(params.note);
  }
}
