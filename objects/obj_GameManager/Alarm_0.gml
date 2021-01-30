//ALARM FOR CLOSING THE GAME//
//Send Message to Disconnect all Clients
if (serverSide == true)
{
	var _serverBuffer = obj_Server.serverBuffer;
	buffer_seek(_serverBuffer, buffer_seek_start, 0);
	buffer_write(_serverBuffer, buffer_u8, messages.clientDisconnect);
	with (obj_PlayerClient)
		network_send_packet(clientSocket, _serverBuffer, buffer_tell(_serverBuffer));
}

//Save && Clear the World
world_save(worldFile);
world_close();
