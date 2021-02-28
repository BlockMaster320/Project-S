//Get Player's Input
scr_Input();

//Get GUI Properties
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
	var _wheelCenterX = wheelCenterX * _guiWidth;
	var _wheelCenterY = wheelCenterY * _guiHeight;
	
	draw_sprite_ext(spr_SlotFrame, 0, _wheelCenterX - _scale * 50 - (22 * _scale) * 0.5,
					_wheelCenterY - (22 * _scale) * 0.5, _scale, _scale, 0, c_white, 1);
	
	for (var _i = 0; _i < wheelSlots; _i ++)
	{
		var _angle = 90 + (180 / (wheelSlots - 1)) * _i;	//get draw x && y
		var _drawX = _wheelCenterX + lengthdir_x(_scale * 50, _angle) - _itemSize * 0.5;
		var _drawY = _wheelCenterY + lengthdir_y(_scale * 50, _angle) - _itemSize * 0.5;
		
		/*draw_circle_colour(wheelCenterX + lengthdir_x(_scale * 50, _angle),
						   wheelCenterY + lengthdir_y(_scale * 50, _angle), 1, c_red, c_red, false);*/
	
		var _position = _initialPosition + _i;	//get && draw the slot
		var _slot = position_slot_get(inventoryGrid, _position);
		slot_draw(_slot, _drawX, _drawY, _itemSize, _scale);
	}
}

//Scroll Through the Inventory Wheel
if (!inventoryMenu)
{
	if (mouse_wheel_down()) selectedPosition += 1;
	if (mouse_wheel_up()) selectedPosition -= 1;
	if (mouse_wheel_up() || mouse_wheel_down()) mineProgress = 0;	//reset mine progress
}

//Update Selected Slot
selectedSlot = position_slot_get(inventoryGrid, selectedPosition);

