//Create a Server
server = network_create_server(network_socket_tcp, 6510, 32);	//create a server socket
if (server < 0) show_message("Failed to create a server.");

//Create a Server Buffer
serverBuffer = buffer_create(256, buffer_grow, 1);

//Create a Player Map
playerMap = ds_map_create();

//Set an Object Count
objectIdCount = 0;

//Give Every Game Instance a Unique ID
with (obj_PlayerLocal)
	objectId = other.objectIdCount ++;
/*with (obj_Block)
	objectId = other.objectIdCount ++;*/

//Set Wheter the Local Player is on the Server Side to True
if (instance_exists(obj_PlayerLocal))
	obj_PlayerLocal.serverSide = true;
