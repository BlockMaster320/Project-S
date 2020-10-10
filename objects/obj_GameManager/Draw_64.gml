//WORLD LOADING && CREATING
//Load the Game Data to a Variable
if (keyboard_check_pressed(ord("C")))
{
	if (file_exists("gamesave.sav"))
		gameFileMap = json_decode(json_string_load("gamesave.sav"));
}

//Draw && Interact with the World Selection
if (keyboard_check(ord("C")))
{
	//Get GUI Properties
	var _guiWidth = display_get_gui_width();
	var _guiHeight = display_get_gui_height();
	
	//Get the List Containg Names of the World Files
	var _worldFileList = gameFileMap[? "worldFileList"];
	var _worldFileNumber = ds_list_size(_worldFileList);
	
	//Draw the World Selection
	for (var _i = 0; _i <_worldFileNumber  + 1; _i ++)
	{
		var _selectionText = (_i == _worldFileNumber) ? "CREATE NEW WORLD" : _worldFileList[| _i];
		draw_text_transformed_colour(_guiWidth - 50, _guiHeight - 400 + _i * 30, _selectionText, 2, 2, 0,
										c_white, c_white, c_white, c_white, 1 - (_i != selectedFile) * 0.5);
	}
	
	//Change the File Selection
	if (mouse_wheel_down())
		selectedFile += 1;
	if (mouse_wheel_up())
		selectedFile -= 1;
	selectedFile = wrap(selectedFile, 0, _worldFileNumber + 1);
}

//Load an Existing World || Create a New One
if (keyboard_check_released(ord("C")))
{
	//Get the List Containg Names of the World Files
	var _worldFileList = gameFileMap[? "worldFileList"];
	var _worldFileNumber = ds_list_size(_worldFileList);
	
	//Load an Existing World
	if (selectedFile < _worldFileNumber)
	{
		var _worldFile = _worldFileList[| selectedFile];	//get the world file
		if (file_exists(_worldFile))
		{
			worldFile = _worldFile;
			world_load(_worldFile);
		}
	}
	
	//Create a New World
	else
	{
		//Create a Name for the New World File
		var _worldFile = "worldsave" + string(_worldFileNumber - 1);
		while (file_exists(_worldFile + ".sav"))
		{
			_worldFile += "_";
		}
		_worldFile += ".sav";
		
		//Destroy the World Entities && Clear the Data Structures
		world_clear();
		
		//Generate a New World && Set Its Properties
		var _worldSeed = irandom(9999);
		var _generationSeed = get_generation_seed(_worldSeed);
		var _worldWidth = 50;
		var _worldHeight = 100;
		
		with(obj_WorldManager)	//set the new world properties in the WorldManager
		{
			worldSeed = _worldSeed;
			generationSeed = _generationSeed;
			worldWidth = _worldWidth;
			worldHeight = _worldHeight;
			worldGrid = generate_world(_worldWidth, _worldHeight, _generationSeed, 10);
		}
		
		//Save the New World to a File
		worldFile = _worldFile;
		world_save(_worldFile);
		
		//Add the World File to the worlFileList && Update the gameFile
		ds_list_add(_worldFileList, _worldFile);
		ds_map_add_list(gameFileMap, "worldFileList", _worldFileList);
		var _saveString = json_encode(gameFileMap);
		json_string_save(_saveString, "gamesave.sav");
	}
	gameFileMap = noone;
}
