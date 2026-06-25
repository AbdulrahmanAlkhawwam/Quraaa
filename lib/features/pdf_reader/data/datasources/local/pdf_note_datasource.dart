import '../../../domain/entities/pdf_text_note.dart';

abstract class PdfNoteDataSource {
  Future<List<PdfTextNote>> loadNotes(String path);

  Future<PdfTextNote> saveNote(PdfTextNote note);

  Future<bool> deleteNote(PdfTextNote note);
}

class InMemoryPdfNoteDataSource implements PdfNoteDataSource {
  final Map<String, List<PdfTextNote>> _notesByPath =
      <String, List<PdfTextNote>>{};

  @override
  Future<List<PdfTextNote>> loadNotes(String path) async {
    return List<PdfTextNote>.unmodifiable(
      _notesByPath[path] ?? const <PdfTextNote>[],
    );
  }

  @override
  Future<PdfTextNote> saveNote(PdfTextNote note) async {
    final List<PdfTextNote> notes = List<PdfTextNote>.of(
      _notesByPath[note.path] ?? const <PdfTextNote>[],
    );

    notes.add(note);
    _notesByPath[note.path] = notes;
    return note;
  }

  @override
  Future<bool> deleteNote(PdfTextNote note) async {
    final List<PdfTextNote> notes = List<PdfTextNote>.of(
      _notesByPath[note.path] ?? const <PdfTextNote>[],
    );
    final int initialLength = notes.length;

    notes.removeWhere((PdfTextNote storedNote) => storedNote.id == note.id);
    if (notes.isEmpty) {
      _notesByPath.remove(note.path);
    } else {
      _notesByPath[note.path] = notes;
    }

    return notes.length != initialLength;
  }
}
