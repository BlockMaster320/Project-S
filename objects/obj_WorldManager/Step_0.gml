//Update playerChunk && chunkOrigin Position
playerChunk = [floor(floor((obj_PlayerLocal.x + sprite_get_width(spr_Player) * 0.5) / CELL_SIZE) / CHUNK_SIZE),
			   floor(floor((obj_PlayerLocal.y + sprite_get_height(spr_Player) * 0.5) / CELL_SIZE) / CHUNK_SIZE)];

chunkOrigin = [playerChunk[0] - floor(CHUNK_GRID_SIZE * 0.5),
			   playerChunk[1] - floor(CHUNK_GRID_SIZE * 0.5)];

//Fill the chunkStruct with Chunks at the Start of the Game
if (array_length(variable_struct_get_names(chunkStruct)) == 0)
{
	for (var _y = 0; _y < CHUNK_GRID_SIZE; _y ++)
	{
		for (var _x = 0; _x < CHUNK_GRID_SIZE; _x ++)
		{
			var _chunk = chunk_get(chunkOrigin[0] + _x, chunkOrigin[1] + _y);
			chunk_set(chunkOrigin[0] + _x, chunkOrigin[1] + _y, _chunk);
		}
	}
}

//Update the Chunk Struct
else if (!array_equals(playerChunk, playerChunkPrevious))
{
	//Get the Direction the Loaded Chunks Should Be Shifted
	var _xShift = sign(playerChunk[0] - playerChunkPrevious[0]);
	var _yShift = sign(playerChunk[1] - playerChunkPrevious[1]);
	
	/*
	show_debug_message("\nchunkStruct size: " + string(array_length(variable_struct_get_names(chunkStruct))));
	show_debug_message("worldStruct size: " + string(array_length(variable_struct_get_names(worldStruct))));*/
	
	//Update the Chunks when Moving Horizontally
	if (_xShift != 0)
	{
		//Set the x Position
		var _x1 = chunkOrigin[0] + (CHUNK_GRID_SIZE - 1) * (_xShift == - 1) - _xShift;
		var _x2 = chunkOrigin[0] + (CHUNK_GRID_SIZE - 1) * (_xShift == 1);
		
		for (var _i = 0; _i < CHUNK_GRID_SIZE; _i ++)
		{
			//Set the y Position
			var _y = chunkOrigin[1] + _i;
			
			//Save && Unset Chunks That Are Not Needed
			var _chunk1 = chunk_get(_x1, _y);
			chunk_save(_x1, _y, _chunk1);
			chunk_unset(_x1, _y);
			
			//Get && Set New Chunks
			var _chunk2 = chunk_get(_x2, _y, false);
			if (obj_GameManager.serverSide != false)
			{
				if (_chunk2 == undefined)
					ds_queue_enqueue(chunkGenerateQueue, [_x2, _y]);	//add the chunk's position to chunkGenerateQueue to be generated
				else
					chunk_set(_x2, _y, _chunk2);
			}
		}
	}
	
	//Update the Chunks when Moving Verically
	if (_yShift != 0)
	{
		//Set the y Position
		var _y1 = chunkOrigin[1] + (CHUNK_GRID_SIZE - 1) * (_yShift == - 1) - _yShift;
		var _y2 = chunkOrigin[1] + (CHUNK_GRID_SIZE - 1) * (_yShift == 1);
		
		for (var _i = 0; _i < CHUNK_GRID_SIZE; _i ++)
		{
			//Set the y Position
			var _x = chunkOrigin[0] + _i;
			
			//Save && Unset Chunks That Are Not Needed
			var _chunk1 = chunk_get(_x, _y1);
			chunk_save(_x, _y1, _chunk1);
			chunk_unset(_x, _y1);
			
			//Get && Set New Chunks
			var _chunk2 = chunk_get(_x, _y2, false);
			if (obj_GameManager.serverSide != false)
			{
				if (_chunk2 == undefined)
					ds_queue_enqueue(chunkGenerateQueue, [_x, _y2]);	//add the chunk's position to chunkGenerateQueue to be generated
				else
					chunk_set(_x, _y2, _chunk2);
			}
		}
	}
}

//Generate the Chunks Added to the chunkGenerateQueue
if (chunkGenerateTimer == CHUNK_GENERATE_RATE)
{
	var _chunkPos = ds_queue_dequeue(chunkGenerateQueue);
	if (_chunkPos != undefined)
	{
		var _chunk2 = chunk_get(_chunkPos[0], _chunkPos[1]);
		chunk_set(_chunkPos[0], _chunkPos[1], _chunk2);
	}
	chunkGenerateTimer = 0;
}
chunkGenerateTimer ++;

//Update the Player Chunk
playerChunkPrevious = playerChunk;

//World Auto-Saving
if (autoSaving)
{
	if (saveTimer == saveRate)
	{
		var _worldFile = obj_GameManager.worldFile;	//save the worldFile
		var _worldFile = _worldFile;
		var _mainStruct = json_parse(json_string_load(_worldFile));
		_mainStruct.worldStruct = worldStruct;
		json_string_save(json_stringify(_mainStruct), _worldFile);
	
		saveTimer = 0;	//reset the saveTimer
	}
	saveTimer ++;
}


/*
show_debug_message("playerChunkX: " + string(playerChunk[0]));
show_debug_message("playerChunkY: " + string(playerChunk[1]));*/
/*show_debug_message(block_get(mouse_x, mouse_y));*/
/*var _blockX = (CHUNK_SIZE + floor(-1 / CELL_SIZE) % CHUNK_SIZE) % CHUNK_SIZE;
show_debug_message(_blockX);*/

/*
if (instance_exists(obj_PlayerLocal))
{
	show_debug_message("playerX: " + string(obj_PlayerLocal.x));
	show_debug_message("playerY: " + string(obj_PlayerLocal.y));
}*/
