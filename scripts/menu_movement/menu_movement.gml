/// @description Provides input functionality for the menu's cursor. Enables selecting of menu options,
/// moving between them, and backing out of selecting an item, or exiting the menu.

// Update current input states for the keyboard variables
keyRight = keyboard_check(rightIndex);
keyLeft = keyboard_check(leftIndex);
keyUp = keyboard_check(upIndex);
keyDown = keyboard_check(downIndex);
keySelect = keyboard_check_pressed(ord("Z"));
keyReturn = keyboard_check_pressed(ord("X"));
keyAuxReturn = keyboard_check_pressed(auxReturnIndex);

// Set the previous option to whatever the curOption value is before any input is considered
prevOption = curOption;

// Pressing the return key will ignore any directional menu input and instantly exit
if (keyReturn || keyAuxReturn){
	// TODO -- Play Return Sound Here if Enabled
	return;
}

if (keySelect){
	// TODO -- Play Select Sound Here if Enabled
	return;
}

// Menu has one or less than one element OR holdTimer is set to -1; don't bother updating menu cursor
if (menuSize <= 1){
	if (!keyRight && !keyLeft && !keyUp && !keyDown){ // Reset auto move key if all directions are released
		holdTimer = 0;
	}
	return;
}

// If any directional keys have been pressed, attempt to update the cursor
if (keyRight || keyLeft || keyUp || keyDown){
	holdTimer -= global.deltaTime;
	// Update the currently highlighted option (curOption)
	if (holdTimer <= 0){
		if (!isAutoScrolling){ // Enable the menu's auto-scrolling
			holdTimer = timeToHold;
			isAutoScrolling = true;
		} else{ // Reduce time needed to move cursor for auto-scrolling
			holdTimer = timeToHold * autoScrollSpeed;
		}
		
		
		// Moving up/down to different rows in the menu
		if ((keyUp && !keyDown) || (keyDown && !keyUp)){
			curOption += (keyDown - keyUp) * menuWidth;
			
			var _curRow = floor(curOption / menuWidth);
			if (keyUp && firstRowToDraw > 0 && _curRow <= firstRowToDraw + scrollOffset){				
				firstRowToDraw--; // SHift the visible region of the menu up
			} else if (keyDown && firstRowToDraw < menuRows - numRowsToDraw && _curRow >= firstRowToDraw + (numRowsToDraw - scrollOffset)){
				firstRowToDraw++; // Shift the visible region of the menu down
			}
			
			if (curOption >= menuSize){ // Wrap the currently highlighted option to the lowest value for that column
				curOption = curOption % menuWidth;
				// Reset the visible menu's region back to a range of 0 to number of rows to draw
				firstRowToDraw = 0;
			} else if (curOption < 0){ // Wrap the currently highlighted option to the highest value of that column
				curOption = ((menuRows - 1) * menuWidth) + prevOption;
				if (curOption >= menuSize){
					curOption -= menuWidth;
				}
				// Offset the visible region to its highest possible value, but no value below 0
				firstRowToDraw = max(0, menuRows - numRowsToDraw);
			}
		}
		
		// Moving left/right through the menu if there is more than one option per row
		if (menuWidth > 1){
			if ((keyLeft && !keyRight) || (!keyLeft && keyRight)){
				curOption += keyRight - keyLeft;
				// Check if the cursor needs to wrap around to the other side
				if (keyRight && (curOption % menuWidth == 0 || curOption == menuSize)){
					if (curOption >= menuSize - 1 && curOption % menuWidth != 0){ // Wrap around to the left-size relative to the amount of options on that row
						curOption = (menuSize - 1) - ((menuSize - 1) % menuWidth);
					} else{ // Wrap around to the left-side as normal
						curOption -= menuWidth;
					}
				} else if (keyLeft && (curOption % menuWidth == menuWidth - 1 || curOption == -1)){ // Wrap around to the right
					curOption += menuWidth;
					if (curOption >= menuSize - 1){ // Lock onto the option farthest to the right in the last row
						curOption = menuSize - 1;
					}
				}
			}
		}
		// Finally, reset the info text's character scrolling position
		numCharacters = 0;
	}
} else{ // No directional keys are being held; reset auto-scroll stat and its associated timer
	isAutoScrolling = false;
	holdTimer = 0;
}