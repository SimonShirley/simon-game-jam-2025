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

Start_Sound:
    POKE SR + 1, CS%(SN%,0) : POKE SR, CS%(SN%,1) : REM Poke Note Frequency
    POKE SR + 4, 33 : REM GATE(1) + SAWTOOTH(32)
    RETURN

Stop_Sound:
    POKE SR + 4, 32 : REM GATE(0) + SAWTOOTH(32)
    RETURN

Wait_Delay:
    FOR DL = 0 TO FD% : NEXT DL : RETURN

Flash_Sprite:
    IF CM% AND SO% THEN Flash_Sprite__Start_Sound
    REM SN% = Sprite Number to Enable
    GOSUB Turn_On_Sprite : REM Turn On Sprite
Flash_Sprite__Start_Sound:
    GOSUB Start_Sound : REM Start Sound

    GOSUB Wait_Delay : REM Wait
    
    GOSUB Stop_Sound : REM Turn Off Sound
    GOSUB Turn_Off_Sprite : REM Turn Off Sprite    
    
    GOSUB Wait_Delay : REM Wait

    RETURN

Increment_Score:
    REM Increment Score and Set High Score
    SC% = SC% + 1
    IF SC% >= HI% THEN HI% = SC%

    GOSUB Print_Score
    RETURN

Set_Cell_Colours:
    IF CB% THEN Set_Cell_Colours__Colour_Blind
    CC%(0, 0) = 2 : CC%(0, 1) = 10
    CC%(1, 0) = 5 : CC%(1, 1) = 13
    CC%(2, 0) = 6 : CC%(2, 1) = 14
    CC%(3, 0) = 7 : CC%(3, 1) = 1

    GOTO Set_Cell_Colours__Update_Sprite_Colours

Set_Cell_Colours__Colour_Blind:
    CC%(0, 0) = 11 : CC%(0, 1) = 1
    CC%(1, 0) = 11 : CC%(1, 1) = 1
    CC%(2, 0) = 11 : CC%(2, 1) = 1
    CC%(3, 0) = 11 : CC%(3, 1) = 1

Set_Cell_Colours__Update_Sprite_Colours:
    REM Sprite Colours
    FOR I = 0 TO 3 : POKE VL+39+I,CC%(I, 0) : NEXT

    RETURN

Initialise_Program:
    POKE 53280,0 : POKE 53281,0
    PRINT "{clr}{home}" : REM Clear the screen
    MX = 20 : REM Max Pattern Length
    DIM PA%(MX) : REM Pattern Array
    DIM CC%(3,3) : REM Cell Colours
    CB% = 0 : REM Colourblind Mode Off
    FS% = 200 : REM Default Flash Delay Setting - FD% is the delay variable
    SO% = 0 : REM Sound Only Mode
    HM% = 0 : REM Hint Mode disabled

Keyboard_Keys:
    DIM KK$(3)

    KK$(0) = "Q"
    KK$(1) = "W"
    KK$(2) = "A"
    KK$(3) = "S"

Initialise_Sound:
    DIM CS%(3,1) : REM Cell Sound

    CS%(0,0) = 22 : CS%(0,1) = 96
    CS%(1,0) = 28 : CS%(1,1) = 49
    CS%(2,0) = 33 : CS%(2,1) = 135
    CS%(3,0) = 44 : CS%(3,1) = 193

    SR = 54272 : REM SID BASE ADDRESS
    FOR I = SR TO SR + 24 : POKE I,0 : NEXT : REM Reset SID
    POKE SR + 5,9 : POKE SR + 6,0 : REM SET ADSR ENVELOPE
    POKE SR + 24,15 : REM SET MAX VOLUME

Initialise_Win_Jingle:
    DIM WJ%(5) : REM Win Jingle Note
    DIM WD%(5) : REM Win Jingle Delay

    WJ%(0) = 0
    WJ%(1) = 1
    WJ%(2) = 2
    WJ%(3) = 3
    WJ%(4) = 2
    WJ%(5) = 3

    WD%(0) = 50
    WD%(1) = 50
    WD%(2) = 50
    WD%(3) = 100
    WD%(4) = 50
    WD%(5) = 100

#--------------

    GOSUB Set_Cell_Colours
    GOSUB Initialise_Sprites

    GOTO Game_Screen__Title_Screen

