//World Properties
worldSeed = 0;
generationSeed = 0;	//the actual value to use when generating the noise values

/*worldWidth = 50;
worldHeight = 100;*/
worldWidth = 0;
worldHeight = 0;
seaLevel = 10;	//sea surface level from the world's top

//World Grid
worldGrid = ds_grid_create(0, 0);
drawTimer = 0;

//Create a Vertex Buffer for Drawing the World
vertex_format_begin();

vertex_format_add_position();	//add properties to the vertex format
vertex_format_add_texcoord();
vertex_format_add_color();

vertexFormat = vertex_format_end();	//store the vertex format inside a variable
vertexBuffer = vertex_create_buffer();	//create a vertex buffer
drawTexture = sprite_get_texture(spr_Block, 0);
