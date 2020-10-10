/// Script storing structs with data of all items in the game.
/// Item's struct can be optained by its ID using the function.

#macro ITEM_NUMBER 3

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
		endurance : 40,
		mineForce : 1,
		craftItems : [[0, 1]],
		craftAmount : 1,
		//section : sections.inventory,
		collisionMask : [0, 0, 16, 16]
	};
	
	static Stone =
	{
		id : 1,
		name : "Stone",
		spriteItem : spr_Test2,
		spriteBlock : spr_BlockSmall,
		itemLimit : 32,
		endurance : 20,
		mineForce : 1,
		craftItems : [[0, 4]],
		craftAmount : 2,
		collisionMask : [4, 4, 12, 12]
	};
	
	static Log =
	{
		id : 2,
		name : "Log",
		spriteItem : spr_Test3,
		spriteBlock : spr_BlockLog,
		itemLimit : 8,
		endurance : 20,
		mineForce : 1,
		craftItems : [[1, 2], [0, 4]],
		craftAmount : 4,
		collisionMask : [3, 0, 13, 16]
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
		case 2:
			return Log;
			break;
	}
}


/*
enum sections
{
	inventory = 0,
	armor = 0
}*/