Restart:
    SC% = 0
    HA% = 3 : REM Hints Available
    HU% = 0 : REM Hint Used This Round
    RD% = RND(-TI) : REM re-seed the random generator

    PRINT "{clr}{home}"
    GOSUB Game_Screen__Simon_Logo
    GOSUB Game_Screen__Colour_Boxes
    GOSUB Set_Cell_Colours
    GOSUB Show_Sprites
    GOSUB Game_Screen__Alto_Fluff_Logo
    
    IF HM% THEN GOSUB Print_Hints    
    IF NOT SO% THEN Game_Start_After_Restart

    GOSUB Print_Instructions__Listen_To_Tones
    SO% = 0 : REM Unset Sound Only mode for the demonstration

    SC% = -1 : GOSUB Increment_Score

    FD% = 200 : REM Set Flash Sprite Delay

    FOR L = 0 TO 1
    FOR I = 0 TO 3
    SN% = I
    GOSUB Flash_Sprite
    NEXT I
    NEXT L

    SO% = -1 : REM Reset Sound Only Mode

Game_Start_After_Restart:
    GOSUB Print_Instructions__Watch_Clearly

    REM Empty sequence
    FOR I = 0 TO MX : PA%(I) = -1 : NEXT

    NC = -1 : REM Next sequence counter
    SC% = -1 : REM Reset Score

Ready_Up_Next_Sequence:
    NC = NC + 1 : REM Move next counter along
    CM% = -1 : REM In computer display mode

    REM No score if a hint was used
    IF NOT HU% THEN GOSUB Increment_Score

    HU% = 0 : REM Reset Hint Used Flag

    GOSUB Generate_Random : REM Generate Random
    PA%(NC) = RD% : REM Store random number in sequence array

Flash_Current_Sequence:
    POKE 649,0 : REM Disable Keyboard Buffer
    CC = 0 : REM Current sequence counter

    GOSUB Print_Instructions__Watch_Clearly
    
    FD% = FS% : REM Set Flash Sprite Delay
    GOSUB Wait_Delay

    FOR I = 0 TO NC    
    SN% = PA%(I) : GOSUB Flash_Sprite
    NEXT I

    POKE 649,10 : REM Set keyboard buffer size to 10
    POKE 631,0 : REM Set remaining keyboard keys buffer to 0

    GOSUB Print_Instructions__Your_Turn

    CM% = 0 : REM Set to user mode

Game_Loop:
    REM Set Flash Sprite Delay
    IF FS% = 200 THEN FD% = 75 : GOTO Get_Next_Key
    FD% = 25

Get_Next_Key:
    GET K$ : IF K$ = "" THEN Game_Loop

    IF NOT HM% THEN Get_Next_Key__Continue
    IF K$ = "H" AND HA% > 0 THEN Show_Hint

Get_Next_Key__Continue:
    K% = -1
    FOR I = 0 TO 3
    IF K$ = KK$(I) THEN K% = I : I = 99
    NEXT

    REM Flash the user's input
    IF K% < 0 OR K% > 3 THEN GOTO Get_Next_Key
    
    SN% = K% : GOSUB Flash_Sprite

    IF K% <> PA%(CC) THEN Game_Over

    REM End game because the array is set to 20
    IF CC = MX - 1 THEN End_Game

    REM Increase Sequence Game Loop
    FD% = 200 : REM Set Flash Sprite Delay
    IF CC = NC THEN GOSUB Wait_Delay : GOTO Ready_Up_Next_Sequence

    CC = CC + 1 : REM Increment current guess counter

    GOTO Game_Loop

Show_Hint:
    HU% = -1 : REM Set Hint Used Flag
    HA% = HA% - 1 : REM Reduce remaining hints available
    GOSUB Print_Hints
    GOSUB Flash_Current_Sequence
    GOTO Get_Next_Key

Game_Over:
    GOSUB Print_Instructions__Blank

Game_Over__Jingle:
    POKE SR + 1, 16 : POKE SR, 195 : REM Poke Note Frequency

    FOR J = 0 TO 2
    POKE SR + 4, 33 : REM GATE(1) + SAWTOOTH(32)
    FD% = 100 : GOSUB Wait_Delay
    POKE SR + 4, 32 : REM GATE(0) + SAWTOOTH(32)
    NEXT J

    #-------

    GOSUB Print_Instructions__Correct_Sequence_Header
    FD% = 500 : GOSUB Wait_Delay

    GOSUB Print_Instructions__Correct_Sequence
    GOTO Pre_Restart

