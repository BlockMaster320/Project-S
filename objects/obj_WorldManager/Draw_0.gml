//Set the Area of worldGrid to Draw
var _playerGridX = obj_Player.x div CELL_SIZE;
var _playerGridY = obj_Player.y div CELL_SIZE;
var _chunkWidth = obj_Camera.viewWidth div CELL_SIZE;
var _chunkHeight = obj_Camera.viewHeight div CELL_SIZE;

var _corner1 = [clamp(floor(_playerGridX - _chunkWidth * 0.5) - 1, 0, worldWidth),	//set the draw area corners
				clamp(floor(_playerGridY - _chunkHeight * 0.5) - 1, 0, worldHeight)];
var _corner2 = [clamp(ceil(_playerGridX + _chunkWidth * 0.5) + 2, 0, worldWidth),
				clamp(ceil(_playerGridY + _chunkHeight * 0.5) + 2, 0, worldHeight)];

//Draw the World
if (drawTimer % 2 == 0)
{
	//Loop trought the worldGrid && Draw the Sprites Using a Vertex Buffer
	vertex_begin(vertexBuffer, vertexFormat);
	for (var _x = _corner1[0]; _x < _corner2[0]; _x ++)
	{
		for (var _y = _corner1[1]; _y < _corner2[1]; _y ++)
		{
			var _block = worldGrid[# _x, _y];
			if (_block != 0)
			{
				//draw_sprite(_cellInfo.blockSprite, 0, _x * CELL_SIZE, _y * CELL_SIZE);
				
				//Get Sprite's Texture Properties
				var _spriteTexture = sprite_get_texture(_block.sprite, 0);
				var _textureUVs = texture_get_uvs(_spriteTexture);

				var _uvLeft = _textureUVs[0];	//where the texture is located on the texture page
				var _uvTop = _textureUVs[1];
				var _uvRight = _textureUVs[2];
				var _uvBottom = _textureUVs[3];

				var _spriteLeft = _x * CELL_SIZE;	//where to draw the sprite in the room
				var _spriteTop = _y * CELL_SIZE;
				var _spriteRight = _x * CELL_SIZE + sprite_get_width(_block.sprite);
				var _spriteBottom = _y * CELL_SIZE + sprite_get_height(_block.sprite);

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
	vertex_end(vertexBuffer);
}
vertex_submit(vertexBuffer, pr_trianglelist, drawTexture);	//submit the vertex buffer

/*
if (timer % 30 == 0)
{
	//instance_deactivate_layer("TestBlocks");
	instance_deactivate_object(obj_TestBlock);
	instance_activate_region(obj_Player.x - obj_Camera.viewWidth * 0.5, obj_Player.y - obj_Camera.viewHeight * 0.5,
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
