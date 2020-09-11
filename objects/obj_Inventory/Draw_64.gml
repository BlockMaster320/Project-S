//Get Player's Input
scr_Input();

//Set GUI Variables
var _guiWidth = display_get_gui_width();
var _guiHeight = display_get_gui_height();

//Set Draw Properties
draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_font(fnt_Inventory);

//INVENTORY WHEEL//
//Draw the Inventory Wheel
if (inventoryWheel)
{
	//Get Inventory Grid Properties
	var _inventoryWidth = ds_grid_width(inventoryGrid);
	var _inventoryHeight = ds_grid_height(inventoryGrid);
	var _initialPosition = selectedPosition - floor(wheelSlots * 0.5);
	
	//Set Slot && item Size
	var _scale = scale * 0.7;
	var _slotSize = SLOT_SIZE * _scale;
	var _itemSize = ITEM_SIZE * _scale;
	
	//Draw the Inventory Wheel
	draw_sprite_ext(spr_SlotFrame, 0, wheelCenterX - _scale * 50 - (22 * _scale) * 0.5,
					wheelCenterY - (22 * _scale) * 0.5, _scale, _scale, 0, c_white, 1);
	for (var _i = 0; _i < wheelSlots; _i ++)
	{
		var _angle = 90 + (180 / (wheelSlots - 1)) * _i;	//get draw x && y
		var _drawX = wheelCenterX + lengthdir_x(_scale * 50, _angle) - _itemSize * 0.5;
		var _drawY = wheelCenterY + lengthdir_y(_scale * 50, _angle) - _itemSize * 0.5;
		
		/*draw_circle_colour(wheelCenterX + lengthdir_x(_scale * 50, _angle),
						   wheelCenterY + lengthdir_y(_scale * 50, _angle), 1, c_red, c_red, false);*/
	
		var _position = _initialPosition + _i;	//get && draw the slot
		var _slot = position_slot_get(inventoryGrid, _position);
		slot_draw(_slot, _drawX, _drawY, _itemSize, _scale);
	}
}

//Scroll Throught the Inventory Wheel
if (mouse_wheel_down()) selectedPosition += 1;
if (mouse_wheel_up()) selectedPosition -= 1;
if (mouse_wheel_up() || mouse_wheel_down()) mineProgress = 0;	//reset mine progress

//Update Selected Slot
selectedSlot = position_slot_get(inventoryGrid, selectedPosition);

//INVENTORY MENU//
//Open/Close the Inventory Menu
if (keyInventory)
	inventoryMenu = !inventoryMenu;

//Draw && Interact With the Inventory Menu
if (inventoryMenu)
{
	//SET VARIABLES//
	//Darken the Background
	draw_set_alpha(0.5);
	draw_rectangle_colour(0, 0, _guiWidth, _guiHeight, c_black, c_black, c_black, c_black, false);
	draw_set_alpha(1);
	
	//Set Slot && item Size
	var _slotSize = SLOT_SIZE * scale;
	var _itemSize = ITEM_SIZE * scale;
	
	//Set Mouse Posiiton on Mouse Click
	mouseX = window_mouse_get_x();
	mouseY = window_mouse_get_y();
	
	//DRAW && INTERACT WITH INVENTORY SECTIONS//
	//Inventory Grid
	var _inventoryWidth = ds_grid_width(inventoryGrid)	//set x && y top-left origin for drawing the inventory
	var _inventoryHeight = ds_grid_height(inventoryGrid)
	var _inventoryX = _guiWidth * 0.5 - _inventoryWidth * _slotSize * 0.5 + (_slotSize - _itemSize) * 0.5;
	var _inventoryY = (ds_list_size(stationList) > 0) ? _guiHeight * 0.5 :
					  _guiHeight * 0.5 - _inventoryHeight * _slotSize * 0.5 + (_slotSize - _itemSize) * 0.5;

	inventory_section(inventoryGrid, 0, _inventoryX, _inventoryY, _itemSize, _slotSize);	//draw && interact with InventoryGrid
	
	//Armor Grid
	var _armorX = _inventoryX - _slotSize * 1.7;	//set x && y top-left origin for drawing the armor
	var _armorY = _inventoryY;
	inventory_section(armorGrid, 0, _armorX, _armorY, _itemSize, _slotSize);	//draw && interact with armorGrid
	
	//Tool Slot
	var _toolX = _armorX;	//set x && y for drawing the item slot
	var _toolY = _armorY + _slotSize * ds_grid_height(armorGrid);
	inventory_section(toolGrid, 0, _toolX, _toolY, _itemSize, _slotSize);	//draw && interact with toolGrid
	
	//Crafting Grid && Crafting Products
	var _craftingX = _inventoryX + (_inventoryWidth + 0.7) * _slotSize;	//set x && y top-left origin for drawing the crafting section
	var _craftingGridY = _inventoryY;
	var _craftingProductsY = _inventoryY + _slotSize * (ds_grid_height(craftingGrid) + 1);
	inventory_section(craftingGrid, 0, _craftingX, _craftingGridY, _itemSize, _slotSize);	//draw && interact with CraftingGrid && craftingProducts
	inventory_section(craftingProducts, 1, _craftingX, _craftingProductsY, _itemSize, _slotSize);
	
	//Held Slot
	if (heldSlot != 0)
	{
		if (heldSlot.itemCount != 0)
			slot_draw(heldSlot, mouseX - _itemSize * 0.5, mouseY - _itemSize * 0.5, _itemSize, scale);	//draw the held slot
	}
	
	
	
	draw_line_width_colour(_guiWidth * 0.5, 0, _guiWidth * 0.5, _guiHeight, 1, c_blue, c_blue);
	draw_line_width_colour(0, _guiHeight * 0.5, _guiWidth, _guiHeight * 0.5, 1, c_red, c_red);
}



scale *= 1 + keyboard_check(vk_add) * 0.05;
scale *= 1 - keyboard_check(vk_subtract) * 0.05;
//show_debug_message(inventoryGrid[# 0, 0]);
//show_debug_message(ds_list_size(splitList));
//show_debug_message(heldSlot);
