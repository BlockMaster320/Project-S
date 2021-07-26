//World Interaction
if (active && !collectItem)
{
	//Apply Movement && Collision
	movement(false, false);
	gravity();
	collision();
	
	if (touchingBlock[3] == true && verticalSpeed == 0)
	{
		active = false;
	}
	
	//Push the Item Out of a Block
	if (check_collision(id))
	{
		//Get Item's Corner Positions
		var _gridLeftX = floor(x / CELL_SIZE);
		var _gridRightX = floor((x + sprite_get_width(spr_ItemMask) * 0.5) / CELL_SIZE);
		var _gridTopY = floor(y / CELL_SIZE);
		var _gridBottomY = floor((y + sprite_get_height(spr_ItemMask) * 0.5) / CELL_SIZE);
	
		//Loop Through Near Horizontal && Vertical Bllocks
		for (var _i = 0; _i < 3; _i ++)
		{
			//Check Blocks on the Left Side
			var _xLeftBlock1 = block_get(_gridLeftX - _i, _gridTopY);	//get the block
			var _xLeftBlock2 = block_get(_gridLeftX - _i, _gridBottomY);
		
			if (_xLeftBlock1 == 0 || _xLeftBlock2 == 0)	//check if the block is empty
			{
				while (check_collision(id)) x -= 1;
				break;
			}
		
			//Check Blocks on the Right Side
			var _xRightBlock1 = block_get(_gridRightX + _i, _gridTopY);	//get the block
			var _xRightBlock2 = block_get(_gridRightX + _i, _gridBottomY);
		
			if (_xRightBlock1 == 0 || _xRightBlock2 == 0)	//check if the block is empty
			{
				while (check_collision(id)) x += 1;
				break;
			}
		
			//Check Blocks Above the Item
			var _yTopBlock1 = block_get(_gridLeftX, _gridTopY - _i);	//get the block
			var _yTopBlock2 = block_get(_gridRightX, _gridTopY - _i);
		
			if (_yTopBlock1 == 0 || _yTopBlock2 == 0)	//check if the block is empty
			{
				while (check_collision(id)) y -= 1;
				break;
			}
		
			//Check Blocks Below the Item
			var _yBottomBlock1 = block_get(_gridLeftX, _gridBottomY + _i);	//get the block
			var _yBottomBlock2 = block_get(_gridRightX, _gridBottomY + _i);
		
			if (_yBottomBlock1 == 0 || _yBottomBlock2 == 0)	//check if the block is empty
			{
				while (check_collision(id)) y += 1;
				break;
			}
		}
		if (check_collision(id)) y -= CELL_SIZE;	//push the block up if there's no free space in the other directions
	}
}

//Approach a Player Collecting the Item
if (collectItem)
{
	//Move the Item Towards the Player
	if (approachSpeed < maxApproachSpeed)
		approachSpeed += approachAccel;
	approachSpeed = clamp(approachSpeed, 0, maxApproachSpeed);
	
	var _direction = point_direction(x, y, approachObject.x, approachObject.y);
	x += lengthdir_x(approachSpeed, _direction);
	y += lengthdir_y(approachSpeed, _direction);
		
	//Collect the Item
	if (point_distance(approachObject.x, approachObject.y, x, y) <= collectRange)
	{
		var _objectIndex = approachObject.object_index;
		if (_objectIndex == obj_PlayerLocal)
		{
			var _fullSlotsIdList = obj_Inventory.fullSlotsIdList;
			var _idPosition = ds_list_find_index(_fullSlotsIdList, itemSlot.id);	//delete the item's ID from the fullSlotsIdList
			if (_idPosition != - 1)
				ds_list_delete(_fullSlotsIdList, _idPosition);
				
			slotSet_add_slot(obj_Inventory.inventoryGrid, itemSlot, noone);	//add item to the inventory
		}
		
		else if (_objectIndex == obj_PlayerClient)
		{
			var _serverBuffer = obj_Server.serverBuffer;
			message_item_give(_serverBuffer, itemSlot);
			network_send_packet(approachObject.clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		
		if (obj_GameManager.networking)
		{
			var _serverBuffer = obj_Server.serverBuffer;
			message_destroy(_serverBuffer, objectId);
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		instance_destroy();
	}
}

//Stack Itself with Near Items of the Same ID
if (active && !collectItem && stackCooldown <= 0)
{
	for (var _i = 0; _i < instance_number(obj_Item); _i ++)	//loop trought all the items
	{
		//Get the Item
		var _item = instance_find(obj_Item, _i);
		if (_item == id)	//skip self
			continue;
		
		//Stack the Items
		if (!_item.collectItem && _item.stackCooldown <= 0)
		{
			//Get Own && Item's Center Position
			var _x = x + sprite_width * 0.5;
			var _y = y + sprite_height * 0.5;
			var _itemX = _item.x + _item.sprite_width * 0.5;
			var _itemY = _item.y + _item.sprite_height * 0.5;
			var _itemSlot = _item.itemSlot;
		
			//Add Its itemCount to a Near Item's itemCount
			if (point_distance(_x, _y, _itemX + _item.horizontalSpeed, _itemY + _item.verticalSpeed) < stackRange	//other item's speed changes after this item's check,
				&& _itemSlot.id == itemSlot.id && _itemSlot.itemCount != id_get_item(_itemSlot.id).itemLimit)	//so it has to be added to its current position
			{
				//Update This Item's itemCount
				var _remainder = slot_add_items(itemSlot, _itemSlot.itemCount)
				if (obj_GameManager.networking)
				{
					var _serverBuffer = obj_Server.serverBuffer;
					message_item_change(_serverBuffer, objectId, itemSlot.itemCount);
					with (obj_PlayerClient)
						network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
				}
				
				//Destroy the Other Item If the Remainder Is 0
				if (_remainder == 0)
				{
					if (obj_GameManager.networking)
					{
						var _serverBuffer = obj_Server.serverBuffer;
						message_destroy(_serverBuffer, _item.objectId);
						with (obj_PlayerClient)
							network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
					}
					instance_destroy(_item);
				}
				
				//Update the Other Item's itemCount
				else
				{
					if (obj_GameManager.networking)
					{
						var _serverBuffer = obj_Server.serverBuffer;
						message_item_change(_serverBuffer, _item.objectId, _remainder);
						with (obj_PlayerClient)
							network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
					}
					_itemSlot.itemCount = _remainder;
				}
			}
		}
	}
}

//Decrease Collection Cooldown && Stack Cooldown
collectCooldown -= 1;
stackCooldown -= 1;
