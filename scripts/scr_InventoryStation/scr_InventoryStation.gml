/// Function checking the space around the player for station blocks to add to stationList.
function station_search()
{
	//Get Station Search Start Position
	var _searchStartX = 0;
	var _searchStartY = 0;
	if (instance_exists(obj_PlayerLocal))	//check wheter the PlayerLocal exists
	{
		var _playerCenterX = obj_PlayerLocal.x + obj_PlayerLocal.sprite_width * 0.5;
		var _playerCenterY = obj_PlayerLocal.y + obj_PlayerLocal.sprite_height * 0.5;
		_searchStartX = _playerCenterX div CELL_SIZE - STATION_SEARCH_SIZE;
		_searchStartY = _playerCenterY div CELL_SIZE - STATION_SEARCH_SIZE;
	}
	
	//Clamp the Station Search Start Position
	var _worldGrid = obj_WorldManager.worldGrid;
	_searchStartX = clamp(_searchStartX, 0, ds_grid_width(_worldGrid) - 1);
	_searchStartY = clamp(_searchStartY, 0, ds_grid_height(_worldGrid) - 1);
	
	//Loop Through Blocks in a Square Area Around the Player && Search for Stations
	craftingLevel = 0;	//reset the craftingLevel
	var _stationList = obj_Inventory.stationList;
	for (var _x = _searchStartX; _x <= _searchStartX + STATION_SEARCH_SIZE * 2; _x ++)
	{
		for (var _y = _searchStartY; _y <= _searchStartY + STATION_SEARCH_SIZE * 2; _y ++)
		{
			//Get the Block
			var _block = _worldGrid[# _x, _y];
			if (_block == undefined)
				continue;
			
			//Check Wheter the Block is a Station
			if (_block != 0)
			{
				var _item = id_get_item(_block.id);
				if (_item.category == itemCategory.station)
				{
					//Add a New Station to the stationList
					if (ds_list_find_index(_stationList, _block) == - 1)
					{
						//Add Variables to the Added Station
						switch (_item.subCategory)
						{
							case itemSubCategory.storage:
							{
								var _storageWidth = _item.storageWidth;
								var _storageHeight = _item.storageHeight;
								
								var _storageGrid = slot_array_to_grid(_block.storageArray, _storageWidth, _storageHeight);
								_block.storageGrid = _storageGrid;
								ds_list_add(_stationList, _block);
							}
							break;
							
							case itemSubCategory.crafting:
							{
								var _craftingLevel = _item.craftingLevel;
								craftingLevel = max(craftingLevel, _craftingLevel);
							}
							break;
						}
					}
					
					//Set Additional Variables for Non-Crafting Stations
					if (_item.subCategory != itemSubCategory.crafting)
					{
						_block.inStationRange = true;	//mark the station so it's not deleted from the list in the next step below
						_block.worldGridX = _x;	//stations's position is needed for networking purposes
						_block.worldGridY = _y;
					}
				}
			}
		}
	}
	
	//Unlist Stations That Are Out of the Range of the Player || Have Been Destroyed
	for (var _i = 0; _i < ds_list_size(_stationList); _i ++)
	{
		var _station = _stationList[| _i];
		if (!_station.inStationRange)
		{
			station_update(_i);
			station_unlist(_i, true);
			continue;
		}
		_station.inStationRange = false;
	}
	
	//Wrap the Selected Station Indexes
	/*
	var _stationItemPreferred = id_get_item(stationList[| stationSelectedArray[stationPreferredSide]].id);
	station_selection_update(1, 1, _stationItemPreferred);*/
}

/// Function updating station's variables.
function station_update(_index)
{
	//Get the Station
	var _station = stationList[| _index];
	
	//Convert the storageGrid Used for Slot Interaction to Station's storageArray
	_station.storageArray = slot_grid_to_array(_station.storageGrid);
	/*show_debug_message(string(_station.storageArray));*/
}

/// Function unlisting a station from stationList.
function station_unlist(_index, _remove)
{
	//Get the Station
	var _station = stationList[| _index];
	
	//Remove Station's Slots from the splitList
	for (var _i = 0; _i < ds_list_size(splitList); _i ++)
	{
		var _splitSlot = splitList[| _i];
		if (_splitSlot[4] == _station)
		{
			heldSlotItemCount -= _splitSlot[3];
			ds_list_delete(splitList, _i);
			_i -= 1;	//this position was deleted so the next station's index is going to be the same (the list shifted by 1)
		}
	}
	
	//Remove Station's Variables Used for Slot Interaction
	ds_grid_destroy(_station.storageGrid);
	variable_struct_remove(_station, "storageGrid");
	variable_struct_remove(_station, "inStationRange");
	variable_struct_remove(_station, "worldGridX");
	variable_struct_remove(_station, "worldGridY");
	
	//Remove the Station from stationList
	if (_remove)
		ds_list_delete(stationList, _index);
}

/// Function for updating the selected station indexes.
function station_selection_update(_scrollDirection, _scrollSide, _stationPreferred)
{
	//Wrap the Selected Station Indexes
	var _stationListSize = ds_list_size(stationList);
	stationSelectedArray[0] = wrap(stationSelectedArray[0], 0, _stationListSize);
	stationSelectedArray[1] = wrap(stationSelectedArray[1], 0, _stationListSize);
	if (_stationListSize == 1) return;
	
	//Make the Selected Stations Not the Same
	if (stationSelectedArray[0] == stationSelectedArray[1])
	{
		/*var _stationIdexPrevious = wrap(stationSelectedArray[_scrollSide] - _scrollDirection, 0, _stationListSize);*/
		var _stationIndex = stationSelectedArray[0];
		var _stationNextIndex = wrap(_stationIndex + _scrollDirection, 0, _stationListSize);
		/*var _stationPreviousIndex = wrap(_stationIndex - _scrollDirection, 0, _stationListSize);*/
		var _station = stationList[| _stationIndex];
		
		var _stationItem = id_get_item(stationList[| _stationIndex].id);
		var _stationPreferredItem = id_get_item(_stationPreferred.id);
		var _stationNextItem = id_get_item(stationList[| _stationNextIndex].id);
		/*var _stationPreviousItem = id_get_item(stationList[| _stationPreviousIndex].id);*/
		
		if (_stationItem.stationSpace == 0 && _stationNextItem.stationSpace == 0 ||
			_stationPreferredItem.stationSpace == 1 && _stationPreferred == _station ||
			_stationItem.stationSpace == 0 && _stationPreferredItem.stationSpace == 0)
		{
			stationSelectedArray[_scrollSide] = wrap(stationSelectedArray[_scrollSide] + _scrollDirection,
													 0, _stationListSize);
		}
	}
}

/// Function for drawing && interacting with a station.
function station_draw(_station, _side, _offsetX, _offsetY, _slotSize, _itemSize)
{
	//Get the GUI Properties
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	
	//Get the Station Properties
	var _storageGrid = _station.storageGrid;
	var _stationSpace = id_get_item(_station.id).stationSpace;
	
	//Set the Station Draw Y
	var _stationY = _guiHeight * 0.5 - ds_grid_height(_storageGrid) * _slotSize
					+ (_slotSize - _itemSize) - _offsetY;
	
	//Set the Station Draw X
	var _stationX = 0;
	if (_side == - 1)	//when the station is on the left side
		var _stationX = _guiWidth * 0.5 - ds_grid_width(_storageGrid) * _slotSize
						+ (_slotSize - _itemSize) * 0.5 - _offsetX;
	
	else if (_side == 1)	//when the station is on the right side
		_stationX = _guiWidth * 0.5 + (_slotSize - _itemSize) * 0.5 + _offsetX;
	
	if (_side == 0 || _stationSpace == 1)	//when the station is in the middle
		_stationX = _guiWidth * 0.5 - ds_grid_width(_storageGrid) * 0.5 * _slotSize
					+ (_slotSize - _itemSize) * 0.5;
	
	//Draw && Interact With the Station
	inventory_section(_storageGrid, 0, _stationX, _stationY, _station, _itemSize, _slotSize, false, false);
}
