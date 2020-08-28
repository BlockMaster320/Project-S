//Resize && Move the View Freely
var _zoom = (keyboard_check(ord("O")) - keyboard_check(ord("U"))) * 0.03;	//zoom
freeSize *= 1 + _zoom;
freeX -= _zoom * (camera_get_view_width(VIEW) * 0.5);
freeY -= _zoom * (camera_get_view_height(VIEW)* 0.5);

freeX += (keyboard_check(ord("L")) - keyboard_check(ord("J"))) * 3;	//movement
freeY += (keyboard_check(ord("K")) - keyboard_check(ord("I"))) * 3;

if (keyboard_check_pressed(ord("P")))	//reset the zoom && movement values
{
	freeSize = 1;
	freeX = 0;
	freeY = 0;
}

//Follow the Player
var _x = obj_Player.x + (obj_Player.sprite_width * 0.5) - viewWidth * 0.5;
var _y = obj_Player.y + (obj_Player.sprite_height * 0.5) - viewHeight * 0.5;

_x = clamp(_x, 0, obj_WorldManager.worldWidth * CELL_SIZE - viewWidth);
_y = clamp(_y, 0, obj_WorldManager.worldHeight * CELL_SIZE - viewHeight);
camera_set_view_pos(VIEW, _x + freeX, _y + freeY);
camera_set_view_size(VIEW, viewWidth * freeSize, viewHeight * freeSize);
