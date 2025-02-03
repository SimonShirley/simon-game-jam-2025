REM Set VIC Bank 2
POKE 56578,PEEK(56578) OR 3 : REM Allow writing to PORT A

REM Set PORT A serial bus access to VIC Bank 2
POKE 56576,(PEEK(56576) AND 252) or 1

REM Set pointer of character memory to $2000-$27FF / 8192-10239
POKE 53272,4

REM Set the text screen pointer start address
POKE 648,128

REM High byte of pointer to screen memory for screen input/output
REM 128 * 256 = 32768, which is the start of Bank 2
REM Reduce Basic RAM Size - Set end to $7FFF
POKE 55,255 : POKE 56,127
CLR

#---------------

GOTO Initialise_Program

Generate_Random:
    RD% = INT(RND(1) * 4)
    RETURN

Set_Cursor_Position:
    REM Set Cursor Position to X=XP%, Y=YP%
    REM Clear Flags
    REM CALL PLOT kernal routine
    POKE 781,YP% : POKE 782,XP% : POKE 783,0 : SYS 65520
    RETURN

Turn_On_Sprite:
    REM SN% = Sprite Number to Enable
    POKE VL+39+SN%, CC%(SN%, 1)
    RETURN

Turn_Off_Sprite:
    REM SN% = Sprite Number to Enable
    POKE VL+39+SN%, CC%(SN%, 0)
    RETURN

Wait_Delay:
    FOR J = 0 TO FD% : NEXT J : RETURN

Flash_Sprite:
    REM SN% = Sprite Number to Enable
    GOSUB Turn_On_Sprite
    GOSUB Wait_Delay
    GOSUB Turn_Off_Sprite
    GOSUB Wait_Delay

    RETURN

Initialise_Program:
    POKE 53280,0 : POKE 53281,0
    PRINT "{clr}{home}" : REM Clear the screen
    MX = 20 : REM Max Pattern Length
    DIM PA%(MX) : REM Pattern Array
    RD% = RND(-TI) : REM re-seed the random generator

Cell_Colours:
    DIM CC%(3,3) : REM Cell Colours

    CC%(0, 0) = 2 : CC%(0, 1) = 10
    CC%(1, 0) = 5 : CC%(1, 1) = 13
    CC%(2, 0) = 6 : CC%(2, 1) = 14
    CC%(3, 0) = 7 : CC%(3, 1) = 1

Keyboard_Keys:
    DIM KK$(3)

    KK$(0) = "Q"
    KK$(1) = "W"
    KK$(2) = "A"
    KK$(3) = "S"

#--------------

    GOSUB Initialise_Sprites
    GOSUB Game_Screen
    GOSUB Print_Instructions
    GOSUB Print_Score

Restart:
    REM Empty sequence
    FOR I = 0 TO MX : PA%(I) = 0 : NEXT

    NC = -1 : REM Next sequence counter

Ready_Up_Next_Sequence:
    POKE 649,0 : REM Disable Keyboard Buffer
    NC = NC + 1 : REM Move next counter along
    CC = 0 : REM Current sequence counter

    GOSUB Generate_Random : REM Generate Random
    PA%(NC) = RD% : REM Store random number in sequence array

    FD% = 300 : REM Set Flash Sprite Delay

    FOR I = 0 TO NC    
    SN% = PA%(I) : GOSUB Flash_Sprite
    NEXT I

    POKE 649,10 : REM Set keyboard buffer size to 10
    POKE 631,0 : REM Set remaining keyboard keys buffer to 0

Game_Loop:    
    FD% = 75 : REM Set Flash Sprite Delay

Get_Next_Key:
    GET K$ : IF K$ = "" THEN Game_Loop

    K% = -1
    FOR I = 0 TO 3
    IF K$ = KK$(I) THEN K% = I : I = 99
    NEXT

    REM Flash the user's input
    IF K% < 0 OR K% > 3 THEN GOTO Get_Next_Key
    
    SN% = K% : GOSUB Flash_Sprite

    IF K% <> PA%(CC) THEN Game_Over
    IF CC = MX - 1 THEN PRINT : PRINT "YOU WIN" : END : REM End game because the array is set to 50

    REM Increase Sequence Game Loop
    FD% = 500 : REM Set Flash Sprite Delay
    IF CC = NC THEN GOSUB Wait_Delay : GOTO Ready_Up_Next_Sequence

    CC = CC + 1 : REM Increment current guess counter

    GOTO Game_Loop

Game_Over:
    PRINT 
    PRINT "The correct sequence was "
    FOR I = 0 TO NC    
    PRINT KK$(PA%(I));
    NEXT I
    PRINT
    PRINT "Game Over"
    POKE 649,10 : REM Set keyboard buffer size to 10
    END

