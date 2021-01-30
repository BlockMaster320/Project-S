//Randomize the Game
randomize();

//Create a Game File if There Ins't One Already
if (!file_exists("gamesave.sav"))
{
	//Create an Array Storing World Save Files
	var _worldFileArray = array_create(0);
	
	//Create a Unique Client ID
	var _clientId = random(4294967296);
	clientId = _clientId;
	
	//Add the Game Data to the Main Struct
	var _gameFileStruct =
	{
		worldFileArray : _worldFileArray,
		clientId : string(_clientId)
	};
	
	//Save the Main Map as a JSON String
	var _saveString = json_stringify(_gameFileStruct);
	json_string_save(_saveString, "gamesave.sav");
}

//Load the clientId From an Existing Game File
else
{
	//Load && Set the clientId
	var _gameFileStruct = json_parse(json_string_load("gamesave.sav"));
	var _clientId = variable_struct_get(_gameFileStruct, "clientId");
	clientId = _clientId;
}

//Deactivate the World Managers
instance_deactivate_layer("WorldManagers");
