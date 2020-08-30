//Open/Close the Inventory Menu
scr_Input();
if (keyInventory)
	inventoryMenu = !inventoryMenu;

//Draw the Inventory Menu
if (inventoryMenu)
{
	//Set GUI Variables
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	
	//Set Slot && item Size
	var _slotSize = SLOT_SIZE * scale;
	var _itemSize = ITEM_SIZE * scale;
	
	//Darken the Background
	draw_set_alpha(0.5);
	draw_rectangle_colour(0, 0, _guiWidth, _guiHeight, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
	//Set Draw Properties
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
	draw_set_font(fnt_Inventory);
	
	//Set Mouse Posiiton on Mouse Click
	mouseX = window_mouse_get_x();
	mouseY = window_mouse_get_y();
	
	//Draw the Inventory Grid
	var _inventoryWidth = ds_grid_width(inventoryGrid)	//set x && y top-left origin for drawing the inventory
	var _inventoryHeight = ds_grid_height(inventoryGrid)
	var _inventoryX = _guiWidth * 0.5 - _inventoryWidth * _slotSize * 0.5 + (_slotSize - _itemSize) * 0.5;
	var _inventoryY = (ds_list_size(stationList) > 0) ? _guiHeight * 0.5 :
					  _guiHeight * 0.5 - _inventoryHeight * _slotSize * 0.5 + (_slotSize - _itemSize) * 0.5;

	for (var _c = 0; _c < ds_grid_height(inventoryGrid); _c ++)	//draw the inventory
	{
		for (var _r = 0; _r < ds_grid_width(inventoryGrid); _r ++)
		{
			var _drawX = _inventoryX + _r * _slotSize;
			var _drawY = _inventoryY + _c * _slotSize;
			
			draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
			
			var _item = inventoryGrid[# _r, _c];
			slot_draw(_item, _drawX, _drawY, _itemSize);
			slot_interact(_item, _drawX, _drawY, inventoryGrid, _r, _c, _itemSize, _slotSize);
		}
	}
	
	//Draw the Armor Grid
	var _armorX = _inventoryX - _slotSize * 1.7;	//set x && y top-left origin for drawing the armor
	var _armorY = _inventoryY;

	for (var _i = 0; _i < ds_list_size(armorList); _i ++)	//draw the armor slots
	{
		var _drawX = _armorX;
		var _drawY = _armorY + _i * _slotSize;
		
		draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
		
		var _item = armorList[| _i];
		slot_draw(_item, _drawX, _drawY, _itemSize);
		slot_interact(_item, _drawX, _drawY, armorList, _i, noone, _itemSize, _slotSize);
	}
	
	//Draw the Tool Slot
	var _toolSlotX = _armorX;	//set x && y for drawing the item slot
	var _toolSlotY = _armorY + _slotSize * ds_list_size(armorList);
			
	draw_sprite_ext(spr_Block, 0, _toolSlotX, _toolSlotY, scale, scale, 0, c_white, 0.5);
	var _item = toolSlot;	//draw the item slot
	slot_draw(_item, _toolSlotX, _toolSlotY, _itemSize);
	slot_interact(_item, _toolSlotX, _toolSlotY, toolSlot, noone, noone, _itemSize, _slotSize);
	
	//Draw the Crafting Grid && Products
	var _craftingX = _inventoryX + (_inventoryWidth + 0.7) * _slotSize;	//set x && y top-left origin for drawing the crafting section
	var _craftingGridY = _inventoryY;
	var _craftingProductsY = _inventoryY + _slotSize * (ds_grid_height(craftingGrid) + 1);
	
	for (var _c = 0; _c < ds_grid_height(craftingGrid); _c ++)	//draw the crafting grid
	{
		for (var _r = 0; _r < ds_grid_width(craftingGrid); _r ++)
		{
			var _drawX = _craftingX + _r * _slotSize;
			var _drawY = _craftingGridY + _c * _slotSize;
			
			draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
			
			var _item = craftingGrid[# _r, _c];
			slot_draw(_item, _drawX, _drawY, _itemSize);
			slot_interact(_item, _drawX, _drawY, craftingGrid, _r, _c, _itemSize, _slotSize);
		}
	}
	
	for (var _i = 0; _i < ds_list_size(craftingProducts); _i ++)	//draw the crafting products
	{
		var _drawX = _craftingX + _slotSize * floor(_i * 0.5);
		var _drawY = _craftingProductsY + _slotSize * (_i % 2 == 0);
		
		draw_sprite_ext(spr_Block, 0, _drawX, _drawY, scale, scale, 0, c_white, 0.5);
		
		var _item = craftingProducts[| _i];
		slot_draw(_item, _drawX, _drawY, _itemSize);
	}
	
	//Draw the Held Slot
	if (heldSlot != 0)
	{
		if (heldSlot.itemCount != 0)
			slot_draw(heldSlot, mouseX - _itemSize * 0.5, mouseY - _itemSize * 0.5, _itemSize);
	}
	
	
	
	draw_line_width_colour(_guiWidth * 0.5, 0, _guiWidth * 0.5, _guiHeight, 1, c_blue, c_blue);
	draw_line_width_colour(0, _guiHeight * 0.5, _guiWidth, _guiHeight * 0.5, 1, c_red, c_red);
}


scale *= 1 + keyboard_check(vk_add) * 0.05;
scale *= 1 - keyboard_check(vk_subtract) * 0.05;
//show_debug_message(inventoryGrid[# 0, 0]);
//show_debug_message(ds_list_size(splitList));
//show_debug_message(heldSlot);