/// Function for running 2 game instances instead of one.

function open_two_windows()
{
	if (parameter_count() == 3)
	{
		execute_shell(parameter_string(0) + " " +
					  parameter_string(1) + " " +
					  parameter_string(2) + " " +
					  parameter_string(3) + " -secondary" + " -tertiary", false);
		
		window_set_caption("Window1");	//first game instance
		window_set_position(100, 50);
	}
	
	if (parameter_count() > 3)
	{
		window_set_caption("Window2");	//second game instance
		window_set_position(720, 150);
	}
}
