{

/// Function generating a new world.
function world_generate(_worldWidth, _worldHeight, _generationSeed, _seaLevel)
{
	//Generate the World
	var _worldGrid = ds_grid_create(_worldWidth, _worldHeight);
	var _biome = id_get_biome(0);
	var _biomeTransition = 0;
	var _terrainHeightPrevious = _seaLevel;
	var _treePrevious = false;
	for (var _x = 0; _x < _worldWidth; _x ++)	//loop trough the terrain columns
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
		if (random(1) <= _biome.treeDensity/* && !_treePrevious*/)
		{
			var _log = new Block(2);
			ds_grid_set_region(_worldGrid, _x, _terrainHeight - 3, _x, _terrainHeight - 1, _log);	//set the layer's blocks
			/*_treePrevious = true;*/
		}
		/*else _treePrevious = false;*/
	
		//Set Variables for the Next Iteration
		_biomeTransition = clamp(_biomeTransition + 1, 0, 10);
		_terrainHeightPrevious = _terrainHeight;
	}
	return _worldGrid;
}

/*
function chunkStruct_get(_x, _y)
{
	var _chunkPos = string(_x) + "," + string(_y);
	return variable_struct_get(obj_WorldManager.chunkStruct, _chunkPos);
}*/
}

/// Function generating a chunk.
function chunk_generate(_chunkX, _chunkY, _generationSeed)
{
	//Create a New Chunk && Get the Its World Position
	var _chunk = array_create(CHUNK_SIZE, array_create(CHUNK_SIZE, 0));
	var _chunkCorner1 = [_chunkX * CHUNK_SIZE, _chunkY * CHUNK_SIZE];
	var _chunkCorner2 = [_chunkX * CHUNK_SIZE + CHUNK_SIZE - 1, _chunkY * CHUNK_SIZE + CHUNK_SIZE - 1];
	
	//Set the Biome
	var _biome = id_get_biome(0);
	var _layers = _biome.terrainLayers;
	
	var _topBlocksY = array_create(CHUNK_SIZE, undefined);
	
	//Generate the Vertical Slices of the Chunk
	for (var _x = 0; _x < CHUNK_SIZE; _x ++)
	{
		//Get the Terrain's Height
		var _noiseValue = noise_perlin(_chunkCorner1[0] + _x + 20000, 5, _biome.frequency, _biome.octaves,
									   _biome.lacunarity, _biome.persistence, _generationSeed);
		var _height = round(SEA_LEVEL - _biome.groundLevel - _noiseValue * _biome.terrainHeight);
		
		//Get the Starting Y Position
		if (_chunkCorner2[1] < _height) continue;
		var _startY = (CHUNK_SIZE + max(_chunkCorner1[1], _height) % CHUNK_SIZE) % CHUNK_SIZE;	//y position within the chunk
		var _startBlockY = _chunkCorner1[1] + _startY;	//y position within the world
		
		//Generate Individual Terrain Layers
		var _y = _startY;
		var _totalHeight = _height;
		for (var _i = 0; _i < array_length(_layers); _i ++)
		{
			//Get the Layer
			var _layer = _layers[_i];
			_totalHeight += _layer[1];
			
			//Check Wheter the Chunk Contains a Part Ground
			if (_totalHeight > _startBlockY || _layer[1] == 0)
			{
				//Get How Many Blocks of the Layer to Add to the Vertical Slice
				var _blocksToPlace = (_layer[1] > 0) ? min(max(0, CHUNK_SIZE - _y),
													   min(_totalHeight - _startBlockY, _layer[1]))
													 : max(0, CHUNK_SIZE - _y);
				
				//Add the Blocks of the Layer
				repeat (_blocksToPlace)
				{
					_chunk[_x, _y] = new Block(_layer[0]);
					_y ++;
				}
				
				//Break When the Chunk Is Fully Filled with Blocks
				if (_y == CHUNK_SIZE) break;
			}
		}
		
		_topBlocksY[_x] =_startBlockY;	//add Y position the uppermost block to the _topBlocksY
	}
	
	//Set the Chunk in the chunkStruct
	chunk_save(_chunkX, _chunkY, _chunk);
	
	//Check Wheter Chunks Adjacent to the Generated One Exist (for tiling)
	var _chunkExistsTop = (chunk_get(_chunkX, _chunkY - 1, false) != undefined);
	var _chunkExistsRight = (chunk_get(_chunkX + 1, _chunkY, false) != undefined);
	var _chunkExistsBottom = (chunk_get(_chunkX, _chunkY + 1, false) != undefined);
	var _chunkExistsLeft = (chunk_get(_chunkX - 1, _chunkY, false) != undefined);
	
	//Tile Necessary Blocks
	for (var _pos = 0; _pos < CHUNK_SIZE; _pos ++)
	{
		//Correct the Tiling of the Closest Rows/Columns of Blocks of the Adjacent Chunks
		if (_chunkExistsTop) block_tile(_chunkCorner1[0] + _pos, _chunkCorner1[1] - 1, false);
		if (_chunkExistsRight) block_tile(_chunkCorner2[0] + 1, _chunkCorner1[1] + _pos, false);
		if (_chunkExistsBottom) block_tile(_chunkCorner1[0] + _pos, _chunkCorner2[1] + 1, false);
		if (_chunkExistsLeft) block_tile(_chunkCorner1[0] - 1, _chunkCorner1[1] + _pos, false);
		
		//Tile the Uppermost Block && the Blocks Below It
		var _blockY = _topBlocksY[_pos];	//get the uppermost block's Y && X position
		if (_blockY == undefined) continue;
		var _blockX = _chunkCorner1[0] + _pos;
		
		var _blockYPrevious = _topBlocksY[max(0, _pos - 1)];	//get the Y position of the adjacent blocks
		var _blockYNext = _topBlocksY[min(CHUNK_SIZE - 1, _pos + 1)];
		if (_blockYPrevious == undefined || _pos == 0) _blockYPrevious = _chunkCorner2[1] + 1;
		if (_blockYNext == undefined || _pos == CHUNK_SIZE - 1) _blockYNext = _chunkCorner2[1] + 1;
		
		var _verticalBlocks = max(1, max(_blockYPrevious, _blockYNext) - _blockY);	//tile the uppermost block && the blocks below it that has no block from one of its side
		for (var _i = 0; _i < _verticalBlocks; _i ++)
			block_tile(_blockX, _blockY + _i, false);
	}
	
	/*_chunk = chunk_get(_chunkX, _chunkY, false);*/
	return _chunk;
}

