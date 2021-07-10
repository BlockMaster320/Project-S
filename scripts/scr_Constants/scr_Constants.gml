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
	clientConnect,
	clientDisconnect,
	inventoryData,
	playerCreate,
	
	chunkGet,
	
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
	station,
	tool,
	material
}

enum itemSubCategory
{
	storage,	//stations
	crafting
}

enum property
{
	power,
	durability,
	hardness
}

//Inventory
enum inventorySection
{
	inventory,	//main inventory space in the middle
	armor,
	tool,
	station	
}

#macro SLOT_SIZE 20
#macro ITEM_SIZE 16
#macro STATION_SEARCH_SIZE 3


#macro ITEM_NUMBER 8

//World Generation
#macro CELL_SIZE 16
#macro CHUNK_SIZE 16
#macro CHUNK_GRID_SIZE 5
#macro SEA_LEVEL 0

#macro CURSOR_BLINK_SPEED 35

