///INVENTORY SECTION SLOT FUNCTIONS///
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
				var _drawY = _y + _slotSize * (_i % 2 == 1);
				
				draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
				
				var _slot = _slotSet[| _i];
				slot_draw(_slot, _drawX, _drawY, _itemSize, scale);
				slot_interact(_drawX, _drawY, _slotSet, _i, noone, noone, _itemSize, _slotSize, _updateCrafting, _takeOnly);
			}
		}
		break
	}
}

/// Function drawing a section slot.
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

/// Function checking for an interaction with a section slot.
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
		
		var _mouseWheel = mouseWheelUp - mouseWheelDown;
		
		//Check for Button Click
		if (_buttonPressed)
		{
			if (keyModifier1 && _slot != 0)	//special slot interactions
			{
				if (_button == 1 && !_takeOnly)	//cluster slots of the same ID to the selected slot
					slot_cluster(_slotSet, _i, _j, _station);
				
				if (_button == - 1)	//move the selectedSlot to the selectedSection (slotSet)
				{
					var _itemCount = _slot.itemCount;
					slot_move(_slotSet, _i, _j, _station);
					
					if (_takeOnly)	//update crafting resources
					{
						var _itemCountDiferrence = _itemCount - _slot.itemCount;
						crafting_update_resources(obj_Inventory.craftingGrid, _slot.id, _itemCountDiferrence);
					}
				}
			}
			
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
				else	//right click
				{
					if (!_takeOnly)	//take half of the items
					{
						if (_slot.itemCount != 1)
						{
							var _itemPart = round(_slot.itemCount / 2);
							heldSlot = new Slot(_slot.id, _itemPart);
							_slot.itemCount -= _itemPart;
							station_slot_update(_station, _i, _j);
						}
					}
					
					else	//take crafting product's craftAmount of its items
					{
						if (!keyModifier1)
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
		
		//Check for Mouse Wheel Scroll (Item Exchange)
		if (_mouseWheel != 0 && !_buttonHold && !keyModifier2 && !_takeOnly)
		{
			//Set Which Slot Which Donates && Which Receives Items
			var _slotDonor = (_mouseWheel == 1) ? heldSlot : _slot;
			var _slotReceiver = (_mouseWheel == 1) ? _slot : heldSlot;
			
			//Exchange Items Between the Donor && Receiver
			if (_slotDonor != 0)
			{
				//Set the Receiver to the Donor's Item If It's 0
				if (_slotReceiver == 0)
				{
					var _newSlot = new Slot(_slotDonor.id, 0);
					if (_slotReceiver == heldSlot)	//if heldslot is the receiver
					{
						heldSlot = _newSlot;
						_slotReceiver = heldSlot;
					}
					else	//if the selected slot is the receiver
					{
						slot_set(_slotSet, _i, _j, _newSlot, noone);
						_slotReceiver = slot_get(_slotSet, _i, _j);
					}
				}
				
				//Exchange the Items
				if (_slotDonor.id == _slotReceiver.id)	//check wheter the slots have the same item ID
				{
					//Add the Items to the Receiver && Subtract Them from the Donor
					var _remainder = slot_add_items(_slotReceiver, 1);
					_slotDonor.itemCount += - 1 + _remainder;
					
					//Make the Donor 0 If It Has No Items
					if (_slotDonor.itemCount == 0)
					{
						if (_slotDonor == heldSlot)	//if heldslot is the donor
						{
							heldSlot = 0;
							heldSlotItemCount = 0;
						}
						else	//if selected slot is the donor
							slot_set(_slotSet, _i, _j, 0, noone);
					}
					
					//Update the Slot in Networking && Update Crafting Products
					if (_remainder == 0)
					{
						station_slot_update(_station, _i, _j);
						crafting_update_products(obj_Inventory.craftingGrid);
					}
				}
			}
		}
	}
}

/// Function checking wheter the cursor is within a section area.
/// variables needed: scale, mouseX, mouseY
function cursor_in_section(_x, _y, _width, _height, _slotSize, _itemSize)
{
	//Check Wheter the Cursor is in the Section Area
	var _areaOffset = 4 * scale;
	var _areaX1 = _x - _areaOffset;
	var _areaX2 = _x + _slotSize * _width - (_slotSize - _itemSize) + _areaOffset;
	var _areaY1 = _y - _areaOffset;
	var _areaY2 = _y + _slotSize * _height - (_slotSize - _itemSize) + _areaOffset;
	var _cursorInSection = point_in_rectangle(mouseX, mouseY, _areaX1, _areaY1, _areaX2, _areaY2);
	
	/*
	draw_set_alpha(0.3);
	draw_rectangle_colour(_areaX1, _areaY1, _areaX2, _areaY2, c_green, c_green, c_green, c_green, false);
	draw_set_alpha(1);*/
	
	return _cursorInSection;
}

///SLOTSET SLOT FUNCTIONS///
/// Function adding a slot into a slotSet.
function slotSet_add_slot(_slotSet, _addedSlot, _station)
{
	//Loop Through the slotSet
	var _rEmptySlot = noone;
	var _cEmptySlot = noone;
	for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
		{
			//Get the Slot
			var _slot = _slotSet[# _c, _r];
			
			//Set Empty Slot's Position
			if (_slot == 0)
			{
				if (_rEmptySlot == noone)
				{
					_rEmptySlot = _r;
					_cEmptySlot = _c;
				}
			}
			
			//Add Added Slot's Items to a Slot of the Same ID
			else if (_slot.id == _addedSlot.id)
			{
				var _remainder = slot_add_items(_slot, _addedSlot.itemCount);
				_addedSlot.itemCount = _remainder;
				station_slot_update(_station, _c, _r);
				if (_remainder == 0) return;
			}
		}
	}
	
	//Add the Added Slot's Items into an Empty Slot
	if (_rEmptySlot != noone)
	{
		var _newSlot = new Slot(_addedSlot.id, _addedSlot.itemCount);
		slot_set(_slotSet, _cEmptySlot, _rEmptySlot, _newSlot, _station);
		_addedSlot.itemCount = 0;
	}
}

/// Function returning how many items will remain after collecting an item.
function slotSet_add_slot_remainder(_slotSet, _addedSlot)
{
	//Set Item Remainder
	var _remainder = _addedSlot.itemCount;
	var _itemLimit = id_get_item(_addedSlot.id).itemLimit;
	
	//Loop Through the slotSet
	for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
		{
			//Get the Slot
			var _slot = _slotSet[# _c, _r];
			
			//Update the Item Remainder
			if (_slot == 0) return 0;
			else if (_slot.id == _addedSlot.id)
			{
				_remainder -= _itemLimit - _slot.itemCount;
				if (_remainder <= 0) return 0;
			}
		}
	}
	return _remainder;
}
