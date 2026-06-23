import 'dart:typed_data';

import '../../../../core/architecture/use_case.dart';
import '../repositories/pdf_reader_repository.dart';
import '../value_objects/pdf_reader_result.dart';

class RenderPdfPageParams {
  const RenderPdfPageParams({
    required this.path,
    required this.pageIndex,
    required this.width,
  });

  final String path;
  final int pageIndex;
  final int width;
}

class RenderPdfPageUseCase
    extends UseCase<PdfReaderResult<Uint8List>, RenderPdfPageParams> {
  const RenderPdfPageUseCase(this._repository);

  final PdfReaderRepository _repository;

  @override
  Future<PdfReaderResult<Uint8List>> call(RenderPdfPageParams params) {
    return _repository.renderPage(
      path: params.path,
      pageIndex: params.pageIndex,
      width: params.width,
    );
  }
}
