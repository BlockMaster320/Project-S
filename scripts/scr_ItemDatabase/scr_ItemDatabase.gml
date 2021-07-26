/// Script storing structs with data of all items in the game.
/// Item's struct can be optained by its ID using the function.
function id_get_item(_id)
{
	//Item Data
	static Dirt =
	{
		id : 0,
		name : "Dirt",
		category : itemCategory.block,
		
		spriteItem : spr_Test1,
		spriteBlock : spr_Dirt,
		collisionMask : [0, 0, 16, 16],
		
		itemLimit : 16,
		craftItems : [[0, 1]],
		craftAmount : 1,
		
		placeable : true,
		tileable: true,
		persistence : 40
	};
	
	static Stone =
	{
		id : 1,
		name : "Stone",
		category : itemCategory.block,
		
		spriteItem : spr_Test2,
		spriteBlock : spr_Rock,
		collisionMask : [0, 0, 16, 16],
		
		itemLimit : 32,
		craftItems : [[0, 4]],
		craftAmount : 2,
		
		placeable : true,
		tileable: true,
		persistence : 20
	};
	
	static Log =
	{
		id : 2,
		name : "Log",
		category : itemCategory.block,
		
		spriteItem : spr_Test3,
		spriteBlock : spr_BlockLog,
		collisionMask : [3, 0, 13, 16],
		
		itemLimit : 8,
		craftItems : [[1, 2], [0, 4]],
		craftAmount : 4,
		
		placeable : true,
		tileable: true,
		persistence : 20
	};
	
	static Box =
	{
		id : 3,
		name : "Box",
		category : itemCategory.station,
		subCategory : itemSubCategory.storage,
		
		spriteItem : spr_Test5,
		spriteBlock : spr_BlockBox,
		collisionMask : [2, 5, 14, 16],
		
		itemLimit : 4,
		craftItems : [[1, 1]],
		craftAmount : 1,
		
		placeable : true,
		tileable: false,
		persistence : 20,
		
		stationSpace : 0,	//0 = part; 1 = full
		storageWidth : 7,
		storageHeight : 4
	};
	
	static Chest =
	{
		id : 4,
		name : "Chest",
		category : itemCategory.station,
		subCategory : itemSubCategory.storage,
		
		spriteItem : spr_Test4,
		spriteBlock : spr_BlockChest,
		collisionMask : [0, 2, 16, 16],
		
		itemLimit : 4,
		craftItems : [[1, 1]],
		craftAmount : 1,
		
		placeable : true,
		tileable: false,
		persistence : 20,
		
		stationSpace : 1,	//0 = part; 1 = full
		storageWidth : 14,
		storageHeight : 4
	};
	
	static CraftingBench =
	{
		id : 5,
		name : "Crafting Bench",
		category : itemCategory.station,
		subCategory : itemSubCategory.crafting,
		
		spriteItem : spr_Test6,
		spriteBlock : spr_BlockCraftingBench,
		collisionMask : [2, 5, 14, 16],
		
		itemLimit : 8,
		craftItems : [[2, 1]],
		craftAmount : 1,
		
		placeable : true,
		tileable: false,
		persistence : 20,
		
		craftingLevel : 1
	};
	
	static Pickaxe =
	{
		id : 6,
		name : "Pickaxe",
		category : itemCategory.tool,
		
		spriteItem : spr_Test7,
		
		itemLimit : 1,
		craftItems : [[7, 1]],
		craftAmount : 1,
		
		placeable : false,
		
		properties : [0, 0, 0]
	};
	
	static Ingot =
	{
		id : 7,
		name : "Ingot",
		category : itemCategory.material,
		
		spriteItem : spr_Test8,
		
		itemLimit : 1,
		craftItems : [[1, 1]],
		craftAmount : 1,
		
		placeable : false,
		
		properties : [5, 1, 2]	//just for testing
	};
	
	static Ruby =
	{
		id : 8,
		name : "Ruby",
		category : itemCategory.block,
		
		spriteItem : spr_Test5,
		spriteBlock : spr_Ruby,
		collisionMask : [0, 0, 16, 16],
		
		itemLimit : 32,
		craftItems : [[0, 4]],
		craftAmount : 2,
		
		placeable : true,
		tileable: true,
		persistence : 20
	};
	
	static GoldOre =
	{
		id : 9,
		name : "Gold Ore",
		category : itemCategory.block,
		
		spriteItem : spr_Test6,
		spriteBlock : spr_Test3,
		collisionMask : [0, 0, 16, 16],
		
		itemLimit : 32,
		craftItems : [[0, 4]],
		craftAmount : 2,
		
		placeable : true,
		tileable: false,
		persistence : 20
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
		case 6:
			return Pickaxe;
			break;
		case 7:
			return Ingot;
			break;
		case 8:
			return Ruby;
			break;
		case 9:
			return GoldOre;
			break;
	}
}
