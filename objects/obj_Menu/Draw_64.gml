//Set Draw Properties
var _guiWidth = display_get_gui_width();
var _guiHeight = display_get_gui_height();
var _drawCenter = _guiWidth * 0.5;

//Set Button Draw Properties
var _buttonWidth = 150;
var _buttonHeight = 50;
var _textFieldWidth = 250;
var _textFieldHeight = 50;
var _buttonSpacingY = 75;
var _buttonSpacingX = 75;

//Draw the Main Menu
if (!inGame)
{
	//Set Draw Origins
	var _originY = _guiHeight * 0.5;
	var _originX = 50;
	var _drawCenter = _guiWidth * 0.5 + 100;
	
	//Create the Main Menu Buttons
	button_redirect(_originX, _originY + _buttonSpacingY * 0, _originX + _buttonWidth,
					_originY + _buttonSpacingY * 0 + _buttonHeight, "SINGLEPLAYER", true, menu.singleplayer);
	button_redirect(_originX, _originY + _buttonSpacingY * 1, _originX + _buttonWidth,
					_originY + _buttonSpacingY * 1 + _buttonHeight, "MULTIPLAYER", true, menu.multiplayer);
	button_redirect(_originX, _originY + _buttonSpacingY * 2, _originX + _buttonWidth,
					_originY + _buttonSpacingY * 2 + _buttonHeight, "OPTIONS", false, menu.options);
	
	text_field(_originX, _originY + _buttonSpacingY * 3, _originX + _textFieldWidth,
			   _originY + _buttonSpacingY * 3 + _textFieldHeight, true, 0);
}
else
{
	//Set Draw Origins
	var _drawCenter = _guiWidth * 0.5;
	
	//Open the In-Game Menu
	if (keyboard_check_pressed(vk_escape))
	{
		if (menuState = noone)
		{
			menuState = menu.ingame;
			ds_stack_push(menuStateStack, noone);
		}
		else menuState = noone;
	}
}

