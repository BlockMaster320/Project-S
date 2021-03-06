//Draw Block Interaction
if (!inventoryMenu)
{
	//Get Player's Center Position									// /*for testing only
	var _playerX = 0;
	var _playerY = 0;
	if (instance_exists(obj_PlayerLocal))
	{
		_playerX = obj_PlayerLocal.x + obj_PlayerLocal.sprite_width * 0.5;
		_playerY = obj_PlayerLocal.y + obj_PlayerLocal.sprite_height * 0.5;
	}																// */

	//Get Selected Block's Position
	var _blockDrawX = (mouse_x div CELL_SIZE) * CELL_SIZE;
	var _blockDrawY = (mouse_y div CELL_SIZE) * CELL_SIZE;

	//Draw Block Selection
	draw_set_alpha(0.05);
	draw_circle_colour(_playerX, _playerY, interactionRange, c_white, c_white, false);
	draw_set_alpha(1);

	//Draw Mine Progress
	var _progressFrame = floor((mineProgress / mineBlockEndurance) * 5);
	draw_sprite_ext(spr_MineProgress, _progressFrame, _blockDrawX, _blockDrawY, 1, 1, 0, c_white, 1);

	if (inRange)
		draw_sprite_ext(spr_BlockSelection, 0, _blockDrawX, _blockDrawY, 1, 1, 0, c_white, 1);
}
