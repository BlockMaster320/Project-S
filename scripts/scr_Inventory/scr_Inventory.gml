/// Function drawing an inventory slot.
/// variables needed: scale

function slot_draw(_slot, _x, _y, _itemSize)
{						
	if (_slot != 0)	//draw the item
	{
		draw_sprite_ext(_slot.sprite, 0, _x, _y, scale, scale, 0, c_white, 1);
		draw_text_transformed_colour(_x + _itemSize * 1.1, _y + _itemSize * 1.15, _slot.itemCount, scale * 0.75, scale * 0.75,
									 0, c_white, c_white, c_white, c_white, 1);
	}
}

/// Function checking for an interaction with inventory slot.
/// variables needed: heldSlot, heldSlotItemCount, splitList, mouseX, mouseY,
/// buttonLeft, buttonLeftPressed, buttonLeftReleased

function slot_interact(_slot, _x, _y, _slotSet, _i, _j, _itemSize, _slotSize)
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
			if (heldSlot != 0)	//start item splitting
				heldSlotItemCount = heldSlot.itemCount;
			
			if (heldSlot == 0 && _slot != 0)	//grab the item if not holding one already
			{
				if (_button == 1)	//take all the items on left click
				{
					heldSlot = new Slot(_slot.id, _slot.itemCount);	//take half of the items on right click
					slot_set(_slotSet, _i, _j, 0);
				}
				else if (_slot.itemCount != 1)
				{
					var _itemPart = round(_slot.itemCount / 2);
					heldSlot = new Slot(_slot.id, _itemPart);
					_slot.itemCount -= _itemPart;
				}
			}
			_slot = slot_get(_slotSet, _i, _j);	//update the item data
		}
		
		//Check for Button Hold (Item Placing/Splitting)
		if (_buttonHold)
		{
			if (heldSlot != 0 && ds_list_size(splitList) < heldSlotItemCount)
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
						
						if (_button == 1)	//update the split slots when holding left btton
							split_update();
						else if (_slot.itemCount + 1 <= id_get_item(_slot.id).itemLimit)	//add 1 item to the current slot when holding right btton
						{
							_slot.itemCount += 1;
							heldSlot.itemCount -= 1;
						}
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
				
				else if (_slot != 0 && ds_list_size(splitList) == 0 && _button != - 1)	//switch the item with the held one
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

/// Function for adding items to an item slot returning number of items exceeding its itemLimit

function slot_add_items(_slot, _amount)
{
	var _itemLimit = id_get_item(_slot.id).itemLimit;
	var _remainder = clamp((_slot.itemCount + _amount) - _itemLimit, 0, infinity);
	_slot.itemCount += _amount - _remainder;
	return _remainder;
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

/// Function which gets a slot from its grid/list/variable.

function slot_get(_slotSet, _i, _j)
{
	if (_j != noone)	//clear a grid slot
		return _slotSet[# _i, _j];
		
	else if (_i != noone)	//clear a list slot
		return _slotSet[| _i];
		
	else return _slotSet;	//clear a variable slot
}

/// Function updating values of items in the split list.
//variables needed: splitList, heldSlot, heldSlotItemCount

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
