//Set the Area of chunkStruct to Be Drawn
if (instance_exists(obj_PlayerLocal))	//get the player's position within the chunk grid
{
	var _playerGridX = obj_PlayerLocal.x div CELL_SIZE;
	var _playerGridY = obj_PlayerLocal.y div CELL_SIZE;
}
else
{
	var _playerGridX = 0;
	var _playerGridY = 0;
}
	
var _visibleWidth = obj_Camera.viewWidth div CELL_SIZE + 2;	//get the size of the camera view (adding some value to make sure that the full view is filled)
var _visibleHeight = obj_Camera.viewHeight div CELL_SIZE + 2;

//Draw the Chunks
if (drawTimer % drawRate == 0)
{
	var _cornerChunk1 = [floor((_playerGridX - ceil(_visibleWidth * 0.5)) / CHUNK_SIZE),	//set the first && last chunk position to draw
						 floor((_playerGridY - ceil(_visibleHeight * 0.5)) / CHUNK_SIZE)];
	var _cornerChunk2 = [((_playerGridX + ceil(_visibleWidth * 0.5)) + 1) / CHUNK_SIZE,
						 ((_playerGridY + ceil(_visibleHeight * 0.5)) + 1) / CHUNK_SIZE];

	var _cornerBlock1 = [(CHUNK_SIZE + ((_playerGridX - ceil(_visibleWidth * 0.5)) % CHUNK_SIZE)) % CHUNK_SIZE,	//set the first && last block position to draw
						 (CHUNK_SIZE + ((_playerGridY - ceil(_visibleHeight * 0.5)) % CHUNK_SIZE)) % CHUNK_SIZE];
	var _cornerBlock2 = [(CHUNK_SIZE + ((_playerGridX + ceil(_visibleWidth * 0.5)) % CHUNK_SIZE)) % CHUNK_SIZE + 1,
						 (CHUNK_SIZE + ((_playerGridY + ceil(_visibleHeight * 0.5)) % CHUNK_SIZE)) % CHUNK_SIZE + 1];
	
	
	/*show_debug_message("corner1: x(" + string(_cornerChunk1[0]) + "), y(" + string(_cornerChunk1[1]) + ")");
	show_debug_message("corner2: x(" + string(_cornerChunk2[0]) + "), y(" + string(_cornerChunk2[1]) + ")");
	show_debug_message("");*/
	
	//Draw the Area
	vertex_begin(vertexBuffer, vertexFormat);
	for (var _chunkX = _cornerChunk1[0]; _chunkX < _cornerChunk2[0]; _chunkX ++)
	{
		//Set the X Position of the First && Last Block in the Chunk to Be Drawn
		var _blockXStart = 0;
		var _blockXEnd = CHUNK_SIZE;
		if (_chunkX == _cornerChunk1[0]) _blockXStart = _cornerBlock1[0];
		else if (_chunkX == _cornerChunk2[0] - 1) _blockXEnd = _cornerBlock2[0];
	
		for (var _chunkY = _cornerChunk1[1]; _chunkY < _cornerChunk2[1]; _chunkY ++)
		{
			//Set the Y Position of the First && Last Block in the Chunk to Be Drawn
			var _blockYStart = 0;
			var _blockYEnd = CHUNK_SIZE;
			if (_chunkY == _cornerChunk1[1]) _blockYStart = _cornerBlock1[1];
			else if (_chunkY == _cornerChunk2[1] - 1) _blockYEnd = _cornerBlock2[1];
			
			//Get the Chunk
			var _chunk = chunk_get(_chunkX, _chunkY, true);
			/* _chunk = testChunk;*/
			if (_chunk == undefined) continue;
			
			//Draw the Chunk
			var _x = _chunkX * CHUNK_SIZE;
			var _y = _chunkY * CHUNK_SIZE;
			for (var _blockX = _blockXStart; _blockX < _blockXEnd; _blockX ++)
			{
				for (var _blockY = _blockYStart; _blockY < _blockYEnd; _blockY ++)
				{
					var _block = _chunk[_blockX][_blockY];	//get the block
					if (_block != 0)
					{
						//Get Sprite's Texture Properties
						var _spriteTexture = sprite_get_texture(_block.sprite, _block.tile);
						var _textureUVs = texture_get_uvs(_spriteTexture);

						var _uvLeft = _textureUVs[0];	//where the texture is located on the texture page
						var _uvTop = _textureUVs[1];
						var _uvRight = _textureUVs[2];
						var _uvBottom = _textureUVs[3];
					
						var _spriteLeft = (_x + _blockX) * CELL_SIZE;	//where to draw the sprite in the room
						var _spriteTop = (_y + _blockY) * CELL_SIZE;
						var _spriteRight = (_x + _blockX) * CELL_SIZE + sprite_get_width(_block.sprite);
						var _spriteBottom = (_y + _blockY) * CELL_SIZE + sprite_get_height(_block.sprite);

						//Add 2 Triangles to the Buffer (2 Halves of the Sprite - 3 Points Each)
						vertex_position(vertexBuffer, _spriteLeft, _spriteTop);	//first triangle
						vertex_texcoord(vertexBuffer, _uvLeft, _uvTop);
						vertex_colour(vertexBuffer, c_white, 1);

						vertex_position(vertexBuffer, _spriteRight, _spriteTop);
						vertex_texcoord(vertexBuffer, _uvRight, _uvTop);
						vertex_colour(vertexBuffer, c_white, 1);

						vertex_position(vertexBuffer, _spriteLeft, _spriteBottom);
						vertex_texcoord(vertexBuffer, _uvLeft, _uvBottom);
						vertex_colour(vertexBuffer, c_white, 1);

						vertex_position(vertexBuffer, _spriteRight, _spriteTop);	//second triangle
						vertex_texcoord(vertexBuffer, _uvRight, _uvTop);
						vertex_colour(vertexBuffer, c_white, 1);

						vertex_position(vertexBuffer, _spriteRight, _spriteBottom);
						vertex_texcoord(vertexBuffer, _uvRight, _uvBottom);
						vertex_colour(vertexBuffer, c_white, 1);

						vertex_position(vertexBuffer, _spriteLeft, _spriteBottom);
						vertex_texcoord(vertexBuffer, _uvLeft, _uvBottom);
						vertex_colour(vertexBuffer, c_white, 1);
					}
				}
			}
		}
	}
	
	
	//Draw Axis Lines
	var _colour = noone;
	for (var _x = _cornerChunk1[0]; _x <= _cornerChunk2[0]; _x ++)
	{
		_colour = (_x == 0) ? c_green : c_blue;
		draw_line_colour(_x * CHUNK_SIZE * CELL_SIZE - 1, _cornerChunk1[1] * CHUNK_SIZE * CELL_SIZE,
						 _x * CHUNK_SIZE * CELL_SIZE - 1, _cornerChunk2[1] * CHUNK_SIZE * CELL_SIZE, _colour, _colour);
		for (var _y = _cornerChunk1[1]; _y <= _cornerChunk2[1]; _y ++)
		{
			_colour = (_y == 0) ? c_red : c_blue;
			draw_line_colour(_cornerChunk1[0] * CHUNK_SIZE * CELL_SIZE, _y * CHUNK_SIZE * CELL_SIZE - 1,
							 _cornerChunk2[0] * CHUNK_SIZE * CELL_SIZE, _y * CHUNK_SIZE * CELL_SIZE - 1, _colour, _colour);
		}
	}
	
	vertex_end(vertexBuffer);
}
vertex_submit(vertexBuffer, pr_trianglelist, drawTexture);	//submit the vertex buffer

