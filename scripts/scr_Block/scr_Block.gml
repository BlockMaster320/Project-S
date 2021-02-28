/// Struct representing a block in the worldGrid.

function Block(_id) constructor
{
	id = _id;
	var _item = id_get_item(_id);
	sprite = _item.spriteBlock;
	
	switch (_item.category)
	{
		case itemCategory.station:
		{
			obj_Inventory.searchForStations = true;	//update the station list
			switch (_item.subCategory)
			{
				case itemSubCategory.storage:
				{
					var _storageWidth = _item.storageWidth;
					var _storageHeight = _item.storageHeight;
					storageArray = array_create(_storageWidth * _storageHeight, 0);
				}
				break;
			}
		}
		break;
	}
}

/// Function destroying Block Struct.

function block_destroy(_blockGridX, _blockGridY)
{
	//Get Block && Its Center Position
	var _selectedBlock = obj_WorldManager.worldGrid[# _blockGridX, _blockGridY];
	var _blockCenterX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5;
	var _blockCenterY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5;
	
	//Set the Dropped Item's Position
	var _dropX = _blockCenterX - sprite_get_width(spr_ItemMask) * 0.5;
	var _dropY = _blockCenterY - sprite_get_height(spr_ItemMask) * 0.5;
	
	//Drop the Item
	slot_drop(_selectedBlock.id, 1, _dropX, _dropY, 0, false);
	
	//Delete the Block From the World Grid && Send a Message to All Clients
	if (obj_GameManager.serverSide != false)	//destroy the local block if serverSide is true || noone (not client side)
	{
		//Send Message to All the Clients Directly
		if (obj_GameManager.networking)
		{
			var _serverBuffer = obj_Server.serverBuffer;	//send a message to destroy the block
			message_block_destroy(_serverBuffer, _blockGridX, _blockGridY);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		
		//Handle Special Cases
		var _blockItem = id_get_item(_selectedBlock.id);
		if (_blockItem.category == itemCategory.station)
		{
			switch (_blockItem.subCategory)
			{
				case itemSubCategory.storage:
				{
					//Drop All Slots of the Storage Station
					var _storageArray = _selectedBlock.storageArray;
					for (var _i = 0; _i < array_length(_storageArray); _i ++)
					{
						var _slot = _storageArray[_i];
						if (_slot!= 0)
							slot_drop(_slot.id, _slot.itemCount, _dropX, _dropY, 0, true);
					}
				}
				break;
			}
			obj_Inventory.searchForStations = true;
		}
		
		//Destroy the Local Block
		obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = 0;
	}
		
	//Send a Message to the Server
	else
	{
		var _clientBuffer = obj_Client.clientBuffer;	//send message to destroy the block
		var _clientSocket = obj_Client.client;
			
		message_block_destroy(_clientBuffer, _blockGridX, _blockGridY);
		network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
	}
}