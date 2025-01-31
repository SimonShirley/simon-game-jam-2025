10 print chr$(147)
20 print "generated with spritemate"
30 print "1 of 1 sprites displayed."
40 poke 53285,15: rem multicolor 1
50 poke 53286,6: rem multicolor 2
60 poke 53269,255 : rem set all 8 sprites visible
70 for x=12800 to 12800+63: read y: poke x,y: next x: rem sprite generation
80 :: rem sprite_box
90 poke 53287,1: rem color = 1
100 poke 2040,200: rem pointer
110 poke 53248, 44: rem x pos
120 poke 53249, 120: rem y pos
130 poke 53276, 0: rem multicolor
140 poke 53277, 1: rem width
150 poke 53271, 1: rem height
1000 :: rem sprite_box / singlecolor / color: 1
1010 data 255,255,240,255,255,240,255,255,240,255,255,240,255,255,240,255
1020 data 255,240,255,255,240,255,255,240,255,255,240,255,255,240,255,255
1030 data 240,255,255,240,255,255,240,255,255,240,255,255,240,255,255,240
1040 data 255,255,240,255,255,240,255,255,240,255,255,240,0,0,0,1
