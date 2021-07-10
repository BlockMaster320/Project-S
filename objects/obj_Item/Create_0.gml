//Item's Slot Structure
itemSlot = new Slot(0, 1, noone);

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
active = true;	//item only interacts && checks collision when moving (for better performance)
horizontalSpeed = 0;
maxWalkSpeed = 1.3;
accel = 0.4;
frict = 0.5;
verticalSpeed = 0;
gravityAccel = 0.15;

//Collision
touchingBlock = array_create(4, 0);	//wheter the object is touching a block from: 0 - left; 1 - top; 2 - right; 3 - bottom

//Networking
objectId = noone;
if (obj_GameManager.networking)
	alarm[0] = POSITION_UPDATE;	
