import 'package:flutter/material.dart';

/// A lightweight model for a book shown on the home screen.
/// This is local/mock data only; no server side is used.
class HomeBook {
  const HomeBook({
    required this.id,
    required this.title,
    this.subtitle,
    required this.size,
    this.coverAsset,
    this.coverColors,
  });

  final String id;
  final String title;
  final String? subtitle;
  final String size;
  final String? coverAsset;
  final List<Color>? coverColors;
}
