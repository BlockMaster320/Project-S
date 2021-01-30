//Create a Server
server = network_create_server(network_socket_tcp, 6510, 32);	//create a server socket
if (server < 0) show_message("Failed to create a server.");

//Create a Server Buffer
serverBuffer = buffer_create(256, buffer_grow, 1);
/*serverBufferWorld = buffer_create(131071, buffer_grow, 1);*/

//Create a Map of Players && Objects
playerMap = ds_map_create();
objectMap = ds_map_create();

//Set an Object Count
objectIdCount = 0;

//Give Every Game Instance a Unique ID
with (obj_PlayerLocal)
{
	var _objectId = other.objectIdCount ++;
	objectId = _objectId;
	other.objectMap[? _objectId] = self;
}
	
with (obj_Item)
{
	var _objectId = other.objectIdCount ++;
	objectId = _objectId
	other.objectMap[? _objectId] = self;
	alarm[0] = POSITION_UPDATE;
}

//Set Networking to True
obj_GameManager.networking = true;

//Set Wheter the Player is on the Server Side to True
obj_GameManager.serverSide = true;
obj_PlayerLocal.serverSide = true;
