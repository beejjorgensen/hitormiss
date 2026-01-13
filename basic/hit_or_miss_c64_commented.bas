REM https://www.c64-wiki.com/wiki/control_character

REM === SETUP ===

REM SN=SID (sound) chip
REM SB=Video memory
REM CB=Color memory
REM HS=High score
REM SD=[sound something]???
REM R=poking values here sets the row the cursor is on? (0-based?)

10 SN=54272:SB=1024:CB=55296:HS=0:SD=0:R=214

REM POKE 650,128: all keys repeat
REM Also set border and background to 0 (black)

20 POKE 650,128:POKE 53281,0:POKE 53280,0

REM Clear out SID chip

30 FOR X=SN TO SN+24:POKE X,0:NEXT X

REM Set ADSR for voice 1, volume to max

40 POKE SN+5,128: POKE SN+6,128:POKE SN+24,15

REM S$=single space
REM L$=Run of 23 spaces

50 S$=CHR$(32):L$=S$:FOR X=1 TO 22:L$=L$+S$:NEXT X

REM CHR$(113)=solid circle ●  ○
REM CHR$(123)=big plus ╋
REM B$=●●●●●●●●●●●●╋╋╋╋●●●●●●●●●●●●
REM        12        4      12
60 B$=CHR$(113):FOR X=2 TO 28
70 B$=B$+CHR$(113-10*(X>12 AND X<17)):NEXT X

REM CHR$(18): reverse on
80 M$=CHR$(18)+"/////////////MISS/////////////"
90 H$=CHR$(18)+"=============HIT!============="

REM CHR$(5): text color white
REM CHR$(118): fat X ✖ or ╳
REM CHR$(144): text color black
REM Q$=white fat X
REM E$=black space

100 Q$=CHR$(5)+CHR$(118):E$=CHR$(144)+S$

REM CHR$(18): reverse on
REM CHR$(156): text color purple
REM CHR$(144): text color black
REM P$=the paddle, three inverse minus signs
REM N$=three black spaces

110 P$=CHR$(18)+CHR$(156)+"---":N$=CHR$(144)+S$+S$+S$

REM === GAME RESTART ===

REM CX=column of ball, screen-relative
REM Choose random column 9-34, excluding 21-24

120 CX=INT(RND(1)*25)+9:IF CX>20 and CX<25 THEN 120

REM RX=row of ball, screen-relative
REM FL=flag TRUE (-1) if HIT! on top, FALSE (0) if HIT! on bottom
REM DR=row direction (-1) if ball going up, (1) if ball going down
REM DC=column direction (-1) for ball left, (1) for ball right
REM SC=score

130 RX=11:FL=-1:DR=-1:DC=-1:SC=0

REM HC=Previous column
REM HR=Previous row
REM NP=???
REM LP=???
REM M=???

140 HC=CX:HR=RX:NP=22:LP=19:M=0

REM CHR$(147): clear screen, home cursor
REM Voice 1 frequency to (45<<8)|198
REM    That comes to 11718
REM    Multiply that by 0.59605 to get
REM    Frequency = 698.45 Hz, F5 on the piano
REM This does not activate voice 1 yet

150 PRINT CHR$(147):POKE SN,198:POKE SN+1,45

REM Set row to 5, text color white, YOUR SCORE
REM on subsequent lines, a blank line, then the score

160 POKE R,5:PRINT:PRINT CHR$(5);" YOUR":PRINT " SCORE:":PRINT:PRINT SC

REM Set row to 12, same thing for HIGH SCORE

170 POKE R,12:PRINT:PRINT " HIGH":PRINT " SCORE:"
180 PRINT:PRINT CHR$(5);HS

REM Set row to 10 (board center-1)
REM CHR$(19): home cursor

190 POKE R,10:PRINT:PRINT TAB(12);"PRESS ANY KEY TO BEGIN.";CHR$(19)

