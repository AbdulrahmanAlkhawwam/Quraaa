import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/architecture/result.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../shared/shared.dart';
import '../../../purchases/purchases.dart';
import '../../domain/repositories/book_assistant_repository.dart';

class AiTextToolsScreen extends StatefulWidget {
  const AiTextToolsScreen({super.key});

  @override
  State<AiTextToolsScreen> createState() => _AiTextToolsScreenState();
}

class _AiTextToolsScreenState extends State<AiTextToolsScreen> {
  final TextEditingController _text = TextEditingController();
  final TextEditingController _page = TextEditingController(text: '1');
  late final Future<Result<List<PurchasedBook>>> _books =
      sl<PurchasesRepository>().getLibrary();
  PurchasedBook? _selected;
  bool _loading = false;
  String? _answer;
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appBackground,
      appBar: AppBar(
        backgroundColor: context.appBackground,
        title: Text('ai_tools.title'.tr()),
      ),
      body: FutureBuilder<Result<List<PurchasedBook>>>(
        future: _books,
        builder: (BuildContext context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final List<PurchasedBook> books = snapshot.data!.fold(
            (_) => const <PurchasedBook>[],
            (value) => value,
          );
          if (books.isEmpty) return Center(child: Text('purchases.empty'.tr()));
          _selected ??= books.first;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: <Widget>[
              DropdownButtonFormField<PurchasedBook>(
                initialValue: _selected,
                decoration: InputDecoration(labelText: 'ai_tools.book'.tr()),
                items: books
                    .map(
                      (PurchasedBook book) => DropdownMenuItem(
                        value: book,
                        child:
                            Text(book.title, overflow: TextOverflow.ellipsis),
                      ),
                    )
                    .toList(growable: false),
                onChanged: (value) => setState(() => _selected = value),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _text,
                minLines: 4,
                maxLines: 8,
                decoration: InputDecoration(
                  labelText: 'ai_tools.selected_text'.tr(),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _page,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'ai_tools.page'.tr()),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _explain,
                      icon: const Icon(Icons.psychology_outlined),
                      label: Text('ai_tools.explain'.tr()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _translate,
                      icon: const Icon(Icons.translate),
                      label: Text('ai_tools.translate'.tr()),
                    ),
                  ),
                ],
              ),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              if (_answer != null)
                Container(
                  margin: const EdgeInsets.only(top: 18),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: context.appSubtleSurface,
                    borderRadius: BorderRadius.circular(AppRadius.radius16),
                  ),
                  child: SelectableText(_answer!),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _explain() => _request(
        sl<BookAssistantRepository>().explain(
          purchaseId: _selected!.purchaseId,
          selectedText: _text.text.trim(),
        ),
      );

  Future<void> _translate() => _request(
        sl<BookAssistantRepository>().translate(
          purchaseId: _selected!.purchaseId,
          pageNumber: int.tryParse(_page.text) ?? 1,
          targetLanguage:
              context.locale.languageCode == 'ar' ? 'Arabic' : 'English',
        ),
      );

  Future<void> _request(Future<Result<String>> request) async {
    setState(() {
      _loading = true;
      _answer = null;
      _error = null;
    });
    final Result<String> result = await request;
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loading = false;
        _error = failure.message;
      }),
      (answer) => setState(() {
        _loading = false;
        _answer = answer;
      }),
    );
  }
}
