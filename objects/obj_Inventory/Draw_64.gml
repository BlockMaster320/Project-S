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
	//Set Slot && item Size
	var _scale = scale * 0.7;
	var _slotSize = SLOT_SIZE * _scale;
	var _itemSize = ITEM_SIZE * _scale;
	
	//Draw the Inventory Wheel
	var _wheelPrimaryX = wheelX * _guiWidth;	//primary inventory wheel
	var _wheelPrimaryY = wheelY * _guiHeight;
	slot_wheel_draw(inventoryGrid, chosenPosition[0], _wheelPrimaryX, _wheelPrimaryY,
					50, 50, wheelSlots, _itemSize, _scale);
	
	var _wheelSecondaryX = (wheelX + 0.005) * _guiWidth;	//secondary inventory wheel
	var _wheelSecondaryY = _wheelPrimaryY;
	slot_wheel_draw(toolGrid, chosenPosition[1], _wheelSecondaryX, _wheelSecondaryY,
					15, 23, 3, _itemSize, _scale);
}

//Scroll Through the Inventory Wheel
if (!inventoryMenu)
{
	if (mouseWheelDown) chosenPosition[keyModifier2] += 1;	//keyModifier2: 0 - primary chosen position, 1 - secondary chosen position
	if (mouseWheelUp) chosenPosition[keyModifier2] -= 1;
	if (mouseWheelDown || mouseWheelUp) mineProgress = 0;	//reset mine progress
}

//Update the Selected Slot
chosenSlot[0] = position_slot_get(inventoryGrid, chosenPosition[0]);
chosenSlot[1] = position_slot_get(toolGrid, chosenPosition[1]);

