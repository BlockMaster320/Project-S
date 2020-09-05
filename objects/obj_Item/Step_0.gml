//Apply Gravity && Collision
if (!collectItem)
{
	gravity();
	collision();
}

//Decrease Collection Cooldown
collectCooldown -= 1;

//Stack Itself with Near Items of the Same ID
if (!collectItem)
{
	for (var _i = 0; _i < instance_number(obj_Item); _i ++)	//loop trought all the items
	{
		//Get the Item
		var _item = instance_find(obj_Item, _i);	//skip self
		if (_item == id)
			continue;
	
		//Get Own && Item's Center Position
		var _x = x + sprite_width * 0.5;
		var _y = y + sprite_height * 0.5;
		var _itemX = _item.x + _item.sprite_width * 0.5;
		var _itemY = _item.y + _item.sprite_height * 0.5;
		var _itemSlot = _item.itemSlot;
		
		//Add Its itemCount to a Near Item's itemCount
		if (point_distance(_x, _y, _itemX, _itemY) < 32 && !_item.collectItem && _itemSlot.id == itemSlot.id)
		{
			var _remainder = slot_add_items(_itemSlot, itemSlot.itemCount)
			itemSlot.itemCount = _remainder;
			if (_remainder == 0)
				instance_destroy();
		}
	}
}

//Approach the Player on Item Collection
/*
if (collectItem)
{
	var _x = x + sprite_width * 0.5;	//get aproach direction
	var _y = y + sprite_height * 0.5;
	var _playerX = obj_Player.x + obj_Player.sprite_width * 0.5;
	var _playerY = obj_Player.y + obj_Player.sprite_height * 0.5;
}*/
