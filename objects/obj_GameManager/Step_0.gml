//Game Saving && Loading
if (keyboard_check_pressed(ord("S")))
	world_save(worldFile);


//TESTING//
if (keyboard_check_pressed(ord("R")))	//restart the game
	game_restart();

if (keyboard_check_pressed(ord("F")))	//code speed testing
{
	var _timeSum = 0;
	var _timeTestNumber = 1;
	
	repeat (_timeTestNumber)
	{
		var _timeStart = get_timer();
		
		repeat (1)
		{
			world_save(worldFile);
		}
		
		var _timeEnd = get_timer();
		_timeSum += (_timeEnd - _timeStart);
	}
	//ds_list_destroy(_testArray);
	
	var _timeAverage = _timeSum / _timeTestNumber;
	show_debug_message(string(_timeAverage) + "ms");
	//show_debug_message(string(_testArray));
}
