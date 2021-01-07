//Set Menu State
inGame = false;
menuState = noone;
menuStateStack = ds_stack_create();

//Set World File Variables
gameFile = "gamesave.sav";
gameFileStruct = noone;
worldFileArray = noone;
selectedWorldFile = noone;	//number of the selected file in the worldFileList

//Text Fields
charSet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_/&-";
textField = noone;
textFieldArray[9] = "ok";
for (var _i = 0; _i < array_length(textFieldArray); _i ++)	//fill the textFileArray with empty strings
	textFieldArray[_i] = "";
textCursorPosition = 0;
textEdgeLeft = 0;	//counting from 0
textEdgeRight = 99;	//counting from 0; just some random larger number
