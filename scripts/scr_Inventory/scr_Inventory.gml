/// Function drawing an inventory slot.
/// variables needed: scale

function slot_draw(_item, _x, _y, _itemSize)
{						
	if (_item != 0)	//draw the item
	{
		draw_sprite_ext(_item.sprite, 0, _x, _y, scale, scale, 0, c_white, 1);
		draw_text_transformed_colour(_x + _itemSize * 1.1, _y + _itemSize * 1.15, _item.itemCount, scale * 0.75, scale * 0.75,
									 0, c_white, c_white, c_white, c_white, 1);
	}
}

/// Function checking for an interaction with inventory slot.
/// variables needed: heldSlot, buttonLeftPressed, mouseX, mouseY

function slot_interact(_item, _x, _y, _itemSet, _i, _j, _itemSize, _slotSize)
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
		
		//Check for Interaction
		if (buttonLeftPressed)
		{
			if (heldSlot != 0)
				heldSlotItemCount = heldSlot.itemCount;
			
			if (heldSlot == 0 && _item != 0)
			{
				heldSlot = new Item(_item.id, _item.itemCount);
				slot_set(_itemSet, _i, _j, 0);
			}
		}
		
		_item = slot_get(_itemSet, _i, _j);
		if (buttonLeft)
		{
			if (heldSlot != 0 && ds_list_size(splitList) < heldSlotItemCount)
			{
				if (_item == 0)
				{
					slot_set(_itemSet, _i, _j, new Item(heldSlot.id, 0));
					_item = slot_get(_itemSet, _i, _j);
				}
				if (_item.id == heldSlot.id)
				{
					var _isInSplitList = false;
					for (var _k = 0; _k < ds_list_size(splitList); _k ++)
					{
						var _splitSlot = splitList[| _k];
						if (_splitSlot[0] == _itemSet &&
							_splitSlot[1] == _i && _splitSlot[2] == _j)
						{
							var _isInSplitList = true
							break;
						}
					}
			
					if (!_isInSplitList)
					{
						var _splitSlot = [_itemSet, _i, _j, 0];
						ds_list_add(splitList, _splitSlot);
						split_update();
					}
				}
			}
		}
		//_item = slot_get(_itemSet, _i, _j);
		if (buttonLeftReleased)
		{
			if (heldSlot != 0)
			{
				heldSlotItemCount = heldSlot.itemCount;
				if (heldSlot.itemCount == 0)
					heldSlot = 0;
				
				else if (_item != 0 && ds_list_size(splitList) == 0)
				{
					var _heldSlotTemp = heldSlot;
					heldSlot = new Item(_item.id, _item.itemCount);
					slot_set(_itemSet, _i, _j, _heldSlotTemp);
				}
			}
			ds_list_clear(splitList);
		}
	}
}

/// Function for adding items to an item slot returning number of items exceeding its itemLimit

function slot_add_items(_itemSlot, _amount)
{
	var _itemLimit = id_get_item(_itemSlot.id).itemLimit;
	var _remainder = clamp((_itemSlot.itemCount + _amount) - _itemLimit, 0, infinity);
	_itemSlot.itemCount += _amount - _remainder;
	return _remainder;
}

/// Function which sets a slot in its grid/list/variable to a given value.

function slot_set(_itemSet, _i, _j, _value)
{
	if (_j != noone)	//clear a grid slot
		_itemSet[# _i, _j] = _value;
		
	else if (_i != noone)	//clear a list slot
		_itemSet[| _i] = _value;
		
	else _itemSet = _value;	//clear a variable slot
}

/// Function which gets a slot from its grid/list/variable.

function slot_get(_itemSet, _i, _j)
{
	if (_j != noone)	//clear a grid slot
		return _itemSet[# _i, _j];
		
	else if (_i != noone)	//clear a list slot
		return _itemSet[| _i];
		
	else return _itemSet;	//clear a variable slot
}

function split_update()
{
	var _splitListSize = ds_list_size(splitList);
	var _splitItemCount = floor(heldSlotItemCount / _splitListSize);
	//if (_splitListSize == 1) _splitItemCount;
	
	var _remainderTotal = 0;
	for (var _i = 0; _i < _splitListSize; _i ++)
	{
		var _splitSlot = splitList[| _i];
		var _item = slot_get(_splitSlot[0], _splitSlot[1], _splitSlot[2]);
		
		_item.itemCount -= _splitSlot[3];
		var _remainder = slot_add_items(_item, _splitItemCount);
		_splitSlot[3] = _splitItemCount - _remainder;
		_remainderTotal += _remainder;
	}
	heldSlot.itemCount = heldSlotItemCount - _splitItemCount * _splitListSize + _remainderTotal;
}
