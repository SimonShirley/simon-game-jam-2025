GOTO Initialise_Program

Generate_Random:
    RD% = INT(RND(1) * 4) + 1
    RETURN

Initialise_Program:
    PRINT "{clr}{home}" : REM Clear the screen
    MX = 20 : REM Max Pattern Length
    DIM PA%(MX) : REM Pattern Array
    RD% = RND(-TI) : REM re-seed the random generator    

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
    PRINT SPC(1);
    NEXT I

    PRINT
    PRINT
    PRINT "Enter the sequence"

Game_Loop:
    GET K$ : IF K$ = "" THEN Game_Loop

    IF VAL(K$) <> PA%(CC) THEN Game_Over
    IF NC = MX THEN Game_Over : REM End game because the array is set to 50
    IF CC = NC THEN Ready_Up_Next_Sequence : REM Increase Sequence Game Loop
    CC = CC + 1 : REM Increment current guess counter

    GOTO Game_Loop

Game_Over:
    PRINT "Game Over"
    END