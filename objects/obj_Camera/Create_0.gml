//View Properties
#macro VIEW view_camera[0]
aspectRatio = 9 / 16;
viewWidth = 600;
viewHeight = viewWidth * aspectRatio;

//Wndow Properties
windowWidth = viewWidth * 2;
windowHeight = viewHeight * 2;

//Set the View
view_enabled = true;
view_visible[0] = true;
camera_set_view_size(VIEW, viewWidth, viewHeight);

//Set the Window
window_set_size(windowWidth, windowHeight);
/*alarm[0] = 1;	//center the window*/
surface_resize(application_surface, windowWidth, windowHeight);

/*display_set_gui_size(windowWidth, windowHeight);
display_set_gui_maximize();*/

//Free View Movement
freeSize = 1;
freeX = 0;
freeY = 0;
