//Inventory Menu
inventoryMenu = false;
scale = 3;
#macro SLOT_SIZE 22
#macro ITEM_SIZE 16
mouseX = 0;
mouseY = 0;

//Player Section
inventoryGrid = ds_grid_create(7, 5);
armorList = ds_list_create(); armorList[| 3] = 0;
toolSlot = 0;

armorList[| 2] = new Item(0, 32);

//Held Slot
heldSlot = 0;
heldSlotItemCount = 0;
splitList = ds_list_create();

inventoryGrid[# 0, 0] = new Item(0, 5);
inventoryGrid[# 5, 3] = new Item(1, 25);

//Crafting Section
craftingLevel = 1;
craftingGrid = ds_grid_create(craftingLevel, 2);
craftingProducts = ds_list_create();
craftingProducts[| 6] = 0

//Stations Section
stationList = ds_list_create();
station1Pointer = 0;
station2Pointer = 0;
station1 = 0;
station2 = 0;

enum station
{
	chestSmall,
	chestLarge
}
