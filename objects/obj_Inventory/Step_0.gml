//Get Player's Input
scr_Input();

//Get Player's Center Position
var _playerX = 0;
var _playerY = 0;
if (instance_exists(obj_PlayerLocal))
{
	_playerX = obj_PlayerLocal.x + obj_PlayerLocal.sprite_width * 0.5;
	_playerY = obj_PlayerLocal.y + obj_PlayerLocal.sprite_height * 0.5;
}

//ITEM INTERACTION//
//Item Collection
var _itemObject = (obj_GameManager.serverSide != false) ? obj_Item : obj_ItemClient;
for (var _i = 0; _i < instance_number(_itemObject); _i ++)	//loop throught all the items
{
	//Get the Item && Its Center Position
	var _item = instance_find(_itemObject, _i);
	var _itemX = _item.x + _item.sprite_width * 0.5;
	var _itemY = _item.y + _item.sprite_height * 0.5;
	
	//Start Item Collection
	if (point_distance(_playerX, _playerY, _itemX, _itemY) < approachRange)
	{
		//Get the Item's Slot
		var _itemSlot = _item.itemSlot;
		var _remainder = slotSet_add_slot_remainder(inventoryGrid, _itemSlot);
		
		//Start Collecting the Item
		if (ds_list_find_index(fullSlotsIdList, _itemSlot.id) == - 1)	//check if there's space for the item in the inventory
		{
			if (_remainder < _itemSlot.itemCount)	//check whether the inventory is full
			{
				//Set the Local Item to Be Collected && Send Message to All the Clients Directly
				if (obj_GameManager.serverSide != false)
				{
					if (!_item.collectItem && _item.collectCooldown <= 0)	//check whether the Item can be collected
					{
						//Divide the Item into 2 Items (If There's Not Enough Space For All the items)
						if (_remainder != 0)
						{
							//Update the Item's itemCount
							_itemSlot.itemCount -= _remainder;
							ds_list_add(fullSlotsIdList, _itemSlot.id);
							
							//Send Message to All Clients Directly
							var _objectId = noone;
							if (obj_GameManager.networking)
							{
								_objectId = obj_Server.objectIdCount ++;
								var _serverBuffer = obj_Server.serverBuffer;
							
								message_item_create(_serverBuffer, _objectId, _item.x, _item.y, _itemSlot.id, _remainder, 10);	//send message to create an Item
								with (obj_PlayerClient)
									network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
								
								message_item_change(_serverBuffer, _item.objectId, _itemSlot.itemCount);	//send message to udpate the collected Item's itemCount
								with (obj_PlayerClient)
									network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
							}
							
							//Create a Local Item
							var _newItem = instance_create_layer(_item.x, _item.y, "Items", obj_Item);	//create the part that's not going to be collected
							with (_newItem)
							{
								objectId = _objectId;
								itemSlot = new Slot(_itemSlot.id, _remainder);
								collectCooldown = 20;
							}
							if (obj_GameManager.networking)
								obj_Server.objectMap[? _objectId] = _newItem;
						}
						
						//Start Item Collection
						with (_item)
						{
							collectItem = true;
							approachObject = obj_PlayerLocal;
						}
					}
				}
				
				//Send Message to Collect the Item to the Server
				else
				{
					var _clientBuffer = obj_Client.clientBuffer;
					var _clientSocket = obj_Client.client;
					message_item_collect(_clientBuffer, _item.objectId, _remainder);
					network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
				}
			}
		}
	}
}

//Item Dropping
var _selectedSlot = selectedSlot;
if (keyItemDrop && _selectedSlot != 0)
{
	//Set Item's Drop Position
	var _dropX = _playerX - sprite_get_width(spr_ItemMask) * 0.5;
	var _dropY = _playerY - sprite_get_height(spr_ItemMask) * 0.5;
	
	//Drop the Item
	slot_drop(selectedSlot.id, selectedSlot.itemCount, _dropX, _dropY, 60, true);
	
	//Clear the Item's Slot
	position_slot_set(inventoryGrid, selectedPosition, 0);
}

//BLOCK INTERACTION//
//Get Block's World Grid Position
var _blockGridX = mouse_x div CELL_SIZE;
var _blockGridY = mouse_y div CELL_SIZE;
var _selectedBlock = obj_WorldManager.worldGrid[# _blockGridX, _blockGridY];

//Get Block's Center Position
var _blockCenterX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5;		
var _blockCenterY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5;
inRange = (point_distance(_playerX, _playerY, _blockCenterX, _blockCenterY) <= interactionRange);

//Block Mining
if (buttonLeft && inRange && _selectedBlock != 0 && !inventoryMenu)
{
	//Increase mineProgress
	mineProgress += (selectedSlot == 0) ? 1 : id_get_item(selectedSlot.id).mineForce;	//increase mine progress
	mineBlockEndurance = id_get_item(_selectedBlock.id).endurance;	//get the block's endurance
	
	//Mine the Block
	if (mineProgress >= mineBlockEndurance)	//mine the block
	{
		//Destroy the Block
		block_destroy(_blockGridX, _blockGridY);
		
		//Reset mineProgress
		mineProgress = 0;
	}
}

//Reset Mine Progress
if (buttonLeftReleased || (_blockGridX != previousBlockGridX || _blockGridY != previousBlockGridY))
	mineProgress = 0;

//Block Placing
if (buttonRightPressed && inRange && selectedSlot != 0 && _selectedBlock == 0 && !inventoryMenu)
{
	var _isOverlappingPlayer = check_block_collision(obj_PlayerLocal, selectedSlot.id, _blockGridX, _blockGridY)
							   || check_block_collision(obj_PlayerClient, selectedSlot.id, _blockGridX, _blockGridY);
	if (!_isOverlappingPlayer)
	{
		//Place the Block && Send a Message to All Clients
		if (obj_GameManager.serverSide != false)
		{
			//Send Message to All the Clients Directly
			if (obj_GameManager.networking)
			{
				var _serverBuffer = obj_Server.serverBuffer;
				message_block_create(_serverBuffer, _blockGridX, _blockGridY, selectedSlot.id);
				with (obj_PlayerClient)
					network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
			}
			
			//Create a Local Block
			obj_WorldManager.worldGrid[# _blockGridX, _blockGridY] = new Block(selectedSlot.id);
		}
		
		//Send a Message to Create the Block to the Server
		else
		{
			var _clientBuffer = obj_Client.clientBuffer;	//send message to create the block
			var _clientSocket = obj_Client.client;
			
			message_block_create(_clientBuffer, _blockGridX, _blockGridY, _selectedSlot.id);
			network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
			
		}
		
		//Subtract the Item from the Inventory
		selectedSlot.itemCount -= 1;
		if (selectedSlot.itemCount <= 0)
			position_slot_set(inventoryGrid, selectedPosition, 0);
	}
}

//Update Previous Block Grid Position
previousBlockGridX = _blockGridX;
previousBlockGridY = _blockGridY;


/*
show_debug_message("\nblockGridX: " + string(_blockGridX));
show_debug_message("blockGridY: " + string(_blockGridY));*/
//show_debug_message("selectedBlock: " + string(_selectedBlock));
