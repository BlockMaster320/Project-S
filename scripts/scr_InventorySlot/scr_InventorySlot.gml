/// Function for adding items to an item slot && returning number of items exceeding its itemLimit.
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
function slot_set(_slotSet, _i, _j, _value, _station)
{
	if (_j != noone)	//set a grid slot
		_slotSet[# _i, _j] = _value;
		
	else if (_i != noone)	//set a list slot
		_slotSet[| _i] = _value;
		
	else _slotSet = _value;	//set a variable slot
	
	station_slot_update(_station, _i, _j);
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
		
		station_slot_update(_splitSlot[4], _splitSlot[1], _splitSlot[2]);
	}
	heldSlot.itemCount = heldSlotItemCount - _splitItemCount * _splitListSize + _remainderTotal;
}

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
		message_slot_change(_serverBuffer, _station.worldGridX, _station.worldGridY, _i, _j, _slot);
		with (obj_PlayerClient)
			network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
	}
	
	//Send Message to the Server
	else if (obj_GameManager.serverSide == false)
	{
		var _clientBuffer = obj_Client.clientBuffer;
		var _clientSocket = obj_Client.client;
		message_slot_change(_clientBuffer, _station.worldGridX, _station.worldGridY, _i, _j, _slot);
		network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
	}
}

/// Function changing a station slot to an updated slot recieved through networking.

function station_slot_change(_worldGridX, _worldGridY, _i, _j, _slot)
{
	//Set the Local Slot to the Updated One
	var _station = obj_WorldManager.worldGrid[# _worldGridX, _worldGridY];
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
