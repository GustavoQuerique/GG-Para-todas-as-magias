import 'package:hive/hive.dart';

part 'spell_model.g.dart';

@HiveType(typeId: 0)
class SpellModel extends HiveObject {
  @HiveField(0)
  final String index;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String school;

  @HiveField(3)
  final int level;

  @HiveField(4)
  final int? range;

  @HiveField(5)
  final bool concentration;

  @HiveField(6)
  final int? duration;

  @HiveField(7)
  final List<String> description;

  SpellModel({
    required this.index,
    required this.name,
    required this.school,
    required this.level,
    this.range,
    required this.concentration,
    this.duration,
    this.description = const <String>[],
  });

  factory SpellModel.fromJson(Map<String, dynamic> json) {
    return SpellModel(
      index: json['index'] as String,
      name: json['name'] as String,
      school: json['school'] is Map
          ? json['school']['name']
                as String // padrão da D&D API
          : json['school'] as String, // padrão do custom
      level: json['level'] as int,
      range: json['range'] as int?,
      concentration: json['concentration'] as bool,
      duration: json['duration'] as int?,
      description: json['desc'] as List<String>,
    );
  }
}
