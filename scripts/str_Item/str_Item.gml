///Struct representing an item slot in the inventory && stations.

function Item(_id, _itemCount) constructor
{
	id = _id;
	sprite = id_get_item(_id).spriteItem;
	itemCount = _itemCount;
}