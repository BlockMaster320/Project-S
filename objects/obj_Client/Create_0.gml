//Create and Connect a Client
/*serverIp = obj_Controller.ipString;*/
client = network_create_socket(network_socket_tcp);	//create a client socket
var _connection = network_connect(client, "127.0.0.1", 6510);	//connect the socket to a certain port
if (_connection < 0) show_message("Connection failed.");

//Create a Client Buffer
clientBuffer = buffer_create(256, buffer_grow, 1);

//Create a Map of Players && Objects
playerMap = ds_map_create();
objectMap = ds_map_create();

//Set Wheter the Local Player is on the Server Side to False
if (instance_exists(obj_PlayerLocal))
	obj_PlayerLocal.serverSide = false;
