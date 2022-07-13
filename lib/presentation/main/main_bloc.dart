import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:memogenerator/data/repositories/memes_repository.dart';
import 'package:memogenerator/presentation/main/memes_with_docs_path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';

import '../../data/models/meme.dart';

class MainBloc {
  Stream<MemesWithDocsPath> observeMemesWithDocsPath() {
    return Rx.combineLatest2<List<Meme>, Directory, MemesWithDocsPath>(
      MemesRepository.getInstance().observeMemes(),
      getApplicationDocumentsDirectory().asStream(),
      (memes, docsDirectory) => MemesWithDocsPath(memes, docsDirectory.path),
    );
  }

  Future<String?> selectMeme() async {
    final xFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    return xFile?.path;
  }

  void dispose() {}
}
