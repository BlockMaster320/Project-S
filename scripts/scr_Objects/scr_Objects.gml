/// Struct representing a player object && its inventory grids.
function PlayerObject(_x, _y, _horizontalSpeed, _verticalSpeed, _chosenPosition, _inventoryGrid, _armorGrid, _toolGrid) constructor
{
	x = _x;
	y = _y;
	horizontalSpeed = _horizontalSpeed;
	verticalSpeed = _verticalSpeed;
	
	chosenPosition = _chosenPosition;
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
	itemSlot = _itemSlot;
}