//Create and Connect a Client
serverIp = obj_Menu.textFieldArray[1];
client = network_create_socket(network_socket_tcp);	//create a client socket
var _connection = network_connect(client, serverIp, 6510);	//connect the socket to a certain port
if (_connection < 0) show_message("Connection failed.");

//Create a Client Buffer
clientBuffer = buffer_create(256, buffer_grow, 1);

//Create a Map of Players && Objects
playerMap = ds_map_create();
objectMap = ds_map_create();

//Set Networking to True
obj_GameManager.networking = true;

//Set Wheter the Player is on the Server Side to False
obj_GameManager.serverSide = false;
