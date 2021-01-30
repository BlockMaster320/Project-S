//Movement Interpolation
xOrigin = x;
yOrigin = y;
xTarget = x;
yTarget = y;
moveTime = 0;

//Movement
horizontalSpeed = 0;	//the variables are there just for collision checking (they're 0 all the time)
verticalSpeed = 0;

//Inventory
playerSelectedPosition = 0;
playerInventoryGrid = ds_grid_create(obj_Inventory.inventoryWidth, obj_Inventory.inventoryHeight);
playerArmorGrid = ds_grid_create(obj_Inventory.armorWidth, obj_Inventory.armorHeight);
playerToolGrid = ds_grid_create(obj_Inventory.toolWidth, obj_Inventory.toolHeight);

//Networking
clientId = noone;
clientName = "";
objectId = noone;
clientSocket = noone;
