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
		terrainHeight : 30,
		terrainLayers : [[0, 5], [1, 0]],	//0 - block ID; 1 - layer thickness (0 = to the bottom of the world)
		treeDensity : 0.3,
		
		terrainFrequency : 0.1,
		terrainOctaves : 1,
		terrainLacunarity : 2,
		terrainPersistence : 0.5,
		
		caveFrequency : 0.04,
		caveBroadness : 0.1,
		cavePenetration : 0.01,	//how much do the caves affect the surface
		
		oreOccurence : [[8, 10, 2], [9, 30, 1]],	//0 - blockID; 1 - min height; 2 - rarity (lower value = lower chance to generated)
		
		structureOccurence : [[1, 0.1]]
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
