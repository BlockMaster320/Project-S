/// Script storing information about biomes.
/// Specific biome can be optained by its ID using the function.

function id_get_biome(_id)
{
	//Biome Data
	static Grassland =
	{
		id : 0,
		name : "Grassland"
	};
	
	//Get a Specific Item By Its ID
	switch(_id)
	{
		case 0:
			return Grassland;
			break;
	}
}
