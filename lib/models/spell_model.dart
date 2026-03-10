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
  final String? range;

  @HiveField(5)
  final bool concentration;

  @HiveField(6)
  final String? duration;

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
      index: json['index'] ?? '',
      name: json['name'] ?? '',
      school: json['school'] is Map
          ? json['school']['name'] ?? ''
          : json['school'] ?? '',
      level: json['level'] ?? 0,
      range: json['range']?.toString(),
      concentration: json['concentration'] ?? false,
      duration: json['duration']?.toString(),
      description:
          (json['desc'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [],
    );
  }

  factory SpellModel.fromMap(Map<String, dynamic> map) {
    return SpellModel(
      index: map['index'],
      name: map['name'],
      school: map['school'],
      level: map['level'],
      description: map['description'],
      concentration: false,
    );
  }
}
