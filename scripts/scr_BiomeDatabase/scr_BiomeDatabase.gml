/// Script storing information about biomes.
/// Specific biome can be optained by its ID using the function.

function id_get_biome(_id)
{
	//Biome Data
	static Grassland =
	{
		id : 0,
		name : "Grassland",
		groundLevel : - 10,
		terrainHeight : 12,
		terrainLayers : [[0, 2], [1, 0]],
		treeDensity : 0.3,
		
		frequency : 0.1,
		octaves : 1,
		lacunarity : 2,
		persistence : 0.5
	};
	
	static Hills =
	{
		id : 1,
		name : "Hills",
		groundLevel : - 5,
		terrainHeight : 15,
		terrainLayers : [[0, 2], [1, 0]],
		treeDensity : 0.2,
		
		frequency : 0.3,
		octaves : 2,
		lacunarity : 2,
		persistence : 0.5
	};
	
	//Get a Specific Biome By Its ID
	switch(_id)
	{
		case 0:
			return Grassland;
			break;
			
		case 1:
			return Hills;
			break;
	}
}
