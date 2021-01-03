/// Function for drawing && interacting with a button.

function button(_x1, _y1, _x2, _y2, _text, _isAbled)
{
	//Set Return Value
	var _returnValue = false;
	
	//Check Wheter the Button is Clickable
	if (_isAbled)
	{
		//Check Wheter the Button is Selected
		var _mouseWindowX = window_mouse_get_x();
		var _mouseWindowY = window_mouse_get_y();
		if (point_in_rectangle(_mouseWindowX, _mouseWindowY, _x1, _y1, _x2, _y2))
		{
			draw_rectangle_colour(_x1, _y1, _x2, _y2, c_gray, c_gray, c_gray, c_gray, false);	//draw selected button
			if (mouse_check_button_pressed(mb_left))
				_returnValue = true;
		}
		else
			draw_rectangle_colour(_x1, _y1, _x2, _y2, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);	//draw normal button
	}
	else
	{
		draw_set_alpha(0.5);
		draw_rectangle_colour(_x1, _y1, _x2, _y2, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);	//draw not abled button
		draw_set_alpha(1);
	}

	//Draw the Button Text
	draw_set_halign(fa_center);
	draw_set_valign(fa_middle);
	var _textX = _x1 + (_x2 - _x1) * 0.5;
	var _textY = _y1 + (_y2 - _y1) * 0.5;
	draw_text_transformed_colour(_textX, _textY, _text, 1, 1, 0, c_white, c_white, c_white, c_white, 1);
	draw_set_halign(fa_left);
	draw_set_valign(fa_top);
	
	return _returnValue;
}

/// Function creating a button which changes the menuState.
/// variables needed: menuState, menuStateStack

function button_redirect(_x1, _y1, _x2, _y2, _text, _isAbled, _menuState)
{
	if (button(_x1, _y1, _x2, _y2, _text, _isAbled))
	{
		//Set the First menuStateStack's Value to noone When Clicking the Main Menu Buttons
		if (_menuState == menu.singleplayer || _menuState == menu.multiplayer || _menuState == menu.options)
		{
			ds_stack_pop(menuStateStack);
			menuState = noone;
		}
		
		//Push the Last menuState to the Stack && Change the menuState
		ds_stack_push(menuStateStack, menuState);
		menuState = _menuState;
		return true;
	}
	else return false;
}

/// Function highlighting a button.

function button_highlight(_x1, _y1, _x2, _y2)
{
	draw_rectangle_colour(_x1, _y1, _x2, _y2, c_white, c_white, c_white, c_white, true);
	draw_set_alpha(0.3);
	draw_rectangle_colour(_x1, _y1, _x2, _y2, c_white, c_white, c_white, c_white, false);
	draw_set_alpha(1);
}

/// Function for drawing && interacting with a text field.
/// variables needed: textField, textFieldArray, textCursorPosition, charSet

function text_field(_x1, _y1, _x2, _y2, _isAbled, _index)
{
	//Check Wheter the Field is Clickable
	if (_isAbled)
	{
		//Check Wheter the Button is Selected
		var _mouseWindowX = window_mouse_get_x();
		var _mouseWindowY = window_mouse_get_y();
		if (point_in_rectangle(_mouseWindowX, _mouseWindowY, _x1, _y1, _x2, _y2))
		{
			if (mouse_check_button_pressed(mb_left))
			{
				textField = _index;
				keyboard_lastchar = "";
			}
		}
		
		//Draw the Text Field
		draw_rectangle_colour(_x1, _y1, _x2, _y2, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);	//the text field box
		var _textY = _y1 + (_y2 - _y1) * 0.5;	//set the text Y origin
		
		//Update the String if the Text Field is Active
		var _string = textFieldArray[_index];
		var _stringPart = string_copy(_string, textEdgeLeft + 1, textEdgeRight - textEdgeLeft);	//text functions are counting from 1 (that's why there's "+ 1" in many functions)
		var _textAlpha = 1;
		if (textField == _index)
		{
			//Update the String According to the Input
			_string = string_input(_string, charSet);
			_stringPart = string_copy(_string, textEdgeLeft + 1, textEdgeRight - textEdgeLeft);
			textFieldArray[_index] = _string;
			
			//Update the Text Cursor Position
			if (keyboard_check_pressed(vk_right))
				textCursorPosition ++;
			if (keyboard_check_pressed(vk_left))
				textCursorPosition --;
			textCursorPosition = clamp(textCursorPosition, 0, string_length(_string));
			
			//Update the Text Edges
			var _textFieldWidth = _x2 - _x1;
			if (string_width(_string) > _textFieldWidth)
			{
				//Set the Right Edge to the Cursor's Position on the First Text Edge Update
				if (textEdgeRight == 99)
					textEdgeRight = string_length(_string) - 1;
				
				//Update the Left Edge if the Cursor Exceeds the Right Edge
				if (textCursorPosition > textEdgeRight)
				{
					textEdgeRight = textCursorPosition;
					while (true)
					{
						textEdgeLeft ++;
						var _stringUpdate = string_copy(_string, textEdgeLeft + 1, textEdgeRight - textEdgeLeft);
						if (string_width(_stringUpdate) <= _textFieldWidth)
							break;
					}
				}
				
				//Update the Right Edge if the Cursor Exceeds the Left Edge
				if (textCursorPosition < textEdgeLeft)
				{
					textEdgeLeft = textCursorPosition;
					while (true)
					{
						textEdgeRight --;
						var _stringUpdate = string_copy(_string, textEdgeLeft + 1, textEdgeRight - textEdgeLeft);
						if (string_width(_stringUpdate) <= _textFieldWidth)
							break;
					}
				}
			}
			
			//Draw the Text Cursor
			_stringPart = string_copy(_string, textEdgeLeft + 1, textEdgeRight - textEdgeLeft);
			var _stringCursor = string_copy(_stringPart, 0, textCursorPosition - textEdgeLeft);
			var _textWidth = string_width(_stringCursor);
			var _textHeight = string_height(_string);
			var _textCursorX = _x1 + 5 + _textWidth;
			var _textCursorY1 = _textY + _textHeight * 0.5;
			var _textCursorY2 = _textY - _textHeight * 0.5;
			draw_line_width_colour(_textCursorX, _textCursorY1, _textCursorX, _textCursorY2, 1, c_white, c_white);
			
			//Deactivate the Text Field on Enter Key Press
			if (keyboard_check_pressed(vk_enter))
				textField = noone;
		}
		else _textAlpha = 0.5;
		
		//Draw the Text
		draw_set_valign(fa_middle);
		draw_text_transformed_colour(_x1 + 5, _textY, _stringPart, 1, 1, 0, c_white, c_white, c_white, c_white, _textAlpha);	//draw the string
		draw_set_valign(fa_top);
	}
	else
	{
		draw_set_alpha(0.5);
		draw_rectangle_colour(_x1, _y1, _x2, _y2, c_dkgray, c_dkgray, c_dkgray, c_dkgray, false);	//draw not abled text field box
		draw_set_alpha(1);
	}
	
}
