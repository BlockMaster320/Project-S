//Get Network Message Properties
var _id = async_load[? "id"];

//Handle Network Message
if (_id == client)
{
	var _buffer = async_load[? "buffer"];
	message_receive_client(_id, _buffer);
}
