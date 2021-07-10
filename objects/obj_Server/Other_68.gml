//Get Network Message Properties
var _type = async_load[? "type"];
var _id = async_load[? "id"];

//Handle Network Message
switch (_type)
{
	case network_type_connect:
	{
		//Get the Client's Socket
		var _socket = async_load[? "socket"];
		
		//Send Initial Message to the Client
		buffer_seek(serverBuffer, buffer_seek_start, 0);
		buffer_write(serverBuffer, buffer_u8, messages.clientConnect);
		
		network_send_packet(_socket, serverBuffer, buffer_tell(serverBuffer));
	}
	break;
	
	case network_type_disconnect:	//disconnect a client in case of closing the game not using the in-game quit button
	{
		//Get the Client
		var _socket = async_load[? "socket"];
		var _playerClient = playerMap[? _socket];
		var _objectId = _playerClient.objectId;
		
		//Disconnect the Client from the Server
		network_destroy(_socket);
			
		//Save Client's Data
		client_save(_playerClient);
			
		//Remove the playerClient from the Other Clients
		message_destroy(serverBuffer, _objectId);
		with (obj_PlayerClient)
			network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			
		//Destroy Client's Local Player
		ds_map_delete(playerMap, _socket);
		ds_map_delete(objectMap, _playerClient.clientId);
		instance_destroy(_playerClient);
	}
	break;

	case network_type_data:
	{
		var _buffer = async_load[? "buffer"];
		message_receive_server(_id, _buffer);
	}
	break;
}
