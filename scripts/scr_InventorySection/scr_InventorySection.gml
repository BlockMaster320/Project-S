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
					slot_draw(_slot, _drawX, _drawY, true, _itemSize, scale);	//draw the slot
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
				var _column = _i - craftingProductsPosition * 2;
				var _drawX = _x + _slotSize * floor(_column * 0.5);
				var _drawY = _y + _slotSize * (_column % 2 == 1);
				
				draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
				
				var _slot = _slotSet[| _i];
				slot_draw(_slot, _drawX, _drawY, true, _itemSize, scale);
				slot_interact(_drawX, _drawY, _slotSet, _i, noone, noone, _itemSize, _slotSize, _updateCrafting, _takeOnly);
			}
		}
		break
	}
}

/// Function drawing a section slot.
function slot_draw(_slot, _x, _y, _drawBackground, _itemSize, _scale)
{
	//Set Draw Properties
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	
	if (_drawBackground)	//draw the slot background
		draw_sprite_ext(spr_Block, 0, _x, _y, _scale, _scale, 0, c_white, 0.5);
	if (_slot != 0)	//draw the item
	{
		draw_sprite_ext(_slot.sprite, 0, _x, _y, _scale, _scale, 0, c_white, 1);
		var _slotItem = id_get_item(_slot.id);
		if (_slotItem.category == itemCategory.tool)
		{
			//Draw Slot's Endurance Represented by a Circle Sector
			if (variable_struct_exists(_slot, "endurance"))
			{
				var _value = _slot.endurance / 100;
				draw_circle_sector(_x, _y, 3 * _scale, _value, 10);
			}
		}
		else
		{
			draw_text_transformed_colour(_x + _itemSize * 1.1, _y + _itemSize * 1.15, _slot.itemCount, _scale * 0.75, _scale * 0.75,
										 0, c_white, c_white, c_white, c_white, 1);
		}
	}
}

/// Function for drawing an info table of a given slot.
function slot_draw_info(_slot, _x, _y)
{
	//Return If the Slot Is 0
	if (_slot == 0 || _slot == noone) return;
	
	//Set the Info Table's Content
	var _infoString = "";
	var _slotItem = id_get_item(_slot.id);
	_infoString += _slotItem.name;
	
	if (variable_struct_exists(_slot, "properties"))
	{
		var _properties = _slot.properties;
		if (_properties[property.power] != 0)
			_infoString += "\npower: " + string(_properties[property.power]);
		if (_properties[property.durability] != 0)
			_infoString += "\ndurability: " + string(_properties[property.durability]);
		if (_properties[property.hardness] != 0)
			_infoString += "\nhardness: " + string(_properties[property.hardness]);
	}
	
	//Set Info Table's Draw Properties
	var _textPadding = [4, 7, 4, 7];	//space between the text && the border from - left, rigth, top, bottom
	var _verticalOffset = 10;
	var _drawX1 = _x;
	var _drawX2 = _drawX1 + string_width(_infoString) + _textPadding[0] + _textPadding[1];
	var _drawY2 = _y - _verticalOffset;
	var _drawY1 = _drawY2 - string_height(_infoString) - _textPadding[2] - _textPadding[3];
	
	//Draw the Info Table
	draw_rectangle_colour(_drawX1 + 4, _drawY1 + 4, _drawX2 + 4, _drawY2 + 4, c_black, c_black, c_black, c_black, false);
	draw_rectangle_colour(_drawX1, _drawY1, _drawX2, _drawY2, c_dkgrey, c_dkgrey, c_dkgrey, c_dkgrey, false);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	draw_text_transformed_colour(_drawX1 + _textPadding[0], _drawY1 + _textPadding[2], _infoString,
								 1, 1, 0, c_white, c_white, c_white, c_white, 1);
}