Setup_Sprites:
Initialise_Sprites:
    REM Initialise Sprites
    VL = 53248 : REM Base Vic Address and Sprite Screen Location (X) Y pos = +1
    SL = 16 : REM Base Sprite Pointer Location
    VR = 32768 : REM VIC Base Address (Bank 2)
    SP = VR + 1016 : REM Base Sprite Pointer Address Location
    
    # POKE VL+37,10 : POKE VL+38,2: rem multicolors 1 & 2
    POKE VL+21,0 : rem set all sprites invisible
    POKE VL+27,255 : REM Set sprites behind characters
    POKE VL+28,0: rem multicolor
    POKE VL+29,255 : POKE VL+23,255: rem width & height    
    
    REM Sprite Colours
    FOR I = 0 TO 3 : POKE VL+39+I,CC%(I, 0) : NEXT
    
    REM Set Sprite Data
    FOR X = 0 TO 0
    RESTORE
    FOR Y = 0 TO 63
    READ Z
    POKE VR + ((X+SL)*64) + Y,Z
    NEXT Y
    NEXT X

    POKE VL+16,10 : REM Enable Sprites MSB 0000 1010 (for x pos)
    POKE VL,24+(24*8) : POKE VL+1,82: rem sprite 0 pos
    POKE VL+2,24 : POKE VL+3,82: rem sprite 1 pos
    POKE VL+4,24+(24*8) : POKE VL+5,146: rem sprite 2 pos
    POKE VL+6,24 : POKE VL+7,146: rem sprite 3 pos

    FOR X = 0 TO 3
    POKE SP + X, SL
    NEXT X

    POKE VL+21,31 : rem set sprites 0-3 visible

    RETURN

#---------------------

Game_Screen:
    REM Instructions
    PRINT "{clr}{home}"
    PRINT
    PRINT
    PRINT "   {pink}{162}{187}{lightgreen}{187}"
    PRINT "   {pink}{rvs on}{252}{rvs off}{187}{lightgreen}{187}{yellow}{162}{172}{187}{cyan}{162}{187}{white}{162}{187}"
    PRINT "   {pink}{162}{161}{lightgreen}{161}{yellow}{161}{190}{161}{cyan}{rvs on}{188}{rvs off}{161}{white}{161}{161}"
    PRINT
    PRINT "   {purple}{rvs on}{162}{162}{162}{162}{162}{162}{162}{162}{162}{rvs off}{190}"

    REM Colour Boxes
    XP% = 23 : YP% = 3 : GOSUB Set_Cursor_Position
    PRINT "{red}{176}     {174} {green}{176}     {174}"

    XP% = 23 : YP% = 6 : GOSUB Set_Cursor_Position
    PRINT "   {white}Q       W"
    
    XP% = 23 : YP% = 9 : GOSUB Set_Cursor_Position
    PRINT "{red}{173}     {189} {green}{173}     {189}"

    XP% = 23 : YP% = 11 : GOSUB Set_Cursor_Position
    PRINT "{blue}{176}     {174} {lightgreen}{176}     {174}"

    XP% = 23 : YP% = 14 : GOSUB Set_Cursor_Position
    PRINT "   {white}A       S"

    XP% = 23 : YP% = 17 : GOSUB Set_Cursor_Position
    PRINT "{blue}{173}     {189} {lightgreen}{173}     {189}"

    REM AltoFluff
    XP% = 23 : YP% = 20 : GOSUB Set_Cursor_Position    
    PRINT "{brown}{rvs on}{172}{rvs off}{161}{161}{188}{rvs on}{172}{161}{187}{brown}{rvs off}{188}{rvs on}{162}{162}{162}{162}{162}{162}{162}{rvs off}"
    
    XP% = 23 : YP% = 21 : GOSUB Set_Cursor_Position
    PRINT "{brown}{rvs on}{172}{rvs off}{161}{rvs on}{188}{rvs off} {161}{rvs on}{161}{190}{rvs off}{orange}{rvs on}{161}{rvs off}{190}{161}{rvs on}{161}{161}{161}{rvs off}{190}{rvs on}{172}{rvs off}"

    XP% = 23 : YP% = 22 : GOSUB Set_Cursor_Position
    PRINT "{orange}{162}{162}{162}{162}{162}{162}{162}{orange}{rvs on}{161}{rvs off}{190}{rvs on}{188}{161}{190}{161}{rvs off}{190}{rvs on}{172}{rvs off}"
    PRINT "{black}{home}"

    RETURN

Print_Instructions:
    XP% = 0 : YP% = 10 : GOSUB Set_Cursor_Position
    PRINT "   {white}Watch the"
    PRINT 
    PRINT "   Sequence Closely"
    PRINT
    PRINT "   Then Replicate"

    RETURN

Print_Score:
    XP% = 0 : YP% = 20 : GOSUB Set_Cursor_Position
    PRINT "   {white}Length: ";PL%
    PRINT
    PRINT "   High Score: ";HI%

    RETURN

Sprite_Data:
    :: rem sprite_box / singlecolor / color: 1
    data 255,255,240,255,255,240,255,255,240,255,255,240,255,255,240,255
    data 255,240,252,3,240,252,3,240,252,3,240,252,3,240,252,3
    data 240,252,3,240,252,3,240,252,3,240,255,255,240,255,255,240
    data 255,255,240,255,255,240,255,255,240,255,255,240,0,0,0,1
