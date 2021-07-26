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
							
								message_item_create(_serverBuffer, _objectId, _item.x, _item.y, _itemSlot, 10);	//send message to create an Item
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
								itemSlot = slot_copy(_itemSlot);
								itemSlot.itemCount = _remainder;
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
if (keyItemDrop && chosenSlot[keyModifier2] != 0)
{
	//Set Item's Drop Position
	var _dropX = _playerX - sprite_get_width(spr_ItemMask) * 0.5;
	var _dropY = _playerY - sprite_get_height(spr_ItemMask) * 0.5;
	
	//Drop the Item
	slot_drop(chosenSlot[keyModifier2], _dropX, _dropY, 60, true, true);
	
	//Clear the Item's Slot
	var _slotSet = (keyModifier2) ? toolGrid : inventoryGrid;
	position_slot_set(_slotSet, chosenPosition[keyModifier2], 0);
}

//BLOCK INTERACTION//
//Get the Block && Its World Position
var _blockGridX = floor(mouseX / CELL_SIZE);
var _blockGridY = floor(mouseY / CELL_SIZE);
var _selectedBlock = block_get(_blockGridX, _blockGridY, false);

//Get Block's Center Position
var _blockCenterX = _blockGridX * CELL_SIZE + CELL_SIZE * 0.5;		
var _blockCenterY = _blockGridY * CELL_SIZE + CELL_SIZE * 0.5;
inRange = (point_distance(_playerX, _playerY, _blockCenterX, _blockCenterY) <= interactionRange);

//Set the Slot Used for Mining && Placing
var _chosenSlotItem = [0, 0];	//get items of the chosen slots
if (chosenSlot[0] != 0) _chosenSlotItem[0] = id_get_item(chosenSlot[0].id);
if (chosenSlot[1] != 0) _chosenSlotItem[1] = id_get_item(chosenSlot[1].id);

var _mineWheel = 0;	//set which slot wheel should be used for mining && which for placing; 0 - primary, 1 - secondary
var _placeWheel = 0;
if (chosenSlot[0] == 0 || chosenSlot[1] == 0)
{
	if (chosenSlot[1] != 0)
	{
		_mineWheel = 1;
		_placeWheel = 1;
	}
}
else
{
	if (_chosenSlotItem[1].category == itemCategory.tool && _chosenSlotItem[0].category != itemCategory.tool)
		_mineWheel = 1;
	if (_chosenSlotItem[1].placeable && !_chosenSlotItem[0].placeable)
		_placeWheel = 1;
}

var _mineSlot = chosenSlot[_mineWheel];	//set which slot should be used for mining && which for placing
var _placeSlot = chosenSlot[_placeWheel];

//Block Mining
var _mineSlotItem = _chosenSlotItem[_mineWheel];
if (buttonLeft && inRange && _selectedBlock != 0 && !inventoryMenu)
{
	//Increase mineProgress
	var _mineForce = 1;
	if (_mineSlot != 0)	//get mineForce of the slot
	{
		if (_mineSlotItem.category == itemCategory.tool)
			_mineForce = 2 * _mineSlot.properties[property.power];
	}
	mineProgress += _mineForce;	//increase mineProgress by mineForce
	mineBlockPersistence = id_get_item(_selectedBlock.id).persistence;	//get the block's persistence
	
	//Mine the Block
	if (mineProgress >= mineBlockPersistence)	//mine the block
	{
		//Destroy the Block
		block_destroy(_blockGridX, _blockGridY);
		block_tile(_blockGridX, _blockGridY, true);
		
		if (_mineSlotItem != 0 && _mineSlotItem.category == itemCategory.tool)
		{
			_mineSlot.endurance -= 1 / (_mineSlot.properties[property.durability] + 1);
			if (_mineSlot.endurance == 0)
			{
				var _slotSet = (_mineWheel == 0) ? inventoryGrid : toolGrid;
				position_slot_set(_slotSet, chosenPosition[_mineWheel], 0);
			}
		}
		
		//Activate Nearby Items
		item_activate(_blockCenterX, _blockCenterY - CELL_SIZE * 0.5);
		
		//Reset mineProgress
		mineProgress = 0;
	}
}

//Reset Mine Progress
if (buttonLeftReleased || (_blockGridX != previousBlockGridX || _blockGridY != previousBlockGridY))
	mineProgress = 0;

//Block Placing
var _placeSlotItem = id_get_item(_placeSlot.id);
if (buttonRightPressed && inRange && _placeSlot != 0 && _selectedBlock == 0 && !inventoryMenu)
{
	if (_placeSlotItem.placeable)
	{
		var _isOverlappingPlayer = check_block_collision(obj_PlayerLocal, _placeSlot.id, _blockGridX, _blockGridY)
								   || check_block_collision(obj_PlayerClient, _placeSlot.id, _blockGridX, _blockGridY);
		if (!_isOverlappingPlayer)
		{
			//Place the Block && Send a Message to All Clients
			if (obj_GameManager.serverSide != false)
			{
				//Send Message to All the Clients Directly
				if (obj_GameManager.networking)
				{
					var _serverBuffer = obj_Server.serverBuffer;
					message_block_create(_serverBuffer, _blockGridX, _blockGridY, _placeSlot.id);
					with (obj_PlayerClient)
						network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
				}
			
				//Create a Local Block
				block_set(_blockGridX, _blockGridY, new Block(_placeSlot.id));
				block_tile(_blockGridX, _blockGridY, true);
				
				//Activate Nearby Items
				item_activate(_blockCenterX, _blockCenterY - CELL_SIZE * 0.5);
			}
		
			//Send a Message to Create the Block to the Server
			else
			{
				var _clientBuffer = obj_Client.clientBuffer;	//send message to create the block
				var _clientSocket = obj_Client.client;
			
				message_block_create(_clientBuffer, _blockGridX, _blockGridY, _placeSlot.id);
				network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
			
			}
		
			//Subtract the Item from the Inventory
			_placeSlot.itemCount -= 1;
			if (_placeSlot.itemCount <= 0)
			{
				var _slotSet = (_placeWheel == 0) ? inventoryGrid : toolGrid;
				position_slot_set(_slotSet, chosenPosition[_placeWheel], 0);
			}
		}
	}
}

//Update Previous Block Grid Position
previousBlockGridX = _blockGridX;
previousBlockGridY = _blockGridY;


/*
show_debug_message("\nblockGridX: " + string(_blockGridX));
show_debug_message("blockGridY: " + string(_blockGridY));*/
//show_debug_message("selectedBlock: " + string(_selectedBlock));