//INVENTORY MENU//
//Open/Close the Inventory Menu
if (keyInventory)
{
	//Close/Open the Inventory
	inventoryMenu = !inventoryMenu;
	
	//Search for Stations
	if (inventoryMenu)
		searchForStations = true;
	
	//Remove All Stations from stationLists
	else
	{
		for (var _i = 0; _i < ds_list_size(stationList); _i ++)
		{
			station_update(_i);
			station_unlist(_i, false);
		}
		ds_list_clear(stationList);
	}
}

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
	//Search for Stations
	if (searchForStations)
	{
		station_search();
		searchForStations = false;
	}
	var _stationListSize = ds_list_size(stationList);
	if (_stationListSize > 0)	//wrap the selected station index
	{
		stationSelectedArray[0] = wrap(stationSelectedArray[0], 0, _stationListSize);
		stationSelectedArray[1] = wrap(stationSelectedArray[1], 0, _stationListSize);
	}
	var _stationOffsetX = 20;	//set station area draw offset
	var _stationOffsetY = 30;
	
	//Inventory Grid
	var _inventoryWidth = ds_grid_width(inventoryGrid)	//set x && y top-left origin for drawing the inventory
	var _inventoryHeight = ds_grid_height(inventoryGrid)
	var _inventoryX = _guiWidth * 0.5 - _inventoryWidth * 0.5 * _slotSize + (_slotSize - _itemSize) * 0.5;
	var _inventoryY = (_stationListSize != 0) ? _guiHeight * 0.5 + _stationOffsetY :
					  _guiHeight * 0.5 - _inventoryHeight * _slotSize * 0.5 + (_slotSize - _itemSize) * 0.5;
	inventory_section(inventoryGrid, 0, _inventoryX, _inventoryY, noone, _itemSize, _slotSize, false, false);	//draw && interact with InventoryGrid
	
	//Armor Grid
	var _armorX = _inventoryX - _slotSize * 1.7;	//set x && y top-left origin for drawing the armor
	var _armorY = _inventoryY;
	inventory_section(armorGrid, 0, _armorX, _armorY, noone, _itemSize, _slotSize, false, false);	//draw && interact with armorGrid
	
	//Tool Slot
	var _toolX = _armorX;	//set x && y for drawing the item slot
	var _toolY = _armorY + _slotSize * ds_grid_height(armorGrid);
	inventory_section(toolGrid, 0, _toolX, _toolY, noone, _itemSize, _slotSize, false, false);	//draw && interact with toolGrid
	
	//Get the Crafting Grid Updated Width
	var _craftingWidth = ds_grid_width(craftingGrid);
	var _craftingWidthUpdated = craftingLevel + 1;
	
	//Check Wheter the Crafting Grid Changed Its Width
	if (_craftingWidth != _craftingWidthUpdated)
	{
		//Loop Through the Crafting Grid Part That Was Subtracted && Drop Its Slots
		var _craftingHeight = ds_grid_height(craftingGrid);
		var _widthChange = clamp(_craftingWidth - _craftingWidthUpdated, 0, infinity);
		for (var _c = _craftingWidth - 1; _c > _craftingWidth - _widthChange - 1; _c --)
		{
			for (var _r = 0; _r < _craftingHeight; _r ++)
			{
				//Drop the Slot
				var _slot = craftingGrid[# _c, _r];
				if (_slot != 0)
				{
					var _dropX = obj_Player.x + sprite_get_width(spr_Player) * 0.5;
					var _dropY = obj_Player.y + sprite_get_height(spr_Player) * 0.5;
					slot_drop(_slot.id, _slot.itemCount, _dropX, _dropY, 60, false);
				}
			}
		}
		
		//Update the Crafting Grid Size
		ds_grid_resize(craftingGrid, _craftingWidthUpdated, 2);
	}
	
	//Crafting Grid
	var _craftingGridX = _inventoryX + (_inventoryWidth + 0.7) * _slotSize;	//set x && y top-left origin for drawing the crafting section
	var _craftingGridY = _inventoryY;
	inventory_section(craftingGrid, 0, _craftingGridX, _craftingGridY, noone, _itemSize, _slotSize, true, false);	//draw && interact with CraftingGrid && craftingProducts
	
	//Crafting Products
	var _craftingProductsX = _craftingGridX;
	var _craftingProductsY = _inventoryY + _slotSize * (ds_grid_height(craftingGrid) + 1);
	inventory_section(craftingProducts, 1, _craftingProductsX, _craftingProductsY, noone, _itemSize, _slotSize, true, true);
	
	//Station Grids
	if (_stationListSize != 0)
	{
		//Set Size of the Station Area
		var _areaWidth = _slotSize * inventoryWidth;
		var _areaHeight = _slotSize * inventoryHeight;
		
		//Set Station Area Sizes
		var _areaLeftX1 = _guiWidth * 0.5 - _areaWidth - _stationOffsetX;
		var _areaLeftX2 = _guiWidth * 0.5 - _stationOffsetX;
		var _areaRightX1 = _guiWidth * 0.5 + _stationOffsetX;
		var _areaRightX2 = _guiWidth * 0.5 + _areaWidth + _stationOffsetX
		var _areaY1 = _guiHeight * 0.5 - _areaHeight - _stationOffsetY;
		var _areaY2 = _guiHeight * 0.5 - _stationOffsetY * 0.5;
		/*draw_rectangle_colour(_areaLeftX1, _areaY1, _areaLeftX2, _areaY2, c_green, c_green, c_green, c_green, false);*/
		
		//Check Wheter the Cursor is Within on the Station Areas
		var _stationLeftSide = point_in_rectangle(mouseX, mouseY, _areaLeftX1, _areaY1,
												  _areaLeftX2, _areaY2);
		var _stationRightSide = point_in_rectangle(mouseX, mouseY, _areaRightX1, _areaY1,
												   _areaRightX2, _areaY2);
		
		//Get the Selected Stations
		var _stationLeft = stationList[| stationSelectedArray[0]];
		var _stationRight = stationList[| stationSelectedArray[1]];
		var _stationArray = [_stationLeft, _stationRight];
		
		//Check Wheter the Whole Station Area Should Be Covered
		var _fullSide = noone;
		
		if (id_get_item(_stationArray[stationPreferredSide].id).stationSpace == 1 ||
			id_get_item(_stationArray[!stationPreferredSide].id).stationSpace == 1)	//check preferred side first
		{
			_fullSide = stationPreferredSide;
		}
		
		if (_stationLeft == _stationRight)	//draw the station in middle if both sides have the same station
			_fullSide = stationPreferredSide;
		
		//Draw the Stations
		if (_fullSide != 1)	//left side station
		{
			var _side = (_fullSide == 0) ? 0 : - 1;
			station_draw(_stationLeft, _side, _stationOffsetX, _stationOffsetY, _slotSize, _itemSize)
		}
		
		if (_fullSide != 0)	//right side staiton
		{
			var _side = (_fullSide == 1) ? 0 : 1;
			station_draw(_stationRight, _side, _stationOffsetX, _stationOffsetY, _slotSize, _itemSize)
		}
		
		//Set Scroll Direction
		var _scrollDirection = 0;
		
		//Scroll Through the Stations Using Arrows
		var _arrowLeftX = _guiWidth * 0.5 - 40 * _scale;
		var _arrowRightX = _guiWidth * 0.5 + 40 * _scale;
		var _arrowSpacing = 4 * _scale;
		if (arrow_button(_arrowLeftX + _arrowSpacing, _areaY2 + 20, 0, true, _scale))
		{
			_stationLeftSide = true;
			_scrollDirection = 1;
		}
		if (arrow_button(_arrowLeftX - _arrowSpacing, _areaY2 + 20, 180, true, _scale))
		{
			_stationLeftSide = true;
			_scrollDirection = - 1;
		}
		if (arrow_button(_arrowRightX + _arrowSpacing, _areaY2 + 20, 0, true, _scale))
		{
			_stationRightSide = true;
			_scrollDirection = 1;
		}
		if (arrow_button(_arrowRightX - _arrowSpacing, _areaY2 + 20, 180, true, _scale))
		{
			_stationRightSide = true;
			_scrollDirection = - 1;
		}
		
		//Scroll Through the Stations Using Mouse Wheel
		if (_scrollDirection == 0)
			_scrollDirection = mouse_wheel_up() - mouse_wheel_down();
		
		//Update the Station Scroll Inexes
		if (_scrollDirection != 0 && (_stationLeftSide || _stationRightSide))
		{
			//Get the Current Station Index of the Selected Side
			var _selectedSide = (_stationLeftSide) ? 0 : 1;	//left side = 0; right side = 1
			
			//Increase/Decrease the Selected Station Index
			//var _stationItemPreferred = id_get_item(stationList[| stationSelectedArray[stationPreferredSide]].id);
			var _stationPreferred = stationList[| stationSelectedArray[stationPreferredSide]];
			stationSelectedArray[_selectedSide] += _scrollDirection;
			station_selection_update(_scrollDirection, _selectedSide, _stationPreferred);
			
			//Set the Preferred Side to the selectedSide
			stationPreferredSide = _selectedSide;
			
			//Wrap the Selected Stations Indexes Again
			stationSelectedArray[0] = wrap(stationSelectedArray[0], 0, _stationListSize);
			stationSelectedArray[1] = wrap(stationSelectedArray[1], 0, _stationListSize);
		}
		
		//STATION SELECTION BAR//
		//Get Indexes of the Selected Stations
		var _stationPreferredIndex = stationSelectedArray[stationPreferredSide];
		var _stationOtherIndex = stationSelectedArray[!stationPreferredSide];
		
		//Set Station Selection Bar Draw Properties
		var _stationSpacing = 5 * _scale;	//draw properties
		var _stationSpriteWidth = sprite_get_width(spr_Test1) * 0.5 * _scale;
		var _drawStartX = _guiWidth * 0.5 - (_stationSpriteWidth + _stationSpacing)
						  * (_stationListSize * 0.5) + _stationSpacing * 0.5;
		var _drawStartY = _areaY1 - 10 * _scale;
		
		//Draw the Station Selection Bar
		for (var _i = 0; _i < _stationListSize; _i ++)
		{
			//Get the Station
			var _station = stationList[| _i];
			var _stationItem = id_get_item(_station.id);
			
			//Set Stations' Draw Properties
			var _isPreferred = _i == _stationPreferredIndex;
			var _stationScale = (_isPreferred) ? 0.8 * _scale : 0.5 * _scale;
			var _offset = (_isPreferred) ? (_stationSpriteWidth * _stationScale - _stationSpriteWidth) * 0.5 : 0;
			var _drawX = _drawStartX + (_stationSpriteWidth + _stationSpacing) * _i - _offset;
			var _drawY = _drawStartY - _offset;
			
			//Draw Station Selection Mark
			if (_isPreferred || _i == _stationOtherIndex)
			{
				var _markScale = (_isPreferred) ? 1.5 * _scale : 1 * _scale;
				var _markX = _drawX + _stationSpriteWidth * _stationScale * 0.5;
				var _markY = _drawY - 4 * _scale - _offset;
				draw_circle_colour(_markX, _markY, _markScale, c_white, c_white, false);
			}
			
			//Draw the Station
			draw_sprite_ext(_stationItem.spriteItem, 0, _drawX, _drawY,
							_stationScale, _stationScale, 0, c_white, 1);
		}
	}
	
	//Held Slot
	if (heldSlot != 0)
	{
		if (heldSlot.itemCount != 0)
			slot_draw(heldSlot, mouseX - _itemSize * 0.5, mouseY - _itemSize * 0.5, _itemSize, scale);	//draw the held slot
	}
	
	//Scroll Through the Crafting Products
	if (mouse_wheel_up())
		craftingProductsPosition += 1;
	if (mouse_wheel_down())
		craftingProductsPosition -= 1;
	craftingProductsPosition = clamp(craftingProductsPosition, 0, 
							   clamp(ceil(ds_list_size(craftingProducts) / 2) - craftingProductsLength, 0, infinity));
	
	draw_line_width_colour(_guiWidth * 0.5, 0, _guiWidth * 0.5, _guiHeight, 1, c_blue, c_blue);	//draw some lines for testing
	draw_line_width_colour(0, _guiHeight * 0.5, _guiWidth, _guiHeight * 0.5, 1, c_red, c_red);
}



scale *= 1 + keyboard_check(vk_add) * 0.05;
scale *= 1 - keyboard_check(vk_subtract) * 0.05;
//show_debug_message(inventoryGrid[# 0, 0]);
//show_debug_message(ds_list_size(splitList));
//show_debug_message(heldSlot);
/*
show_debug_message("leftStationIndex: " + string(stationSelectedArray[0]));
show_debug_message("rightStationIndex: " + string(stationSelectedArray[1]));*/
