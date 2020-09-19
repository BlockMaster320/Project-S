//World Properties
worldSeed = 0;
generationSeed = random_value(worldSeed + 1, worldSeed + 1);	//the actual value to use when generating the noise values

worldWidth = 50;
worldHeight = 100;
seaLevel = 10;	//sea surface level from the world's top

//World Grid
worldGrid = ds_grid_create(worldWidth, worldHeight);
drawTimer = 0;
#macro CELL_SIZE 16

//Generate the World
var _biome = id_get_biome(0);
var _biomeTransition = 0;
var _terrainHeightPrevious = seaLevel;
var _treePrevious = false;
for (var _x = 0; _x < worldWidth; _x ++)	//loop trought the terrain columns
{
	//Change the Biome
	if (_x == 10)
	{
		_biome = id_get_biome(1);
		_biomeTransition = 0;
	}
	
	//Get the Top Height of the Terrain Column
	var _noiseValue = noise_perlin(_x, 5, _biome.frequency, _biome.octaves, _biome.lacunarity, _biome.persistence);
	var _terrainHeight = seaLevel - _biome.groundLevel - _noiseValue * _biome.terrainHeight;
	_terrainHeight = lerp(_terrainHeightPrevious, _terrainHeight, _biomeTransition * 0.1);
	
	//Generate Individual Layers of the Terrain Column
	var _terrainLayers = _biome.terrainLayers;
	var _layerHeightTop = _terrainHeight;
	for (var _i = 0; _i < array_length(_terrainLayers); _i ++)	//loop trought the biome's layers
	{
		var _block = new Block(_terrainLayers[_i][0]);	//get the layer information
		var _layerThickness = _terrainLayers[_i][1];
		var _layerHeightBottom = (_layerThickness > 0) ? _layerHeightTop + _layerThickness : worldHeight;
		
		ds_grid_set_region(worldGrid, _x, _layerHeightTop, _x, _layerHeightBottom, _block);	//set the layer's blocks
		_layerHeightTop = _layerHeightBottom;
	}
	
	//Generate a Tree
	random_set_seed(random_seed_value(_x + 1, 1, generationSeed));
	if (random(1) <= _biome.treeDensity && !_treePrevious)
	{
		var _log = new Block(2);
		ds_grid_set_region(worldGrid, _x, _terrainHeight - 3, _x, _terrainHeight - 1, _log);	//set the layer's blocks
		_treePrevious = true;
	}
	else _treePrevious = false;
	
	//Set Variables for the Next Iteration
	_biomeTransition = clamp(_biomeTransition + 1, 0, 10);
	_terrainHeightPrevious = _terrainHeight;
}


var _blockk = new Block(0);	//place some block for testing
var _blockSmall = new Block(1);
worldGrid[# 2, 4] = _blockk;
worldGrid[# 8, 3] = _blockSmall;
worldGrid[# 8, 4] = _blockk;
worldGrid[# 8, 5] = _blockSmall;
worldGrid[# 4, 7] = _blockSmall;
worldGrid[# 5, 7] = _blockk;
worldGrid[# 6, 7] = _blockSmall;
//worldGrid[# 8, 5] = _block;
//instance_deactivate_layer("TestBlocks");

//Create a Vertex Buffer for Drawing the World
vertex_format_begin();

vertex_format_add_position();	//add properties to the vertex format
vertex_format_add_texcoord();
vertex_format_add_color();

vertexFormat = vertex_format_end();	//store the vertex format inside a variable
vertexBuffer = vertex_create_buffer();	//create a vertex buffer
drawTexture = sprite_get_texture(spr_Block, 0);
