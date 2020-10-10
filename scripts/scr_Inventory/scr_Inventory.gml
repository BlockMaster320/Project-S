//INVENTORY MENU//

/// Function for drawing && interacting with Inventory Section
/// variables needed: scale
function inventory_section(_slotSet, _type, _x, _y, _itemSize, _slotSize, _updateCrafting, _takeOnly)
{
	switch(_type)
	{
		case 0:
		{
			//Basic Grid
			for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
			{
				for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
				{
					var _drawX = _x + _c * _slotSize;
					var _drawY = _y + _r * _slotSize;
			
					draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
			
					var _slot = _slotSet[# _c, _r];
					slot_draw(_slot, _drawX, _drawY, _itemSize, scale);	//draw the slot
					slot_interact(_slot, _drawX, _drawY, _slotSet, _c, _r, _itemSize, _slotSize, _updateCrafting, _takeOnly);	//interact with the slot
				}
			}
		}
		break;
		
		case 1:
		{
			//List Drawn as 2-Column Grid
			for (var _i = 0; _i < ds_list_size(_slotSet); _i ++)	//draw the crafting products
			{
				var _drawX = _x + _slotSize * floor(_i * 0.5);
				var _drawY = _y + _slotSize * (_i % 2 == 0);
		
				draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
		
				var _slot = _slotSet[| _i];
				slot_draw(_slot, _drawX, _drawY, _itemSize, scale);
				slot_interact(_slot, _drawX, _drawY, _slotSet, _i, noone, _itemSize, _slotSize, _updateCrafting, _takeOnly);
			}
		}
		break
	}
}

/// Function drawing an inventory slot.
function slot_draw(_slot, _x, _y, _itemSize, _scale)
{						
	draw_sprite_ext(spr_Block, 0, _x, _y, _scale, _scale, 0, c_white, 0.5);
	if (_slot != 0)	//draw the item
	{
		
		draw_sprite_ext(_slot.sprite, 0, _x, _y, _scale, _scale, 0, c_white, 1);
		draw_text_transformed_colour(_x + _itemSize * 1.1, _y + _itemSize * 1.15, _slot.itemCount, _scale * 0.75, _scale * 0.75,
									 0, c_white, c_white, c_white, c_white, 1);
	}
}

/// Function checking for an interaction with inventory slot.
/// variables needed: heldSlot, heldSlotItemCount, splitList, mouseX, mouseY,
/// buttonLeft, buttonLeftPressed, buttonLeftReleased
function slot_interact(_slot, _x, _y, _slotSet, _i, _j, _itemSize, _slotSize, _updateCrafting, _takeOnly)
{
	//Check for Mouse Selection
	var _slotBorder = (_slotSize - _itemSize) * 0.5;
	if (point_in_rectangle(mouseX, mouseY, _x - _slotBorder + 1, _y - _slotBorder + 1,
						   _x + _slotSize - _slotBorder - 1, _y + _slotSize - _slotBorder - 1))
	{
		//Highlight the Slot
		draw_set_alpha(0.5);
		draw_rectangle_colour(_x, _y, _x + _itemSize, _y + _itemSize, 
							  c_white, c_white, c_white, c_white, false);
		draw_set_alpha(1);
		
		//Set Mouse Check Variables
		var _buttonHold = buttonLeft || buttonRight;
		var _buttonPressed = buttonLeftPressed || buttonRightPressed;
		var _buttonReleased = buttonLeftReleased || buttonRightReleased;
		
		var _button = (buttonLeft || buttonLeftPressed || buttonLeftReleased) -	//1 = left; - 1 = right
					  (buttonRight || buttonRightPressed || buttonRightReleased)
		
		//Check for Button Click
		if (_buttonPressed)
		{
			if (heldSlot != 0)	//take an item of the same ID / start splitting the held items
			{
				if (!_takeOnly)	//start item splitting
				{
					heldSlotItemCount = heldSlot.itemCount;
					swapSlots = true;
				}
				
				else	//take the crafting product if the held slot's item has the same ID
				{
					if (_slot.id == heldSlot.id)
					{
						var _craftAmount = id_get_item(_slot.id).craftAmount;	//get the maximum number of items that can be taken
						var _itemsToAdd = ((id_get_item(_slot.id).itemLimit - heldSlot.itemCount) div _craftAmount) * _craftAmount;
						
						if (_button == 1)	//add all the crafting product's items
							_itemsToAdd = min(_itemsToAdd, _slot.itemCount);
						else				//add crafting products's craftAmount of its items
							_itemsToAdd = min(_itemsToAdd, _craftAmount);
						
						_slot.itemCount -= _itemsToAdd;	//transfer the items
						heldSlot.itemCount += _itemsToAdd
						if (_slot.itemCount == 0)
							slot_set(_slotSet, _i, _j, 0);
						
						crafting_update_resources(obj_Inventory.craftingGrid, _slot.id, _itemsToAdd);
					}
					swapSlots = false;
				}
			}
			
			if (heldSlot == 0 && _slot != 0)	//take the item if not holding one already
			{
				if (_button == 1)	//take all the items on left click
				{
					heldSlot = new Slot(_slot.id, _slot.itemCount);
					slot_set(_slotSet, _i, _j, 0);
					swapSlots = false;
					
					if (_takeOnly)
						crafting_update_resources(obj_Inventory.craftingGrid, _slot.id, _slot.itemCount);
				}
				else if (_slot.itemCount != 1)	//right click
				{
					if (!_takeOnly)	//take half of the items
					{
						var _itemPart = round(_slot.itemCount / 2);
						heldSlot = new Slot(_slot.id, _itemPart);
						_slot.itemCount -= _itemPart;
					}
					
					else	//take crafting product's craftAmount of its items
					{
						var _craftAmount = id_get_item(_slot.id).craftAmount;
						heldSlot = new Slot(_slot.id, _craftAmount);
						_slot.itemCount -= _craftAmount;
						if (_slot.itemCount == 0)
							slot_set(_slotSet, _i, _j, 0);
						
						crafting_update_resources(obj_Inventory.craftingGrid, _slot.id, _craftAmount);
					}
				}
			}
			_slot = slot_get(_slotSet, _i, _j);	//update the item data
			
			if (_updateCrafting)
				crafting_update_products(obj_Inventory.craftingGrid);	//update the craftingProducts list
		}
		
		//Check for Button Hold (Item Placing/Splitting)
		if (_buttonHold)
		{
			if (heldSlot != 0 && ds_list_size(splitList) < heldSlotItemCount && !_takeOnly)
			{
				if (_slot == 0)	//set the slot with no item to the held item
				{
					slot_set(_slotSet, _i, _j, new Slot(heldSlot.id, 0));
					_slot = slot_get(_slotSet, _i, _j);
				}
				
				if (_slot.id == heldSlot.id)	//check if the item is already in the split list
				{
					var _isInSplitList = false;
					for (var _k = 0; _k < ds_list_size(splitList); _k ++)
					{
						var _splitSlot = splitList[| _k];
						if (_splitSlot[0] == _slotSet &&
							_splitSlot[1] == _i && _splitSlot[2] == _j)
						{
							var _isInSplitList = true
							break;
						}
					}
			
					if (!_isInSplitList)	//add the item to the split list
					{
						var _splitSlot = [_slotSet, _i, _j, 0];
						ds_list_add(splitList, _splitSlot);
						
						if (_button == 1)	//update the split slots when holding left button
							split_update();
						else if (_slot.itemCount + 1 <= id_get_item(_slot.id).itemLimit)	//add 1 item to the current slot when holding right btton
						{
							_slot.itemCount += 1;
							heldSlot.itemCount -= 1;
						}
						
						crafting_update_products(obj_Inventory.craftingGrid);	//update the craftingProducts list
					}
				}
			}
		}
		
		//Check for Button Release
		if (_buttonReleased)
		{
			if (heldSlot != 0)
			{
				heldSlotItemCount = heldSlot.itemCount;	//stop item splitting
				if (heldSlot.itemCount == 0)
					heldSlot = 0;
				
				else if (_slot != 0 && ds_list_size(splitList) == 0 && _button != - 1 && swapSlots)	//swap the item with the held one
				{
					var _heldSlotTemp = heldSlot;
					heldSlot = new Slot(_slot.id, _slot.itemCount);
					slot_set(_slotSet, _i, _j, _heldSlotTemp);
				}
			}
			ds_list_clear(splitList);
		}
	}
}


//SLOT INTERACTION

/// Function for adding items to an item slot && returning number of items exceeding its itemLimit
function slot_add_items(_slot, _amount)
{
	var _itemLimit = id_get_item(_slot.id).itemLimit;
	var _remainder = clamp((_slot.itemCount + _amount) - _itemLimit, 0, infinity);
	_slot.itemCount += _amount - _remainder;
	return _remainder;
}

/// Function which gets a slot from its grid/list/variable.
function slot_get(_slotSet, _i, _j)
{
	if (_j != noone)	//clear a grid slot
		return _slotSet[# _i, _j];
		
	else if (_i != noone)	//clear a list slot
		return _slotSet[| _i];
		
	else return _slotSet;	//clear a variable slot
}

/// Function which sets a slot in its grid/list/variable to a given value.
function slot_set(_slotSet, _i, _j, _value)
{
	if (_j != noone)	//clear a grid slot
		_slotSet[# _i, _j] = _value;
		
	else if (_i != noone)	//clear a list slot
		_slotSet[| _i] = _value;
		
	else _slotSet = _value;	//clear a variable slot
}

/// Function updating values of items in the split list.
/// variables needed: splitList, heldSlot, heldSlotItemCount
function split_update()
{
	var _splitListSize = ds_list_size(splitList);	//get number of items each split item should get
	var _splitItemCount = floor(heldSlotItemCount / _splitListSize);
	
	var _remainderTotal = 0;
	for (var _i = 0; _i < _splitListSize; _i ++)	//loop trought the split items && add the items
	{
		var _splitSlot = splitList[| _i];
		var _slot = slot_get(_splitSlot[0], _splitSlot[1], _splitSlot[2]);
		
		_slot.itemCount -= _splitSlot[3];
		var _remainder = slot_add_items(_slot, _splitItemCount);
		_splitSlot[3] = _splitItemCount - _remainder;
		_remainderTotal += _remainder;
	}
	heldSlot.itemCount = heldSlotItemCount - _splitItemCount * _splitListSize + _remainderTotal;
}

/// Function returning position of a slot on a given position in a grid.

function position_get_gridPosition(_slotSet, _position)
{
	var _columns = ds_grid_width(_slotSet);	//get number of columns && rows
	var _rows = ds_grid_height(_slotSet);
	
	var _totalSlots = _columns * _rows;	//tile the position to fit into the slotSet
	_position = _position % _totalSlots;
	if (sign(_position) == - 1)
		_position = _totalSlots + _position;
	
	var _slotRow = _position div _columns;	//get slot's column && row
	var _slotColumn = _position % _columns;
	
	return [_slotColumn, _slotRow];
}

/// Function returning a slot on a given position in a grid.

function position_slot_get(_slotSet, _position)
{
	var _gridPosition = position_get_gridPosition(_slotSet, _position)
	return _slotSet[# _gridPosition[0], _gridPosition[1]];
}

/// Function changing value of a slot on a given position in a grid.

function position_slot_set(_slotSet, _position, _value)
{
	var _gridPosition = position_get_gridPosition(_slotSet, _position)
	_slotSet[# _gridPosition[0], _gridPosition[1]] = _value;
}


//ITEM COLLECTION//

/// Function returning how many items will remain after collecting an item.

function item_collect_remainder(_slotSet, _itemSlot)
{
	var _remainder = _itemSlot.itemCount;
	var _itemLimit = id_get_item(_itemSlot.id).itemLimit;
	
	for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
		{
			var _slot = _slotSet[# _c, _r];
			
			if (_slot == 0) return 0;
			else if (_slot.id == _itemSlot.id)
			{
				_remainder -= _itemLimit - _slot.itemCount;
				if (_remainder <= 0) return 0;
			}
		}
	}
	return _remainder;
}

/// Function collecting an item. (Adding an item to the inventory.)

function item_collect(_slotSet, _itemSlot)
{
	for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
		{
			var _slot = _slotSet[# _c, _r];
			
			if (_slot == 0)
			{
				_slotSet[# _c, _r] = new Slot(_itemSlot.id, _itemSlot.itemCount);
				return;
			}
			else if (_slot.id == _itemSlot.id)
			{
				var _remainder = slot_add_items(_slot, _itemSlot.itemCount);
				_itemSlot.itemCount = _remainder;
				if (_remainder == 0) return;
			}
		}
	}
}

//CRAFTING//

//Function checking the slots in the crafting grid && updating the crafting products accordingly.

function crafting_update_products(_craftingGrid)
{
	//Create a Map of Resources (Items That Can Be Used for Crafting)
	var _resourceMap = ds_map_create();
	for (var _r = 0; _r < ds_grid_height(_craftingGrid); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_craftingGrid); _c ++)
		{
			var _slot = craftingGrid[# _c, _r];
			
			if (_slot != 0)
			{
				//Add the Slot's Item Data to the resourceMap
				if (is_undefined(_resourceMap[? _slot.id]))
					_resourceMap[? _slot.id] = _slot.itemCount;	//create new key for the item
				else
					_resourceMap[? _slot.id] += _slot.itemCount;	//add the slot's itemCount to an existing key
			}
		}
	}
	
	//Create a List of Crafting Products
	var _productList = ds_list_create();
	for (var _id = 0; _id < ITEM_NUMBER; _id ++)	//loop through all the existing items
	{
		//Get the Resources Needed to Craft the Item
		var _item = id_get_item(_id);
		var _craftItems = _item.craftItems;
		var _timesCanBeCrafted = infinity;	//how many times the item can be crafted
		
		//Check if There Are All the Resources Needed in the reourceMap
		for (var _i = 0; _i < array_length(_craftItems); _i ++)	//loop through all the item's craft items
		{
			var _craftItem = _craftItems[_i]
			var _resourceItemCount = _resourceMap[? _craftItem[0]];
			if (!is_undefined(_resourceItemCount))	//check if there's the id needed in the reourceMap
			{
				_timesCanBeCrafted = min(_timesCanBeCrafted, _resourceItemCount div _craftItem[1]);
				if (_timesCanBeCrafted == 0)
					break;
			}
			else 
			{
				_timesCanBeCrafted = 0;
				break;
			}
		}
		
		//Add the Item to the prductList
		if (_timesCanBeCrafted != 0)
		{
			var _productItemCount = _timesCanBeCrafted * _item.craftAmount;
			_productItemCount = clamp(_productItemCount, 1, _item.itemLimit);
			ds_list_add(_productList, new Slot(_id, _productItemCount));
		}
	}
	obj_Inventory.craftingProducts = _productList;
}

/// Function updating the the slots in the craftingGrid according to taken crafting products.

function crafting_update_resources(_craftingGrid, _productId, _productItemCount)
{
	//Get the Crafring Product Data
	var _timesCrafted = _productItemCount div id_get_item(_productId).craftAmount;
	var _craftItems = id_get_item(_productId).craftItems;
	
	//Update the Resources
	for (var _i = 0; _i < array_length(_craftItems); _i ++)	//loop through the items needed to craft the product
	{
		var _craftItem = _craftItems[_i];
		var _resourceItemsNeeded = _craftItem[1] * _timesCrafted;	//get how many items of the product craftItem's ID has to be subtracted from the craftingGrid's slots
		
		for (var _r = 0; _r < ds_grid_height(_craftingGrid); _r ++)	//loop through the inventoryGrid
		{
			for (var _c = 0; _c < ds_grid_width(_craftingGrid); _c ++)
			{
				//Subtract the Needed Items from the Slot
				var _slot = _craftingGrid[# _c, _r];
				if (_slot != 0)
				{
					if (_slot.id == _craftItem[0])
					{
						_resourceItemsNeeded -= _slot.itemCount;
						_slot.itemCount = abs(clamp(_resourceItemsNeeded, - infinity, 0));
						
						if (_slot.itemCount == 0)
							slot_set(_craftingGrid, _c, _r, 0);
						if (_resourceItemsNeeded <= 0) break;
					}
				}
			}
			if (_resourceItemsNeeded <= 0) break;
		}
	}
}
