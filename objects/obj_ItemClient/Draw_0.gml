//Draw Item's Sprite
var _spriteCount = itemSlot.itemCount div 9 + 1;
for (var _i = 0; _i < _spriteCount; _i ++)	//draw multiple item's sprites based on it's itemCount
	draw_sprite_ext(itemSlot.sprite, 0, x + _i * 2, y, 0.5, 0.5, 0, c_white, 1);

//Draw the itemCount
draw_set_halign(fa_left);
draw_set_valign(fa_top);
var _itemCountX = x + _i * (_spriteCount - 1) + sprite_width * 0.6;
var _itemCountY = y + sprite_height * 0.4;
draw_text_transformed_colour(_itemCountX, _itemCountY , itemSlot.itemCount,
							 0.5, 0.5, 0, c_white, c_white, c_white, c_white, 1);