End_Game:
    GOSUB Increment_Score
    GOSUB Print_Instructions__Win

    FOR J = 0 TO 5
    FD% = WD%(J)
    SN% = WJ%(J)
    GOSUB Start_Sound
    GOSUB Wait_Delay
    GOSUB Stop_Sound    
    NEXT J
    
Pre_Restart:
    FD% = 2000
    GOSUB Wait_Delay
    GOTO Game_Screen__Title_Screen


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
    
    GOSUB Set_Cell_Colours
    
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

Show_Sprites:
    POKE VL+21,31 : rem set sprites 0-3 visible
    RETURN

Hide_Sprites:
    POKE VL+21,0 : rem turn off all sprites
    RETURN

Hide_Sprites__Game_Screen:
    GOSUB Hide_Sprites

    PRINT "{clr}{home}"
    GOSUB Game_Screen__Simon_Logo

    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position

    RETURN

Game_Screen__Simon_Logo:
    REM Simon Logo
    PRINT "{clr}{home}"
    PRINT
    PRINT "   {pink}{162}{187}{lightgreen}{187}"
    PRINT "   {pink}{rvs on}{252}{rvs off}{187}{lightgreen}{187}{yellow}{162}{172}{187}{cyan}{162}{187}{white}{162}{187}"
    PRINT "   {pink}{162}{161}{lightgreen}{161}{yellow}{161}{190}{161}{cyan}{rvs on}{188}{rvs off}{161}{white}{161}{161}"
    PRINT
    PRINT "   {purple}{rvs on}{162}{162}{162}{162}{162}{162}{162}{162}{162}{rvs off}{190}"
    PRINT

    RETURN

Game_Screen__Colour_Boxes:
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

    RETURN

Game_Screen__Alto_Fluff_Logo:
    REM AltoFluff
    REM Remember to manually set YP%
    XP% = 23 : YP% = 22 : GOSUB Set_Cursor_Position    
    PRINT "{brown}{rvs on}{172}{rvs off}{161}{161}{188}{rvs on}{172}{161}{187}{brown}{rvs off}{188}{rvs on}{162}{162}{162}{162}{162}{162}{162}{rvs off}"
    
    XP% = 23 : YP% = 23 : GOSUB Set_Cursor_Position
    PRINT "{brown}{rvs on}{172}{rvs off}{161}{rvs on}{188}{rvs off} {161}{rvs on}{161}{190}{rvs off}{orange}{rvs on}{161}{rvs off}{190}{161}{rvs on}{161}{161}{161}{rvs off}{190}{rvs on}{172}{rvs off}"

    XP% = 23 : YP% = 24 : GOSUB Set_Cursor_Position
    PRINT "{orange}{162}{162}{162}{162}{162}{162}{162}{orange}{rvs on}{161}{rvs off}{190}{rvs on}{188}{161}{190}{161}{rvs off}{190}{rvs on}{172}{rvs off}";

    RETURN


Game_Screen__Title_Screen:
    GOSUB Hide_Sprites__Game_Screen

    PRINT "   {white}A {light-red}simple {lightgreen}game {white}of"
    PRINT
    PRINT "   {yellow}memorisation"
    PRINT
    PRINT "   {white}and {lightblue}repetition"
    PRINT
    PRINT
    PRINT
    PRINT "   {white}P - Play Game"
    PRINT
    PRINT "   I - Instructions"
    PRINT
    PRINT "   C - Credits"
    PRINT
    PRINT
    PRINT "   {grey}Jan-Feb 2025";

    TC% = CB% : REM Temp Colourblind setting
    CB% = 0 : GOSUB Set_Cell_Colours

    GOSUB Show_Sprites
    GOSUB Game_Screen__Alto_Fluff_Logo

    CB% = TC% : REM Restore Colourblind Setting


Wait__Title_Screen:
    GET K$ : IF K$ = "" THEN Wait__Title_Screen

    IF K$ = "C" THEN Game_Screen__Credits
    IF K$ = "I" THEN Game_Screen__Instructions
    IF K$ = "P" THEN Game_Screen__Options
    
    GOTO Wait__Title_Screen

