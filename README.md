# Simon for Commodore 64
A Simon clone for the Commodore 64, written in BASIC.

This game is a submission for the Retro Programmers Inside (RPI) and Phaze101 game jam.

More details can be found at https://itch.io/jam/simongame

The premise of the game is to memorise and repeat a random sequence, generated by the computer. Every time the player enters the sequence correctly, the current sequence is repeated but with one random colour added to the end.

The game continues until either the player has entered the correct sequence of 20 colours, or an incorrect colour is entered. 

The game generates a random sequence as the game goes along, so all plays will be different!

## How to Play
The game is played using the keyboard only.

### Game Controls
After the sequence has been shown to the player, the player will need to repeat the sequence using the Q, W, A and S keys.

Q - The red colour, also the lowest tone.

W - The green colour, the lower middle tone.

A - The blue colour, the upper middle tone.

S - The yellow colour, the highest tone.

If **hints mode** is enabled, press the H key to repeat the sequence.

### Menu Controls

From the intial menu screen, the player can press P to setup the game options, press I to read the in-game instructions, or press C to view the credits and special thanks. Pressing M will return to the previous menu.

### Game Options / Modes
After pressing P on the initial menu screen, the player can select from a number of options, using the function keys:

F1 - Toggles whether the game will be played in colour or monochrome mode. In colour mode, the sprites that indicate the sequence will show as red, green, blue and yellow. The colours will flash a lighter version of those colours to indicate the sequence.

In monochrome mode, all of the sequence sprites will be a dark grey and will flash white to indicate the sequence.

F3 - Toggles a sound only mode. In this mode, the computer will play the four tones from lowest to highest twice, before the game begins. Listen carefully to these as after these have played, the game will begin and only play the tones that correspond to the sequence colours. The colours will only flash to confirm the player's guesses.

F5 - Toggles the speed between each of the sequence flashes. Fast mode will flash the sequence quicker. Will also reduce the time that the player's entry confirmation will flash and sound.

F7 - Toggles Hints Mode. With hints enabled, the player will be given 3 hints that will help them through the game. Using a hint will repeat the sequence from the beginning and once the computer has revealed the sequence, the player will need to re-enter the sequence, **from the beginning**. If a hint is used, the player will __not__ score a point once the sequence has been correctly entered.

Pressing P will start the game, based upon the options highlighted.

Pressing M will return to the initial menu.

## Scoring
The player will score 1 point for every correct sequencee entered, except when a hint is used.

The game will keep track of a high-score throughout all playthroughs in memory, until the computer is restarted or powered off.

## Loading the Game
The game can be played on a Commodore 64 or using an emulator, such as [VICE](https://vice-emu.sourceforge.io/) or [online](https://c64online.com/c64-online-emulator/).

Mount the d64 image into your Commodore's disk drive (which is usually device 8) and load using the following command:

`LOAD "*",8,1`

## Credits
Special thanks go to **DeadSheppy**, **Oberon** and **Sabbath** for supporting me in the creation of the game, for advice on what game modes to include and for testing the game.

Thanks to **Retro Programmers Inside** (**RPI**) and **Phaze101** for hosting the game jam.

The source code was written in [Visual Studio Code](https://code.visualstudio.com/), using the [VS64 extension](https://github.com/rolandshacks/vs64) by Roland Shacks.