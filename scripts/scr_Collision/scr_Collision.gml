/// Function checking  for collision with a block in the worldGrid.
/// modifiying variables: x, y, horizontalSpeed, verticalSpeed, touchingBlock[4]

function collision()
{
	//Reset touchingBlock Values
	touchingBlock = [0, 0, 0, 0];
	
	//Horizontal Collision
	x += horizontalSpeed;
	var _resetSpeed = false;	//make the speed 0 after checking for collision on every collision point
	var _verticalCells = ceil(sprite_height / CELL_SIZE);	//numbers of worldGrid cells the sprite occupies vertically
	var _spriteCellHeight = sprite_height / _verticalCells;	//(based on that number of horizontal collision points is decided)

	for (var _i = 0; _i < _verticalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _xRounded = (sign(horizontalSpeed == 1)) ? ceil(x) : floor(x);
		var _collisionPoint = [(_xRounded + (sprite_width * 0.5) * (sign(horizontalSpeed) + 1)) div CELL_SIZE, (y + _spriteCellHeight * _i) div CELL_SIZE];
		var _collisionCell = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionCell != 0)
		{
			var _xOriginal = x;
			x = (sign(horizontalSpeed) == 1) ? ceil(x) : floor(x);	//round the x value according to the movement direction
			var _collisionMask = id_get_item(_collisionCell.blockId).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1],
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2], _collisionPoint[1] * CELL_SIZE + _collisionMask[3] - 1, id, true, false))
			{
				if (sign(horizontalSpeed) = 1)
				{
					x = _collisionPoint[0] * CELL_SIZE + _collisionMask[0] - sprite_width;
					touchingBlock[2] = true;
				}
				else if (sign(horizontalSpeed) = - 1)
				{
					x = _collisionPoint[0] * CELL_SIZE + _collisionMask[2];
					touchingBlock[0] = true;
				}
			
				_resetSpeed = true;;
			}
			else x = _xOriginal;	//don't round the x value if there's no collision
		}
	}
	horizontalSpeed *= (!_resetSpeed);

	//Vertical Collision
	y += verticalSpeed;
	var _resetSpeed = false;	//make the speed 0 after checking for collision on every collision point
	var _horizontalCells = ceil(sprite_width / CELL_SIZE);	//number of worldGrid cells the sprite occupies horizontally
	var _spriteCellWidth = sprite_width / _horizontalCells;	//(based on that number of vertical collision points is decided)

	for (var _i = 0; _i < _horizontalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _yRounded = (sign(verticalSpeed == 1)) ? ceil(y) : floor(y);
		var _collisionPoint = [(x + _spriteCellWidth * _i) div CELL_SIZE, (_yRounded + (sprite_height * 0.5) * (sign(verticalSpeed) + 1)) div CELL_SIZE];
		var _collisionCell = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionCell != 0)
		{
			var _yOriginal = y;
			y = (sign(verticalSpeed == 1)) ? ceil(y) : floor(y);	//round the y value according to the movement direction
			var _collisionMask = id_get_item(_collisionCell.blockId).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1] - 1,
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2] - 1, _collisionPoint[1] * CELL_SIZE + _collisionMask[3], id, true, false))
			{
				if (sign(verticalSpeed) = 1)
				{
					y = _collisionPoint[1] * CELL_SIZE + _collisionMask[1] - sprite_height;
					touchingBlock[3] = true;
				}
				else if (sign(verticalSpeed) = - 1)
				{
					y = _collisionPoint[1] * CELL_SIZE + _collisionMask[3];
					touchingBlock[1] = true;
				}
			
				_resetSpeed = true;
			}
			else y = _yOriginal;	//don't round the y value if there's no collision
		}
	}
	verticalSpeed *= (!_resetSpeed);
}