Game_Screen__Options:
    GOSUB Hide_Sprites__Game_Screen

    PRINT "   {white}Game Options :"
    PRINT "   {red}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}"
    PRINT
    PRINT "   {light-red}Colours  {white}F1 : "; : GOSUB Options__Colour_Mode_Print
    PRINT
    PRINT "   {lightblue}Mode     {white}F3 : "; : GOSUB Options__Sound_Only_Print
    PRINT
    PRINT "   {yellow}Speed    {white}F5 : "; : GOSUB Options__Flash_Delay_Print
    PRINT
    PRINT "   {lightgreen}Hints    {white}F7 : "; : GOSUB Options__Hints_Print
    PRINT
    PRINT
    PRINT
    PRINT "   {white}P - Play Game"
    PRINT
    PRINT "   M - Main Menu";

    GOSUB Game_Screen__Alto_Fluff_Logo

Wait_Options:
    GET K$ : IF K$ = "" THEN Wait_Options

    IF K$ = CHR$(133) THEN GOSUB Options__Colour_Mode_Set
    IF K$ = CHR$(134) THEN GOSUB Options__Sound_Only_Set
    IF K$ = CHR$(135) THEN GOSUB Options__Flash_Delay_Set
    IF K$ = CHR$(136) THEN GOSUB Options__Hints_Set
    IF K$ = "P" THEN Restart
    IF K$ = "M" THEN Game_Screen__Title_Screen

    GOTO Wait_Options

Options__Colour_Mode_Set:
    CB% = NOT CB%

Options__Colour_Mode_Print:
    XP% = 17 : YP% = 12 : GOSUB Set_Cursor_Position
    
    IF CB% THEN PRINT "{white}Normal / {rvs on}Monochrome{rvs off}" : RETURN
    PRINT "{white}{rvs on}Normal{rvs off} / Monochrome"
    RETURN

Options__Sound_Only_Set:
    SO% = NOT SO%

Options__Sound_Only_Print:
    XP% = 17 : YP% = 14 : GOSUB Set_Cursor_Position

    IF SO% THEN PRINT "{white}Normal / {rvs on}Sound Only{rvs off}" : RETURN
    PRINT "{white}{rvs on}Normal{rvs off} / Sound Only"
    RETURN

Options__Flash_Delay_Set:
    IF FS% = 200 THEN FS% = 50 : GOTO Options__Flash_Delay_Print
    FS% = 200

Options__Flash_Delay_Print:
    XP% = 17 : YP% = 16 : GOSUB Set_Cursor_Position

    IF FS% = 200 THEN PRINT "{white}{rvs on}Normal{rvs off} / Fast" : RETURN
    PRINT "{white}Normal / {rvs on}Fast{rvs off}"
    RETURN

Options__Hints_Set:
    HM% = NOT HM%

Options__Hints_Print:
    XP% = 17 : YP% = 18 : GOSUB Set_Cursor_Position

    IF HM% THEN PRINT "{white}Off / {rvs on}On{rvs off}" : RETURN
    PRINT "{white}{rvs on}Off{rvs off} / On"
    RETURN

Game_Screen__Instructions:
    GOSUB Hide_Sprites__Game_Screen

    PRINT "   {white}The Game will generate a random"
    PRINT "   sequence of colours"
    PRINT
    PRINT "   Once the computer has shown the"
    PRINT "   sequence, you will need to enter"
    PRINT "   the same sequence using the"
    PRINT "   {light-red}Q {lightgreen}W {yellow}A {lightblue}S {white}keys"
    PRINT
    PRINT "   On successful entry, the sequence"
    PRINT "   will repeat, with one new random"
    PRINT "   colour added to the end"
    PRINT
    PRINT "   How many can you remember?"
    PRINT
    PRINT
    PRINT "   M - Main Menu";

Wait__Instructions:
    GET K$ : IF K$ = "M" THEN Game_Screen__Title_Screen
    GOTO Wait__Instructions

Game_Screen__Credits:
    GOSUB Hide_Sprites__Game_Screen

    PRINT "   {white}Participated in the"
    PRINT "   {lightblue}Retro Programmers Inside {white}({lightblue}RPI{white})"
    PRINT "   and {yellow}Phaze101 {white}Game Jam"
    PRINT
    PRINT "   {lightgreen}https://itch.io/jam/simongame"
    PRINT
    PRINT
    PRINT
    PRINT "   {white}With special thanks to :"
    PRINT "   {light-red}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}{99}"
    PRINT
    PRINT "   {lightblue}DeadSheppy{white}, {lightblue}Oberon{white}, & {lightblue}Sabbath"
    PRINT "   {white}for mode ideas and game testing"
    PRINT
    PRINT
    PRINT "   M - Main Menu";

