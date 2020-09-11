//Get Player's Input
scr_Input();

//Horizontal Movement
movement(keyRight, keyLeft);

//Vertical Movement
if (jumpTime <= 0) gravity();	//gravity
jump(keyJumpPressed, keyJump);	//jump

//Collision
collision();