/// Function returning a chunk on a given chunk position.
/// Generates a new chunk if necessarily.
function chunk_get(_chunkX, _chunkY, _generateChunk)
{
	//Get the Chunk from the chunkStruct
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	var _chunk = obj_WorldManager.chunkStruct[$ _fileChunkPos];
	
	//Otherwise, Get the Chunk from the worldStruct
	if (_chunk == undefined)
	{
		//Get the Chunk from the worldStruct
		var _worldStruct = obj_WorldManager.worldStruct;
		_chunk = _worldStruct[$ _fileChunkPos];
		
		//Otherwise, Generate a New Chunk || Get the Chunk from the Server
		if (_chunk == undefined)
		{
			//Generate a New Chunk
			if (obj_GameManager.serverSide != false)
			{
				if (_generateChunk)
				{
					//Generate the Chunk
					_chunk = chunk_generate(_chunkX, _chunkY, obj_WorldManager.generationSeed);
				}
			}
			//Get the Chunk from the Server
			else
			{
				var _clientBuffer = obj_Client.clientBuffer;
				var _clientSocket = obj_Client.client;
				message_chunk_get(_clientBuffer, _chunkX, _chunkY);
				network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
			}
		}
	}
	return _chunk;
}

/// Function setting a given chunk to a given position in the chunkStruct.
function chunk_set(_chunkX, _chunkY, _chunk)
{
	if (_chunk == undefined) return;
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	variable_struct_set(obj_WorldManager.chunkStruct, _fileChunkPos, _chunk);
}

/// Function unsetting a chunk on a given position in the chunkStruct.
function chunk_unset(_chunkX, _chunkY)
{
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	variable_struct_remove(obj_WorldManager.chunkStruct, _fileChunkPos);
}

/// Function saving a chunk on a given position to the worldStruct.
function chunk_save(_chunkX, _chunkY, _chunk)
{
	//Get the Chunk
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	
	//Get the Chunk If It's Not Provided
	if (_chunk == noone)
		_chunk = chunk_get(_chunkX, _chunkY, true);
	
	//Save the Chunk
	var _worldStruct = obj_WorldManager.worldStruct;
	variable_struct_set(_worldStruct, _fileChunkPos, _chunk);
}

/// Function returning a block on a given poisition in the world.
function block_pos_get(_x, _y)
{
	//Get the Block's Chunk
	var _chunkX = floor((_x / CELL_SIZE) / CHUNK_SIZE);
	var _chunkY = floor((_y / CELL_SIZE) / CHUNK_SIZE);
	var _chunk = chunk_get(_chunkX, _chunkY, true);
	
	//Get the Block
	var _blockX = (CHUNK_SIZE + floor(_x / CELL_SIZE) % CHUNK_SIZE) % CHUNK_SIZE;
	var _blockY = (CHUNK_SIZE + floor(_y / CELL_SIZE) % CHUNK_SIZE) % CHUNK_SIZE;
	
	if (_chunk == undefined) return undefined;
	return _chunk[_blockX][_blockY];
}

/// Function returning a block on a given block position.
/// _generateChunk - generate a new chunk if necessarily
function block_get(_blockX, _blockY, _generateChunk)
{
	//Get the Block's Chunk
	var _chunkX = floor(_blockX / CHUNK_SIZE);
	var _chunkY = floor(_blockY / CHUNK_SIZE);
	var _chunk = chunk_get(_chunkX, _chunkY, _generateChunk);
	
	//Get the Block's Position Within the Chunk
	_blockX = (CHUNK_SIZE + _blockX % CHUNK_SIZE) % CHUNK_SIZE;
	_blockY = (CHUNK_SIZE + _blockY % CHUNK_SIZE) % CHUNK_SIZE;
	
	if (_chunk == undefined) return undefined;
	return _chunk[_blockX][_blockY];
}

/// Function setting a block on a given position to a given value.
function block_set(_blockX, _blockY, _value)
{
	//Get the Block's Chunk
	var _chunkX = floor(_blockX / CHUNK_SIZE);
	var _chunkY = floor(_blockY / CHUNK_SIZE);
	var _chunk = chunk_get(_chunkX, _chunkY, true);
	
	//Get the Block's Position Within the Chunk
	_blockX = (CHUNK_SIZE + _blockX % CHUNK_SIZE) % CHUNK_SIZE;
	_blockY = (CHUNK_SIZE + _blockY % CHUNK_SIZE) % CHUNK_SIZE;
	
	//Seth the Value in the Chunk
	_chunk[_blockX][_blockY] = _value;
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	variable_struct_set(obj_WorldManager.chunkStruct, _fileChunkPos, _chunk);
}
