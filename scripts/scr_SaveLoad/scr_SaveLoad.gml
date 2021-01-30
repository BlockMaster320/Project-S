/// Function triggering the world saving && closing process.

function world_save_close()
{
	//Save the Game After Getting Client's Inventory Data
	if (obj_GameManager.networking)
	{
		//Get All the Client's Invenotry Data
		var _serverBuffer = obj_Server.serverBuffer;
		buffer_seek(_serverBuffer, buffer_seek_start, 0);
		buffer_write(_serverBuffer, buffer_u8, messages.inventoryData);
		with (obj_PlayerClient)
			network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		
		obj_GameManager.alarm[0] = SAVE_TIME;	//set the save game timer
	}

	//Save the Game Straight Away
	else
		obj_GameManager.alarm[0] = 1;	//set the save game timer
}

/// Function saving the world data to a given file.

function world_save(_file)
{
	//Convert the World Grid to an Array
	var _worldArray = block_grid_to_array(obj_WorldManager.worldGrid);
	
	//Get the Player Struct If the World File Already Exists
	var _playerStruct = noone;
	var _mainStruct = noone;
	if (file_exists(_file))
	{
		_mainStruct = json_parse(json_string_load(_file));
		_playerStruct = _mainStruct.playerStruct;
	}
	
	//Create a New mainStruct
	else
	{
		_mainStruct =
		{
			worldSeed : obj_WorldManager.worldSeed,
			worldWidth : obj_WorldManager.worldWidth,
			worldHeight: obj_WorldManager.worldHeight,
		
			playerStruct : noone,
			worldArray : noone,
			itemArray : noone
		};
		_playerStruct = {};
	}
	
	//Save the Players && Their Inventories to a Struct
	obj_PlayerLocal.selectedPosition = obj_Inventory.selectedPosition;
	with (obj_Player)
	{
		var _player = new PlayerObject(x, y, horizontalSpeed, verticalSpeed, playerSelectedPosition,
									   playerInventoryGrid, playerArmorGrid, playerToolGrid);
		variable_struct_set(_playerStruct, string(clientId), _player);
	}
	
	//Save the Items to an Array
	var _itemArray = array_create(0);
	with (obj_Item)
	{
		var _item = new ItemObject(x, y, horizontalSpeed, verticalSpeed, itemSlot);
		array_push(_itemArray, _item);
	}
	
	//Add the World Data to the Main Struct
	variable_struct_set(_mainStruct, "playerStruct", _playerStruct);
	variable_struct_set(_mainStruct, "worldArray", _worldArray);
	variable_struct_set(_mainStruct, "itemArray", _itemArray);
	
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
		
		var _playerStruct = _mainStruct.playerStruct;
		var _worldArray = _mainStruct.worldArray;
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
		
		var _clientId = obj_GameManager.clientId;	//get the local player's data
		var _player = variable_struct_get(_playerStruct, string(_clientId));
		var _x = _player.x;
		var _y = _player.y;
		var _horizontalSpeed = _player.horizontalSpeed;
		var _verticalSpeed = _player.verticalSpeed;
		
		var _localPlayer = instance_create_layer(_x, _y, "Players", obj_PlayerLocal);	//create the local player
		with (_localPlayer)
		{
			clientId = obj_GameManager.clientId;
			horizontalSpeed = _horizontalSpeed;
			verticalSpeed = _verticalSpeed;
		}
		
		//Get the Local Player's Inventory Grids && Replace Them With the Current Ones
		var _selectedPosition = _player.selectedPosition;	//get the local player's invenotry grids
		var _inventoryArray = _player.inventoryArray;
		var _armorArray = _player.armorArray;
		var _toolArray = _player.toolArray;
		
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
		
		obj_Inventory.selectedPosition = _selectedPosition;	//load the selectedPosition
		obj_Inventory.selectedSlot = position_slot_get(obj_Inventory.inventoryGrid, _selectedPosition);
		
		//Instantiate Loaded Items
		with (obj_Item) instance_destroy();	//destroy all existing items
		for (var _i = 0; _i < array_length(_itemArray); _i ++)
		{
			var _itemStruct = _itemArray[_i];
			var _x = _itemStruct.x;
			var _y = _itemStruct.y;
			var _horizontalSpeed = _itemStruct.horizontalSpeed;
			var _verticalSpeed = _itemStruct.verticalSpeed;
			var _itemId = _itemStruct.itemId;
			var _itemCount = _itemStruct.itemCount;
			
			var _item = instance_create_layer(_x, _y, "Items", obj_Item);
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
	var _worldSeed = irandom(65536);
	var _generationSeed = get_generation_seed(_worldSeed);
	var _worldWidth = 300;
	var _worldHeight = 100;
	
	with (obj_WorldManager)	//set the new world properties in the WorldManager
	{
		worldSeed = _worldSeed;
		generationSeed = _generationSeed;
		worldWidth = _worldWidth;
		worldHeight = _worldHeight;
		worldGrid = world_generate(_worldWidth, _worldHeight, _generationSeed, 20);
	}
	
	//Spawn the Player
	instance_create_layer(100, 50, "Players", obj_PlayerLocal);
	
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
	with (obj_ItemClient) instance_destroy();
	
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

/// Function for quitting to the main menu.

function world_close()
{
	//Turn Off Networking
	if (obj_GameManager.serverSide == true)
	{
		network_destroy(obj_Server.server);
		instance_destroy(obj_Server);
	}
	else if (obj_GameManager.serverSide == false)
	{
		network_destroy(obj_Client.client);
		instance_destroy(obj_Client);
	}
	obj_GameManager.networking = false;
	obj_GameManager.serverSide = noone;
	
	//Close the In-Game Menu
	with (obj_Menu)
	{
		ds_stack_clear(menuStateStack);
		menuState = noone;
		inGame = false;
	}
	
	//Clear the World
	world_clear();
	instance_deactivate_layer("WorldManagers");
	worldFile = noone;
}

/// Function for saving client's data to the world file.

function client_save(_playerClient)
{
	//Get the playerStruct
	var _file = obj_GameManager.worldFile;
	if (file_exists(_file))
	{
		var _mainStruct = json_parse(json_string_load(_file));
		var _playerStruct = _mainStruct.playerStruct;
	}
	else return;
	
	//Create Struct Representing the PlayerClient
	with (_playerClient)
	{
		var _player = new PlayerObject(x, y, horizontalSpeed, verticalSpeed, playerSelectedPosition,
									   playerInventoryGrid, playerArmorGrid, playerToolGrid);
		variable_struct_set(_playerStruct, string(_playerClient.clientId), _player);
	}
	
	//Save the mainStruct
	var _saveString = json_stringify(_mainStruct);
	json_string_save(_saveString, _file);
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
