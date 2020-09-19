/// Function for mapping a value to the given range.

function map(_value, _currentMin, _currentMax, _targetMin, _targetMax)
{
	return _targetMin + ((_value - _currentMin) / (_currentMax - _currentMin)) * (_targetMax - _targetMin);
}