Wait__Credits:
    GET K$ : IF K$ = "M" THEN Game_Screen__Title_Screen
    GOTO Wait__Credits


Print_Instructions__Blank:
    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position
    
    FOR BL = 0 TO 10
    PRINT "                       "
    NEXT BL

    RETURN

Print_Instructions__Watch_Clearly:
    GOSUB Print_Instructions__Blank
    
    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position
    
    IF SO% THEN PRINT "   {white}Listen to the" : GOTO Print_Instructions__Watch_Clearly_Continue
    PRINT "   {white}Watch the"
Print_Instructions__Watch_Clearly_Continue:
    PRINT
    PRINT "   Sequence Closely"

    RETURN

Print_Instructions__Your_Turn:
    GOSUB Print_Instructions__Blank
    
    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position
    
    PRINT "   {white}Repeat the"
    PRINT
    PRINT "   Sequence"

    IF NOT HU% THEN RETURN

    PRINT
    PRINT "   From the"
    PRINT
    PRINT "   Beginning"

    RETURN

Print_Instructions__Win:
    GOSUB Print_Instructions__Blank

    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position
    
    PRINT "   {white}Congratulations"
    PRINT
    PRINT
    PRINT
    PRINT "   You Completed"
    PRINT
    PRINT "   The Sequence!"

    RETURN

Print_Instructions__Correct_Sequence_Header:
    GOSUB Print_Instructions__Blank

    LN = 13
    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position    
    
    PRINT "   {white}The Correct"
    PRINT
    PRINT "   Sequence Was: "
    PRINT

    RETURN

Print_Instructions__Correct_Sequence:
    PC = 0
    PL = 8 : REM PL : Print per line

    FD% = 150 : REM Reduce Wait Delay
    
    FOR J = 0 TO NC STEP PL
    IF (NC - PC) < PL THEN PL = NC - PC + 1
Print_Loop:
    PRINT "   ";
    FOR I = 0 TO PL - 1
    PRINT KK$(PA%(PC));" ";
    SN% = PA%(PC) : GOSUB Flash_Sprite
    PC = PC + 1
    NEXT I
    PRINT
    NEXT J

    RETURN

Print_Instructions__Listen_To_Tones:
    GOSUB Print_Instructions__Blank
    
    XP% = 0 : YP% = 9 : GOSUB Set_Cursor_Position
    
    PRINT "   {white}Listen to the"
    PRINT
    PRINT "   Tones and"
    PRINT
    PRINT "   Memorise"

    RETURN

Print_Hints:
    XP% = 0 : YP% = 20 : GOSUB Set_Cursor_Position
    PRINT "                         "

    IF NOT HM% THEN RETURN
    XP% = 0 : YP% = 20 : GOSUB Set_Cursor_Position
    PRINT "   {white}Hints (H)  :    ";

    XP% = 16 : YP% = 20 : GOSUB Set_Cursor_Position
    PRINT HA%

    RETURN


Print_Score:
    XP% = 0 : YP% = 22 : GOSUB Set_Cursor_Position    
    PRINT "   {white}Score      :    "
    PRINT
    PRINT "   High Score :    ";

    XP% = 16 : YP% = 22 : GOSUB Set_Cursor_Position
    PRINT "   "

    XP% = 16 : YP% = 24 : GOSUB Set_Cursor_Position
    PRINT "   ";

    XP% = 16 : YP% = 22 : GOSUB Set_Cursor_Position
    PRINT SC%

    XP% = 16 : YP% = 24 : GOSUB Set_Cursor_Position
    PRINT HI%;

    RETURN

Sprite_Data:
    :: rem sprite_box / singlecolor / color: 1
    data 255,255,240,255,255,240,255,255,240,255,255,240,255,255,240,255
    data 255,240,252,3,240,252,3,240,252,3,240,252,3,240,252,3
    data 240,252,3,240,252,3,240,252,3,240,255,255,240,255,255,240
    data 255,255,240,255,255,240,255,255,240,255,255,240,0,0,0,1