function slot_wheel_draw(_slotSet, _chosenPosition, _wheelX, _wheelY, _radiusX, _radiusY, _wheelSlots, _itemSize, _scale)
{
	//Get Initial Position
	var _initialPosition = _chosenPosition - floor(_wheelSlots * 0.5);
	
	draw_sprite_ext(spr_SlotFrame, 0, _wheelX - _scale * _radiusX - (22 * _scale) * 0.5,
					_wheelY - (22 * _scale) * 0.5, _scale, _scale, 0, c_white, 1);
	
	//Draw Each Slot of the Inventory Wheel
	for (var _i = 0; _i < _wheelSlots; _i ++)
	{
		var _angle = 90 + (180 / (_wheelSlots - 1)) * _i;	//get draw x && y
		var _drawX = _wheelX + lengthdir_x(_scale * _radiusX, _angle) - _itemSize * 0.5;
		var _drawY = _wheelY + lengthdir_y(_scale * _radiusY, _angle) - _itemSize * 0.5;
		
		/*draw_circle_colour(wheelCenterX + lengthdir_x(_scale * 50, _angle),
						   wheelCenterY + lengthdir_y(_scale * 50, _angle), 1, c_red, c_red, false);*/
	
		var _position = _initialPosition + _i;	//get && draw the slot
		var _slot = position_slot_get(_slotSet, _position);
		slot_draw(_slot, _drawX, _drawY, true, _itemSize, _scale);
	}
}

/// Function checking for an interaction with a section slot.
/// variables needed: heldSlot, heldSlotItemCount, chosenSlot, splitList, mouseX, mouseY
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
		selectedSlot = [_slot, _x, _y];
		
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
				
				if (_button == - 1)	//move the chosenSlot to the selectedSection (slotSet)
				{
					var _itemCount = _slot.itemCount;
					slot_move(_slotSet, _i, _j, _station);
					
					if (_takeOnly)	//update crafting resources
					{
						var _itemCountDiferrence = _itemCount - _slot.itemCount;
						crafting_update_resources(obj_Inventory.craftingGrid, _slot, _itemCountDiferrence);
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
						
						crafting_update_resources(obj_Inventory.craftingGrid, _slot, _itemsToAdd);
					}
					swapSlots = false;
				}
			}
			
			if (heldSlot == 0 && _slot != 0)	//take the item if not holding one already
			{
				if (_button == 1)	//take all the items on left click
				{
					if (variable_struct_exists(_slot, "endurance"))
						_slot.endurance -= 1;
					
					heldSlot = _slot;
					slot_set(_slotSet, _i, _j, 0, _station);
					swapSlots = false;
					
					if (_takeOnly)
						crafting_update_resources(obj_Inventory.craftingGrid, _slot, _slot.itemCount);
				}
				else	//right click
				{
					if (!_takeOnly)	//take half of the items
					{
						if (_slot.itemCount != 1)
						{
							var _itemPart = round(_slot.itemCount / 2);
							heldSlot = slot_copy(_slot);
							heldSlot.itemCount = _itemPart;
							_slot.itemCount -= _itemPart;
							station_slot_update(_station, _i, _j);
						}
					}
					
					else	//take crafting product's craftAmount of its items
					{
						if (!keyModifier1)
						{
							var _craftAmount = id_get_item(_slot.id).craftAmount;
							heldSlot = slot_copy(_slot);
							heldSlot.itemCount = _craftAmount;
							_slot.itemCount -= _craftAmount;
							if (_slot.itemCount == 0)
								slot_set(_slotSet, _i, _j, 0, _station);
							
							crafting_update_resources(obj_Inventory.craftingGrid, _slot, _craftAmount);
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
					var _newSlot = slot_copy(heldSlot);
					_newSlot.itemCount = 0;
					slot_set(_slotSet, _i, _j,_newSlot, noone);
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
					heldSlot = _slot;
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
					var _newSlot = slot_copy(_slotDonor);
					_newSlot.itemCount = 0;
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
		var _newSlot = slot_copy(_addedSlot);
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
