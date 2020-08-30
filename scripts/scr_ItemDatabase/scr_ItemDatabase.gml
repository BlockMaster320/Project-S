/// Script storing structs with data of all items in the game.
/// Item's struct can be optain by its ID using the function.

function id_get_item(_id)
{
	//Item Data
	static Dirt =
	{
		id : 0,
		name : "Dirt",
		spriteItem : spr_Test1,
		spriteBlock : spr_Block,
		itemLimit : 16,
		collisionMask : [0, 0, 16, 16]
	};
	
	static Stone =
	{
		id : 1,
		name : "Stone",
		spriteItem : spr_Test2,
		spriteBlock : spr_BlockSmall,
		itemLimit : 32,
		collisionMask : [4, 4, 12, 12]
	};
	
	//Get a Specific Item By Its ID
	switch(_id)
	{
		case 0:
			return Dirt;
			break;
		case 1:
			return Stone;
			break;
	}
}
