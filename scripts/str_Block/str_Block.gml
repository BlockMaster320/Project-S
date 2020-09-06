/// Struct representing a block in the worldGrid.

function Block(_id) constructor
{
	id = _id;
	sprite = id_get_item(_id).spriteBlock;
}