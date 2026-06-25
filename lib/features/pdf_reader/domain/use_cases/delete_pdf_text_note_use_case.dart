import '../../../../core/architecture/use_case.dart';
import '../entities/pdf_text_note.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class DeletePdfTextNoteParams {
  const DeletePdfTextNoteParams({required this.note});

  final PdfTextNote note;
}

class DeletePdfTextNoteUseCase
    extends UseCase<PdfReaderResult<bool>, DeletePdfTextNoteParams> {
  const DeletePdfTextNoteUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<bool>> call(DeletePdfTextNoteParams params) {
    return _repository.deleteNote(params.note);
  }
}
