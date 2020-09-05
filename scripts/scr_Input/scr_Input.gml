/// Script which stores player's input checking variables.

keyRight = keyboard_check(ord("D"));
keyLeft = keyboard_check(ord("A"));
keyJump = keyboard_check(ord("W"));
keyJumpPressed = keyboard_check_pressed(ord("W"));

keyInventory = keyboard_check_pressed(ord("E"));
keyItemDrop = keyboard_check_pressed(ord("Q"));

buttonLeft = mouse_check_button(mb_left);
buttonLeftPressed = mouse_check_button_pressed(mb_left);
buttonLeftReleased = mouse_check_button_released(mb_left);
buttonRight = mouse_check_button(mb_right);
buttonRightPressed = mouse_check_button_pressed(mb_right);
buttonRightReleased = mouse_check_button_released(mb_right);
