import 'dart:convert';

import 'package:memogenerator/data/models/meme.dart';
import 'package:memogenerator/data/shared_preferences_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class MemesRepository {
  final updater = PublishSubject<Null>();
  final SharedPreferencesData spData;

  static MemesRepository? _instance;

  factory MemesRepository.getInstance() => _instance ??=
      MemesRepository._internal(SharedPreferencesData.getInstance());

  MemesRepository._internal(this.spData);

  Future<bool> addToMemes(final Meme meme) async {
    final rawMemes = await spData.getMemes();
    rawMemes.add(json.encode(meme.toJson()));
    return await _setRawMemes(rawMemes);
  }

  Future<bool> removeFromMemes(final String id) async {
    final memes = await getMemes();
    memes.removeWhere((meme) => meme.id == id);
    return _setMemes(memes);
  }

  Future<Meme?> getMeme(final String id) async {
    final memes = await getMemes();
    return memes.firstWhereOrNull((meme) => meme.id == id);
  }

  Future<List<Meme>> getMemes() async {
    final rawMemes = await spData.getMemes();
    return rawMemes
        .map((rawMeme) => Meme.fromJson(json.decode(rawMeme)))
        .toList();
  }

  Stream<List<Meme>> observeMemes() async* {
    yield await getMemes();
    await for (final _ in updater) {
      yield await getMemes();
    }
  }

  Future<bool> _setRawMemes(final List<String> memes) async {
    updater.add(null);
    return spData.setMemes(memes);
  }

  Future<bool> _setMemes(final List<Meme> memes) async {
    final rawMemes = memes.map((meme) => json.encode(meme.toJson())).toList();
    return _setRawMemes(rawMemes);
  }
}