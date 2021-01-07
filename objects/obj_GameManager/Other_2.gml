//Randomize the Game
randomize();

//Create a Game File if There Ins't One Already
if (!file_exists("gamesave.sav"))
{
	//Create an Array Storing World Save Files
	var _worldFileArray = array_create(0);
	
	//Add the Game Data to the Main Struct
	var _gameFileStruct =
	{
		worldFileArray : _worldFileArray
	};
	
	//Save the Main Map as a JSON String
	var _saveString = json_stringify(_gameFileStruct);
	json_string_save(_saveString, "gamesave.sav");
}

//Deactivate the World Managers
instance_deactivate_layer("WorldManagers");
