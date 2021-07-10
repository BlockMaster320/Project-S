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

/*
show_debug_message("x: " + string(x));
show_debug_message("y: " + string(y));*/

/*
//temporary movement for chunk testing
x += (keyboard_check(ord("D")) - keyboard_check(ord("A"))) * 3;
y += (keyboard_check(ord("S")) - keyboard_check(ord("W"))) * 3;
*/