if (menuState != noone)
{
	var _originY = _guiHeight * 0.2;
	var _originX1 = _drawCenter - _buttonSpacingX - _buttonWidth;
	var _originX2 = _drawCenter + _buttonSpacingX;
	
	draw_line_colour(_drawCenter, 0, _drawCenter, _guiHeight, c_blue, c_blue);

	switch (menuState)
	{
		case menu.singleplayer:
		{
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_text_transformed_colour(_drawCenter, 20, "SINGLEPLAYER", 1, 1, 0, c_white, c_white, c_white, c_white, 1);
			
			if (file_exists(gameFile))
			{
				//Set the worldFileList
				if (gameFileMap == noone)
				{
					gameFileMap = json_decode(json_string_load(gameFile));
					worldFileList = gameFileMap[? "worldFileList"];
				}
				
				//Draw the World Selection
				for (var _i = 0; _i < ds_list_size(worldFileList); _i ++)
				{
					//Draw the World Buttons
					if (button(_originX1, _originY + _buttonSpacingY * _i, _originX1 + _buttonWidth,
							   _originY + _buttonSpacingY * _i + _buttonHeight, worldFileList[| _i], true))
					{
						//Select a World
						selectedWorldFile = _i;
					}
					
					//Hightlight the Selected World
					if (_i == selectedWorldFile)
					{
						button_highlight(_originX1, _originY + _buttonSpacingY * _i, _originX1 + _buttonWidth,
										 _originY + _buttonSpacingY * _i + _buttonHeight);
					}
				}
				
				//Load the World Button
				var _worldIsSelected = selectedWorldFile != noone;
				if (button(_originX2, _originY + _buttonSpacingY * 0, _originX2 + _buttonWidth,
							   _originY + _buttonSpacingY * 0 + _buttonHeight, "Load the World", _worldIsSelected))
				{
					//Load the World
					var _worldFile = worldFileList[| selectedWorldFile];
					with (obj_GameManager)
					{
						worldFile = _worldFile;
						world_load(worldFile);
					}
					
					//Close the Main Menu
					ds_stack_clear(menuStateStack);
					menuState = noone;
					inGame = true;
				}
				
				//Delete the World Button
				var _worldIsSelected = selectedWorldFile != noone;
				if (button(_originX2, _originY + _buttonSpacingY * 1, _originX2 + _buttonWidth,
							   _originY + _buttonSpacingY * 1 + _buttonHeight, "Delete the World", _worldIsSelected))
				{
					//Delete the World File
					var _worldFile = worldFileList[| selectedWorldFile];
					file_delete(_worldFile);
					ds_list_delete(worldFileList, selectedWorldFile);
					
					//Update the gameFile
					ds_map_add_list(gameFileMap, "worldFileList", worldFileList);
					var _saveString = json_encode(gameFileMap);
					json_string_save(_saveString, gameFile);
					
					selectedWorldFile = noone;
				}
				
				//Create New World Button
				if (button(_originX2, _originY + _buttonSpacingY * 2, _originX2 + _buttonWidth,
						   _originY + _buttonSpacingY * 2 + _buttonHeight, "Create New World", true))
				{
					//Create a Name for the New World
					var _worldName = "worldsave" + string(ds_list_size(worldFileList));
					while (file_exists(_worldName + ".sav"))
					{
						_worldName += "_";
					}
					world_create(_worldName);
				}
			}
		}
		break;
	
		case menu.multiplayer:
		{
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_text_transformed_colour(_drawCenter, 20, "MULTIPLAYER", 1, 1, 0, c_white, c_white, c_white, c_white, 1);
			
			button_redirect(_drawCenter, _guiHeight * 0.3, _drawCenter + _buttonWidth,
							_guiHeight * 0.3 + _buttonHeight, "deep", true, menu.test1);
		}
		break;
	
		case menu.options:
		{
			draw_set_halign(fa_center);
			draw_set_valign(fa_top);
			draw_text_transformed_colour(_drawCenter, 20, "OPTIONS", 1, 1, 0, c_white, c_white, c_white, c_white, 1);
		}
		break;
		
		case menu.ingame:	//in-game menu
		{
			//Quit to the Main Menu
			if (button(_originX1, _originY + _buttonSpacingY * 3, _originX1 + _buttonWidth,
					   _originY + _buttonSpacingY * 3 + _buttonHeight, "MAIN MENU", true))
			{
				//Save && Clear the World
				with (obj_GameManager)
				{
					world_save(worldFile);
					world_clear();
					worldFile = noone;
				}
				instance_deactivate_layer("WorldManagers");
				
				//Close the In-Game Menu
				ds_stack_clear(menuStateStack);
				menuState = noone;
				inGame = false;
			}
		}
		break;
		
		case menu.test1:
		{
			button_redirect(_drawCenter, _guiHeight * 0.3, _drawCenter + _buttonWidth,
							_guiHeight * 0.3 + _buttonHeight, "deeper", true, menu.test2);
		}
		break;
		
		case menu.test2:
		{
			button_redirect(_drawCenter, _guiHeight * 0.3, _drawCenter + _buttonWidth,
							_guiHeight * 0.3 + _buttonHeight, "DHEEPER", true, menu.test3);
		}
		break;
		
		case menu.test3:
		{
			button_redirect(_drawCenter, _guiHeight * 0.3, _drawCenter + _buttonWidth,
							_guiHeight * 0.3 + _buttonHeight, "ok, ztop", true, menu.test4);
		}
		break;
	}
	
	//Back Button
	if (button(_originX2, _originY + _buttonSpacingY * 3, _originX2 + _buttonWidth,
			   _originY + _buttonSpacingY * 3 + _buttonHeight, "BACK", true))
	{
		if (!ds_stack_empty(menuStateStack))
		{
			menuState = ds_stack_pop(menuStateStack);
		}
	}
}

/*
var testString = "randstring";
show_debug_message(string_copy(testString, 0, 5));
show_debug_message(string_insert("1", testString, 1));
show_debug_message(string_delete(testString, 1, 1));
show_debug_message("\n");*/

//show_debug_message(textCursorPosition);
/*
show_debug_message("key: " + string(keyboard_key));
show_debug_message("lastKey: " + string(keyboard_lastkey));
show_debug_message("lastChar: " + string(keyboard_lastchar));
show_debug_message("string: " + string(keyboard_string) + "\n");*/

/*inputString = string_input(inputString, charSet);
show_debug_message(inputString);*/
