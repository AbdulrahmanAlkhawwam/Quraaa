import '../../../../core/architecture/use_case.dart';
import '../entities/pdf_text_layer.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class GetPdfTextLayerParams {
  const GetPdfTextLayerParams({
    required this.path,
    required this.pageIndex,
  });

  final String path;
  final int pageIndex;
}

class GetPdfTextLayerUseCase
    extends UseCase<PdfReaderResult<PdfPageTextLayer>, GetPdfTextLayerParams> {
  const GetPdfTextLayerUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<PdfPageTextLayer>> call(
    GetPdfTextLayerParams params,
  ) {
    return _repository.textLayer(
      path: params.path,
      pageIndex: params.pageIndex,
    );
  }
}
