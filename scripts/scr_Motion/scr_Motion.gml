/// Function for horizontal movement.
/// modyfing varaibles: horizontalSpeed
/// variables needed: accel, frict, maxWalkSpeed
function movement(_moveRight, _moveLeft)
{
	var _moveSign = sign(_moveRight - _moveLeft);

	if (horizontalSpeed < maxWalkSpeed)	//acceleration
	{
		horizontalSpeed += accel * _moveSign;
		horizontalSpeed = clamp(horizontalSpeed, - maxWalkSpeed, maxWalkSpeed);
	}

	if (_moveSign != sign(horizontalSpeed))	//friction
	{
		var _speedSign = sign(horizontalSpeed);
		horizontalSpeed -= frict * sign(horizontalSpeed);
		if (sign(horizontalSpeed) != _speedSign)
			horizontalSpeed = 0;
	}
}

/// Function for jumping.
/// modifying variables: verticalSpeed, jumpTime, onGroundTimer, delayedJumpTimer
/// varaibles needed: touchingBlocks[4]
function jump(_jump, _jumpHold)
{
	if (_jump) delayedJumpTimer = 4;	//jump
	if (delayedJumpTimer && onGroundTimer > 0)
	{
		verticalSpeed = - jumpAccel;
		jumpTime = jumpMaxTime;
		onGroundTimer = 0;
	}
	if (!_jumpHold) jumpTime = 0;
	
	jumpTime --;	//update the jump variables
	onGroundTimer --;
	delayedJumpTimer --;
	if (touchingBlock[3]) onGroundTimer = 5;
	if (touchingBlock[1]) jumpTime = 3;	//set the jumpTime to a low value when hitting the ceiling
}

/// Function for applying gravity.
/// modyfing varaibles: verticalSpeed
/// variables needed: gravityAccel
function gravity()
{
	verticalSpeed += gravityAccel;	//gravity
}

/// Function for linearly interpolating between 2 position.
/// modyfing varaibles: x, y
/// variables needed: xOrigin, yOrigin, xTarget, yTarget, moveTime
function interpolate(_xOrigin, _yOrigin, _xTarget, _yTarget, _moveTime)
{
	x = lerp(_xOrigin, _xTarget, _moveTime / POSITION_UPDATE);
	y = lerp(_yOrigin, _yTarget, _moveTime / POSITION_UPDATE);
}