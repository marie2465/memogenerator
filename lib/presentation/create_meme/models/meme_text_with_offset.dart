import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:memogenerator/presentation/create_meme/models/meeme_text.dart';

class MemeTextWithOffset extends Equatable {
  final String id;
  final String text;
  final Offset? offset;

  const MemeTextWithOffset({
    required this.id,
    required this.text,
    required this.offset,
  });

  @override
  List<Object?> get props => [id, text, offset];


}