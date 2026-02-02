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

  SpellModel({
    required this.index,
    required this.name,
    required this.school,
    required this.level,
  });
}
