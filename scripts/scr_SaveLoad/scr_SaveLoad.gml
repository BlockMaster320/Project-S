/// Function saving the world Data to a given file.

function world_save(_file)
{
	//Convert the World Grid && Inventory Grids to Lists
	var _worldList = block_grid_to_list(obj_WorldManager.worldGrid);
	var _inventoryList = slot_grid_to_list(obj_Inventory.inventoryGrid);
	var _armorList = slot_grid_to_list(obj_Inventory.armorGrid);
	var _toolList = slot_grid_to_list(obj_Inventory.toolGrid);
	
	//Save the Entities to a List
	var _entityList = ds_list_create();
	with (obj_Entity)
	{
		var _entityMap = ds_map_create();
		ds_map_add(_entityMap, "object", object_get_name(object_index));
		ds_map_add(_entityMap, "x", x);
		ds_map_add(_entityMap, "y", y);
		ds_map_add(_entityMap, "horizontalSpeed", horizontalSpeed);
		ds_map_add(_entityMap, "verticalSpeed", verticalSpeed);
		
		ds_list_add(_entityList, _entityMap);
		ds_list_mark_as_map(_entityList, ds_list_size(_entityList) - 1);
	}
	
	//Save the Items to a List
	var _itemList = ds_list_create();
	with (obj_Item)
	{
		var _itemMap = ds_map_create();
		ds_map_add(_itemMap, "object", object_get_name(object_index));
		ds_map_add(_itemMap, "x", x);
		ds_map_add(_itemMap, "y", y);
		ds_map_add(_itemMap, "horizontalSpeed", horizontalSpeed);
		ds_map_add(_itemMap, "verticalSpeed", verticalSpeed);
		ds_map_add(_itemMap, "itemId", itemSlot.id);
		ds_map_add(_itemMap, "itemCount", itemSlot.itemCount);
		
		ds_list_add(_itemList, _itemMap);
		ds_list_mark_as_map(_itemList, ds_list_size(_itemList) - 1);
	}
	
	//Add the World Data to the Main Map
	var _mainMap = ds_map_create();
	ds_map_add(_mainMap, "worldSeed", obj_WorldManager.worldSeed);
	ds_map_add(_mainMap, "worldWidth", obj_WorldManager.worldWidth);
	ds_map_add(_mainMap, "worldHeight", obj_WorldManager.worldHeight);
	ds_map_add_list(_mainMap, "worldList", _worldList);
	ds_map_add_list(_mainMap, "inventoryList", _inventoryList);
	ds_map_add_list(_mainMap, "armorList", _armorList);
	ds_map_add_list(_mainMap, "toolList", _toolList);
	ds_map_add_list(_mainMap, "entityList", _entityList);
	ds_map_add_list(_mainMap, "itemList", _itemList);
	
	//Save the Main Map as a JSON String
	var _saveString = json_encode(_mainMap);
	json_string_save(_saveString, _file);
	ds_map_destroy(_mainMap);
}

/// Function loading the world data from a given file.

