/// Function processing a message sent by the server to the client.

function server_receive_message(_socket, _buffer)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _message = buffer_read(_buffer, buffer_u8);
	var _playerClient = playerMap[? _socket];
	var _playerClientId = _playerClient.objectId;
	
	switch (_message)
	{
		case messages.join:
		{
			var _joinMessage = buffer_read(_buffer, buffer_string);
			//show_message(_joinMessage);
		}
		break;
		
		case messages.move:
		{
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			
			_playerClient.xTarget = _x;
			_playerClient.yTarget = _y;
			_playerClient.xOrigin = _playerClient.x;
			_playerClient.yOrigin = _playerClient.y;
			_playerClient.moveTime = 0;
			
			message_move(serverBuffer, _objectId, _x, _y);
			with (obj_PlayerClient)
			{
				if (clientSocket != _socket)
					network_send_packet(clientSocket, other.serverBuffer, buffer_tell(other.serverBuffer));
			}
		}
		break;
	}
}

/// Function processing a message sent by a client to the server.

function client_receive_message(_socket, _buffer)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	var _message = buffer_read(_buffer, buffer_u8);
	
	switch(_message)
	{
		case messages.join:	//send some initial data to the server
		{
			var _playerId = buffer_read(_buffer, buffer_u16);	//receive && set local player's objectId
			obj_PlayerLocal.objectId = _playerId;
		}
		break;
		
		case messages.createPlayer:	//create a new PlayerClient
		{
			//Get the Player's Data
			var _objectId = buffer_read(_buffer, buffer_u8);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			
			//Create the PlayerClient Instance && Save Its ID to the Object Map
			var _playerClient = instance_create_layer(_x, _y, "Entities", obj_PlayerClient);
			_playerClient.objectId = _objectId;
			
			objectMap[? _objectId] = _playerClient;
		}
		break;
		
		/*case messages.createBlock:	//create a new BlockClient
		{
			//Get the Block's Data
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			
			//Create the PlayerClient Instance && Save Its ID to the Object Map
			var _blockClient = instance_create_layer(_x, _y, "Blocks", obj_BlockClient);
			_blockClient.objectId = _objectId;
			
			objectMap[? _objectId] = _blockClient;
		}
		break;*/
		
		case messages.destroy:	//destroy an object
		{
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _object = objectMap[? _objectId];
			ds_map_delete(objectMap, _objectId);
			instance_destroy(_object);
		}
		break;
		
		case messages.move:
		{
			var _objectId = buffer_read(_buffer, buffer_u16);
			var _x = buffer_read(_buffer, buffer_u16);
			var _y = buffer_read(_buffer, buffer_u16);
			
			var _playerClient = objectMap[? _objectId];
			if (_playerClient == undefined) break;
			_playerClient.xTarget = _x;
			_playerClient.yTarget = _y;
			_playerClient.xOrigin = _playerClient.x;
			_playerClient.yOrigin = _playerClient.y;
			_playerClient.moveTime = 0;
		}
		break;
	}
}


function message_create_player(_buffer, _objectId, _x, _y)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.createPlayer);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u16, _x);
	buffer_write(_buffer, buffer_u16, _y);
}

/*function message_create_block(_buffer, _objectId, _x, _y)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.createBlock);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u16, _x);
	buffer_write(_buffer, buffer_u16, _y);
}*/

function message_destroy(_buffer, _objectId)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.destroy);
	buffer_write(_buffer, buffer_u16, _objectId);
}

function message_move(_buffer, _objectId, _x, _y)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.move);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u16, _x);
	buffer_write(_buffer, buffer_u16, _y);
}
