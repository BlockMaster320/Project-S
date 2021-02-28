//Get Player's Input
scr_Input();

//Horizontal Movement
movement(keyRight, keyLeft);

//Vertical Movement
if (jumpTime <= 0) gravity();	//gravity
jump(keyJumpPressed, keyJump);	//jump

//Update the Station List
if (horizontalSpeed != 0 || verticalSpeed - gravityAccel != 0)
	obj_Inventory.searchForStations = true;

//Collision
collision();
