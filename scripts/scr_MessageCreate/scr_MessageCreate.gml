/// Functions for creating network messages.
function message_inventoryData(_buffer, _chosenPosition, _inventoryString, _armorString, _toolString)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.inventoryData);
	buffer_write(_buffer, buffer_u8, _chosenPosition[0]);
	buffer_write(_buffer, buffer_u8, _chosenPosition[1]);
	buffer_write(_buffer, buffer_string, _inventoryString);
	buffer_write(_buffer, buffer_string, _armorString);
	buffer_write(_buffer, buffer_string, _toolString);
}

function message_chunk_get(_buffer, _chunkX, _chunkY)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.chunkGet);
	buffer_write(_buffer, buffer_s16, _chunkX);
	buffer_write(_buffer, buffer_s16, _chunkY);
}

function message_player_create(_buffer, _objectId, _clientName, _x, _y)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.playerCreate);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_string, _clientName);
	buffer_write(_buffer, buffer_u16, _x);
	buffer_write(_buffer, buffer_u16, _y);
}

function message_item_create(_buffer, _objectId, _x, _y, _itemSlot, _collectCooldown)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.itemCreate);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u16, _x);
	buffer_write(_buffer, buffer_u16, _y);
	buffer_write(_buffer, buffer_string, json_stringify(_itemSlot));
	buffer_write(_buffer, buffer_u8, _collectCooldown);
}

function message_item_change(_buffer, _objectId, _itemCount)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.itemChange);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u8, _itemCount);
}

function message_item_collect(_buffer, _objectId, _remainder)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.itemCollect);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_u8, _remainder);
}

function message_item_give(_buffer, _itemSlot)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.itemGive);
	buffer_write(_buffer, buffer_string, json_stringify(_itemSlot));
}

function message_block_create(_buffer, _gridX, _gridY, _itemId)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.blockCreate);
	buffer_write(_buffer, buffer_s16, _gridX);
	buffer_write(_buffer, buffer_s16, _gridY);
	buffer_write(_buffer, buffer_u16, _itemId);
}

function message_block_destroy(_buffer, _gridX, _gridY)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.blockDestroy);
	buffer_write(_buffer, buffer_s16, _gridX);
	buffer_write(_buffer, buffer_s16, _gridY);
}

function message_slot_change(_buffer, _gridX, _gridY, _i, _j, _slot)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.slotChange);
	buffer_write(_buffer, buffer_s16, _gridX);
	buffer_write(_buffer, buffer_s16, _gridY);
	buffer_write(_buffer, buffer_u8, _i);
	buffer_write(_buffer, buffer_u8, _j);
	buffer_write(_buffer, buffer_string, json_stringify(_slot));
}

function message_destroy(_buffer, _objectId)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.destroy);
	buffer_write(_buffer, buffer_u16, _objectId);
}

function message_position(_buffer, _objectId, _x, _y)
{
	buffer_seek(_buffer, buffer_seek_start, 0);
	buffer_write(_buffer, buffer_u8, messages.position);
	buffer_write(_buffer, buffer_u16, _objectId);
	buffer_write(_buffer, buffer_s16, _x);
	buffer_write(_buffer, buffer_s16, _y);
}
