/// Script storing structs with data of all items in the game.
/// Item's struct can be optained by its ID using the function.

function id_get_item(_id)
{
	//Item Data
	static Dirt =
	{
		id : 0,
		category : itemCategory.block,
		name : "Dirt",
		spriteItem : spr_Test1,
		spriteBlock : spr_Block,
		itemLimit : 16,
		endurance : 40,
		mineForce : 1,
		craftItems : [[0, 1]],
		craftAmount : 1,
		collisionMask : [0, 0, 16, 16]
	};
	
	static Stone =
	{
		id : 1,
		category : itemCategory.block,
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
		category : itemCategory.block,
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
	
	static Box =
	{
		id : 3,
		category : itemCategory.station,
		subCategory : itemSubCategory.storage,
		stationSpace : 0,	//0 = part; 1 = full
		storageWidth : 7,
		storageHeight : 4,
		name : "Box",
		spriteItem : spr_Test5,
		spriteBlock : spr_BlockBox,
		itemLimit : 4,
		endurance : 20,
		mineForce : 1,
		craftItems : [[1, 1]],
		craftAmount : 1,
		collisionMask : [2, 5, 14, 16]
	};
	
	static Chest =
	{
		id : 4,
		category : itemCategory.station,
		subCategory : itemSubCategory.storage,
		stationSpace : 1,	//0 = part; 1 = full
		storageWidth : 14,
		storageHeight : 4,
		name : "Chest",
		spriteItem : spr_Test4,
		spriteBlock : spr_BlockChest,
		itemLimit : 4,
		endurance : 20,
		mineForce : 1,
		craftItems : [[1, 1]],
		craftAmount : 1,
		collisionMask : [0, 2, 16, 16]
	};
	
	static CraftingBench =
	{
		id : 5,
		category : itemCategory.station,
		subCategory : itemSubCategory.crafting,
		craftingLevel : 1,
		name : "Crafting Bench",
		spriteItem : spr_Test6,
		
		spriteBlock : spr_BlockCraftingBench,
		itemLimit : 8,
		endurance : 20,
		mineForce : 1,
		craftItems : [[2, 1]],
		craftAmount : 1,
		collisionMask : [2, 5, 14, 16]
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
		case 3:
			return Box;
			break;
		case 4:
			return Chest;
			break;
		case 5:
			return CraftingBench;
			break;
	}
}


/*
enum sections
{
	inventory = 0,
	armor = 0
}*/