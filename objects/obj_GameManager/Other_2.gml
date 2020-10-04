//Randomize the Game
randomize();

//Create a Game File if There Ins't One Already
if (!file_exists("gamesave.sav"))
{
	//Create a List Storing World Save Files
	var _worldFileList = ds_list_create();
	
	//Add the Game Data to the Main Map
	var _gameFileMap = ds_map_create();
	ds_map_add_list(_gameFileMap, "worldFileList", _worldFileList);
	
	//Save the Main Map as a JSON String
	var _saveString = json_encode(_gameFileMap);
	json_string_save(_saveString, "gamesave.sav");
}

//Deactivate the World Managers
instance_deactivate_layer("WorldManagers");
