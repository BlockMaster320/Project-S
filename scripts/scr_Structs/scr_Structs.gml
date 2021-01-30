///Struct representing an item slot in the inventory && stations.

function Slot(_id, _itemCount) constructor
{
	id = _id;
	sprite = id_get_item(_id).spriteItem;
	itemCount = _itemCount;
}

/// Struct representing a block in the worldGrid.

function Block(_id) constructor
{
	id = _id;
	sprite = id_get_item(_id).spriteBlock;
}

/// Struct representing a player object && its inventory grids.

function PlayerObject(_x, _y, _horizontalSpeed, _verticalSpeed, _selectedPosition, _inventoryGrid, _armorGrid, _toolGrid) constructor
{
	x = _x;
	y = _y;
	horizontalSpeed = _horizontalSpeed;
	verticalSpeed = _verticalSpeed;
	
	selectedPosition = _selectedPosition;
	inventoryArray = slot_grid_to_array(_inventoryGrid);	//convert player's inventory grids to arrays
	armorArray = slot_grid_to_array(_armorGrid);
	toolArray = slot_grid_to_array(_toolGrid);
}

/// Struct representing an item object.

function ItemObject(_x, _y, _horizontalSpeed, _verticalSpeed, _itemSlot) constructor
{
	x = _x;
	y = _y;
	horizontalSpeed = _horizontalSpeed;
	verticalSpeed = _verticalSpeed;
	itemId = _itemSlot.id;
	itemCount = _itemSlot.itemCount
}