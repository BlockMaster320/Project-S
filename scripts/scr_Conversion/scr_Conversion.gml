//GRIDS <-> ARRAYS && STRUCTS
/// Function converting a grid containing blocks to a array of structs representing the blocks.
function block_grid_to_array(_blockGrid)
{
	//Set Variables
	var _blockGridWidth = ds_grid_width(_blockGrid);
	var _blockGridHeight = ds_grid_height(_blockGrid);
	var _blockArray = array_create(_blockGridWidth * _blockGridHeight, 0);
	
	//Convert the Grid to an Array of Structs
	for (var _r = 0; _r < _blockGridHeight; _r ++)
	{
		for (var _c = 0; _c < _blockGridWidth; _c ++)
		{
			var _block = _blockGrid[# _c, _r];
			_blockArray[_r * _blockGridWidth + _c] = _block;
		}
	}
	return _blockArray;
}

/// Function converting a grid containing slots to a array of structs representing the slots.
function slot_grid_to_array(_slotGrid)
{
	//Set Variables
	var _slotGridWidth = ds_grid_width(_slotGrid);
	var _slotGridHeight = ds_grid_height(_slotGrid);
	var _slotArray = array_create(_slotGridWidth * _slotGridHeight);
	
	//Convert the Grid to an Array of Structs
	for (var _r = 0; _r < _slotGridHeight; _r ++)
	{
		for (var _c = 0; _c < _slotGridWidth; _c ++)
		{
			var _slot = _slotGrid[# _c, _r];
			/*
			if (_slot != 0)
			{
				var _slotStruct =
				{
					id : _slot.id,
					itemCount : _slot.itemCount
				};
				_slotArray[_r * _slotGridWidth + _c] = _slotStruct;
			}
			else
				_slotArray[_r * _slotGridWidth + _c] = 0;*/
			_slotArray[_r * _slotGridWidth + _c] = _slot;
		}
	}
	return _slotArray;
}

/// Function converting a array containing structs representing the blocks to a grid of blocks.
function block_array_to_grid(_blockArray, _gridWidth, _gridHeight)
{
	var _blockGrid = ds_grid_create(_gridWidth, _gridHeight);
	for (var _i = 0; _i < array_length(_blockArray); _i ++)
	{
		var _block = _blockArray[_i];
		/*
		if (_block != 0)
			_block.sprite = id_get_item(_block.id).spriteBlock;*/
		_blockGrid[# _i % _gridWidth, _i div _gridWidth] = _block;
	}
	return _blockGrid;
}

/// Function converting a array containing structs representing slots to a grid of slots.
function slot_array_to_grid(_slotArray, _gridWidth, _gridHeight)
{
	var _slotGrid = ds_grid_create(_gridWidth, _gridHeight);
	for (var _i = 0; _i < array_length(_slotArray); _i ++)
	{
		var _slot = _slotArray[_i];
		
		/*
		var _slotStruct = 0;
		if (is_struct(_slot))
		{
			_slotStruct = new Slot(_slot.id, _slot.itemCount, noone);
		}*/
		_slotGrid[# _i % _gridWidth, _i div _gridWidth] = _slot;
	}
	return _slotGrid;
}


//GRIDS <-> LISTS && MAPS (OBSOLETE)
/// Function converting a grid containing blocks to a list of maps representing the blocks.
function block_grid_to_list(_blockGrid)
{
	var _blockList = ds_list_create();
	for (var _r = 0; _r < ds_grid_height(_blockGrid); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_blockGrid); _c ++)
		{
			var _block = _blockGrid[# _c, _r];
			if (_block != 0)
			{
				var _blockMap = ds_map_create();
				ds_map_add(_blockMap, "id", _block.id);
			
				ds_list_add(_blockList, _blockMap);
				ds_list_mark_as_map(_blockList, ds_list_size(_blockList) - 1);
			}
			else
				ds_list_add(_blockList, 0);
		}
	}
	return _blockList;
}

/// Function converting a grid containing slots to a list of maps representing the slots.
function slot_grid_to_list(_slotGrid)
{
	var _slotList = ds_list_create();
	for (var _r = 0; _r < ds_grid_height(_slotGrid); _r ++)
	{
		for (var _c = 0; _c < ds_grid_width(_slotGrid); _c ++)
		{
			var _slot = _slotGrid[# _c, _r];
			if (_slot != 0)
			{
				var _slotMap = ds_map_create();
				ds_map_add(_slotMap, "id", _slot.id);
				ds_map_add(_slotMap, "itemCount", _slot.itemCount);
			
				ds_list_add(_slotList, _slotMap);
				ds_list_mark_as_map(_slotList, ds_list_size(_slotList) - 1);
			}
			else
				ds_list_add(_slotList, 0);
		}
	}
	return _slotList;
}

/// Function converting a list containing maps representing the blocks to a grid of blocks.
function block_list_to_grid(_blockList, _gridWidth, _gridHeight)
{
	var _blockGrid = ds_grid_create(_gridWidth, _gridHeight);
	for (var _i = 0; _i < ds_list_size(_blockList); _i ++)
	{
		var _blockMap = _blockList[| _i];
		var _block = 0;
		if (ds_list_is_map(_blockList, _i))
		{
			var _id = _blockMap[? "id"];
			var _block = new Block(_id); 
		}
			
		_blockGrid[# _i % _gridWidth, _i div _gridWidth] = _block;
	}
	return _blockGrid;
}

/// Function converting a list containing maps representing the slots to a grid of slots.
function slot_list_to_grid(_slotList, _gridWidth, _gridHeight)
{
	var _slotGrid = ds_grid_create(_gridWidth, _gridHeight);
	for (var _i = 0; _i < ds_list_size(_slotList); _i ++)
	{
		var _slotMap = _slotList[| _i];
		var _slot = 0;
		if (ds_list_is_map(_slotList, _i))
		{
			var _id = _slotMap[? "id"];
			var _itemCount = _slotMap[? "itemCount"];
			var _slot = new Slot(_id, _itemCount, noone);
		}
		
		_slotGrid[# _i % _gridWidth, _i div _gridWidth] = _slot;
	}
	return _slotGrid;
}