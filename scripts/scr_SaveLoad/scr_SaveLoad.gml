/// Function saving the world data to a given file.

function world_save(_file)
{
	//Convert the World Grid to an Array
	var _worldArray = block_grid_to_array(obj_WorldManager.worldGrid);
	
	//Save the Players && Their Inventories to an Array
	var _playerArray = array_create(0);
	with (obj_Player)
	{
		var _playerStruct =
		{
			object : object_get_name(object_index),
			x : x,
			y : y,
			horizontalSpeed : horizontalSpeed,
			verticalSpeed : verticalSpeed,
			
			inventoryArray : slot_grid_to_array(playerInventoryGrid),	//convert player's inventory grids to arrays
			armorArray : slot_grid_to_array(playerArmorGrid),
			toolArray : slot_grid_to_array(playerToolGrid)
		};
		_playerArray[playerId] = _playerStruct;
	}
	
	//Save the Items to an Array
	var _itemArray = array_create(0);
	with (obj_Item)
	{
		var _itemStruct =
		{
			object : object_get_name(object_index),
			x : x,
			y : y,
			horizontalSpeed : horizontalSpeed,
			verticalSpeed : verticalSpeed,
			itemId : itemSlot.id,
			itemCount : itemSlot.itemCount
		}
		array_push(_itemArray, _itemStruct);
	}
	
	//Add the World Data to the Main Struct
	var _mainStruct =
	{
		worldSeed : obj_WorldManager.worldSeed,
		worldWidth : obj_WorldManager.worldWidth,
		worldHeight: obj_WorldManager.worldHeight,
		
		worldArray : _worldArray,
		playerArray : _playerArray,
		itemArray : _itemArray
	};
	
	//Save the Main Struct as a JSON String
	var _saveString = json_stringify(_mainStruct);
	json_string_save(_saveString, _file);
}

/// Function loading the world data from a given file.

function world_load(_file)
{
	if (file_exists(_file))
	{
		//Activate the World Control Objects
		instance_activate_layer("WorldManagers");
		
		//Load the World Data from the Main Struct
		var _mainStruct = json_parse(json_string_load(_file));
		
		var _worldSeed = _mainStruct.worldSeed;
		var _worldWidth = _mainStruct.worldWidth;
		var _worldHeight = _mainStruct.worldHeight;

		var _worldArray = _mainStruct.worldArray;
		var _playerArray = _mainStruct.playerArray;
		var _itemArray = _mainStruct.itemArray
		
		//Convert the World Array to a Grid && Replace It with the Current One
		ds_grid_destroy(obj_WorldManager.worldGrid);
		obj_WorldManager.worldGrid = block_array_to_grid(_worldArray, _worldWidth, _worldHeight);
		
		//Update World Parameters in the WorldManager
		obj_WorldManager.worldWidth = _worldWidth;
		obj_WorldManager.worldHeight = _worldHeight;
		obj_WorldManager.worldSeed = _worldSeed;
		obj_WorldManager.generationSeed = get_generation_seed(_worldSeed);
		
		//Instantiate Loaded Local Player
		with (obj_Player) instance_destroy();	//destroy all existing players
		
		var _localPlayerStruct = _playerArray[0];	//get the local player's data
		var _object = _localPlayerStruct.object;
		var _x = _localPlayerStruct.x;
		var _y = _localPlayerStruct.y;
		var _horizontalSpeed = _localPlayerStruct.horizontalSpeed;
		var _verticalSpeed = _localPlayerStruct.verticalSpeed;
		
		var _localPlayer = instance_create_layer(_x, _y, "Entities", asset_get_index(_object));	//create the local player
		with (_localPlayer)
		{
			horizontalSpeed = _horizontalSpeed;
			verticalSpeed = _verticalSpeed;
		}
		
		//Get the Local Player's Inventory Grids && Replace Them With the Current Ones
		var _inventoryArray = _localPlayerStruct.inventoryArray;	//get the local player's invenotry grids
		var _armorArray = _localPlayerStruct.armorArray;
		var _toolArray = _localPlayerStruct.toolArray;
		
		ds_grid_destroy(obj_Inventory.inventoryGrid);	//load the inventory grid
		var _inventoryWidth = obj_Inventory.inventoryWidth;
		var _inventoryHeight = obj_Inventory.inventoryHeight;
		obj_Inventory.inventoryGrid = slot_array_to_grid(_inventoryArray, _inventoryWidth, _inventoryHeight);
		
		ds_grid_destroy(obj_Inventory.armorGrid);	//load the armor grid
		var _armorWidth = obj_Inventory.armorWidth;
		var _armorHeight = obj_Inventory.armorHeight;
		obj_Inventory.armorGrid = slot_array_to_grid(_armorArray, _armorWidth, _armorHeight);
		
		ds_grid_destroy(obj_Inventory.toolGrid);	//load the tool grid
		var _toolWidth = obj_Inventory.toolWidth;
		var _toolHeight = obj_Inventory.toolHeight;
		obj_Inventory.toolGrid = slot_array_to_grid(_toolArray, _toolWidth, _toolHeight);
		
		//Instantiate Loaded Items
		with (obj_Item) instance_destroy();	//destroy all existing items
		for (var _i = 0; _i < array_length(_itemArray); _i ++)
		{
			var _itemStruct = _itemArray[_i];
			var _object = _itemStruct.object;
			var _x = _itemStruct.x;
			var _y = _itemStruct.y;
			var _horizontalSpeed = _itemStruct.horizontalSpeed;
			var _verticalSpeed = _itemStruct.verticalSpeed;
			var _itemId = _itemStruct.itemId;
			var _itemCount = _itemStruct.itemCount;
			
			var _item = instance_create_layer(_x, _y, "Items", asset_get_index(_object));
			with (_item)
			{
				horizontalSpeed = _horizontalSpeed;
				verticalSpeed = _verticalSpeed;
				itemSlot = new Slot(_itemId, _itemCount);
			}
		}
	}
}

/// Function for generating a new world && storing its data in a file.

function world_create(_worldName)
{
	//Create a Name for the New World File
	var _worldFile = _worldName + ".sav";
	
	//Destroy the World Entities && Clear the Data Structures
	world_clear();
	
	//Activate the World Control Objects
	instance_activate_layer("WorldManagers");
	
	//Generate a New World && Set Its Properties
	var _worldSeed = irandom(9999);
	var _generationSeed = get_generation_seed(_worldSeed);
	var _worldWidth = 50;
	var _worldHeight = 100;
	
	with (obj_WorldManager)	//set the new world properties in the WorldManager
	{
		worldSeed = _worldSeed;
		generationSeed = _generationSeed;
		worldWidth = _worldWidth;
		worldHeight = _worldHeight;
		worldGrid = world_generate(_worldWidth, _worldHeight, _generationSeed, 10);
	}
	
	//Spawn the Player
	instance_create_layer(100, 50, "Entities", obj_PlayerLocal);
	
	//Save the New World to a File
	obj_GameManager.worldFile = _worldFile;
	world_save(_worldFile);
	
	//Add the World File to the worldFileList && Update the gameFile
	array_push(worldFileArray, _worldFile);
	gameFileStruct.worldFileArray = worldFileArray;
	var _saveString = json_stringify(gameFileStruct);
	json_string_save(_saveString, "gamesave.sav");
}

/// Function clearing the world's content. (Destroying objects, clearing data structures.)

function world_clear()
{
	//Destroy Objects
	with (obj_Entity) instance_destroy();
	with (obj_Item) instance_destroy();
	
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
	
	//Clear the worldGrid
	with (obj_WorldManager) ds_grid_clear(worldGrid, 0);
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
