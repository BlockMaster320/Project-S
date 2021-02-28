/// Function for drawing && interacting with Inventory Section.
/// variables needed: scale, craftingProductsPosition, craftingProductsLength
function inventory_section(_slotSet, _type, _x, _y, _station, _itemSize, _slotSize, _updateCrafting, _takeOnly)
{
	switch(_type)
	{
		case 0:	//Basic Grid
		{
			//Get the Selected Slot's Row && Column
			var _slotBorder = (_slotSize - _itemSize) * 0.5;
			var _rSelected = (mouseY - _y + _slotBorder) div _slotSize;
			var _cSelected = (mouseX - _x + _slotBorder) div _slotSize;
			
			//Draw && Interact With the Grid
			for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
			{
				for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
				{
					var _drawX = _x + _c * _slotSize;
					var _drawY = _y + _r * _slotSize;
					
					draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
					
					var _slot = _slotSet[# _c, _r];
					slot_draw(_slot, _drawX, _drawY, _itemSize, scale);	//draw the slot
					if (_r == _rSelected && _c == _cSelected)
						slot_interact(_drawX, _drawY, _slotSet, _c, _r, _station, _itemSize, _slotSize, _updateCrafting, _takeOnly);	//interact with the slot
				}
			}
		}
		break;
		
		case 1:	//List Drawn as 2-Column Grid
		{
			//Draw && Interact With the Grid
			var _lastSlotIndex = min(craftingProductsPosition * 2 + craftingProductsLength * 2, ds_list_size(_slotSet));
			for (var _i = craftingProductsPosition * 2; _i < _lastSlotIndex; _i ++)	//draw the crafting products
			{
				var _drawX = _x + _slotSize * floor(_i * 0.5);
				var _drawY = _y + _slotSize * (_i % 2 == 0);
				
				draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
				
				var _slot = _slotSet[| _i];
				slot_draw(_slot, _drawX, _drawY, _itemSize, scale);
				slot_interact(_drawX, _drawY, _slotSet, _i, noone, noone, _itemSize, _slotSize, _updateCrafting, _takeOnly);
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
function slot_interact(_x, _y, _slotSet, _i, _j, _station, _itemSize, _slotSize, _updateCrafting, _takeOnly)
{
	//Check for Mouse Selection
	var _slotBorder = (_slotSize - _itemSize) * 0.5;
	if (point_in_rectangle(mouseX, mouseY, _x - _slotBorder + 1, _y - _slotBorder + 1,
						   _x + _slotSize - _slotBorder - 1, _y + _slotSize - _slotBorder - 1))
	{
		//Get the Slot We're Interacting With
		var _slot = slot_get(_slotSet, _i, _j);
		
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
							slot_set(_slotSet, _i, _j, 0, _station);
						
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
					slot_set(_slotSet, _i, _j, 0, _station);
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
						station_slot_update(_station, _i, _j);
					}
					
					else	//take crafting product's craftAmount of its items
					{
						var _craftAmount = id_get_item(_slot.id).craftAmount;
						heldSlot = new Slot(_slot.id, _craftAmount);
						_slot.itemCount -= _craftAmount;
						if (_slot.itemCount == 0)
							slot_set(_slotSet, _i, _j, 0, _station);
						
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
					slot_set(_slotSet, _i, _j, new Slot(heldSlot.id, 0), noone);
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
						var _splitSlot = [_slotSet, _i, _j, 0, _station];
						ds_list_add(splitList, _splitSlot);
						
						if (_button == 1)	//update the split slots when holding left button
							split_update();
						else if (_slot.itemCount + 1 <= id_get_item(_slot.id).itemLimit)	//add 1 item to the current slot when holding right btton
						{
							_slot.itemCount += 1;
							heldSlot.itemCount -= 1;
							station_slot_update(_station, _i, _j);
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
					slot_set(_slotSet, _i, _j, _heldSlotTemp, _station);
				}
				
				crafting_update_products(obj_Inventory.craftingGrid);	//update the craftingProducts list
			}
			ds_list_clear(splitList);
		}
	}
}

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
