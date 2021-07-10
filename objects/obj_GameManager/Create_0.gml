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


//Noise Testing
/*show_debug_message(frac(-1.5));*/

/*
for (var _i = 0; _i < 100; _i ++)
	show_debug_message(noise_perlin(_i, 5, 0.1, 1, 2, 0.5, 4152));

show_debug_message("___________________________________");
	
for (var _i = - 100; _i < 0; _i ++)
	show_debug_message(noise_perlin(_i, 5, 0.1, 1, 2, 0.5, 4152));
*/
/*
var _oke;
for (var _i = 0; _i < 100; _i ++)
	_oke = noise_perlin(_i, 5, 0.1, 1, 2, 0.5, 4152);

show_debug_message("___________________________________");
	
for (var _i = 0; _i > - 100; _i --)
	_oke = noise_perlin(_i, 5, 0.1, 1, 2, 0.5, 4152);*/


//Bitwise Operations Testing
/*
var _value = 0;
_value = _value | (1 << 5);
show_debug_message(_value);*/
