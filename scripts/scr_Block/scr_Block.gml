/// Struct representing a block in the world.
function Block(_id) constructor
{
	id = _id;
	var _item = id_get_item(_id);
	sprite = _item.spriteBlock;
	tile = 15;
	
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
	var _selectedBlock = block_get(_blockGridX, _blockGridY);
	var _blockCenterX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5;
	var _blockCenterY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5;
	
	//Set the Dropped Item's Position
	var _dropX = _blockCenterX - sprite_get_width(spr_ItemMask) * 0.5;
	var _dropY = _blockCenterY - sprite_get_height(spr_ItemMask) * 0.5;
	
	//Drop the Item
	slot_drop(new Slot(_selectedBlock.id, 1, noone), _dropX, _dropY, 0, false, false);
	
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
							slot_drop(_slot, _dropX, _dropY, 0, true, true);
					}
				}
				break;
			}
			obj_Inventory.searchForStations = true;
		}
		
		//Destroy the Local Block
		block_set(_blockGridX, _blockGridY, 0);
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

/// Function for tiling a bloc according to the adjacent blocks.
/// _tileAdjacentBlocks - the adjacent blocks are going to be tiled as well
function block_tile(_blockX, _blockY, _tileAdjacentBlocks)
{
	//Get the Block
	var _tile = 0;
	var _block = block_get(_blockX, _blockY, false);
	
	//Get the Adjacent Blocks
	var _blockTop = block_get(_blockX, _blockY - 1, false);
	var _blockRight = block_get(_blockX + 1, _blockY, false);
	var _blockBottom = block_get(_blockX, _blockY + 1, false);
	var _blockLeft = block_get(_blockX - 1, _blockY, false);
	
	//Tile the Adjacent Blocks
	if (_tileAdjacentBlocks)
	{
		block_tile(_blockX, _blockY - 1, false);
		block_tile(_blockX + 1, _blockY, false);
		block_tile(_blockX, _blockY + 1, false);	
		block_tile(_blockX - 1, _blockY, false);
	}
	
	//Return the Function If the Block Cannot Be Tiled
	if (_block == 0 || _block == undefined || id_get_item(_block.id).tileable == false)
		return;
	
	//Find Out Which Sides are Occupied by the Adjacent Blocks
	_tile = _tile | 8 * (_blockTop != 0 && _blockTop != undefined && id_get_item(_blockTop.id).tileable == true);
	_tile = _tile | 4 * (_blockRight != 0 && _blockRight != undefined && id_get_item(_blockRight.id).tileable == true);
	_tile = _tile | 2 * (_blockBottom != 0 && _blockBottom != undefined && id_get_item(_blockBottom.id).tileable == true);
	_tile = _tile | 1 * (_blockLeft != 0 && _blockLeft != undefined && id_get_item(_blockLeft.id).tileable == true);
	
	//Set the Index of the Tile
	_block.tile = _tile;
}

/// Function activating items nearby the given position.
function item_activate(_x, _y)
{
	//Get Nearby Items
	var _nearbyItems = ds_list_create();
	var _itemNumber = collision_circle_list(_x, _y, CELL_SIZE, obj_Item, false, true, _nearbyItems, false);
	
	//Activate the Items
	for (var _i = 0; _i < _itemNumber; _i ++)
	{
		var _item = _nearbyItems[| _i];
		_item.active = true;
	}
}
