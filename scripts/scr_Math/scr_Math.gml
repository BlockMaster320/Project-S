/// Function for mapping a value to a given range.

function map(_value, _currentMin, _currentMax, _targetMin, _targetMax)
{
	return _targetMin + ((_value - _currentMin) / (_currentMax - _currentMin)) * (_targetMax - _targetMin);
}

/// Function wrapping a given value around when exceeding a given range.

function wrap(_value, _min, _max)
{
	var _difference = _max - _min;
	if (_difference == 0) return 0;
	return (_value >= 0) ? _min + _value % _difference
						 : _max + _value % _difference;
}