REM Board printing code
REM
REM K1 is the top circles color, K2 is the bottom. KO (oh) is the
REM current color depending on where we're drawing.
REM
REM Not sure why the top colors are more limited than the bottom.
REM
REM K1/KO is color:
REM 152: Medium Gray
REM 153: Light Green
REM 154: Light Blue
REM
REM K2 is color:
REM 149: Brown
REM 150: Light Red
REM 151: Dark Gray
REM 152: Medium Gray
REM 153: Light Green
REM 154: Light Blue
REM 155: Light Gray

200 K1=INT(RND(1)*3)+152:K2=INT(RND(1)*7)+149:KO=K1

REM Draw 19 rows, starting with a purple inverted space on the left
REM CHR$(18): reverse on
REM CHR$(156): Purple

210 PRINT:FOR X=1 TO 19:PRINT TAB(8);CHR$(18);CHR$(156);S$;

REM If we're above or below the paddle zone, draw the line of balls and
REM plusses in color KO.
REM CHR$(146): reverse off

220 IF X<9 OR X>11 THEN PRINT CHR$(146);CHR$(KO);B$;

REM Draw the right side reverse purple space

230 PRINT TAB(37);CHR$(18);CHR$(156);S$

REM If we hit the midline, switch the balls-and-plusses color to K2.

240 IF X=11 THEN KO=K2
250 NEXT X

REM Set row to 22, print instructions.
REM CHR$(19): Home cursor

260 POKE R,22:PRINT:PRINT TAB(18);"PADDLE KEYS:"
270 PRINT TAB(13);"B = LEFT    N = RIGHT";CHR$(19)

REM Subroutine: Print HIT! on top and MISS at the bottom

280 GOSUB 1030

REM Busy wait for any key to be pressed.

290 GET K$:IF K$="" THEN 290

REM Clear out PRESS ANY KEY message

300 POKE R,10:PRINT:PRINT TAB(12);L$

REM === MAIN LOOP ===

REM 95% chance we do NOT add a new character to the grid.
REM
REM RND(0) gets a random number from the hardware clock
REM RND(1) gets it from a PRNG?
REM
REM I think this could have been RND(1) and worked just as well.

310 IF RND(0)>0.05 THEN 360

REM Add a new item to the board, Typicall an `*`.
REM But if the M counter is over 300 there's a 50% change it's a ╋
REM CHR$(42): asterisk
REM CHR$(123): big plus ╋

320 CH=42:IF M>300 AND RND(1)>0.5 THEN CH=123

REM Choose a random row for the new item

330 XR=INT(RND(1)*16)+3

REM But if it's in the paddle zone, choose another

340 IF XR>9 AND XR<13 THEN 330

REM Set the row to the new random row
REM TAB in to a random position on the board, text color white, print
REM the new item.
350 POKE R,XR-1:PRINT:PRINT TAB(INT(RND(1)*21)+10);CHR$(5);CHR$(CH)

REM Move the ball

360 CX=CX+DC:RX=RX+DR

REM Peek the screen at the ball location

370 PE=PEEK(SB+CX+RX*40)

REM If you hit a circle or plus, get 20 points
REM Add one to the M counter.
REM Screen code 81 is ●
REM Screen code 91 is ╋

380 IF PE=81 OR PE=91 THEN SC=SC+20:M=M+1

REM If you hit an asterisk, get 500 points.
REM Set voice 1 to sawtooth/gate?

390 IF PE=42 THEN SC=SC+500:SD=33:POKE SN+4,SD

REM Subroutine: update score on screen
REM If you hit a ╋, reverse column direction and skip ???

400 GOSUB 2000:IF PE=91 THEN DC=-DC:GOTO 520

REM If we're just in a regular column, skip ???

410 IF CX>8 AND CX<37 THEN 440

REM This must be for hitting the walls
REM Reverse column direction, play a noise sound
REM Move the ball in the new column direction

420 DC=-DC:SD=129:POKE SN+4,SD:CX=CX+DC

REM Peek the screen at the ball location

430 PE=PEEK(SB+CX+RX*40)

