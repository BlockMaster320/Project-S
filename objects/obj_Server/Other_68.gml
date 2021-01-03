var _type = async_load[? "type"];
var _id = async_load[? "id"];

switch (_type)
{
	case network_type_connect:
	{
		//Create the Client's Player on the Server Side
		var _socket = async_load[? "socket"];
		var _playerClient = instance_create_layer(0, 0, "Entities", obj_PlayerClient);
		_playerClient.clientSocket = _socket;
		_playerClient.objectId = objectIdCount ++;
		playerMap[? _socket] = _playerClient;
		
		//Send Some Initial Data
		buffer_seek(serverBuffer, buffer_seek_start, 0);
		buffer_write(serverBuffer, buffer_u8, messages.join);
		buffer_write(serverBuffer, buffer_u16, _playerClient.objectId);
		network_send_packet(_socket, serverBuffer, buffer_tell(serverBuffer));
		
		//Create the Client's Player on the Other Clients' Side
		message_create_player(serverBuffer, _playerClient.objectId, 0, 0);
		with (obj_PlayerClient)
		{
			if (clientSocket != _socket)
				network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
		}
		
		//Create All the Game's Objects on the Client's Side
		with (obj_Player)
		{
			if (clientSocket != _socket)
			{
				message_create_player(other.serverBuffer, objectId, x, y);
				network_send_packet(_socket, other.serverBuffer, buffer_tell(other.serverBuffer));
			}
		}
		
		/*
		with (obj_Block)
		{
			message_create_block(other.serverBuffer, objectId, x, y);
			network_send_packet(_socket, other.serverBuffer, buffer_tell(other.serverBuffer));
		}*/
	}
	break;

	case network_type_disconnect:
	{
		//Get the Player Instance of the Disconnecting Client
		var _socket = async_load[? "socket"];
		var _playerClient = playerMap[? _socket];
		var _playerClientId = _playerClient.objectId;
		
		//Delete the playerClient from the playerMap && Destroy It
		ds_map_delete(playerMap, _socket);
		instance_destroy(_playerClient);
		
		//Remove the playerClient from the Other Clients
		message_destroy(serverBuffer, _playerClientId);
		with (obj_PlayerClient)
			network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
	}
	break;

	case network_type_data:
	{
		var _buffer = async_load[? "buffer"];
		server_receive_message(_id, _buffer);
	}
	break;
}
