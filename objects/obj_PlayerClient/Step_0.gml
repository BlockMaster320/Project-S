//Interpolate the Player's Movement
x = lerp(xOrigin, xTarget, moveTime / MOVE_UPDATE);
y = lerp(yOrigin, yTarget, moveTime / MOVE_UPDATE);
moveTime ++;
