//Game Saving && Loading
selectedFile = 0;	//number of a file in the worldFileList to load
/*gameFileMap = noone;*/
worldFile = noone;	//currently loaded world file
closeWorld = false;

//Networking
networking = false;
clientId = noone;
serverSide = noone;

open_two_windows();	//run 2 instances of the game (for networking testing)
