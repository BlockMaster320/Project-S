/// Function for drawing a circle sector.
function draw_circle_sector(_x, _y, _radius, _value, _resolution)
{
	//Draw a Background
	draw_set_alpha(0.3);
	draw_circle_colour(_x, _y, _radius * 1.3, c_black, c_black, false);
	draw_set_alpha(1);
	
	//Draw the Circle Sector Using Multiple Triangles
	var _angleIncrement = 360 / _resolution;
	for (var _i = 0; _i < round(_value * _resolution); _i ++)
	{
		var _x1 = _x + lengthdir_x(_radius, - _angleIncrement * _i);
		var _y1 = _y + lengthdir_y(_radius, - _angleIncrement * _i);
		var _x2 = _x + lengthdir_x(_radius, - _angleIncrement * _i - _angleIncrement);
		var _y2 = _y + lengthdir_y(_radius, - _angleIncrement * _i - _angleIncrement);
		draw_triangle_colour(_x, _y, _x1, _y1, _x2, _y2, c_ltgrey, c_ltgrey, c_ltgrey, false);
	}
}
