/// Function checking for collision with any block in the worldGrid, modifying object's position && speed accordingly.
/// modifiying variables: x, y, horizontalSpeed, verticalSpeed, touchingBlock[4]

function collision()
{
	//Reset touchingBlock Values
	//touchingBlock = [0, 0, 0, 0];
	
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
		var _collisionBlock = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionBlock != 0)
		{
			var _xOriginal = x;
			var _yOriginal = y;
			x = (sign(horizontalSpeed) == 1) ? ceil(x) : floor(x);	//round the x value according to the movement direction
			y = (_i == 0) ? floor(y) : ceil(y);	//floor the y value based on the collision point position (checking for the very top one || all the others under it works fine)
			var _collisionMask = id_get_item(_collisionBlock.id).collisionMask;
		
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
			
				_resetSpeed = true;
			}
			else x = _xOriginal;	//don't round the x value if there's no collision
			y = _yOriginal;	//don't round the y value
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
		var _collisionBlock = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionBlock != 0)
		{
			var _yOriginal = y;
			var _xOriginal = x;
			y = (sign(verticalSpeed == 1)) ? ceil(y) : floor(y);	//round the y value according to the movement direction
			x = (_i == 0) ? floor(x) : ceil(x);	//floor the x value based on the collision point position (checking for the very left one || all the others to the rigth works fine)
			var _collisionMask = id_get_item(_collisionBlock.id).collisionMask;
			
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
			x = _xOriginal;	//don't round the x value
		}
	}
	verticalSpeed *= (!_resetSpeed);
}

/// Function checking for collision of an object with any block in the worldGrid.
/// The function isn't as precise as the original collision() function. (The precision wasn't needed so far.)

function check_collision(_object)
{
	//Get Object's Variables
	var _x = _object.x;	//get object's position && speed
	var _y = _object.y;
	var _horizontalSpeed = _object.horizontalSpeed;
	var _verticalSpeed = _object.horizontalSpeed;
	
	var _spriteWidth = _object.sprite_width;	//get object's size
	var _spriteHeight = _object.sprite_height;
	
	//Horizontal Collision
	var _verticalCells = ceil(_spriteHeight / CELL_SIZE);	//numbers of worldGrid cells the sprite occupies vertically
	var _spriteCellHeight = _spriteHeight / _verticalCells;	//(based on that number of horizontal collision points is decided)

	for (var _i = 0; _i < _verticalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _xRounded = (sign(_horizontalSpeed == 1)) ? ceil(_x) : floor(_x);
		var _collisionPoint = [(_xRounded + (_spriteWidth * 0.5) * (sign(_horizontalSpeed) + 1)) div CELL_SIZE, (_y + _spriteCellHeight * _i) div CELL_SIZE];
		var _collisionBlock = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionBlock != 0)
		{
			var _collisionMask = id_get_item(_collisionBlock.id).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1],
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2], _collisionPoint[1] * CELL_SIZE + _collisionMask[3] - 1, _object, true, false))
			{
				return true;
			}
		}
	}
	
	//Vertical Collision
	var _horizontalCells = ceil(_spriteWidth / CELL_SIZE);	//number of worldGrid cells the sprite occupies horizontally
	var _spriteCellWidth = _spriteWidth / _horizontalCells;	//(based on that number of vertical collision points is decided)

	for (var _i = 0; _i < _horizontalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _yRounded = (sign(_verticalSpeed == 1)) ? ceil(_y) : floor(_y);
		var _collisionPoint = [(_x + _spriteCellWidth * _i) div CELL_SIZE, (_yRounded + (_spriteHeight * 0.5) * (sign(_verticalSpeed) + 1)) div CELL_SIZE];
		var _collisionBlock = obj_WorldManager.worldGrid[# _collisionPoint[0], _collisionPoint[1]];
	
		//Check for Collision with the Block
		if (_collisionBlock != 0)
		{
			var _collisionMask = id_get_item(_collisionBlock.id).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1],	//in this check there is a slight difference from the collision() function to make the check more forgiving (- 1 pixel in the second argument was removed)
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2] - 1, _collisionPoint[1] * CELL_SIZE + _collisionMask[3], _object, true, false))
			{
				return true;
			}
		}
	}
	
	return false;
}

/// Function checking for collision of an object with a given block on a given position.
/// The function isn't as precise as the original collision() function. (The precision wasn't needed so far.)

function check_block_collision(_object, _colliderId, _colliderGridX, _colliderGridY)
{
	//Get Object's Variables
	var _x = _object.x;	//get object's position && speed
	var _y = _object.y;
	var _horizontalSpeed = _object.horizontalSpeed;
	var _verticalSpeed = _object.horizontalSpeed;
	
	var _spriteWidth = _object.sprite_width;	//get object's size
	var _spriteHeight = _object.sprite_height;
	
	//Horizontal Collision
	var _verticalCells = ceil(_spriteHeight / CELL_SIZE);	//numbers of worldGrid cells the sprite occupies vertically
	var _spriteCellHeight = _spriteHeight / _verticalCells;	//(based on that number of horizontal collision points is decided)

	for (var _i = 0; _i < _verticalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _xRounded = (sign(_horizontalSpeed == 1)) ? ceil(_x) : floor(_x);
		var _collisionPoint = [(_xRounded + (_spriteWidth * 0.5) * (sign(_horizontalSpeed) + 1)) div CELL_SIZE, (_y + _spriteCellHeight * _i) div CELL_SIZE];
	
		//Check for Collision with the Block
		if (_collisionPoint[0] == _colliderGridX && _collisionPoint[1] == _colliderGridY)
		{
			var _collisionMask = id_get_item(_colliderId).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1],
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2], _collisionPoint[1] * CELL_SIZE + _collisionMask[3] - 1, _object, true, false))
			{
				return true;
			}
		}
	}
	
	//Vertical Collision
	var _horizontalCells = ceil(_spriteWidth / CELL_SIZE);	//number of worldGrid cells the sprite occupies horizontally
	var _spriteCellWidth = _spriteWidth / _horizontalCells;	//(based on that number of vertical collision points is decided)

	for (var _i = 0; _i < _horizontalCells + 1; _i ++)	//iterate trought the horizontal corners && check for collision on their position
	{
		//Get the Block Struct (or 0 - Air) from the Corner Position
		var _yRounded = (sign(_verticalSpeed == 1)) ? ceil(_y) : floor(_y);
		var _collisionPoint = [(_x + _spriteCellWidth * _i) div CELL_SIZE, (_yRounded + (_spriteHeight * 0.5) * (sign(_verticalSpeed) + 1)) div CELL_SIZE];
	
		//Check for Collision with the Block
		if (_collisionPoint[0] == _colliderGridX && _collisionPoint[1] == _colliderGridY)
		{
			var _collisionMask = id_get_item(_colliderId).collisionMask;
		
			if (collision_rectangle(_collisionPoint[0] * CELL_SIZE + _collisionMask[0], _collisionPoint[1] * CELL_SIZE + _collisionMask[1] - 1,	//in this check there is a slight difference from the collision() function to make the check more forgiving (- 1 pixel in the second argument was removed)
									_collisionPoint[0] * CELL_SIZE + _collisionMask[2] - 1, _collisionPoint[1] * CELL_SIZE + _collisionMask[3], _object, true, false))
			{
				return true;
			}
		}
	}
	
	return false;
}
