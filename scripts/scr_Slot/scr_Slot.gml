/// Struct representing an item slot in the inventory && stations.
function Slot(_id, _itemCount, _attributes) constructor
{
	id = _id;
	var _slotItem = id_get_item(_id);
	sprite = _slotItem.spriteItem;
	itemCount = _itemCount;
	
	switch (_slotItem.category)
	{
		case itemCategory.tool:
		{
			if (_attributes != noone)
				properties = _attributes[0];
			else
				properties = _slotItem.properties;
			endurance = 100;
		}
		break;
		
		case itemCategory.material:
		{
			if (_attributes != noone)
				properties = _attributes[0];
			else
				properties = _slotItem.properties;
		}
	}
}

/// Function creating a copy of the given slot.
function slot_copy(_slot)
{
	var _newSlot = new Slot(_slot.id, _slot.itemCount, noone);
	var _slotItem = id_get_item(_slot.id);
	
	switch (_slotItem.category)
	{
		case itemCategory.tool:
		{
			_newSlot.properties = _slot.properties;
			_newSlot.endurance = _slot.endurance;
		}
		break;
		
		case itemCategory.material:
		{
			_newSlot.properties = _slot.properties;
		}
		break;
	}
	
	//Return Copy of the Slot
	return _newSlot;
}


//Function dropping a slot as an Item.
function slot_drop(_slot, _dropX, _dropY, _collectCooldown, _scatter, _sendClientMessage)
{
	//Set Item Drop Properties
	var _itemDropX = _dropX;
	var _itemDropY = _dropY;
	if (_scatter)
	{
		_itemDropX += random(2) * choose(- 1, 1);
		_itemDropY += random(2) * choose(- 1, 1);
	}
	var _dropVelocity = random_range(1.5, 2);
	var _dropDirection = random_range(0, 180);
	var _horizontalSpeed = lengthdir_x(_dropVelocity, _dropDirection);
	var _verticalSpeed = lengthdir_y(_dropVelocity, _dropDirection);
	
	//Drop the Item && Send a Message to All Clients
	if (obj_GameManager.serverSide != false)
	{
		//Send Message to All the Clients Directly
		var _objectId = noone;
		if (obj_GameManager.networking)
		{
			_objectId = obj_Server.objectIdCount ++;	//send a message to create an Item
			var _serverBuffer = obj_Server.serverBuffer;
			message_item_create(_serverBuffer, _objectId, _itemDropX, _itemDropY,
								_slot, _collectCooldown);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		
		//Create a Local Item
		var _droppedItem = instance_create_layer(_itemDropX, _itemDropY, "Items", obj_Item);
		with (_droppedItem)	//set properties of the dropped item
		{
			collectCooldown = _collectCooldown;
			itemSlot = _slot;
			objectId = _objectId;
			
			horizontalSpeed = _horizontalSpeed;
			verticalSpeed = _verticalSpeed;
		}
		if (obj_GameManager.networking)
			obj_Server.objectMap[? _objectId] = _droppedItem;
	}
	
	//Send Message to the Server
	else if (_sendClientMessage)
	{
		var _clientBuffer = obj_Client.clientBuffer;
		var _clientSocket = obj_Client.client;
		message_item_create(_clientBuffer, noone, _itemDropX, _itemDropY, _slot, _collectCooldown);
		network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
	}
}
