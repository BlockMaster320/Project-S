/// Script which stores player's input checking variables.
//Movement Keys
keyRight = keyboard_check(ord("D"));
keyLeft = keyboard_check(ord("A"));
keyJump = keyboard_check(ord("W"));
keyJumpPressed = keyboard_check_pressed(ord("W"));

//Inventory
keyInventory = keyboard_check_pressed(ord("E"));
keyItemDrop = keyboard_check_pressed(ord("Q"));
keyModifier1 = keyboard_check(vk_shift);
keyModifier2 = keyboard_check(vk_lcontrol);

//Mouse Buttons
buttonLeft = mouse_check_button(mb_left);
buttonLeftPressed = mouse_check_button_pressed(mb_left);
buttonLeftReleased = mouse_check_button_released(mb_left);
buttonRight = mouse_check_button(mb_right);
buttonRightPressed = mouse_check_button_pressed(mb_right);
buttonRightReleased = mouse_check_button_released(mb_right);

mouseWheelDown = mouse_wheel_down();
mouseWheelUp = mouse_wheel_up();