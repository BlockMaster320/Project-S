//Game Saving && Loading
/*if (keyboard_check_pressed(ord("S")) && obj_Menu.inGame)
	world_save(worldFile);*/


//TESTING//
if (keyboard_check_pressed(ord("R")))	//restart the game
	game_restart();

if (keyboard_check_pressed(ord("F")))	//code speed testing
{
	var _timeSum = 0;
	var _timeTestNumber = 50;
	
	repeat (_timeTestNumber)
	{
		var _timeStart = get_timer();
		
		repeat (1)
		{
			var _testtt = block_pos_get(0, 0);
		}
		
		var _timeEnd = get_timer();
		_timeSum += (_timeEnd - _timeStart);
	}
	//ds_list_destroy(_testArray);
	
	var _timeAverage = _timeSum / _timeTestNumber;
	show_debug_message(string(_timeAverage) + "ms");
	//show_debug_message(string(_testArray));
}

/*
var _guiWidth = display_get_gui_width(); 
var _guiHeight = display_get_gui_width();
show_debug_message("guiWidth: " + string(_guiWidth));
show_debug_message("guiHeight: " + string(_guiHeight));*/
