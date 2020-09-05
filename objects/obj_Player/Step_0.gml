//Get Player's Input
scr_Input();

//Horizontal Movement
movement(keyRight, keyLeft);

//Vertical Movement
if (jumpTime <= 0) gravity();	//gravity
jump(keyJumpPressed, keyJump);	//jump

//Collision
collision();

//ITEM INTERACTION//
//Item Collection
var _x = x + sprite_width * 0.5;	//get player's center position
var _y = y + sprite_height * 0.5;

for (var _i = 0; _i < instance_number(obj_Item); _i ++)	//loop trought all the items
{
	//Get the Item && Its Center Position
	var _item = instance_find(obj_Item, _i);
	var _itemX = _item.x + _item.sprite_width * 0.5;
	var _itemY = _item.y + _item.sprite_height * 0.5;
	
	//Interact with the Item
	if (point_distance(_x, _y, _itemX, _itemY) < 32)
	{
		var _itemSlot = _item.itemSlot;
		var _remainder = item_collect_remainder(obj_Inventory.inventoryGrid, _itemSlot);
		show_debug_message(_remainder);
		
		//Item Approach
		if (ds_list_find_index(fullSlotsIdList, _itemSlot.id) == - 1 && _item.collectCooldown <= 0)	//check if there's space for the item in the inventory
		{
			if (_remainder == 0) _item.collectItem = true;	//collect the whole item
			else if (_remainder < _itemSlot.itemCount)	//divide the item into 2 items if there's not enough space for all the items
			{
				var _newItem = instance_create_layer(_item.x, _item.y, "Items", obj_Item);
				_newItem.itemSlot = new Slot(_itemSlot.id, _remainder);
			
				_itemSlot.itemCount -= _remainder;
				_item.collectItem = true;
				ds_list_add(fullSlotsIdList, _itemSlot.id);
			}
		}
		//show_debug_message("fullSlotsIdList: " + string(fullSlotsIdList));
		
		//Item Collection
		if (_item.collectItem)
		{
			_item.approachSpeed += approachAccel;	//move the item towards the player
			var _direction = point_direction(_itemX, _itemY, _x, _y);
			_item.x += lengthdir_x(_item.approachSpeed, _direction);
			_item.y += lengthdir_y(_item.approachSpeed, _direction);
		
			if (point_distance(_x, _y, _itemX, _itemY) < 10)	//collect the item
			{
				var _idPosition = ds_list_find_index(fullSlotsIdList, _itemSlot.id);	//delete the item ID from the fullSlotsIdList
				if (_idPosition != - 1)
					ds_list_delete(fullSlotsIdList, _idPosition);
				
				item_collect(obj_Inventory.inventoryGrid, _itemSlot);	//add item to the inventory
				instance_destroy(_item);
			}
		}
	}
}

//Item Dropping
var _selectedSlot = obj_Inventory.selectedSlot;
if (keyItemDrop && _selectedSlot != 0)
{
	var _droppedItem = instance_create_layer(_x, _y, "Items", obj_Item);
	_droppedItem.itemSlot = new Slot(_selectedSlot.id, _selectedSlot.itemCount);
	_droppedItem.collectCooldown = 60;
	
	position_set_slot(obj_Inventory.inventoryGrid, obj_Inventory.selectedPosition, 0);
}

