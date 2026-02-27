import 'inventory_item_instance.dart';
import 'inventory_container.dart';

class InventoryGrid {
  final InventoryContainer container;

  late List<List<InventoryItemInstance?>> grid;

  InventoryGrid(this.container) {
    _initializeGrid();
  }

  void _initializeGrid() {
    grid = List.generate(
      container.rows,
      (_) => List.generate(container.columns, (_) => null),
    );
  }

  bool canPlaceItem(
    InventoryItemInstance item,
    int startRow,
    int startCol,
  ) {
    final width = item.effectiveWidth;
    final height = item.effectiveHeight;

    if (startCol + width > container.columns) return false;
    if (startRow + height > container.rows) return false;

    for (int r = 0; r < height; r++) {
      for (int c = 0; c < width; c++) {
        if (grid[startRow + r][startCol + c] != null) {
          return false;
        }
      }
    }

    return true;
  }

  bool placeItem(
    InventoryItemInstance item,
    int startRow,
    int startCol,
  ) {
    if (!canPlaceItem(item, startRow, startCol)) {
      if (container.type == InventoryType.bagOfHolding) {
        container.expandForBagOfHolding();
        _initializeGrid();
      } else {
        return false;
      }
    }

    for (int r = 0; r < item.effectiveHeight; r++) {
      for (int c = 0; c < item.effectiveWidth; c++) {
        grid[startRow + r][startCol + c] = item;
      }
    }

    item.posX = startCol;
    item.posY = startRow;

    return true;
  }
}
