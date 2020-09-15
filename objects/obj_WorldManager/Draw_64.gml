for (var _i = 0; _i < 500; _i ++)
{
	for (var _j = 0; _j < 500; _j ++)
	{
		var _value = noise_spaghetti(_i, _j, 0.02, 1, 2, 0.5);
		draw_point_colour(_i, _j, make_colour_hsv(255, 0, _value * 255));
	}
}