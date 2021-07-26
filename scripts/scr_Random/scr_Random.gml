/// Function returning a random value (0. - 1.) based on given vec2 value.
function random_value(_x, _y)
{
	return abs(frac(sin(dot_product(_x, _y, 12.9898, 78.233)) * 43758.5453));
}

/// Function returning a random value based on given vec2 value && given generation seed.
function random_seed_value(_x, _y, _generationSeed)
{
	return floor(abs(frac(sin(dot_product(_x, _y, 12.9898, 78.233)) * 43758.5453)) * 99999 * _generationSeed);
}

/// Function returning a generation seed based on given world seed.
function get_generation_seed(_worldSeed)
{
	return random_value(_worldSeed + 1, _worldSeed + 1);
}

/// Function returning a random value (0. - 1.) based on given vec2 value.
function random_vector(_x, _y)
{
	random_set_seed(floor(random_value(_x, _y) * 99999));
	return [random(1), random(1)];
}

/// Function returning a random vector from the given vector set.
function random_limited_vector(_x, _y, _vectorSet)
{
	//Get a Random Vector
	var _randomVector = random_vector(_x, _y);
	
	//Return a Random Limited Vector
	switch (_vectorSet)
	{
		//Random Directional Vector
		case 0:
		{
			return [_randomVector[0], _randomVector[1]];
		}
		break;
		
		//8-Direcitional Vector (left, left up, up, right up, right, right down, down, left down)
		case 1:
		{
			var _vectorX = (_randomVector[0] > 0.333) - (_randomVector[0] > 0.666) * 2;
			var _vectorY = (round(_randomVector[1]) * 2 - 1) * 
						   (_randomVector[1] > 0.333 || _randomVector[0] <= 0.333);
			return [_vectorX, _vectorY];
		}
		break;
	
		//Horizontal-Vertical Vector (left, up, right, down)
		case 2:
		{
			var _vectorX = (_randomVector[0] > 0.5) - (_randomVector[0] > 0.75) * 2;
			var _vectorY = (round(_randomVector[1]) * 2 - 1) * (_randomVector[0] <= 0.5);
			return [_vectorX, _vectorY];
		}
		break;
		
		//Diagonal Vector (left up, right up, right down, left down)
		case 3:
		{
			var _vectorX = (_randomVector[0] > 0.5) * 2 - 1;
			var _vectorY = (_randomVector[1] > 0.5) * 2 - 1;
			return [_vectorX, _vectorY];
		}
		break;
	}
}
