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
charSet = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM_-/.,&0123456789";
textField = noone;
textFieldArray = array_create(9, "");
textFieldArray[1] = "127.0.0.1";
textFieldPassiveArray = array_create(9, "");	//stores part of the string that's shown when the text field isn't activated
/*for (var _i = 0; _i < array_length(textFieldArray); _i ++)	//fill the textFileArray with empty strings
	textFieldArray[_i] = "";*/
textCursorPosition = 0;
textEdgeLeft = 0;	//counting from 0
textEdgeRight = 99;	//counting from 0; just some random larger number
textCursorIsVisible = true;
alarm[0] = CURSOR_BLINK_SPEED;	//alarm that makes the textCursor blink
