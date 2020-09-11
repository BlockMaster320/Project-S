//Draw Item's Sprite
var _spriteCount = itemSlot.itemCount div 9 + 1;
for (var _i = 0; _i < _spriteCount; _i ++)	//draw multiple item's sprites based on it's itemCount
	draw_sprite_ext(itemSlot.sprite, 0, x + _i * 2, y, 0.5, 0.5, 0, c_white, 1);

draw_text_transformed_colour(x + 8, y + 8, itemSlot.itemCount, 0.5, 0.5, 0, c_white, c_white, c_white, c_white, 1);
