/// Function processing a message sent by client to the server.

function message_receive_server(_socket, _buffer)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _message = buffer_read(_buffer, buffer_u8);
	var _playerClient = playerMap[? _socket];
	/*var _playerClientObjectId = _playerClient.objectId;*/
	
	switch (_message)
	{
		case messages.clientData:	//get client's data, send them to the other clients, create a local player && send the client entities && items data
		{
			//Get Client's ID && Name
			var _clientId = buffer_read(_buffer, buffer_u32);
			var _clientName = buffer_read(_buffer, buffer_string);
			show_debug_message(_clientName);
			
			//Load the Player Struct
			var _worldFile = obj_GameManager.worldFile;
			var _mainStruct = json_parse(json_string_load(_worldFile));
			var _playerStruct = _mainStruct.playerStruct;
			
			//Create a New Player || Get an Existing One From the World File
			var _player = noone;
			if (!variable_struct_exists(_playerStruct, _clientId))
			{
				//Create Blank Inventory Grids && Save Them to the Player
				var _inventoryGrid = ds_grid_create(obj_Inventory.inventoryWidth, obj_Inventory.inventoryHeight);
				var _armorGrid = ds_grid_create(obj_Inventory.armorWidth, obj_Inventory.armorHeight);
				var _toolGrid = ds_grid_create(obj_Inventory.toolWidth, obj_Inventory.toolHeight);
				_player = new PlayerObject(100, 100, 0, 0, 0,_inventoryGrid, _armorGrid, _toolGrid);
				
				//Destroy the Created Inventory Grids
				ds_grid_destroy(_inventoryGrid);
				ds_grid_destroy(_armorGrid);
				ds_grid_destroy(_toolGrid);
				
				//Save the Client's Player to the World File
				variable_struct_set(_playerStruct, _clientId, _player);
				var _saveString = json_stringify(_mainStruct);
				json_string_save(_saveString, _worldFile);
			}
			else
				_player = variable_struct_get(_playerStruct, _clientId);	//get an exisitng player
			
			//Create a New Object ID For the Player
			var _objectId = objectIdCount ++;
			
			//Send the Client's Data to the Client
			buffer_seek(serverBuffer, buffer_seek_start, 0);	//player data
			buffer_write(serverBuffer, buffer_u8, messages.clientData);
			buffer_write(serverBuffer, buffer_u16, _objectId);
			buffer_write(serverBuffer, buffer_u16, _player.x);
			buffer_write(serverBuffer, buffer_u16, _player.y);
			buffer_write(serverBuffer, buffer_u16, _player.horizontalSpeed);
			buffer_write(serverBuffer, buffer_u16, _player.verticalSpeed);
			
			buffer_write(serverBuffer, buffer_u8, json_stringify(_player.selectedPosition));	//inventory grids
			buffer_write(serverBuffer, buffer_string, json_stringify(_player.inventoryArray));
			buffer_write(serverBuffer, buffer_string, json_stringify(_player.armorArray));
			buffer_write(serverBuffer, buffer_string, json_stringify(_player.toolArray));
			
			network_send_packet(_socket, serverBuffer, buffer_tell(serverBuffer));
			
			//Send All the Players to the Client
			with (obj_Player)
			{
				message_player_create(other.serverBuffer, objectId, clientName, x, y);
				network_send_packet(_socket, other.serverBuffer, buffer_tell(other.serverBuffer));
			}
		
			//Send All the Items to the Client
			with (obj_Item)
			{
				message_item_create(other.serverBuffer, objectId, x, y, itemSlot.id, itemSlot.itemCount, 0);
				network_send_packet(_socket, other.serverBuffer, buffer_tell(other.serverBuffer));
			}
			
			//Create Client's Player on the Other Clients' Side
			message_player_create(serverBuffer, _objectId, _clientName, _player.x, _player.y);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Create Client's PlayerClient
			var _playerClient = instance_create_layer(_player.x, _player.y, "Players", obj_PlayerClient);
			with (_playerClient)
			{
				clientId = _clientId;
				clientName = _clientName;
				clientSocket = _socket;
				objectId = _objectId;
			}
			
			//Add the Player to the playerMap && objectMap
			playerMap[? _socket] = _playerClient;
			objectMap[? _objectId] = _playerClient;
		}
		break;
		
		case messages.clientDisconnect:	//disconnect a client from the server
		{
			//Disconnect the Client from the Server
			network_destroy(_socket);
			
			//Save Client's Data
			client_save(_playerClient);
			
			//Remove the playerClient from the Other Clients
			message_destroy(serverBuffer, _playerClient.objectId);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Destroy Client's Local Player
			ds_map_delete(playerMap, _socket);
			ds_map_delete(objectMap, _playerClient.clientId);
			instance_destroy(_playerClient);
		}
		break;
		
		case messages.inventoryData:	//set playerClients's inventory strings to the received ones
		{
			//Get the Inventory Data
			var _selectedPosition = buffer_read(_buffer, buffer_u8);
			var _inventoryString = buffer_read(_buffer, buffer_string);
			var _armorString = buffer_read(_buffer, buffer_string);
			var _toolString = buffer_read(_buffer, buffer_string);
			
			//Convert the Inventory Strings to Grids
			ds_grid_destroy(_playerClient.playerInventoryGrid);	//inventory grid
			var _inventoryWidth = obj_Inventory.inventoryWidth;
			var _inventoryHeight = obj_Inventory.inventoryHeight;
			var _inventoryGrid = slot_array_to_grid(json_parse(_inventoryString), _inventoryWidth, _inventoryHeight);
			
			ds_grid_destroy(_playerClient.playerArmorGrid);	//armor grid
			var _armorWidth = obj_Inventory.armorWidth;
			var _armorHeight = obj_Inventory.armorHeight;
			var _armorGrid = slot_array_to_grid(json_parse(_armorString), _armorWidth, _armorHeight);
			
			ds_grid_destroy(_playerClient.playerToolGrid);	//tool grid
			var _toolWidth = obj_Inventory.toolWidth;
			var _toolHeight = obj_Inventory.toolHeight;
			var _toolGrid = slot_array_to_grid(json_parse(_toolString), _toolWidth, _toolHeight);
			
			//Set the Invenory Grids
			with (_playerClient)
			{
				playerSelectedPosition = _selectedPosition;
				playerInventoryGrid = _inventoryGrid;
				playerArmorGrid = _armorGrid;
				playerToolGrid = _toolGrid;
			}
		}
		break;
		
		case messages.blockCreate:	//create a block in the worldGrid
		{
			//Get the Block's Data
			var _blockGridX = buffer_read(_buffer, buffer_u16);
			var _blockGridY = buffer_read(_buffer, buffer_u16);
			var _itemId = buffer_read(_buffer, buffer_u16);
			
			//Check If There's no Block in the Position
			var _block = obj_WorldManager.worldGrid[# _blockGridX, _blockGridY];
			if (_block != 0) break;
			
			//Send a Message to Create the Block
			message_block_create(serverBuffer, _blockGridX, _blockGridY, _itemId);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Create a Local Block
			obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = new Block(_itemId);
		}
		break;
		
		case messages.blockDestroy:	//destroy a block && send a message to destroy it to all clients
		{
			//Get the Block's Position in the worldGrid
			var _blockGridX = buffer_read(_buffer, buffer_u16);
			var _blockGridY = buffer_read(_buffer, buffer_u16);
			
			//Get the Block
			var _block = obj_WorldManager.worldGrid[# _blockGridX, _blockGridY];
			if (_block == 0) break;
			
			//Set the Dropped Item's Position
			var _objectId = objectIdCount ++;	//send message to create an Item object
			var _blockCenterX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5
			var _blockCenterY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5
			var _itemDropX = _blockCenterX - sprite_get_width(spr_ItemMask) * 0.5;
			var _itemDropY = _blockCenterY - sprite_get_height(spr_ItemMask) * 0.5;
			
			//Send a Message to Destroy the Block
			message_block_destroy(serverBuffer, _blockGridX, _blockGridY);
			with (obj_PlayerClient)
					network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Send a Message to Create an Item Object
			message_item_create(serverBuffer, _objectId, _itemDropX, _itemDropY, _block.id, 1, 0);
			with (obj_PlayerClient)
					network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Create a Local Item
			var _droppedItem = instance_create_layer(_itemDropX, _itemDropY, "Items", obj_Item);
			with (_droppedItem)
			{
				objectId = _objectId;
				itemSlot = new Slot(_block.id, 1);
				stackCooldown = 10;
			}
			objectMap[? _objectId] = _droppedItem;
			
			//Destroy the Local Block
			obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = 0;
		}
		break;
		
		case messages.itemCreate:	//create an Item dropped by a client
		{
			//Get the Items's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			var _itemId = buffer_read(_buffer, buffer_u16);
			var _itemCount = buffer_read(_buffer, buffer_u8);
			var _collectCooldown = buffer_read(_buffer, buffer_u8);
			_objectId = objectIdCount ++;
			
			//Send a Message to Create the Item to All Clients
			message_item_create(serverBuffer, _objectId, _x, _y, _itemId, _itemCount, _collectCooldown);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
			//Create a Local Item && Add It to the objectMap
			var _item = instance_create_layer(_x, _y, "Items", obj_Item);
			with (_item)
			{
				objectId = _objectId;
				itemSlot = new Slot(_itemId, _itemCount);
				collectCooldown = _collectCooldown;
			}
			objectMap[? _objectId] = _item;
		}
		break;
		
		case messages.itemCollect:	//check wheter an Item can be collected && start its collection
		{
			//Get the Item's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _remainder = buffer_read(_buffer, buffer_u8);
			var _item = objectMap[? _objectId];
			
			//Check Whether the Item Exists
			if (_item == undefined) break;
			if (!instance_exists(_item)) break;
			
			
			//Start Collecting the Item
			if (!_item.collectItem && _item.collectCooldown <= 0)	//check whether the inventory is full
			{
				//Divide the Item into 2 Items (If There's Not Enough Space For All the items)
				if (_remainder != 0)
				{
					//Update the Item's itemCount
					var _itemSlot = _item.itemSlot;
					_itemSlot.itemCount -= _remainder;
					
					//Send a Message to Add the Item's ID to fullSlotsIdList of the Client
					buffer_seek(serverBuffer, buffer_seek_start, 0);
					buffer_write(serverBuffer, buffer_u8, messages.itemCollect);
					buffer_write(serverBuffer, buffer_u16, _itemSlot.id);
					network_send_packet(_socket, serverBuffer, buffer_tell(serverBuffer));
					
					//Send Messages to all Clients
					var _objectIdNew = objectIdCount ++;	//send message to create an Item
					message_item_create(serverBuffer, _objectIdNew, _item.x, _item.y, _itemSlot.id, _remainder, 10);
					with (obj_PlayerClient)
						network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
					
					message_item_change(serverBuffer, _objectId, _itemSlot.itemCount);	//send message to udpate the collected Item's itemCount
					with (obj_PlayerClient)
						network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
					
					//Create a Local Item
					var _newItem = instance_create_layer(_item.x, _item.y, "Items", obj_Item);	//create the part that's not going to be collected
					with (_newItem)
					{
						objectId = _objectIdNew;
						itemSlot = new Slot(_itemSlot.id, _remainder);
						collectCooldown = 20;
					}
					objectMap[? _objectIdNew] = _newItem;
				}
				
				//Start Item Collection
				with (_item)
				{
					collectItem = true;
					approachObject = _playerClient;
				}
			}
		}
		break;
		
		case messages.position:	//change position of an object (it's always player's positon at the moment)
		{
			//Get the Object's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			var _object = objectMap[? _objectId];
			
			//Check if the Object Exists
			if (_object == undefined) break;
			
			//Set the Object's Position Interpolation Variables
			_object.xTarget = _x;
			_object.yTarget = _y;
			_object.xOrigin = _object.x;
			_object.yOrigin = _object.y;
			_object.moveTime = 0;
			
			//Send a Message to all Clients
			message_position(serverBuffer, _objectId, _x, _y);
			with (obj_PlayerClient)
			{
				if (clientSocket != _socket)
					network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			}
		}
		break;
	}
}

/// Function processing a message sent by the server to client.

function message_receive_client(_socket, _buffer)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _message = buffer_read(_buffer, buffer_u8);
	
	switch(_message)
	{
		case messages.worldData:	//receive world data && send back the client's data
		{
			//Prepare the Game for a World to Be Loaded
			world_clear();
			instance_activate_layer("WorldManagers");
			instance_create_layer(100, 100, "Players", obj_PlayerLocal);
			
			//Close the Main Menu
			with (obj_Menu)
			{
				ds_stack_clear(menuStateStack);
				menuState = noone;
				inGame = true;
			}
			
			//Get the World Data
			var _worldSeed = buffer_read(_buffer, buffer_u16);
			var _worldWidth = buffer_read(_buffer, buffer_u16);
			var _worldHeight = buffer_read(_buffer, buffer_u16);
			var _worldString = buffer_read(_buffer, buffer_string);
			
			var _worldArray = json_parse(_worldString);
			var _worldGrid = block_array_to_grid(_worldArray, _worldWidth, _worldHeight);
			
			//Set the World Data in the WorldManager
			with (obj_WorldManager)
			{
				worldSeed = _worldSeed;
				generationSeed = get_generation_seed(_worldSeed);
				worldWidth = _worldWidth;
				worldHeight = _worldHeight;
				worldGrid = _worldGrid;
			}
			
			//Send the Client Data to the Server
			var _clientName = obj_Menu.textFieldArray[0];
			buffer_seek(clientBuffer, buffer_seek_start, 0);
			buffer_write(clientBuffer, buffer_u8, messages.clientData);
			buffer_write(clientBuffer, buffer_u32, obj_GameManager.clientId);
			buffer_write(clientBuffer, buffer_string, _clientName);
			
			network_send_packet(_socket, clientBuffer, buffer_tell(clientBuffer));
		}
		break;
		
		case messages.clientData:	//receive the client's data && world's entities
		{
			//Get the Client's Data
			var _objectId = buffer_read(_buffer, buffer_u16);	//player data
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			var _horizontalSpeed = buffer_read(_buffer, buffer_u16);
			var _verticalSpeed = buffer_read(_buffer, buffer_u16);
			
			var _selectedPosition = buffer_read(_buffer, buffer_u8);	//inventory grids
			var _inventoryArray = json_parse(buffer_read(_buffer, buffer_string));
			var _armorArray = json_parse(buffer_read(_buffer, buffer_string));
			var _toolArray = json_parse(buffer_read(_buffer, buffer_string));
			
			//Set the Player's Data to the Recieved Data
			with (obj_PlayerLocal)
			{
				objectId = _objectId;
				x = _x;
				y = _y;
				horizontalSpeed = _horizontalSpeed;
				verticalSpeed = _verticalSpeed;
			}
			objectMap[? _objectId] = obj_PlayerLocal;
			
			//Replace th Current Inventory Grids With the Recieved Ones
			ds_grid_destroy(obj_Inventory.inventoryGrid);	//replace the inventory grid
			var _inventoryWidth = obj_Inventory.inventoryWidth;
			var _inventoryHeight = obj_Inventory.inventoryHeight;
			obj_Inventory.inventoryGrid = slot_array_to_grid(_inventoryArray, _inventoryWidth, _inventoryHeight);
			
			ds_grid_destroy(obj_Inventory.armorGrid);	//replace the armor grid
			var _armorWidth = obj_Inventory.armorWidth;
			var _armorHeight = obj_Inventory.armorHeight;
			obj_Inventory.armorGrid = slot_array_to_grid(_armorArray, _armorWidth, _armorHeight);
		
			ds_grid_destroy(obj_Inventory.toolGrid);	//replace the tool grid
			var _toolWidth = obj_Inventory.toolWidth;
			var _toolHeight = obj_Inventory.toolHeight;
			obj_Inventory.toolGrid = slot_array_to_grid(_toolArray, _toolWidth, _toolHeight);
			
			obj_Inventory.selectedPosition = _selectedPosition;	//replace the selectedPosition
			obj_Inventory.selectedSlot = position_slot_get(obj_Inventory.inventoryGrid, _selectedPosition);
		}
		break;
		
		case messages.clientDisconnect:	//disconnect the client from the server
		{
			show_debug_message("yeaazz");
			//Quit to Main Menu
			world_close();
		}
		break;
		
		case messages.inventoryData:	//send local inventory grids to the server
		{
			//Convert the Inventory Grids to Strings
			var _selectedPosition = obj_Inventory.selectedPosition;
			var _inventoryString = json_stringify(slot_grid_to_array(obj_Inventory.inventoryGrid));
			var _armorString = json_stringify(slot_grid_to_array(obj_Inventory.armorGrid));
			var _toolString = json_stringify(slot_grid_to_array(obj_Inventory.toolGrid));
			
			//Send the Inventory Grids to the Server
			var _clientBuffer = obj_Client.clientBuffer;
			var _clientSocket = obj_Client.client;
			message_inventoryData(_clientBuffer, _selectedPosition, _inventoryString,
								  _armorString, _toolString);
			network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
		}
		break;
		
		case messages.playerCreate:	//create a new PlayerClient
		{
			//Get the Player's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _clientName = buffer_read(_buffer, buffer_string);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			
			//Create the PlayerClient Instance && Save Its ID to the Object Map
			var _playerClient = instance_create_layer(_x, _y, "Players", obj_PlayerClient);
			with (_playerClient)
			{
				objectId = _objectId;
				clientName = _clientName;
			}
			objectMap[? _objectId] = _playerClient;
		}
		break;
		
		case messages.blockCreate:	//create a block in the worldGrid
		{
			//Get the Block's Data
			var _blockGridX = buffer_read(_buffer, buffer_u16);
			var _blockGridY = buffer_read(_buffer, buffer_u16);
			var _itemId = buffer_read(_buffer, buffer_u16);
			
			//Add the Block to the worldGrid
			obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = new Block(_itemId);
		}
		break;
		
		case messages.blockDestroy:	//destroy a block in the worldGrid
		{
			//Get the Block's Position in the worldGrid
			var _blockGridX = buffer_read(_buffer, buffer_u16);
			var _blockGridY = buffer_read(_buffer, buffer_u16);
			
			//Destroy the Block
			obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = 0;
		}
		break;
		
		case messages.itemCreate:	//create a new ItemClient
		{
			show_debug_message("itemCreate");
			//Get the Items's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			var _itemId = buffer_read(_buffer, buffer_u16);
			var _itemCount = buffer_read(_buffer, buffer_u8);
			var _collectCooldown = buffer_read(_buffer, buffer_u8);
			
			//Create an ItemClient Instance && Save It to the objectMap
			var _itemClient = instance_create_layer(_x, _y, "Items", obj_ItemClient);
			with (_itemClient)
			{
				objectId = _objectId;
				collectCooldown = _collectCooldown;
				itemSlot = new Slot(_itemId, _itemCount);
			}
			objectMap[? _objectId] = _itemClient;
		}
		break;
		
		case messages.itemChange:	//change Item's properties
		{
			//Get Item's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _itemCount = buffer_read(_buffer, buffer_u8);
			var _itemClient = objectMap[? _objectId];
			
			//Set Item's Properties
			var _itemSlot = _itemClient.itemSlot;
			_itemSlot.itemCount = _itemCount;
		}
		break;
		
		case messages.itemCollect:	//add collected Item's ID to the fullSlotsIdList
		{
			var _itemId = buffer_read(_buffer, buffer_u16);
			ds_list_add(obj_Inventory.fullSlotsIdList, _itemId);
		}
		break;
		
		case messages.itemGive:	//add an Item to the inventory
		{
			//Get the Item's Data
			var _itemId = buffer_read(_buffer, buffer_u16);
			var _itemCount = buffer_read(_buffer, buffer_u8);
			
			//Remove the Item's ID From the fullSlotsIdList (When the Item Has Been Collected)
			var _fullSlotsIdList = obj_Inventory.fullSlotsIdList;
			var _idPosition = ds_list_find_index(_fullSlotsIdList, _itemId);	//delete the item's ID from the fullSlotsIdList
			if (_idPosition != - 1)
				ds_list_delete(_fullSlotsIdList, _idPosition);
			
			//Add the Item to the Inventory
			var _itemSlot = new Slot(_itemId, _itemCount);
			item_collect(obj_Inventory.inventoryGrid, _itemSlot);	//add item to the inventory
		}
		break;
		
		case messages.destroy:	//destroy an object
		{
			//Get the Object's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _object = objectMap[? _objectId];
			
			//Destroy the Object
			ds_map_delete(objectMap, _objectId);
			instance_destroy(_object);
		}
		break;
		
		case messages.position:	//change position of an object
		{
			//Get the Object's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			var _object = objectMap[? _objectId];
			
			//Check if the Object Exists
			if (_object == undefined) break;
			
			//Set the Object's Position Interpolation Variables
			_object.xTarget = _x;
			_object.yTarget = _y;
			_object.xOrigin = _object.x;
			_object.yOrigin = _object.y;
			_object.moveTime = 0;
		}
		break;
	}
}
