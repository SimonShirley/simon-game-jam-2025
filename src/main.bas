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
    RD% = INT(RND(1) * 4) + 1
    RETURN

Initialise_Program:
    PRINT "{clr}{home}" : REM Clear the screen
    MX = 20 : REM Max Pattern Length
    DIM PA%(MX) : REM Pattern Array
    RD% = RND(-TI) : REM re-seed the random generator   

    GOSUB Initialise_Sprites

Restart:
    REM Empty sequence
    FOR I = 0 TO MX : PA%(I) = 0 : NEXT

    NC = -1 : REM Next sequence counter

Ready_Up_Next_Sequence:
    NC = NC + 1 : REM Move next counter along
    CC = 0 : REM Current sequence counter

    GOSUB Generate_Random : REM Generate Random
    PA%(NC) = RD% : REM Store random number in sequence array

    PRINT "{clr}{home}" : REM Clear the screen

    FOR I = 0 TO NC    
    PRINT STR$(PA%(I));
    FOR J = 0 TO 300 : NEXT J
    PRINT "{clr}{home}" : REM Clear the screen
    FOR J = 0 TO 300 : NEXT J
    NEXT I

    PRINT
    PRINT
    PRINT "Enter the sequence:"

Game_Loop:
    GET K$ : IF K$ = "" THEN Game_Loop

    PRINT K$;

    IF VAL(K$) <> PA%(CC) THEN Game_Over
    IF CC = MX - 1 THEN PRINT : PRINT "YOU WIN" : END : REM End game because the array is set to 50
    IF CC = NC THEN Ready_Up_Next_Sequence : REM Increase Sequence Game Loop
    CC = CC + 1 : REM Increment current guess counter

    GOTO Game_Loop

Game_Over:
    PRINT 
    PRINT "The correct sequence was "
    FOR I = 0 TO NC    
    PRINT STR$(PA%(I));
    NEXT I
    PRINT
    PRINT "Game Over"
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
    POKE VL+39,10
    POKE VL+40,13
    POKE VL+41,7
    POKE VL+42,14
    
    REM Set Sprite Data
    FOR X = 0 TO 0
    RESTORE
    FOR Y = 0 TO 63
    READ Z
    POKE VR + ((X+SL)*64) + Y,Z
    NEXT Y
    NEXT X

    POKE VL+16,0 : REM Disable Sprites MSB (for x pos)
    POKE VL,32 : POKE VL+1,58: rem sprite 0 pos
    POKE VL+2,32+48 : POKE VL+3,58: rem sprite 1 pos
    POKE VL+4,32 : POKE VL+5,58+40: rem sprite 0 pos
    POKE VL+6,32+48 : POKE VL+7,58+40: rem sprite 1 pos

    FOR X = 0 TO 3
    POKE SP + X, SL
    NEXT X


    POKE VL+21,0 : rem set sprites 0-3 visible

    RETURN

#---------------------

Sprite_Data:
    :: rem sprite_box / singlecolor / color: 1
    data 255,255,240,255,255,240,255,255,240,255,255,240,255,255,240,255
    data 255,240,255,255,240,255,255,240,255,255,240,255,255,240,255,255
    data 240,255,255,240,255,255,240,255,255,240,255,255,240,255,255,240
    data 255,255,240,255,255,240,255,255,240,255,255,240,0,0,0,1
