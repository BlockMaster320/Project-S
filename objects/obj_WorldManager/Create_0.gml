//World Properties
worldSeed = 0;
generationSeed = 0;	//the actual value to use when generating the noise values

//World Chunks
chunkStruct = {};	//only the chunks currently needed
worldStruct = {};	//all chunks of the world
worldMetadataStruct = {};	//metadata for creating chunks
chunkOrigin = [0, 0];

playerChunk = [0, 0];
playerChunkPrevious = [0, 0];

chunkGenerateQueue = ds_queue_create();
chunkGenerateTimer = 0;

//Chunk Auto-Saving
autoSaving = false;
saveTimer = 0;
saveRate = 60 * 5;

//World Drawing
drawTimer = 0;
drawRate = 2;	//delay between drawing the blocks of the world in frames

//Create a Vertex Buffer for Drawing the World
vertex_format_begin();

vertex_format_add_position();	//add properties to the vertex format
vertex_format_add_texcoord();
vertex_format_add_color();

vertexFormat = vertex_format_end();	//store the vertex format inside a variable
vertexBuffer = vertex_create_buffer();	//create a vertex buffer
drawTexture = sprite_get_texture(spr_Block, 0);

//Create a Vertex Buffer for Drawing the World
vertex_format_begin();

vertex_format_add_position();	//add properties to the vertex format
vertex_format_add_color();

vertexFormatLight = vertex_format_end();	//store the vertex format inside a variable
vertexBufferLight = vertex_create_buffer();	//create a vertex buffer


testChunk = array_create(CHUNK_SIZE, array_create(CHUNK_SIZE, new Block(0)));
