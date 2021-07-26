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
	var _caveBroadness = _biome.caveBroadness;
	var _oreOccurence = _biome.oreOccurence;
	var _structureOccurence = _biome.structureOccurence;
	
	//Set Array	for Storing Y Positions of the Blocks to Tile
	var _topBlocksY = array_create(CHUNK_SIZE, undefined);	//y positions of the uppermost blocks
	var _tileBlocksY = array_create(CHUNK_SIZE, 0);	//array containing y position of each block created for tiling
	for (var _i = 0; _i < CHUNK_SIZE; _i ++)
		_tileBlocksY[_i] = [];
	
	//TERRAIN GENERATION//
	//Generate the Vertical Slices of the Chunk
	for (var _x = 0; _x < CHUNK_SIZE; _x ++)
	{
		//Get the Terrain's Height
		var _blockX = _chunkCorner1[0] + _x;
		var _noiseHeight = noise_perlin(_blockX + 20000, 5, _biome.terrainFrequency, _biome.terrainOctaves,
									    _biome.terrainLacunarity, _biome.terrainPersistence, _generationSeed);
		var _height = round(SEA_LEVEL - _biome.groundLevel - _noiseHeight * _biome.terrainHeight);
		
		//Get the Starting Y Position
		if (_chunkCorner2[1] < _height) continue;
		var _startY = (CHUNK_SIZE + max(_chunkCorner1[1], _height) % CHUNK_SIZE) % CHUNK_SIZE;	//y position within the chunk
		var _startBlockY = _chunkCorner1[1] + _startY;	//y position within the world
		
		if (_startBlockY == _height)
			_topBlocksY[_x] =_startBlockY;	//add Y position the uppermost block to the _topBlocksY
		
		//Noise Value That Determines How Much Are the Caves Going to Be Affecting the Surface
		var _noiseCavePenetration = (noise_perlin(_blockX + 20000, 5000,
												  _biome.cavePenetration, 1, 2, 0.5, _generationSeed) < 0.3);
		
		//Generate Individual Terrain Layers
		var _y = _startY;
		var _totalHeight = _height;
		for (var _i = 0; _i < array_length(_layers); _i ++)
		{
			//Get the Layer
			var _layer = _layers[_i];
			_totalHeight += _layer[1];
			
			//Check Wheter the Chunk Contains Ground
			if (_totalHeight > _startBlockY || _layer[1] == 0)
			{
				//Get How Many Blocks of the Layer to Add to the Vertical Slice
				var _blocksToPlace = (_layer[1] > 0) ? min(max(0, CHUNK_SIZE - _y),
													   min(_totalHeight - _startBlockY, _layer[1]))
													 : max(0, CHUNK_SIZE - _y);
				
				//Add the Blocks of the Layer
				var _firstBlock = true;
				repeat (_blocksToPlace)
				{
					//Set the Block ID
					var _blockId = _layer[0];
										
					//Get the Noise Value of the Block
					var _blockY = _chunkCorner1[1] + _y;
					var _noiseCave = noise_spaghetti(_blockX + 20000, _blockY + 5000,	//get value for the cave tunnels
													 _biome.caveFrequency, 1, 2, 0.5, _generationSeed);
					_noiseCave += max(0, noise_perlin(_blockX + 20000, _blockY + 5000,	//add value to create larger area filled with blocks
													  0.02, 1, 2, 0.5, _generationSeed) * 2.5 - 1.3);
					
					//Generate an Ore
					/*var _oreChunk = [_blockX >> 3, _blockY >> 3];*/
					var _noiseOre = noise_perlin(_blockX + 20000, _chunkCorner1[1] + _y + 5000,	//add value to create larger area filled with blocks
												 0.18, 1, 2, 0.5, _generationSeed);	 
					if (_noiseOre > 0.75)
					{
						//Loop through the oreOccurence Array && Add Each Ore's ID Certain Number of Times to Make It More or Less Probable to Be Chosen
						var _oreChoose = [];
						for (var _oreIndex = 0; _oreIndex < array_length(_oreOccurence); _oreIndex ++)
						{
							var _ore = _oreOccurence[_oreIndex];	//get the ore array
							if (_blockY < _ore[1]) break;
							
							repeat (_ore[2])	//add the ore's ID to the oreOccurence based on its probability
								array_push(_oreChoose, _ore[0]);
						}
						
						//Choose a Random Ore
						var _oreChooseLength = array_length(_oreChoose);
						if (_oreChooseLength != 0)
						{
							/*random_set_seed(random_seed_value(_oreChunk[0], _oreChunk[1], _generationSeed));*/	//this works (and even better) without setting the seed here because the seed is already set in the noise function for generating the ore (this also makes all the ores seperated)
							_blockId = _oreChoose[irandom(_oreChooseLength - 1)];
						}
					}
					
					//Set the Broadness of the Cave
					var _broadness = _caveBroadness * min(abs(_totalHeight - _startBlockY) / 12 + _noiseCavePenetration, 1);
					
					//Set the Block
					var _block = (_noiseCave >= _broadness) ? new Block(_blockId) : 0;
					_chunk[_x, _y] = _block;
					
					//Remove the Block's Y Position from the _topBlocksY If It's the Uppermost Blocks && Is Affected by the Caves (there is no block on its position)
					if (_firstBlock && _block == 0)
						_topBlocksY[_x] = undefined;
					
					//Add the Block to the _tileBlocksY Array for Tiling
					if (_block != 0)
						array_push(_tileBlocksY[_x], _y);
					
					_firstBlock = false;
					_y ++;
				}
				
				//Break When the Chunk Is Fully Filled with Blocks
				if (_y == CHUNK_SIZE) break;
			}
		}
		
		/*if (_topBlocksY[_x] != undefined)	//place boxes on the surface of the terrain for testing
			_chunk[_x, (CHUNK_SIZE + _topBlocksY[_x] % CHUNK_SIZE) % CHUNK_SIZE] = new Block(4);*/
	}
	
	//STRUCTURE GENERATION//
	//Generate Structures of the Chunk
	for (var _x = 0; _x < CHUNK_SIZE; _x ++)
	{
		//Get the Uppermost Block of the Chunk
		var _blockY = _topBlocksY[_x];
		if (_blockY == undefined) continue;
		_blockY -= 1;
		
		//Choose a Random Structure (Or No Structure)
		var _structureId = noone;
		var _structureValue = random_value(_chunkCorner1[0] + _x, _generationSeed);
		for (var _i = 0; _i < array_length(_structureOccurence); _i ++)
		{
			var _structureArray = _structureOccurence[_i];
			if (_structureValue > _structureArray[1]) break;
			_structureId = _structureArray[0];
		}
		
		//Generate the Structure at the Place of the Block
		if (_structureId != noone)
			_chunk = chunk_structure_generate(_structureId, _chunk, _chunkX, _chunkY, _chunkX, _chunkY, _chunkCorner1[0] + _x, _blockY);
	}
	
	//Generate Structures From the Metadata of the Chunk
	var _fileChunkPos = string(_chunkX) + "," + string(_chunkY);
	var _worldMetadataStruct = obj_WorldManager.worldMetadataStruct;
	
	var _metadataArray = _worldMetadataStruct[$ _fileChunkPos];
	if (_metadataArray != undefined)
	{
		//Loop Through the Structures
		for (var _i = 0; _i < array_length(_metadataArray); _i ++)
		{
			var _metadata = _metadataArray[_i];
			chunk_structure_generate(_metadata[0], _chunk, _chunkX, _chunkY, _metadata[1], _metadata[2], _metadata[3], _metadata[4]);
		}
		
		//Delete the Metadata of the Chunk
		variable_struct_remove(_worldMetadataStruct, _fileChunkPos);
	}
	
	//Set the Chunk in the chunkStruct
	chunk_save(_chunkX, _chunkY, _chunk);
	
	//BLOCK TILING//
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
		
		//Tile All the Created Blocks
		var _blocksToTile = _tileBlocksY[_pos];
		for (var _i = 0; _i < array_length(_blocksToTile); _i ++)
			block_tile(_chunkCorner1[0] + _pos, _chunkCorner1[1] + _blocksToTile[_i], false);
		
		/*	//this solution was tiling only the uppermost blocks (more efficient) but didn't work later for the caves (so I ended up tiling every block created)
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
			block_tile(_blockX, _blockY + _i, false);*/
	}
	
	if (obj_GameManager.serverSide)
	{
		var _serverBuffer = obj_Server.serverBuffer;
		
		if (_chunkExistsTop)
		{
			message_chunk(_serverBuffer, _chunkX, _chunkY - 1, true);
			buffer_write(_serverBuffer, buffer_string, json_stringify(chunk_get(_chunkX, _chunkY - 1, false)));
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		if (_chunkExistsRight)
		{
			message_chunk(_serverBuffer, _chunkX + 1, _chunkY, true);
			buffer_write(_serverBuffer, buffer_string, json_stringify(chunk_get(_chunkX + 1, _chunkY, false)));
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		if (_chunkExistsBottom)
		{
			message_chunk(_serverBuffer, _chunkX, _chunkY + 1, true);
			buffer_write(_serverBuffer, buffer_string, json_stringify(chunk_get(_chunkX, _chunkY + 1, false)));
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
		if (_chunkExistsLeft)
		{
			message_chunk(_serverBuffer, _chunkX - 1, _chunkY, true);
			buffer_write(_serverBuffer, buffer_string, json_stringify(chunk_get(_chunkX - 1, _chunkY, false)));
			with (obj_PlayerClient)
				network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
		}
	}
	
	/*_chunk = chunk_get(_chunkX, _chunkY, false);*/
	return _chunk;
}

/// Function generating a structure in a given chunk.
/// _chunkX/Y - pos of the chunk to generate the structure in; _structureChunkX/Y - pos of the chunk in which the structure is located
function chunk_structure_generate(_structureId, _chunk, _chunkX, _chunkY, _structureChunkX, _structureChunkY, _structureX, _structureY)
{
	/*if (_chunkX == 0 && _chunkY == 0)
	{
		var he;
		var le; 
		var hele;
	}
	show_debug_message("\nCHUNK: " + string(_chunkX) + ", " + string(_chunkY));
	show_debug_message("x: " + string(_structureX));
	show_debug_message("y: " + string(_structureY));*/
	
	
	//Get the Strucure
	var _structure = id_get_structure(_structureId);
	
	//Set the Chunk Position Within the World
	var _chunkCorner1 = [_chunkX * CHUNK_SIZE, _chunkY * CHUNK_SIZE];
	var _chunkCorner2 = [_chunkX * CHUNK_SIZE + CHUNK_SIZE - 1, _chunkY * CHUNK_SIZE + CHUNK_SIZE - 1];
	
	//Set the Offset of the Structure in Relation to the Chunk's Position
	var _structureOffset = [_chunkCorner1[0] - (_structureX - floor(_structure.width * 0.5)),	//from (0 - left; 1 - top; 2 - right; 3 - bottom) side
							_chunkCorner1[1] - (_structureY - _structure.height) - 1,			//the value determines distance from the structure's side to the chunks side
							(_structureX + floor(_structure.width * 0.5)) - _chunkCorner2[0],	//if negative, the structure's side is inside the chunk, if positive, the structure's side is outside the chunk
							_structureY - _chunkCorner2[1]];
	/*show_debug_message(_structureOffset[0]);
	show_debug_message(_structureOffset[1]);*/
	
	//Loop Throught the Structure's Array && Set Its Blocks
	var _xPosIncrement = 0;	//the block position where to place the structure block
	var _yPosIncrement = 0;
	for (var _x = max(0, _structureOffset[0]); _x < _structure.width - max(0, _structureOffset[2]); _x ++)
	{
		for (var _y = max(0, _structureOffset[1]); _y < _structure.height - max(0, _structureOffset[3]); _y ++)
		{
			var _chunkBlockX = abs(min(0, _structureOffset[0])) + _xPosIncrement;
			var _chunkBlockY = abs(min(0, _structureOffset[1])) + _yPosIncrement;
			/*show_debug_message("xGenerate: " + string(_chunkCorner1[0] + _chunkBlockX));
			show_debug_message(" yGenerate: " + string(_chunkCorner1[1] + _chunkBlockY));*/
			var _blockId = _structure.structureArray[_y, _x];
			if (_blockId != noone) _chunk[_chunkBlockX, _chunkBlockY] = new Block(_blockId);
			
			_yPosIncrement ++;
		}
		_yPosIncrement = 0;
		_xPosIncrement ++;
	}
	
	//Generate the Structure in the Other Chunks the Structure Steps in
	if (_chunkX == _structureChunkX && _chunkY == _structureChunkY)
	{
		var _chunkStart = [_chunkX - ceil(max(0, _structureOffset[0]) / CHUNK_SIZE), _chunkY - ceil(max(0, _structureOffset[1]) / CHUNK_SIZE)];
		var _chunkEnd = [_chunkX + ceil(max(0, _structureOffset[2]) / CHUNK_SIZE), _chunkY + ceil(max(0, _structureOffset[3]) / CHUNK_SIZE)];
		for (var _x = _chunkStart[0]; _x < _chunkEnd[0] + 1; _x ++)
		{
			for (var _y = _chunkStart[1]; _y < _chunkEnd[1] + 1; _y ++)
			{
				//Get the Chunk In Which to Generate the Structure
				if (_x == _chunkX && _y == _chunkY) continue;
				var _chunkTarget = chunk_get(_x, _y, false);
				
				//Generate the Structure If the Chunk Exists
				if (_chunkTarget != undefined)
				{
					_chunkTarget = chunk_structure_generate(_structureId, _chunkTarget, _x, _y, _structureChunkX, _structureChunkY, _structureX, _structureY);
					chunk_save(_x, _y, _chunkTarget);
					chunk_set(_x, _y, _chunkTarget);
				}
				
				//Add the Structure to the Chunks Metadata if the Chunk Doesn't Exist Already (the structure is going to be generated when creating the chunk)
				else
				{
					//Create the Metadata for Generating the Structure
					var _metadata = [_structureId, _structureChunkX, _structureChunkY, _structureX, _structureY];
					
					//Add the Chunk's Metadata to the worldMetadataStruct
					var _fileChunkPos = string(_x) + "," + string(_y);
					var _worldMetadataStruct = obj_WorldManager.worldMetadataStruct;
					
					if (!variable_struct_exists(_worldMetadataStruct, _fileChunkPos))
						variable_struct_set(_worldMetadataStruct, _fileChunkPos, []);
					var _metadataArray = _worldMetadataStruct[$ _fileChunkPos];
					array_push(_metadataArray, _metadata);
				}
			}
		}
	}
	
	return _chunk;
}

/// Function returning a chunk on a given chunk position.
/// Generates a new chunk if necessarily.
function chunk_get(_chunkX, _chunkY, _generateChunk = true)
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
				message_chunk(_clientBuffer, _chunkX, _chunkY, true);
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
		_chunk = chunk_get(_chunkX, _chunkY);
	
	//Save the Chunk
	var _worldStruct = obj_WorldManager.worldStruct;
	variable_struct_set(_worldStruct, _fileChunkPos, _chunk);
}

/// Function returning a block on a given poisition in the world.
function block_pos_get(_x, _y, _generateChunk = true)
{
	//Get the Block's Chunk
	var _chunkX = floor((_x / CELL_SIZE) / CHUNK_SIZE);
	var _chunkY = floor((_y / CELL_SIZE) / CHUNK_SIZE);
	var _chunk = chunk_get(_chunkX, _chunkY, _generateChunk);
	
	//Get the Block
	var _blockX = (CHUNK_SIZE + floor(_x / CELL_SIZE) % CHUNK_SIZE) % CHUNK_SIZE;
	var _blockY = (CHUNK_SIZE + floor(_y / CELL_SIZE) % CHUNK_SIZE) % CHUNK_SIZE;
	
	if (_chunk == undefined) return undefined;
	return _chunk[_blockX][_blockY];
}

/// Function returning a block on a given block position.
/// _generateChunk - generate a new chunk if necessarily
function block_get(_blockX, _blockY, _generateChunk = true)
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
