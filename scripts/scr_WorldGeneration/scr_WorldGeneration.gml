/// Function generating a new world.

 function world_generate(_worldWidth, _worldHeight, _generationSeed, _seaLevel)
{
	//Generate the World
	var _worldGrid = ds_grid_create(_worldWidth, _worldHeight);
	var _biome = id_get_biome(0);
	var _biomeTransition = 0;
	var _terrainHeightPrevious = _seaLevel;
	var _treePrevious = false;
	for (var _x = 0; _x < _worldWidth; _x ++)	//loop trought the terrain columns
	{
		//Change the Biome
		if (_x == 10)
		{
			_biome = id_get_biome(1);
			_biomeTransition = 0;
		}
	
		//Get the Top Height of the Terrain Column
		var _noiseValue = noise_perlin(_x, 5, _biome.frequency, _biome.octaves, _biome.lacunarity, _biome.persistence, _generationSeed);
		var _terrainHeight = _seaLevel - _biome.groundLevel - _noiseValue * _biome.terrainHeight;
		_terrainHeight = lerp(_terrainHeightPrevious, _terrainHeight, _biomeTransition * 0.1);
	
		//Generate Individual Layers of the Terrain Column
		var _terrainLayers = _biome.terrainLayers;
		var _layerHeightTop = _terrainHeight;
		for (var _i = 0; _i < array_length(_terrainLayers); _i ++)	//loop trought the biome's layers
		{
			var _block = new Block(_terrainLayers[_i][0]);	//get the layer information
			var _layerThickness = _terrainLayers[_i][1];
			var _layerHeightBottom = (_layerThickness > 0) ? _layerHeightTop + _layerThickness : _worldHeight;
		
			ds_grid_set_region(_worldGrid, _x, _layerHeightTop, _x, _layerHeightBottom, _block);	//set the layer's blocks
			_layerHeightTop = _layerHeightBottom;
		}
	
		//Generate a Tree
		random_set_seed(random_seed_value(_x + 1, 1, _generationSeed));
		if (random(1) <= _biome.treeDensity && !_treePrevious)
		{
			var _log = new Block(2);
			ds_grid_set_region(_worldGrid, _x, _terrainHeight - 3, _x, _terrainHeight - 1, _log);	//set the layer's blocks
			_treePrevious = true;
		}
		else _treePrevious = false;
	
		//Set Variables for the Next Iteration
		_biomeTransition = clamp(_biomeTransition + 1, 0, 10);
		_terrainHeightPrevious = _terrainHeight;
	}
	return _worldGrid;
}


/*
var _blockk = new Block(0);	//place some blocks for testing
var _blockSmall = new Block(1);
worldGrid[# 2, 4] = _blockk;
worldGrid[# 8, 3] = _blockSmall;
worldGrid[# 8, 4] = _blockk;
worldGrid[# 8, 5] = _blockSmall;
worldGrid[# 4, 7] = _blockSmall;
worldGrid[# 5, 7] = _blockk;
worldGrid[# 6, 7] = _blockSmall;*/
//worldGrid[# 8, 5] = _block;
//instance_deactivate_layer("TestBlocks");