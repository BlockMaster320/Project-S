//Draw Self
draw_self();

//Draw the Player's Client Name
draw_set_halign(fa_center);
draw_text_transformed_colour(x + sprite_width * 0.5, y - sprite_height * 0.6, clientName,
							 1, 1, 0, c_white, c_white, c_white, c_white, 1);
draw_set_halign(fa_left);
