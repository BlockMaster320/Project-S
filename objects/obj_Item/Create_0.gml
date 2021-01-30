//Item's Slot Structure
itemSlot = new Slot(0, 15);

//Item Collection
collectItem = false;
collectRange = 10;
collectCooldown = 0;	//time after which the item can be collected

approachObject = noone;
approachSpeed = 0;
approachAccel = 0.4;
maxApproachSpeed = 5;

//Item Stacking
stackCooldown = 10;	//time after which the item can be stacked with other item
stackRange = CELL_SIZE * 2;

//Movement
horizontalSpeed = 0;
verticalSpeed = 0;
gravityAccel = 0.25;

//Collision
touchingBlock[3] = false;

//Networking
objectId = noone;
if (obj_GameManager.networking)
	alarm[0] = POSITION_UPDATE;	
