import 'package:hive/hive.dart';

part 'diary_model.g.dart';

@HiveType(typeId: 6)
class DiaryModel extends HiveObject {
  @HiveField(0)
  String title; // Nome do diário

  @HiveField(1)
  List<DiaryEntry> entries; // Lista de textos dentro deste diário

  @HiveField(2)
  DateTime lastUpdate;

  DiaryModel({
    required this.title,
    required this.entries,
    required this.lastUpdate,
  });

  factory DiaryModel.empty(String title) => DiaryModel(
    title: title,
    entries: [],
    lastUpdate: DateTime.now(),
  );
}

@HiveType(typeId: 7)
class DiaryEntry {
  @HiveField(0)
  String text;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  int? session;

  DiaryEntry({required this.text, required this.date, this.session});
}
