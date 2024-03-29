import 'dart:convert';

import 'package:memogenerator/data/models/template.dart';
import 'package:memogenerator/data/repositories/list_with_ids_reactive_repository.dart';
import 'package:memogenerator/data/shared_preference_data.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';

class TemplatesRepository extends ListWithIdsReactiveRepository<Template> {
  final updater = PublishSubject<Null>();
  final SharedPreferenceData spData;

  static TemplatesRepository? _instance;

  factory TemplatesRepository.getInstance() => _instance ??=
      TemplatesRepository._internal(SharedPreferenceData.getInstance());

  TemplatesRepository._internal(this.spData);

  @override
  Template convertFromString(String rawItem) =>
      Template.fromJson(json.decode(rawItem));

  @override
  String convertToString(Template item) => json.encode(item.toJson());

  @override
  dynamic getId(Template item) => item.id;

  @override
  Future<List<String>> getRawData() => spData.getTemplates();

  @override
  Future<bool> saveRawData(List<String> items) => spData.setTemplates(items);
}
