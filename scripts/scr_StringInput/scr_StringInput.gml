/// Function checking for key input to update a given string.
/// variables needed: textCursorPosition

function string_input(_string, _charSet)
{
	if (keyboard_check_pressed(vk_anykey))
	{
		//Get Input Data
		var _key = keyboard_key;
		var _char = keyboard_lastchar;
		
		//Add a Character to the String
		if (string_count(_char, _charSet) == 1)
		{
			_string = string_insert(_char, _string, textCursorPosition + 1);
			textCursorPosition ++;
		}
		keyboard_lastchar = "";
		
		//Handle Special Keys
		switch (_key)
		{
			case vk_space:	//space bar
			{
				_string = string_insert(" ", _string, textCursorPosition + 1);
				textCursorPosition ++;
			}
			break;
			
			case vk_backspace:	//enter key
			{
				_string = string_delete(_string, textCursorPosition, 1);
				textCursorPosition --;
			}
			break;
		}
	}
	return _string;
}
