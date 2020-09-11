//Apply Gravity && Collision
if (!collectItem)
{
	gravity();
	collision();
}

//Push the Item Out of a Block
if (check_collision(id) && !collectItem)
{
	//Get Item's Corner Positions
	var _gridLeftX = x div CELL_SIZE;
	var _gridRightX = (x + sprite_get_width(spr_ItemMask) * 0.5) div CELL_SIZE;
	var _gridTopY = y div CELL_SIZE;
	var _gridBottomY = (y + sprite_get_height(spr_ItemMask) * 0.5) div CELL_SIZE;
	
	//Get the World Grid
	var _worldGrid = obj_WorldManager.worldGrid;
	
	//Loop Through Near Horizontal && Vertical Bllocks
	for (var _i = 0; _i < 3; _i ++)
	{
		//Check Blocks on the Left Side
		var _gridLeftXClamped = clamp(_gridLeftX - _i, 0, ds_grid_width(_worldGrid) - 1);	//get the block
		var _xLeftBlock1 = _worldGrid[# _gridLeftXClamped, _gridTopY];
		var _xLeftBlock2 = _worldGrid[# _gridLeftXClamped, _gridBottomY];
		
		if (_xLeftBlock1 == 0 || _xLeftBlock2 == 0)	//check if the block is empty
		{
			//show_debug_message("left");
			while (check_collision(id)) x -= 1;
			break;
		}
		
		//Check Blocks on the Right Side
		var _gridRightXClamped = clamp(_gridRightX + _i, 0, ds_grid_width(_worldGrid) - 1);	//get the block
		var _xRightBlock1 = _worldGrid[# _gridRightXClamped, _gridTopY];
		var _xRightBlock2 = _worldGrid[# _gridRightXClamped, _gridBottomY];
		
		if (_xRightBlock1 == 0 || _xRightBlock2 == 0)	//check if the block is empty
		{
			//show_debug_message("right");
			while (check_collision(id)) x += 1;
			break;
		}
		
		//Check Blocks Above the Item
		var _gridTopYClamped = clamp(_gridTopY - _i, 0, ds_grid_height(_worldGrid) - 1);	//get the block
		var _yTopBlock1 = _worldGrid[# _gridLeftX, _gridTopYClamped];
		var _yTopBlock2 = _worldGrid[# _gridRightX, _gridTopYClamped];
		
		if (_yTopBlock1 == 0 || _yTopBlock2 == 0)	//check if the block is empty
		{
			//show_debug_message("top");
			while (check_collision(id)) y -= 1;
			break;
		}
		
		//Check Blocks Below the Item
		var _gridBottomYClamped = clamp(_gridBottomY + _i, 0, ds_grid_height(_worldGrid) - 1);	//get the block
		var _yBottomBlock1 = _worldGrid[# _gridLeftX, _gridBottomYClamped];
		var _yBottomBlock2 = _worldGrid[# _gridRightX, _gridBottomYClamped];
		
		if (_yBottomBlock1 == 0 || _yBottomBlock2 == 0)	//check if the block is empty
		{
			//show_debug_message("bottom");
			while (check_collision(id)) y += 1;
			break;
		}
	}
	if (check_collision(id)) y -= CELL_SIZE;	//push the block up if there's no free space in the other directions
}

//Stack Itself with Near Items of the Same ID
if (!collectItem && stackCooldown <= 0)
{
	for (var _i = 0; _i < instance_number(obj_Item); _i ++)	//loop trought all the items
	{
		//Get the Item
		var _item = instance_find(obj_Item, _i);	//skip self
		if (_item == id)
			continue;
		
		//Stack the Items
		if (_item.stackCooldown <= 0)
		{
			//Get Own && Item's Center Position
			var _x = x + sprite_width * 0.5;
			var _y = y + sprite_height * 0.5;
			var _itemX = _item.x + _item.sprite_width * 0.5;
			var _itemY = _item.y + _item.sprite_height * 0.5;
			var _itemSlot = _item.itemSlot;
		
			//Add Its itemCount to a Near Item's itemCount
			if (point_distance(_x, _y, _itemX + _item.horizontalSpeed, _itemY + _item.verticalSpeed) < stackRange					//other item's speed changes after this item's check,
				&& _itemSlot.id == itemSlot.id && !_item.collectItem && _itemSlot.itemCount != id_get_item(_itemSlot.id).itemLimit)	//so it has to be added to its current position
			{
				var _remainder = slot_add_items(itemSlot, _itemSlot.itemCount)
				_itemSlot.itemCount = _remainder;
				if (_remainder == 0)
					instance_destroy(_item);
			}
		}
	}
}

//Decrease Collection Cooldown && Stack Cooldown
collectCooldown -= 1;
stackCooldown -= 1;
