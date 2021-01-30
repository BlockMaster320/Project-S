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
	
	destroy,
	position
}

#macro POSITION_UPDATE 3

#macro SAVE_TIME 30

#macro CURSOR_BLINK_SPEED 35