REM If we're mid screen and the ball didn't hit the paddle, skip ???
REM Screen code 173: inverse `-` (the paddle)

440 IF RX>1 AND RX<21 AND PE<>173 THEN 520

REM If we got here, we hit the top or bottom
REM Reverse row direction, play noise sound

450 DR=-DR:SD=129:POKE SN+4,SD

REM If we went off the top, and if top is MISS, then goto game over

460 IF RX<2 THEN RX=3:IF NOT FL THEN 620

REM If we went off the bottom, and if bottom is MISS, then goto game over

470 IF RX>20 THEN RX=19:IF FL THEN 620

REM If we hit the paddle, RX=RX+2*DR ???  skip ???

480 IF PE=173 THEN RX=RX+2*DR:GOTO 520

REM If row is 11 print peeked value and break (debugging?)
490 IF RX=11 THEN PRINT PE:STOP

REM Add M counter to the score
REM Subroutine: update score on screen
500 SC=SC+M:GOSUB 2000

REM 30% chance we swap hit/miss
510 IF RND(1)>0.7 THEN GOSUB 1000

REM Print a space at the old ball position

520 POKE R,HR-1:PRINT:PRINT TAB(HC);S$

REM Print a heavy X at the new ball position

530 POKE R,RX-1:PRINT:PRINT TAB(CX);Q$

REM Update previous position to current position
REM If the row is 11???, jump to start of game loop (why?)

540 HC=CX:HR=RX:IF RX=11 THEN 310


550 GET K$:NP=NP+2*((K$="B")-(K$="N")):IF SD THEN POKE SN+4,SD-1:SD=0
560 IF LP=NP THEN 310
570 IF NP<9 THEN NP=9
580 IF NP>34 THEN NP=34
590 POKE R,10:PRINT:PRINT TAB(LP);N$
600 POKE R,10:PRINT:PRINT TAB(NP);P$
610 LP=NP:GOTO 310
620 POKE SN+4,33:FOR DE=1 TO 25
630 POKE R,HR-1:PRINT:PRINT TAB(HC);CHR$(INT(RND(1)*2)+118)
640 POKE SN,38:POKE SN+1,INT(RND(1)*69)+1:NEXT DE
650 POKE SN+4,0
660 POKE R,23:PRINT
670 FOR DE=1 TO 10:PRINT CHR$(13):NEXT DE
680 PRINT CHR$(158);"SORRY, YOU MISSED."
690 PRINT:PRINT "YOUR SCORE WAS";SC;"POINTS."
700 IF SC>HS THEN HS=SC:PRINT:PRINT CHR$(159);"A NEW RECORD!";CHR$(158)
710 PRINT:PRINT "THE HIGH SCORE IS";HS;"POINTS."
720 PRINT:PRINT:PRINT:PRINT CHR$(150);" PLEASE SELECT:":PRINT
730 PRINT " <R>EPLAY"
740 PRINT " <Q>UIT"
750 PRINT:PRINT:PRINT:PRINT
760 GET K$:IF K$="Q" THEN END
770 IF K$<>"R" THEN 760
780 GOTO 120

REM SUBROUTINE: Swap hit/miss. Play triangle waveform.

1000 POKE SN+4,17:FL=NOT FL:IF FL THEN 1030

REM SUBROUTINE: Print MISS on top and HIT! on the bottom.

1010 POKE R,1:PRINT:PRINT CHR$(19);CHR$(28);TAB(48);M$
1020 POKE R,20:PRINT:PRINT CHR$(158);TAB(8);H$:RETURN

REM SUBROUTINE: Print HIT! on top and MISS on the bottom.

1030 POKE R,1:PRINT:PRINT CHR$(19);CHR$(158);TAB(48);H$
1040 POKE R,20:PRINT:PRINT CHR$(28);TAB(8);M$:RETURN

REM SUBROUTINE: Update score on screen

2000 POKE R,8:PRINT:PRINT CHR$(5);SC:RETURN
