//Get Player's Input
scr_Input();

//Get Player's Center Position
var _playerX = 0;
var _playerY = 0;
if (instance_exists(obj_Player))
{
	_playerX = obj_Player.x + obj_Player.sprite_width * 0.5;
	_playerY = obj_Player.y + obj_Player.sprite_height * 0.5;
}

//ITEM INTERACTION//
//Item Collection
for (var _i = 0; _i < instance_number(obj_Item); _i ++)	//loop throught all the items
{
	//Get the Item && Its Center Position
	var _item = instance_find(obj_Item, _i);
	var _itemX = _item.x + _item.sprite_width * 0.5;
	var _itemY = _item.y + _item.sprite_height * 0.5;
	
	//Start Item Collection
	if (point_distance(_playerX, _playerY, _itemX, _itemY) < approachRange)
	{
		//Get the Item's Slot
		var _itemSlot = _item.itemSlot;
		var _remainder = item_collect_remainder(inventoryGrid, _itemSlot);
		
		//Start Collecting the Item
		if (ds_list_find_index(fullSlotsIdList, _itemSlot.id) == - 1 && _item.collectCooldown <= 0)	//check if there's space for the item in the inventory
		{
			if (_remainder == 0) _item.collectItem = true;	//collect the whole item
			
			else if (_remainder < _itemSlot.itemCount)	//divide the item into 2 items (if there's not enough space for all the items)
			{
				var _newItem = instance_create_layer(_item.x, _item.y, "Items", obj_Item);	//create the part that's not going to be collected
				_newItem.itemSlot = new Slot(_itemSlot.id, _remainder);
			
				_itemSlot.itemCount -= _remainder;
				_item.collectItem = true;
				ds_list_add(fullSlotsIdList, _itemSlot.id);
			}
		}
	}
	//show_debug_message("fullSlotsIdList: " + string(fullSlotsIdList));
		
	//Attract && Collect the Item
	if (_item.collectItem)
	{
		//Move the Item Towards the Player
		if (_item.approachSpeed < maxApproachSpeed)
			_item.approachSpeed += approachAccel;
		var _direction = point_direction(_itemX, _itemY, _playerX, _playerY);
		_item.x += lengthdir_x(_item.approachSpeed, _direction);
		_item.y += lengthdir_y(_item.approachSpeed, _direction);
		
		//Collect the Item
		if (point_distance(_playerX, _playerY, _itemX, _itemY) < collectRange)
		{
			var _idPosition = ds_list_find_index(fullSlotsIdList, _itemSlot.id);	//delete the item ID from the fullSlotsIdList
			if (_idPosition != - 1)
				ds_list_delete(fullSlotsIdList, _idPosition);
				
			item_collect(inventoryGrid, _itemSlot);	//add item to the inventory
			instance_destroy(_item);
		}
	}
}

//Item Dropping
var _selectedSlot = selectedSlot;
if (keyItemDrop && _selectedSlot != 0)
{
	var _itemDropX = _playerX - sprite_get_width(spr_ItemMask) * 0.5;	//create the dropped item
	var _itemDropY = _playerY - sprite_get_height(spr_ItemMask) * 0.5;
	var _droppedItem = instance_create_layer(_itemDropX, _itemDropY, "Items", obj_Item);
	
	_droppedItem.itemSlot = new Slot(_selectedSlot.id, _selectedSlot.itemCount);	//add properties to the dropped item
	_droppedItem.collectCooldown = 60;
	_droppedItem.stackCooldown = 10;
	
	position_slot_set(inventoryGrid, selectedPosition, 0);
}

//BLOCK INTERACTION//
//Get Block's World Grid Position
var _blockGridX = mouse_x div CELL_SIZE;
var _blockGridY = mouse_y div CELL_SIZE;
var _selectedBlock = obj_WorldManager.worldGrid[# _blockGridX, _blockGridY];

//Get Block's Center Position
var _blockX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5;		
var _blockY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5;
inRange = (point_distance(_playerX, _playerY, _blockX, _blockY) <= interactionRange);

//Block Mining
if (buttonLeft && inRange && _selectedBlock != 0)
{
	mineProgress += (selectedSlot == 0) ? 1 : id_get_item(selectedSlot.id).mineForce;	//increase mine progress
	mineBlockEndurance = id_get_item(_selectedBlock.id).endurance;	//get the block's endurance
	if (mineProgress >= id_get_item(_selectedBlock.id).endurance)	//mine the block
	{
		obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = 0;	//delete the block from the world grid
		mineProgress = 0;
		
		var _itemDropX = _blockX - sprite_get_width(spr_ItemMask) * 0.5;
		var _itemDropY = _blockY - sprite_get_height(spr_ItemMask) * 0.5;
		var _droppedItem = instance_create_layer(_itemDropX, _itemDropY, "Items", obj_Item);	//drop the block's item
		_droppedItem.itemSlot = new Slot(_selectedBlock.id, 1);
		_droppedItem.stackCooldown = 10;
	}
}

//Reset Mine Progress
if (buttonLeftReleased || (_blockGridX != previousBlockGridX || _blockGridY != previousBlockGridY))
	mineProgress = 0;

//Block Placing
if (buttonRightPressed && inRange && selectedSlot != 0 && _selectedBlock == 0)
{
	var _isOverlappingPlayer = check_block_collision(obj_Player, selectedSlot.id, _blockGridX, _blockGridY);
	if (!_isOverlappingPlayer)
	{
		obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = new Block(selectedSlot.id);
		selectedSlot.itemCount -= 1;
		if (selectedSlot.itemCount <= 0)
			position_slot_set(inventoryGrid, selectedPosition, 0);
	}
}

//Update Previous Block Grid Position
previousBlockGridX = _blockGridX;
previousBlockGridY = _blockGridY;


/*
show_debug_message("\nblockGridX: " + string(_blockGridX));
show_debug_message("blockGridY: " + string(_blockGridY));*/
//show_debug_message("selectedBlock: " + string(_selectedBlock));
