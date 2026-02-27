///Opção de mochilas e seus grids

enum InventoryType {
  smallBackpack,
  mediumBackpack,
  largeBackpack,
  bagOfHolding,
}

class InventoryContainer {
  final InventoryType type;

  int columns;
  int rows;

  InventoryContainer({
    required this.type,
    required this.columns,
    required this.rows,
  });

  factory InventoryContainer.create(InventoryType type) {
    switch (type) {
      case InventoryType.smallBackpack:
        return InventoryContainer(type: type, columns: 5, rows: 5);

      case InventoryType.mediumBackpack:
        return InventoryContainer(type: type, columns: 7, rows: 6);

      case InventoryType.largeBackpack:
        return InventoryContainer(type: type, columns: 10, rows: 8);

      case InventoryType.bagOfHolding:
        return InventoryContainer(type: type, columns: 15, rows: 15);
    }
  }

  void expandForBagOfHolding() {
    if (type == InventoryType.bagOfHolding) {
      rows += 5;
    }
  }
}
