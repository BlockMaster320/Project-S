//Inventory Menu
inventoryMenu = false;
scale = 3;
#macro SLOT_SIZE 22
#macro ITEM_SIZE 16

mouseX = 0;
mouseY = 0;

//Player Sections
inventoryWidth = 3;	//set invenory grid
inventoryHeight = 2;
inventoryGrid = ds_grid_create(inventoryWidth, inventoryHeight);

armorWidth = 1;	//set armor grid
armorHeight = 4;
armorGrid = ds_grid_create(armorWidth, armorHeight);

toolWidth = 1;	//set tool grid
toolHeight = 1;
toolGrid = ds_grid_create(toolWidth, toolHeight);

inventoryGrid[# 0, 0] = new Slot(0, 16);	//add items for testing
inventoryGrid[# 1, 0] = new Slot(0, 16);
inventoryGrid[# 2, 0] = new Slot(1, 32);
inventoryGrid[# 0, 1] = new Slot(0, 16);
inventoryGrid[# 1, 1] = new Slot(1, 5);
inventoryGrid[# 2, 1] = new Slot(0, 8);
/*
inventoryGrid[# 5, 3] = new Slot(1, 25);
inventoryGrid[# 3, 2] = new Slot(1, 25);
armorGrid[# 0, 1] = new Slot(0, 32);*/

//Held Slot
heldSlot = 0;
heldSlotItemCount = 0;
swapSlots = false;	//variable preventing swapping the held slot on the first button release
splitList = ds_list_create();

//Crafting Sections
craftingLevel = 1;
craftingGrid = ds_grid_create(craftingLevel, 2);
craftingProducts = ds_list_create();
//craftingProducts[| 6] = 0

//Stations Section
stationList = ds_list_create();
station1Pointer = 0;
station2Pointer = 0;
station1 = 0;
station2 = 0;

//Inventory Wheel
inventoryWheel = true;
selectedPosition = 17;	//slot's position in the invetoryGrid
selectedSlot = position_slot_get(inventoryGrid, selectedPosition);

wheelSlots = 7;
wheelCenterX = display_get_gui_width() * 0.97;
wheelCenterY = display_get_gui_height() * 0.17;

//Item Interaction
approachAccel = 0.4;
maxApproachSpeed = 5;
approachRange = CELL_SIZE * 2;
collectRange = 10;
fullSlotsIdList = ds_list_create();	//ID's of the items which are collected at the moment if there's no space for
									//items of the same id in the inventory (to prevent collecting those items)
//Block Interaction
previousBlockGridX = 0;
previousBlockGridY = 0;
interactionRange = CELL_SIZE * 5;
inRange = false;
mineProgress = 0;
mineBlockEndurance = 0;

enum station
{
	chestSmall,
	chestLarge
}
