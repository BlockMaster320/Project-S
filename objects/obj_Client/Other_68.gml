var _type = async_load[? "type"];
var _id = async_load[? "id"];

if (_id == client)
{
	var _buffer = async_load[? "buffer"];
	client_receive_message(_id, _buffer);
}
