//MOVEMENT//
//Horizontal Movement
horizontalSpeed = 0;
maxWalkSpeed = 1.3;
accel = 0.4;
frict = 0.5;

//Vertical Movement
verticalSpeed = 0;	//gravity
gravityAccel = 0.25;

jumpAccel = 3;	//jump
jumpTime = 0;
jumpMaxTime = 10;	//max number of frames before enabeling gravity
onGroundTimer = 0;	//time from ground touch
delayedJumpTimer = 0;	//time from the last jump key press

//Collision
touchingBlock = array_create(4, false);	//wheter the object is touching a block from: 0 - left; 1 - top; 2 - right; 3 - bottom
										//the object has to be moving to the block (standing next to a block with speed of 0 isn't touching)
//Inventory References
playerChosenPosition = [0, 0];
playerInventoryGrid = obj_Inventory.inventoryGrid;
playerArmorGrid = obj_Inventory.armorGrid;
playerToolGrid = obj_Inventory.toolGrid;

//Networking
clientId = obj_GameManager.clientId;
clientName = obj_Menu.textFieldArray[0];
objectId = noone;
serverSide = obj_GameManager.serverSide;
clientSocket = noone;
alarm[0] = POSITION_UPDATE;	//update the player's position
