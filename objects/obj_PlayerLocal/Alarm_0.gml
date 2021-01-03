//Update the Player's Position
if (serverSide == true)
{
	var _serverBuffer = obj_Server.serverBuffer;
	message_move(_serverBuffer, objectId, x, y);
	
	with (obj_PlayerClient)
		network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
}
else if (serverSide == false)
{
	var _clientBuffer = obj_Client.clientBuffer;
	var _clientSocket = obj_Client.client;
	message_move(_clientBuffer, objectId, x, y);
	
	network_send_packet(_clientSocket, _clientBuffer, buffer_tell(_clientBuffer));
}
alarm[0] = MOVE_UPDATE;
