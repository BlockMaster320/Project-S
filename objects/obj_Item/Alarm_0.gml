//Send Item's Position to all Clients
var _serverBuffer = obj_Server.serverBuffer;
message_position(_serverBuffer, objectId, x, y);
	
with (obj_PlayerClient)
	network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));

alarm[0] = POSITION_UPDATE;