//INVENTORY MENU//
//Open/Close the Inventory Menu
if (keyInventory)
{
	//Open/Close the Inventory
	inventoryMenu = !inventoryMenu;
	
	//Search for Stations
	if (inventoryMenu)
		searchForStations = true;
	
	//Remove All Stations from the stationList
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
	
	//Set Draw Offsets
	var _sectionOffset = _slotSize * 0.7;
	
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
	
	//Check Wheter the Cursor is Within the Area of the Inventory Section
	var _areaInventory = cursor_in_section(_inventoryX, _inventoryY, _inventoryWidth, _inventoryHeight, _slotSize, _itemSize);
	
	//Change chosenPosition Inside the Inventory
	if (_areaInventory && keyModifier2)
	{
		if (mouseWheelDown) chosenPosition[0] += 1;
		if (mouseWheelUp) chosenPosition[0] -= 1;
	}
	
	//Tool Grid
	var _toolX = _inventoryX - _sectionOffset - _slotSize;	//set x && y for drawing the tool grid
	var _toolY = _inventoryY;
	inventory_section(toolGrid, 0, _toolX, _toolY, noone, _itemSize, _slotSize, false, false);	//draw && interact with toolGrid
	
	//Armor Grid
	var _armorX = _toolX - _sectionOffset - _slotSize * ds_grid_width(armorGrid);	//set x && y top-left origin for drawing the armor
	var _armorY = _inventoryY;
	inventory_section(armorGrid, 0, _armorX, _armorY, noone, _itemSize, _slotSize, false, false);	//draw && interact with armorGrid
	
	//Get the craftingGrid Updated Width
	var _craftingWidth = ds_grid_width(craftingGrid);
	var _craftingWidthUpdated = craftingLevel + 1;
	
	//Drop Slots Whose Position Exceeded the craftingGrid Width
	if (_craftingWidth != _craftingWidthUpdated)	//check wheter the craftingGrid changed its width
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
					slot_drop(_slot, _dropX, _dropY, 60, false, true);
				}
			}
		}
		
		//Update the Crafting Grid Size
		ds_grid_resize(craftingGrid, _craftingWidthUpdated, 2);
		crafting_update_products(craftingGrid);
	}
	
	//Crafting Grid
	var _craftingGridX = _inventoryX + _sectionOffset + (_inventoryWidth) * _slotSize;	//set x && y top-left origin for drawing the crafting section
	var _craftingGridY = _inventoryY;
	inventory_section(craftingGrid, 0, _craftingGridX, _craftingGridY, noone, _itemSize, _slotSize, true, false);	//draw && interact with CraftingGrid && craftingProducts
	
	//Crafting Products
	var _craftingProductsX = _craftingGridX;
	var _craftingProductsY = _inventoryY + _slotSize * (ds_grid_height(craftingGrid) + 1);
	inventory_section(craftingProducts, 1, _craftingProductsX, _craftingProductsY, noone, _itemSize, _slotSize, true, true);
	
	//Check Wheter the Cursor is Within the Area of the Crafting Section
	var _areaCrafting = cursor_in_section(_craftingGridX, _craftingGridY, 5, 5, _slotSize, _itemSize);
	
	//Scroll Through the Crafting Prodducts Using Mouse Wheel
	if (_areaCrafting && keyModifier2)
	{
		if (mouseWheelUp)
			craftingProductsPosition += 1;
		if (mouseWheelDown)
			craftingProductsPosition -= 1;
	}
	
	//Scroll Through the Crafting Products Using Arrows
	if (ds_list_size(craftingProducts) > 0)
	{
		var _arrowSpacing = 4 * _scale;
		var _arrowX = _craftingProductsX + sprite_get_width(spr_Arrow) * _scale + _arrowSpacing;
		var _arrowY = _craftingProductsY - _slotSize * 0.5;
	
		if (arrow_button(_arrowX - _arrowSpacing, _arrowY, 180, true, _scale))
			craftingProductsPosition -= 1;
		if (arrow_button(_arrowX + _arrowSpacing, _arrowY, 0, true, _scale))
			craftingProductsPosition += 1;
	}
	
	//Clamp the craftingProductsPosition
	craftingProductsPosition = clamp(craftingProductsPosition, 0, 
							   clamp(ceil(ds_list_size(craftingProducts) / 2) - craftingProductsLength, 0, infinity));
	
	//Station Grids
	if (_stationListSize != 0)
	{
		//Set Size of the Station Area
		var _stationWidth = inventoryWidth;
		var _stationHeight = inventoryHeight;
		
		//Check Wheter the Cursor is Within the Area of the Station Section
		var _stationLeftX = _guiWidth * 0.5 - _stationWidth * _slotSize + (_slotSize - _itemSize) * 0.5 - _stationOffsetX;
		var _stationRightX = _guiWidth * 0.5 + (_slotSize - _itemSize) * 0.5 + _stationOffsetX;
		var _stationY = _guiHeight * 0.5 - _stationHeight * _slotSize + (_slotSize - _itemSize) - _stationOffsetY;
		var _areaStationLeft = cursor_in_section(_stationLeftX, _stationY, _stationWidth + 0.15, _stationHeight, _slotSize, _itemSize);
		var _areaStationRight = cursor_in_section(_stationRightX - _slotSize * 0.15, _stationY, _stationWidth, _stationHeight, _slotSize, _itemSize);
		
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
		var _arrowY = _guiHeight * 0.5 - _stationOffsetY * 0.5;
		var _arrowSpacing = 4 * _scale;
		if (arrow_button(_arrowLeftX + _arrowSpacing, _arrowY + 20, 0, true, _scale))
		{
			_areaStationLeft = true;
			_scrollDirection = 1;
		}
		if (arrow_button(_arrowLeftX - _arrowSpacing, _arrowY + 20, 180, true, _scale))
		{
			_areaStationLeft = true;
			_scrollDirection = - 1;
		}
		if (arrow_button(_arrowRightX + _arrowSpacing, _arrowY + 20, 0, true, _scale))
		{
			_areaStationRight = true;
			_scrollDirection = 1;
		}
		if (arrow_button(_arrowRightX - _arrowSpacing, _arrowY + 20, 180, true, _scale))
		{
			_areaStationRight = true;
			_scrollDirection = - 1;
		}
		
		//Scroll Through the Stations Using Mouse Wheel
		if (_scrollDirection == 0)
			_scrollDirection = (mouseWheelUp - mouseWheelDown) * keyModifier2;
		
		//Update the Station Scroll Inexes
		if (_scrollDirection != 0 && (_areaStationLeft || _areaStationRight))
		{
			//Get the Current Station Index of the Selected Side
			var _selectedSide = (_areaStationLeft) ? 0 : 1;	//left side = 0; right side = 1
			
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
			
			//Remove Slots of Stations That Are Not Selected from the splitList
			/*	//possible feature; not working yet
			for (var _i = 0; _i < ds_list_size(splitList); _i ++)
			{
				var _splitSlot = splitList[| _i];
				var _splitSlotStation = _splitSlot[4];
				if (_splitSlotStation != noone)
				{
					if (_splitSlotStation != stationList[| stationSelectedArray[stationPreferredSide]]
						&& _splitSlotStation != stationList[| stationSelectedArray[!stationPreferredSide]])
					{
						heldSlotItemCount -= _splitSlot[3];
						ds_list_delete(splitList, _i);
						_i -= 1;	//this position was deleted so the next station's index is going to be the same (the list shifted by 1)
					}
				}
			}*/
		}
		
		//Set the Station Section As Selected
		if (_areaStationLeft || _areaStationRight)
		{
			selectedSection = inventorySection.station;
			if (_fullSide == noone)	//switch the preferred side
				stationPreferredSide = _areaStationRight;	//left = 0, right = 1; right side == false => left side is selected
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
		var _drawStartY = _stationY - 30 * _scale;
		
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
	
	//Draw the Held Slot
	if (heldSlot != 0)
	{
		if (heldSlot.itemCount != 0)
			slot_draw(heldSlot, mouseX - _itemSize * 0.5, mouseY - _itemSize * 0.5, false, _itemSize, scale);	//draw the held slot
	}
	
	//Draw the Selected Slot's Info Table
	slot_draw_info(selectedSlot[0], selectedSlot[1], selectedSlot[2]);
	selectedSlot = [noone, 0, 0];
	
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
