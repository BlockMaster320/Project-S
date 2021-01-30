//Item's Slot Structure
itemSlot = new Slot(0, 15);
/*
//Item Collection && Stacking
collectItem = false;
approachSpeed = 0;
collectCooldown = 0;	//time after which the item can be collected
stackCooldown = 0;	//time after which the item can be stacked with other item
stackRange = CELL_SIZE * 2;

//Movement
horizontalSpeed = 0;
verticalSpeed = 0;
gravityAccel = 0.25;

//Collision
touchingBlock[3] = false;*/

//Movement Interpolation
xOrigin = x;
yOrigin = y;
xTarget = x;
yTarget = y;
moveTime = 0;

//Networking
objectId = noone;
