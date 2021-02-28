///Struct representing an item slot in the inventory && stations.

function Slot(_id, _itemCount) constructor
{
	id = _id;
	sprite = id_get_item(_id).spriteItem;
	itemCount = _itemCount;
}

function slot_drop(_id, _itemCount, _dropX, _dropY, _collectCooldown, _scatter)
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
								_id, _itemCount, _collectCooldown);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		
		//Create a Local Item
		var _droppedItem = instance_create_layer(_itemDropX, _itemDropY, "Items", obj_Item);
		with (_droppedItem)	//set properties of the dropped item
		{
			collectCooldown = _collectCooldown;
			itemSlot = new Slot(_id, _itemCount);
			objectId = _objectId;
			
			horizontalSpeed = _horizontalSpeed;
			verticalSpeed = _verticalSpeed;
		}
		if (obj_GameManager.networking)
			obj_Server.objectMap[? _objectId] = _droppedItem;
	}
	
	//Send Message to the Server
	else
	{
		var _clientBuffer = obj_Client.clientBuffer;
		var _clientSocket = obj_Client.client;
		message_item_create(_clientBuffer, noone, _itemDropX, _itemDropY, _id, _itemCount, _collectCooldown);
		network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
	}
}
