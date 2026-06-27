import '../../../../core/architecture/use_case.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class SharePdfTextParams {
  const SharePdfTextParams({required this.text});

  final String text;
}

class SharePdfTextUseCase
    extends UseCase<PdfReaderResult<bool>, SharePdfTextParams> {
  const SharePdfTextUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<bool>> call(SharePdfTextParams params) {
    return _repository.shareText(params.text);
  }
}