function world_load(_file)
{
	if (file_exists(_file))
	{
		//Activate the World Control Objects
		instance_activate_layer("WorldManagers");
		
		//Load the World Data from the Main Map
		var _mainMap = json_decode(json_string_load(_file));
		var _worldSeed = _mainMap[? "worldSeed"];
		var _worldWidth = _mainMap[? "worldWidth"];
		var _worldHeight = _mainMap[? "worldHeight"];
		var _worldList = _mainMap[? "worldList"];
		var _inventoryList = _mainMap[? "inventoryList"];
		var _armorList = _mainMap[? "armorList"];
		var _toolList = _mainMap[? "toolList"];
		var _entityList = _mainMap[? "entityList"];
		var _itemList = _mainMap[? "itemList"];
		
		//Convert the World List && Inventory Lists to Grids && Replace Them with the Current Ones
		ds_grid_destroy(obj_WorldManager.worldGrid);	//load the world grid
		obj_WorldManager.worldGrid = block_list_to_grid(_worldList, _worldWidth, _worldHeight);
		
		ds_grid_destroy(obj_Inventory.inventoryGrid);	//load the inventory grid
		var _inventoryWidth = obj_Inventory.inventoryWidth;
		var _inventoryHeight = obj_Inventory.inventoryHeight;
		obj_Inventory.inventoryGrid = slot_list_to_grid(_inventoryList, _inventoryWidth, _inventoryHeight);
		
		ds_grid_destroy(obj_Inventory.armorGrid);	//load the armor grid
		var _armorWidth = obj_Inventory.armorWidth;
		var _armorHeight = obj_Inventory.armorHeight;
		obj_Inventory.armorGrid = slot_list_to_grid(_armorList, _armorWidth, _armorHeight);
		
		ds_grid_destroy(obj_Inventory.toolGrid);	//load the tool grid
		var _toolWidth = obj_Inventory.toolWidth;
		var _toolHeight = obj_Inventory.toolHeight;
		obj_Inventory.toolGrid = slot_list_to_grid(_toolList, _toolWidth, _toolHeight);
		
		//Update World Parameters in the WorldManager
		obj_WorldManager.worldWidth = _worldWidth;
		obj_WorldManager.worldHeight = _worldHeight;
		obj_WorldManager.worldSeed = _worldSeed;
		obj_WorldManager.generationSeed = get_generation_seed(_worldSeed);
		
		//Instantiate Loaded Entities
		with (obj_Entity) instance_destroy();	//destroy all existing entities
		for (var _i = 0; _i < ds_list_size(_entityList); _i ++)
		{
			var _entityMap = _entityList[| _i];
			var _object = _entityMap[? "object"];
			var _x = _entityMap[? "x"];
			var _y = _entityMap[? "y"];
			var _horizontalSpeed = _entityMap[? "horizontalSpeed"];
			var _verticalSpeed = _entityMap[? "verticalSpeed"];
			
			var _entity = instance_create_layer(_x, _y, "Entities", asset_get_index(_object));
			with (_entity)
			{
				horizontalSpeed = _horizontalSpeed;
				verticalSpeed = _verticalSpeed;
			}
		}
		
		//Instantiate Loaded Items
		with (obj_Item) instance_destroy();	//destroy all existing items
		for (var _i = 0; _i < ds_list_size(_itemList); _i ++)
		{
			var _itemMap = _itemList[| _i];
			var _object = _itemMap[? "object"];
			var _x = _itemMap[? "x"];
			var _y = _itemMap[? "y"];
			var _horizontalSpeed = _itemMap[? "horizontalSpeed"];
			var _verticalSpeed = _itemMap[? "verticalSpeed"];
			var _itemId = _itemMap[? "itemId"];
			var _itemCount = _itemMap[? "itemCount"];
			
			var _item = instance_create_layer(_x, _y, "Items", asset_get_index(_object));
			with (_item)
			{
				horizontalSpeed = _horizontalSpeed;
				verticalSpeed = _verticalSpeed;
				show_debug_message(_itemId);
				itemSlot = new Slot(_itemId, _itemCount);
			}
		}
		
		//Destroy the Main Map
		ds_map_destroy(_mainMap);
	}
}

/// Function clearing the world's content. (Destroying objects, clearing data structures.)

function world_clear()
{
	//Destroy Objects
	with (obj_Entity) instance_destroy();
	with (obj_Item) instance_destroy();
	
	//Spawn the Player
	instance_create_layer(100, 50, "Entities", obj_Player);
	
	//Clear the Inventory Data Structures
	with (obj_Inventory)
	{
		ds_grid_clear(inventoryGrid, 0);
		ds_grid_clear(armorGrid, 0);
		ds_grid_clear(toolGrid, 0);
		ds_grid_clear(craftingGrid, 0);
		
		ds_list_clear(splitList);
		ds_list_clear(stationList);
	}
	
	//Destroy the worldGrid
	with (obj_WorldManager) ds_grid_destroy(worldGrid);
}

/// Function saving a JSON string to a given file using a buffer.

function json_string_save(_string, _file)
{
	var _buffer = buffer_create(string_byte_length(_string) + 1, buffer_fixed, 1);
	buffer_write(_buffer, buffer_string, _string);
	buffer_save(_buffer, _file);
	buffer_delete(_buffer);
}

/// Function loading a JSON string from given file using a buffer.

function json_string_load(_file)
{
	var _buffer = buffer_load(_file);
	var _string = buffer_read(_buffer, buffer_string);
	buffer_delete(_buffer);
	return _string;
}

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
			var _slot = new Slot(_id, _itemCount);
		}
		
		_slotGrid[# _i % _gridWidth, _i div _gridWidth] = _slot;
	}
	return _slotGrid;
}
