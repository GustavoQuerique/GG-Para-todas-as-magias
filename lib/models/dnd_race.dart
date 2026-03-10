import 'package:hive/hive.dart';

part 'dnd_race.g.dart';

@HiveType(typeId: 5)
class DndRace {
  @HiveField(0)
  final String index;

  @HiveField(1)
  final String name;

  DndRace({required this.index, required this.name});

  factory DndRace.fromJson(Map<String, dynamic> json) {
    return DndRace(index: json['index'], name: json['name']);
  }
}
