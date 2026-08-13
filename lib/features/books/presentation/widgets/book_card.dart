import 'package:flutter/material.dart';
import '../../domain/entities/book.dart';

class BookCard extends StatelessWidget {
  const BookCard({required this.book, super.key});
  final Book book;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(8),
    child: SizedBox(height: 200, child: Stack(fit: StackFit.expand, children: <Widget>[
      const ColoredBox(color: Color(0xFF145FA3)),
      Image.asset(book.coverAsset, fit: BoxFit.cover),
      const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: <Color>[Colors.transparent, Color(0x7A000000)]))),
      Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        if (book.format == BookFormat.audio) Align(alignment: AlignmentDirectional.topEnd, child: Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .24), borderRadius: BorderRadius.circular(999)), child: const Text('Sound Book', style: TextStyle(color: Colors.white, fontSize: 8)))),
        const Spacer(), Text(book.title, style: const TextStyle(color: Colors.white, fontSize: 14)), Text(book.subtitle, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w300)), const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[Text(book.price, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .24), borderRadius: BorderRadius.circular(4)), child: const Text('view', style: TextStyle(color: Colors.white, fontSize: 8)))])
      ]))
    ])),
  );
}
