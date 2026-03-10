import 'package:hive/hive.dart';

part 'dnd_class.g.dart';

@HiveType(typeId: 4)
class DndClass extends HiveObject {
  @HiveField(0)
  final String index;

  @HiveField(1)
  final String name;

  DndClass({
    required this.index,
    required this.name,
  });

  factory DndClass.fromJson(Map<String, dynamic> json) {
    return DndClass(
      index: json['index'],
      name: json['name'],
    );
  }
}
