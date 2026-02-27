import 'package:guia_de_garlou_para_todas_as_magias/models/inventory/inventory_item.dart';

///Separa o item do peso, nome, tamanho e rotação
class InventoryItemInstance {
  final InventoryItem baseItem;

  int width;
  int height;
  bool isRotated;

  int posX;
  int posY;

  InventoryItemInstance({
    required this.baseItem,
    required this.width,
    required this.height,
    this.isRotated = false,
    this.posX = -1,
    this.posY = -1,
  });

  int get effectiveWidth => isRotated ? height : width;
  int get effectiveHeight => isRotated ? width : height;

  Map<String, dynamic> toJson() {
    return {
      'name': baseItem.name,
      'weight': baseItem.weight,
      'quantity': baseItem.quantity,
      'width': width,
      'height': height,
      'row': posX,
      'col': posY,
    };
  }

  factory InventoryItemInstance.fromJson(Map<String, dynamic> json) {
    return InventoryItemInstance(
        baseItem: InventoryItem(
          name: json['name'],
          weight: (json['weight'] as num).toDouble(),
          quantity: json['quantity'],
        ),
        width: json['width'],
        height: json['height'],
      )
      ..posX = json['row']
      ..posY = json['col'];
  }
}
