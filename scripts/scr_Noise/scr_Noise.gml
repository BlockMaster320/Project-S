/// Function returning Perlin Noise value for the given vec2 value.

function noise_perlin(_x, _y, _frequency, _octaves, _lacunarity, _persistence, _generationSeed)
{
	var _finalValue = 0;
	var _amplitude = 1;
	var _maxValue = 0;
	
	for (var _i = 0; _i < _octaves; _i ++)
	{
		//Get the Cell's Position Within the Grid && Point's Position Within the Cell
		var _cellX = floor(_x * _frequency);
		var _cellY = floor(_y * _frequency);
		var _pointX = frac(_x * _frequency);
		var _pointY = frac(_y * _frequency);
		
		//Get the Gradient Vectors of the 4 Nearest Grid Points
		random_set_seed(random_seed_value(_cellX, _cellY, _generationSeed));
		var _gradientVector1 = [choose(- 1, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX + 1, _cellY, _generationSeed));
		var _gradientVector2 = [choose(- 1, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX, _cellY + 1, _generationSeed));
		var _gradientVector3 = [choose(- 1, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX + 1, _cellY + 1, _generationSeed));
		var _gradientVector4 = [choose(- 1, 1), choose(- 1, 1)];
		
		//Get the Distance Vectors of the Point (Vectors from the Point to the Grid Points)
		var _distanceVector1 = [_pointX, - _pointY];
		var _distanceVector2 = [- (1 - _pointX ), - _pointY];
		var _distanceVector3 = [_pointX, 1 - _pointY];
		var _distanceVector4 = [- (1 -_pointX), 1 - _pointY];
		
		//Calculate Dot Product of the Gradient && Distance Vectors
		var _dotProduct1 = dot_product(_gradientVector1[0], _gradientVector1[1], _distanceVector1[0], _distanceVector1[1]);
		var _dotProduct2 = dot_product(_gradientVector2[0], _gradientVector2[1], _distanceVector2[0], _distanceVector2[1]);
		var _dotProduct3 = dot_product(_gradientVector3[0], _gradientVector3[1], _distanceVector3[0], _distanceVector3[1]);
		var _dotProduct4 = dot_product(_gradientVector4[0], _gradientVector4[1], _distanceVector4[0], _distanceVector4[1]);
		
		//Smooth the Point's x && y Position Using the Smootherstep Function for Interpolation
		var _pointXSmoothed = 6 * power(_pointX, 5) - 15 * power(_pointX, 4) + 10 * power(_pointX, 3);
		var _pointYSmoothed = 6 * power(_pointY, 5) - 15 * power(_pointY, 4) + 10 * power(_pointY, 3);
		
		//Interpolate Between the Dot Products
		var _interpolation1 = lerp(_dotProduct1, _dotProduct2, _pointXSmoothed);
		var _interpolation2 = lerp(_dotProduct3, _dotProduct4, _pointXSmoothed);
		var _interpolation3 = lerp(_interpolation1, _interpolation2, _pointYSmoothed);
		
		_finalValue += (_interpolation3 * 0.5 + 0.5) * _amplitude;
		_maxValue += _amplitude;
		_amplitude *= _persistence;
		_frequency *= _lacunarity;
	}
	return _finalValue / _maxValue;
}

/// Function returning "Spaghetti Noise" value for the given vec2 value.

function noise_spaghetti(_x, _y, _frequency, _octaves, _lacunarity, _persistence, _generationSeed)
{
	var _finalValue = 0;
	var _amplitude = 1;
	var _maxValue = 0;
	
	for (var _i = 0; _i < _octaves; _i ++)
	{
		//Get the Cell's Position Within the Grid && Point's Position Within the Cell
		var _cellX = floor(_x * _frequency);
		var _cellY = floor(_y * _frequency);
		var _pointX = frac(_x * _frequency);
		var _pointY = frac(_y * _frequency);
		
		//Get the Gradient Vectors of the 4 Nearest Grid Points
		random_set_seed(random_seed_value(_cellX, _cellY, _generationSeed));
		var _gradientVector1 = [choose(- 1, 0, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX + 1, _cellY, _generationSeed));
		var _gradientVector2 = [choose(- 1, 0, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX, _cellY + 1, _generationSeed));
		var _gradientVector3 = [choose(- 1, 0, 1), choose(- 1, 1)];
		
		random_set_seed(random_seed_value(_cellX + 1, _cellY + 1, _generationSeed));
		var _gradientVector4 = [choose(- 1, 0, 1), choose(- 1, 1)];
		
		//Get the Distance Vectors of the Point (Vectors from the Point to the Grid Points)
		var _distanceVector1 = [_pointX, - _pointY];
		var _distanceVector2 = [- (1 - _pointX ), - _pointY];
		var _distanceVector3 = [_pointX, 1 - _pointY];
		var _distanceVector4 = [- (1 -_pointX), 1 - _pointY];
		
		//Calculate Dot Product of the Gradient && Distance Vectors
		var _dotProduct1 = dot_product(_gradientVector1[0], _gradientVector1[1], _distanceVector1[0], _distanceVector1[1]);
		var _dotProduct2 = dot_product(_gradientVector2[0], _gradientVector2[1], _distanceVector2[0], _distanceVector2[1]);
		var _dotProduct3 = dot_product(_gradientVector3[0], _gradientVector3[1], _distanceVector3[0], _distanceVector3[1]);
		var _dotProduct4 = dot_product(_gradientVector4[0], _gradientVector4[1], _distanceVector4[0], _distanceVector4[1]);
		
		//Smooth the Point's x && y Position Using the Smootherstep Function for Interpolation
		var _pointXSmoothed = 6 * power(_pointX, 5) - 15 * power(_pointX, 4) + 10 * power(_pointX, 3);
		var _pointYSmoothed = 6 * power(_pointY, 5) - 15 * power(_pointY, 4) + 10 * power(_pointY, 3);
		
		//Interpolate Between the Dot Products
		var _interpolation1 = lerp(_dotProduct1, _dotProduct2, _pointXSmoothed);
		var _interpolation2 = lerp(_dotProduct3, _dotProduct4, _pointXSmoothed);
		var _interpolation3 = lerp(_interpolation1, _interpolation2, _pointYSmoothed);
		
		_finalValue += abs(_interpolation3) * _amplitude;
		_maxValue += _amplitude;
		_amplitude *= _persistence;
		_frequency *= _lacunarity;
	}
	return _finalValue / _maxValue;
}
