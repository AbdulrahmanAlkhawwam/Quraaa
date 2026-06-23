import '../../../../core/architecture/use_case.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class GetPdfPageCountParams {
  const GetPdfPageCountParams({required this.path});

  final String path;
}

class GetPdfPageCountUseCase
    extends UseCase<PdfReaderResult<int>, GetPdfPageCountParams> {
  const GetPdfPageCountUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<int>> call(GetPdfPageCountParams params) {
    return _repository.pageCount(params.path);
  }
}
