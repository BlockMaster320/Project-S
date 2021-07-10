///SLOT GET && SET///
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
function slot_set(_slotSet, _i, _j, _value, _station)
{
	if (_j != noone)	//set a grid slot
		_slotSet[# _i, _j] = _value;
		
	else if (_i != noone)	//set a list slot
		_slotSet[| _i] = _value;
		
	else _slotSet = _value;	//set a variable slot
	
	station_slot_update(_station, _i, _j);
}

/// Function returning a slot on a given position in a grid.
function position_slot_get(_slotSet, _position)
{
	var _gridPosition = slot_get_gridPosition(_slotSet, _position)
	return _slotSet[# _gridPosition[0], _gridPosition[1]];
}

/// Function changing value of a slot on a given position in a grid.
function position_slot_set(_slotSet, _position, _value)
{
	var _gridPosition = slot_get_gridPosition(_slotSet, _position)
	_slotSet[# _gridPosition[0], _gridPosition[1]] = _value;
}

/// Function returning row && column of a slot on a given position in a grid.
function slot_get_gridPosition(_slotSet, _position)
{
	//Get Number of Columns && Rows
	var _columns = ds_grid_width(_slotSet);
	var _rows = ds_grid_height(_slotSet);
	
	//Wrap the Position to Fit into the slotSet
	var _totalSlots = _columns * _rows;
	_position = _position % _totalSlots;
	if (sign(_position) == - 1)
		_position = _totalSlots + _position;
	
	//Get Slot's Column && Row
	var _slotRow = _position div _columns;
	var _slotColumn = _position % _columns;
	
	return [_slotColumn, _slotRow];
}

///SLOT SPECIFIC ACTIONS///
/// Function for adding items to an item slot && returning number of items exceeding its itemLimit.
function slot_add_items(_slot, _amount)
{
	var _itemLimit = id_get_item(_slot.id).itemLimit;
	var _remainder = clamp((_slot.itemCount + _amount) - _itemLimit, 0, infinity);
	_slot.itemCount += _amount - _remainder;
	return _remainder;
}

/// Function clustering all items of the same idea to the selected slot.
function slot_cluster(_slotSet, _i, _j, _station)
{
	//Loop Through the Given Set of Slots
	var _slotSelected = slot_get(_slotSet, _i, _j);
	for (var _r = 0; _r < ds_grid_height(_slotSet); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotSet); _c ++)
		{
			//Skip the Selected Slot
			if (_r == _j && _c == _i)
				continue;
			
			//Merge the Slot to the Selected One
			var _slot = _slotSet[# _c, _r];
			if (_slot != 0 && _slot.id == _slotSelected.id)
			{
				//Add the Slot's itemCount to the Selected Slot
				var _remainder = slot_add_items(_slotSelected, _slot.itemCount);
				_slot.itemCount = _remainder;
				if (_slot.itemCount == 0)
					slot_set(_slotSet, _c, _r, 0, _station);
				
				//Return the Function if the Selected Slot is Full
				if (_remainder > 0)
					return;
			}
		}
	}
}

/// Function moving a slot from its inventory section to selected one.
/// variables needed: selectedSection, stationList, stationSelectedArray, stationPreferredSide, inventoryGrid
function slot_move(_slotSet, _i, _j, _station)
{
	//Get the Slot
	var _slot = slot_get(_slotSet, _i, _j);
	var _slotSetTarget = noone;
	var _stationSelected = noone;
	
	//Set the Target slotSet to Inventory Grid
	if (_slotSet != inventoryGrid)
		_slotSetTarget = inventoryGrid;
	
	//Set the Target slotSet to the Selected Section's slotSet
	else
	{
		switch (selectedSection)
		{
			case noone:
				return;
				break;
		
			case inventorySection.station:
			{
				//Return If There's No Station
				if (ds_list_size(stationList) == 0)
					return;
				
				//Get the Selected Station && Its slotSet
				_stationSelected = stationList[| stationSelectedArray[stationPreferredSide]];
				_slotSetTarget = _stationSelected.storageGrid;
			}
			break;
		}
	}
	
	//Add the Slot to the Selected slotSet
	slotSet_add_slot(_slotSetTarget, _slot, _stationSelected);
	if (_slot.itemCount == 0)
		slot_set(_slotSet, _i, _j, 0, _station);
	else if (selectedSection != inventorySection.station)	//update the slot in networking
		station_slot_update(_station, _i, _j);
}

/// Function updating values of items in the split list.
/// variables needed: splitList, heldSlot, heldSlotItemCount
function split_update()
{
	var _splitListSize = ds_list_size(splitList);	//get number of items each split item should get
	var _splitItemCount = floor(heldSlotItemCount / _splitListSize);
	
	/*if (_splitListSize == 2)
	{
		show_debug_message("ejje");
		var _test;
	}*/
	
	var _remainderTotal = 0;
	for (var _i = 0; _i < _splitListSize; _i ++)	//loop trought the split items && add the items
	{
		var _splitSlot = splitList[| _i];
		var _slot = slot_get(_splitSlot[0], _splitSlot[1], _splitSlot[2]);
		
		_slot.itemCount -= _splitSlot[3];
		var _remainder = slot_add_items(_slot, _splitItemCount);
		_splitSlot[@ 3] = _splitItemCount - _remainder;
		_remainderTotal += _remainder;
		
		station_slot_update(_splitSlot[4], _splitSlot[1], _splitSlot[2]);
	}
	heldSlot.itemCount = heldSlotItemCount - _splitItemCount * _splitListSize + _remainderTotal;
}

///SLOT NETWORKING UPDATE///
/// Function sending a network message to update changed slot in a station.
function station_slot_update(_station, _i, _j)
{
	//Return If the Slot Isn't in a Station or If Networking Isn't Turned On
	if (_station == noone || obj_GameManager.networking == false)
		return;
	
	//Get the Changed Slot
	var _slot = slot_get(_station.storageGrid, _i, _j);
	show_debug_message(_slot);
	
	//Send Message to All Clients
	if (obj_GameManager.serverSide == true)
	{
		var _serverBuffer = obj_Server.serverBuffer;
		message_slot_change(_serverBuffer, _station.worldX, _station.worldY, _i, _j, _slot);
		with (obj_PlayerClient)
			network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
	}
	
	//Send Message to the Server
	else if (obj_GameManager.serverSide == false)
	{
		var _clientBuffer = obj_Client.clientBuffer;
		var _clientSocket = obj_Client.client;
		message_slot_change(_clientBuffer, _station.worldX, _station.worldY, _i, _j, _slot);
		network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
	}
}

/// Function changing a station slot to an updated slot recieved through networking.
function station_slot_change(_gridX, _gridY, _i, _j, _slot)
{
	//Set the Local Slot to the Updated One
	var _station = block_get(_gridX, _gridY, true);
	var _stationItem = id_get_item(_station.id);
	var _slotPosition = _j * _stationItem.storageWidth + _i;
	_station.storageArray[_slotPosition] = _slot;
	if (variable_struct_exists(_station, "storageGrid"))
		position_slot_set(_station.storageGrid, _slotPosition, _slot);
			
	//Remove the Slot From the splitList
	var _splitList = obj_Inventory.splitList;
	for (var _k = 0; _k < ds_list_size(_splitList); _k ++)
	{
		var _splitSlot = _splitList[| _k]
		if (_station == _splitSlot[4] && _i == _splitSlot[1] && _j == _splitSlot[2])	//check wheter the slot is in the splitList
		{
			with (obj_Inventory)
			{
				//Subtract Split Slot's itemCount Added When Splitting from the heldSlot
				heldSlotItemCount -= _splitSlot[3];
				if (heldSlotItemCount == 0)
					heldSlot = 0;
						
				//Delete the Slot from the splitList
				ds_list_delete(splitList, _k);
				split_update();
			}
		}
	}
}
