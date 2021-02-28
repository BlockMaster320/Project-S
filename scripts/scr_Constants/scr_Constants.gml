//Menu
enum menu
{
	singleplayer,
	multiplayer,
	options,
	ingame,
	test1,
	test2,
	test3,
	test4
}

//Networking
enum messages
{
	worldData,
	clientData,
	clientDisconnect,
	inventoryData,
	playerCreate,
	
	itemCreate,
	itemChange,
	itemCollect,
	itemGive,
	
	blockCreate,
	blockDestroy,
	
	slotChange,
	
	destroy,
	position
}

#macro POSITION_UPDATE 3
#macro SAVE_TIME 30

//Items
enum itemCategory
{
	block,
	station
}

enum itemSubCategory
{
	storage,	//stations
	crafting
}

//Inventory
#macro SLOT_SIZE 20
#macro ITEM_SIZE 16
#macro STATION_SEARCH_SIZE 3


#macro ITEM_NUMBER 6

#macro CELL_SIZE 16

#macro CURSOR_BLINK_SPEED 35

