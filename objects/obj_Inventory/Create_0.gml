//Inventory Menu
inventoryMenu = false;
scale = 2.5;

mouseX = 0;
mouseY = 0;

selectedSection = inventorySection.station;
selectedSlot = [noone, 0, 0];	//an array containing a slot selected by the cursor && its x && y position

//Player Sections
inventoryWidth = 7;	//set invenory grid
inventoryHeight = 4;
inventoryGrid = ds_grid_create(inventoryWidth, inventoryHeight);

armorWidth = 3;	//set armor grid
armorHeight = 2;
armorGrid = ds_grid_create(armorWidth, armorHeight);

toolWidth = 1;	//set tool grid
toolHeight = 4;
toolGrid = ds_grid_create(toolWidth, toolHeight);

/*
inventoryGrid[# 0, 0] = new Slot(0, 16, noone);	//add some items for testing
inventoryGrid[# 1, 0] = new Slot(0, 16, noone);
inventoryGrid[# 2, 0] = new Slot(1, 32, noone);
inventoryGrid[# 0, 1] = new Slot(0, 16, noone);
inventoryGrid[# 1, 1] = new Slot(1, 5, noone);
inventoryGrid[# 2, 1] = new Slot(0, 8, noone);*/
/*
inventoryGrid[# 5, 3] = new Slot(1, 25, noone);
inventoryGrid[# 3, 2] = new Slot(1, 25, noone);
armorGrid[# 0, 1] = new Slot(0, 32, noone);*/

//Held Slot
heldSlot = 0;
heldSlotItemCount = 0;
swapSlots = false;	//variable preventing swapping the held slot on the first button release
splitList = ds_list_create();

//Crafting Section
craftingLevel = 0;
craftingGrid = ds_grid_create(craftingLevel + 1, 2);
craftingProducts = ds_list_create();
craftingProductsLength = 2;	//the number of columns of crafting product slots that will be drawn
craftingProductsPosition = 0;	//number of the collumn from which to draw the crafting products
//craftingProducts[| 6] = 0

//Stations Section
stationList = ds_list_create();
searchForStations = false;
stationSelectedArray = [0, 0];
stationPreferredSide = 0;

//Inventory Wheel
inventoryWheel = true;
chosenPosition = [0, 0];	//position of the primary && secondary chosen slot
chosenSlot = [position_slot_get(inventoryGrid, chosenPosition[0]), 
			  position_slot_get(toolGrid, chosenPosition[1])];

wheelSlots = 7;
wheelX = 0.97;
wheelY = 0.17;

//Item Interaction
approachRange = CELL_SIZE * 2;
fullSlotsIdList = ds_list_create();	//ID's of the items which are collected at the moment if there's no space for
									//items of the same id in the inventory (to prevent collecting those items)
//Block Interaction
previousBlockGridX = 0;
previousBlockGridY = 0;
interactionRange = CELL_SIZE * 5;
inRange = false;
mineProgress = 0;
mineBlockPersistence = 0;

/*
var _testStruct1 =
{
	textVar : 5
};

var _testStruct2 =
{
	textVar : 5
};
ds_list_add(stationList, _testStruct1);
show_debug_message(string(ds_list_find_index(stationList, _testStruct2)));*/
