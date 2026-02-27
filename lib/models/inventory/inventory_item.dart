import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 2)
class InventoryItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double weight;

  @HiveField(2)
  int quantity;

  InventoryItem({
    required this.name,
    required this.weight,
    required this.quantity,
  });

  double get totalWeight => weight * quantity;
}
