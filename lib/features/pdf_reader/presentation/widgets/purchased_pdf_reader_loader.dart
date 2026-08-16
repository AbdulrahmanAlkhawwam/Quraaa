import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/extensions/app_context.dart';
import '../../../purchases/purchases.dart';
import '../pages/pdf_reader_page.dart';

/// Prepares a purchased book for the existing path-based PDF reader.
///
/// The visual reader stays unchanged. Only this route-level bridge owns the
/// short-lived clear-text file and removes it when the reader is closed.
class PurchasedPdfReaderLoader extends StatefulWidget {
  const PurchasedPdfReaderLoader({
    required this.purchaseId,
    required this.name,
    super.key,
  });

  final String purchaseId;
  final String name;

  @override
  State<PurchasedPdfReaderLoader> createState() =>
      _PurchasedPdfReaderLoaderState();
}

class _PurchasedPdfReaderLoaderState extends State<PurchasedPdfReaderLoader> {
  late Future<Result<PreparedPurchaseBook>> _preparation;
  PreparedPurchaseBook? _preparedBook;

  @override
  void initState() {
    super.initState();
    _preparation = _prepare();
  }

  Future<Result<PreparedPurchaseBook>> _prepare() async {
    final Result<PreparedPurchaseBook> result = await sl<PurchasesRepository>()
        .prepareForReading(widget.purchaseId);
    await result.fold((_) async {}, (PreparedPurchaseBook preparedBook) async {
      if (!mounted) {
        await preparedBook.dispose();
        return;
      }
      _preparedBook = preparedBook;
    });
    return result;
  }

  void _retry() {
    setState(() => _preparation = _prepare());
  }

  @override
  void dispose() {
    final PreparedPurchaseBook? preparedBook = _preparedBook;
    if (preparedBook != null) {
      unawaited(preparedBook.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<PreparedPurchaseBook>>(
      future: _preparation,
      builder: (BuildContext context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _StatusScaffold(
            name: widget.name,
            message: 'purchases.opening'.tr(),
            loading: true,
          );
        }

        final Result<PreparedPurchaseBook>? result = snapshot.data;
        if (result == null) {
          return _StatusScaffold(
            name: widget.name,
            message: 'errors.unknown.message'.tr(),
            onRetry: _retry,
          );
        }

        return result.fold(
          (failure) => _StatusScaffold(
            name: widget.name,
            message: failure.message,
            onRetry: _retry,
          ),
          (PreparedPurchaseBook preparedBook) => PdfReaderPage(
            path: preparedBook.path,
            name: widget.name,
            purchaseId: widget.purchaseId,
          ),
        );
      },
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  const _StatusScaffold({
    required this.name,
    required this.message,
    this.loading = false,
    this.onRetry,
  });

  final String name;
  final String message;
  final bool loading;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appCard,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: context.pop,
          icon: Icon(context.isRTL ? Icons.arrow_forward : Icons.arrow_back),
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (loading) const CircularProgressIndicator(),
              if (loading) const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              if (onRetry != null) const SizedBox(height: 16),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text('common.retry'.tr()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