//Draw Items
var _cornerPos1 = [(_playerGridX - ceil(_visibleWidth * 0.5)) * CELL_SIZE,	//get visible world area
				   (_playerGridY - ceil(_visibleHeight * 0.5)) * CELL_SIZE];
var _cornerPos2 = [(_playerGridX + ceil(_visibleWidth * 0.5) + 1) * CELL_SIZE,
				   (_playerGridY + ceil(_visibleHeight * 0.5) + 1) * CELL_SIZE];

draw_set_halign(fa_left);	//set draw align
draw_set_valign(fa_top);

with (obj_Item)
{
	if (x > _cornerPos1[0] && y > _cornerPos1[1] && x < _cornerPos2[0] && y < _cornerPos2[1])
	{
		//Draw Item's Sprite
		var _spriteCount = itemSlot.itemCount div 9 + 1;
		for (var _i = 0; _i < _spriteCount; _i ++)	//draw multiple item's sprites based on it's itemCount
			draw_sprite_ext(itemSlot.sprite, 0, x + _i * 2, y, 0.5, 0.5, 0, c_white, 1);

		//Draw the itemCount
		var _itemCountX = x + _i * (_spriteCount - 1) + sprite_width * 0.6;
		var _itemCountY = y + sprite_height * 0.4;
		draw_text_transformed_colour(_itemCountX, _itemCountY , itemSlot.itemCount,
									 0.5, 0.5, 0, c_white, c_white, c_white, c_white, 1);
	}
}


/*
if (timer % 30 == 0)
{
	//instance_deactivate_layer("TestBlocks");
	instance_deactivate_object(obj_TestBlock);
	instance_activate_region(obj_PlayerLocal.x - obj_Camera.viewWidth * 0.5, obj_PlayerLocal.y - obj_Camera.viewHeight * 0.5,
							 obj_Camera.viewWidth, obj_Camera.viewHeight, true);
}*/
drawTimer ++;

/*
randomize();
if (keyboard_check_pressed(ord("S")))
{
	random_set_seed(718516646);
	var _randomValue = random(1);
	show_debug_message(_randomValue);
	show_debug_message(random(1));
}*/

/*/
var _item = id_get_item(0);
show_debug_message(_item.sprite);
show_debug_message(_item.id);
show_debug_message(_item.name);*/

