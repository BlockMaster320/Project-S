//World Properties
worldWidth = 50;
worldHeight = 100;
worldLevel = 10;	//surface level from the world's top

//World Grid
worldGrid = ds_grid_create(worldWidth, worldHeight);
drawTimer = 0;
#macro CELL_SIZE 16

//Generate the World
var _block = new Block(0);
var _blockSmall = new Block(1);
for (var _x = 0; _x < worldWidth; _x ++)
{
	var _terrainHeight = worldLevel;
	ds_grid_set_region(worldGrid, _x, _terrainHeight, _x, worldHeight, _block);
	//else ds_grid_set_region(worldGrid, _x, _terrainHeight, _x, worldHeight, new Block(0, spr_Player));
	
	/*
	for (var _y = _terrainHeight; _y < worldHeight; _y ++)
	{
		instance_create_layer(_x * CELL_SIZE, _y * CELL_SIZE, "TestBlocks", obj_TestBlock);
	}*/
}
worldGrid[# 2, 4] = _block;
worldGrid[# 8, 3] = _blockSmall;
worldGrid[# 8, 4] = _block;
worldGrid[# 8, 5] = _blockSmall;
worldGrid[# 4, 7] = _blockSmall;
worldGrid[# 5, 7] = _block;
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
