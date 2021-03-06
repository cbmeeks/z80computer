;port #0 VRAM Data (R/W)		$A020
;port #1 Status register (R) / VRAM Address (W) / Register set-up (W)	$A021
;port #2 Palette registers (W)	$A022
;port #3 Register indirect addressing (W)
;$2FFE - used for draw rectangle filled function
initializeVideo:
	call clearVram
	call VdpCharsIntoRam
	call setupDefaultColors

	;set up palette register with 4 colors
	;ld a, 0
	;ld d, %00000000		;green
	;ld e, %00000111
	;call VdpWriteToPaletteRegister

	;ld a, 1
	;ld d, %00000111
	;ld e, %00000000 	;blue
	;call VdpWriteToPaletteRegister

	;ld a, 2
	;ld d, %01110111
	;ld e, %00000111 	;white
	;call VdpWriteToPaletteRegister

	;ld a, 3
	;ld d, %00000000
	;ld e, %00000000 	;black
	;call VdpWriteToPaletteRegister

	;setup text mode 1

	;register 0
	ld d, %00000100 		;change to %00000100 for text2. %00000000
	ld a, 0
	call VdpWriteToStandardRegister

	;set up register 1
	ld d, %01010000
	ld a, 1
	call VdpWriteToStandardRegister

	;set up register 8
	;ld d, %00101000
	;ld a, 8
	;call VdpWriteToStandardRegister

	;set up register 9
	;ld d, %00000000 	;dot clock in "output" mode. s1 and s0 "simultaneous mode" (Whatever that means) set to zero
	;ld a, 9
	;call VdpWriteToStandardRegister

	ld d, %11110000 	;do it again just to make sure
	ld a, 7
	call VdpWriteToStandardRegister

	;set up register 12 and configure cursor color in text 2 mode
	ld d, %00001010
	ld a, 12
	call VdpWriteToStandardRegister

	;configure register 13, the cursor blink time register
	ld d, %01000100
	ld a, 13
	call VdpWriteToStandardRegister

	;set values of pattern generator, pattern layout and pattern color table
	;I am using "MSX system default" values
	;text 2 pattern generator: 01000h-017FFh. Pattern layout: 00000h-0077Fh (00000h-0086Fh in 26.5 line mode). Pattern color table 800h-8EFh (800h-90Dh in 26.5 mode)
	ld d, %00000011
	ld a, 2
	call VdpWriteToStandardRegister

	ld d, %00000010
	ld a, 4
	call VdpWriteToStandardRegister

	ld d, %00100111
	ld a, 3
	call VdpWriteToStandardRegister

	ld d, %00000000
	ld a, 10
	call VdpWriteToStandardRegister

	;do this after loading registers in case its needed or something
	call writeRegisterOne


;set vram to pos 0
	ld a, 14
	ld d, %00000000 	;bits a16, a15 and a14
	call VdpWriteToStandardRegister
	;pro-gamer move: since register b and c got set in the prev function, i'm not setting them again
	ld a, %00000000 	;bits a0-a7
	out (c), a
	ld a, %00000000 	;bits a8-a13. bit 6 is r/w. bit 7 should stay zero
	out (c), a

	;put a visual confirmation on the lcd that this function finished
	ld a, %11000000 					;the lcd's address for the 2nd line
	call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command

	ld hl, donemsg
	call printString

	call backToPrevCursorPos

ret

;sets up and configures graphics 4 mode
;	pattern layout (bitmap): 00000h-069ffh
;	sprite patterns 07800h-07fffh
;	sprite attributes 07600h-0767Ffh
;	sprite colors 07400h-075ffh
setupG4Mode:

	;put the vdp into graphics mode 4. m5 = 0. m4 = 1. m3 = 1. m2 = 0. m1 = 0
	;register 0
	ld d, %00000110 		;change to %00000100 for text2. %00000000
	ld a, 0
	call VdpWriteToStandardRegister

	;set up register 1
	ld d, %01000000
	ld a, 1
	call VdpWriteToStandardRegister

	;set up register 8
	ld d, %00001000
	ld a, 8
	call VdpWriteToStandardRegister

	;set register 23 to zero
	ld d, 0
	ld a, 23
	call VdpWriteToStandardRegister

	call clearMostVram

	;here's what I need to set:
	;	pattern layout (bitmap): 00000h-069ffh
	;	sprite patterns 07800h-07fffh
	;	sprite attributes 07600h-0767Ffh
	;	sprite colors 07400h-075ffh

	;pattern layout table
	ld d, %00011111
	ld a, 2
	call VdpWriteToStandardRegister

	;sprite patterns
	ld d, %00001111
	ld a, 6
	call VdpWriteToStandardRegister

	;sprite attributes high
	ld d, %00000000
	ld a, 11
	call VdpWriteToStandardRegister

	;sprite attributes low ($7600)
	ld d, %11101111
	ld a, 5
	call VdpWriteToStandardRegister

	;sprite color table high
	ld d, %00000001
	ld a, 10
	call VdpWriteToStandardRegister

	;sprite color table low
	ld d, %11010000
	ld a, 3
	call VdpWriteToStandardRegister

ret

;sets the color palette to the default
;I'm making it the same as the Microsoft Windows default 16-color palette
;https://en.wikipedia.org/wiki/List_of_software_palettes#Microsoft_Windows_default_16-color_palette
setupDefaultColors:
	
	;color 0 = black
	ld a, 0
	ld d, 0
	ld e, 0
	call VdpWriteToPaletteRegister

	;color 1 = maroon
	ld a, 1
	ld d, %01000000
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 2 = dark green
	ld a, 2
	ld d, %00000000
	ld e, %00000100
	call VdpWriteToPaletteRegister

	;color 3 = poop brown
	ld a, 3
	ld d, %01000000
	ld e, %00000100
	call VdpWriteToPaletteRegister

	;color 4 = navy blue
	ld a, 4
	ld d, %00000100
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 5 = purple
	ld a, 5
	ld d, %01000100
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 6 = teal
	ld a, 6
	ld d, %00000100
	ld e, %00000100
	call VdpWriteToPaletteRegister

	;color 7 = silver
	ld a, 7
	ld d, %01000100
	ld e, %00000100
	call VdpWriteToPaletteRegister

	;color 8 = gray
	ld a, 8
	ld d, %00100010
	ld e, %00000010
	call VdpWriteToPaletteRegister

	;color 9 = red
	ld a, 9
	ld d, %01110000
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 10 = bright green
	ld a, 10
	ld d, %00000000
	ld e, %00000111
	call VdpWriteToPaletteRegister

	;color 11 = yellow
	ld a, 11
	ld d, %01110000
	ld e, %00000111
	call VdpWriteToPaletteRegister

	;color 12 = blue
	ld a, 12
	ld d, %00000111
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 13 = fuchsia
	ld a, 13
	ld d, %01110111
	ld e, %00000000
	call VdpWriteToPaletteRegister

	;color 14 = aqua
	ld a, 14
	ld d, %00000111
	ld e, %00000111
	call VdpWriteToPaletteRegister

	;color 15 = white
	ld a, 15
	ld d, %01110111
	ld e, %00000111
	call VdpWriteToPaletteRegister


ret

;reads status from whatever status register number the a register contains
VdpReadStatus:

	;write contents of a register to vdp register 15 (should be 0-9)
	;ld hl, $A021
	;ld (hl), a
	ld b, $A0
	ld c, $21
	out (c), a

	ld a, 15 + 128
	out (c), a

	;it shoud now be set up to read the status of the inputted register
	in a, (c)

ret

;d should contain register data
;a should contain register number
VdpWriteToStandardRegister:
	ld b, $A0
	ld c, $21

	;write the data byte first because that's just what you do
	out (c), d

	;write the register number next
	;add a, 128
	or %10000000		;different way of adding 128 to a
	out (c), a
ret

; a register needs to contain palette register number you want to write to (0-15)
; d register needs to contain first palette byte
; e register needs to contain second palette byte
;note that the pointer value in register 16 auto increments each time you do this
VdpWriteToPaletteRegister:
	push af
	push de
		ld d, a
		ld a, 16
		call VdpWriteToStandardRegister
	pop de
	pop af

	ld b, $A0
	ld c, $22
	out (c), d
	out (c), e


ret

;text 2 pattern generator: 01000h-017FFh. Pattern layout: 00000h-0077Fh (00000h-0086Fh in 26.5 line mode)
VdpCharsIntoRam:
	ld a, 14
	ld d, %00000000 	;bits a16, a15 and a14
	call VdpWriteToStandardRegister
	;pro-gamer move: since register b and c got set in the prev function, i'm not setting them again
	ld a, %00000000 	;bits a0-a7
	out (c), a
	ld a, %00010001 	;bits a8-a13. bit 6 is r/w. bit 7 should stay zero
	out (c), a

	;now, time to make a bigass loop
	;get ready to start writing to port 0 - the vram access port
	ld b, $A0
	ld c, $20

	ld hl, letters_space
	ld a, (hl)
	
	VdpCharsIntoRamLoopStart:
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		out (c), a
		inc hl
		ld a, (hl)
		cp %11111111
		jr nz, VdpCharsIntoRamLoopStart

ret

;copy whatever's in register a to next address in vram
;changed registers: a, b, c and hl
VdpPrintChar:

	ld b, $A0
	ld c, $20
	out (c), a

	;update the column counter
	ld hl, $9EFA
	ld a, (hl)
	inc a
	ld (hl), a
	cp 80
	jr nc, incRow
	jr VdpPrintCharExit

	;if more than 80 columns, set column numbers to 0 and increment row number
	incRow:
		ld a, 0
		ld (hl), a
		ld hl, $9EFB
		ld a, (hl)
		inc a
		ld (hl), a
	VdpPrintCharExit:

ret

;hl should contain memory address of the string to print
;print a string using the VdpPrintChar subroutine
VPrintString:
	push hl
	call RowsColumnsToVram
	pop hl

	ld a, (hl)
	;==========================
	;push hl
	;call VdpPrintChar 		;load the first character of every string twice so I can see wtf it's really doing when it copies over that other pointless garbage
	;;pop hl
	;==========================
	VPrintStringLoop:
		push hl
		call VdpPrintChar
		pop hl
		inc hl
		ld a, (hl)
		cp 0
		jr nz, VPrintStringLoop

ret

VdpNewLine:

	ld hl, $9EFB 		;increase row by 1
	ld a, (hl)
	inc a
	ld (hl), a

ret

VdpCarriageReturn:

	ld hl, $9EFA 		;reset column to 0
	ld a, 0
	ld (hl), a

ret

VdpInsertEnter:

	call VdpNewLine
	call VdpCarriageReturn
	call checkScreenSize
	call RowsColumnsToCursorPos
	call RowsColumnsToVram

ret

VdpBackspace:
	ld hl, $9EFA
	ld a, (hl)
	cp 0
	jr z, VdpBackspaceExit 			;if the current column is zero, you can't backspace any further

	dec a
	ld (hl), a

	;let's  nullify the latest command buffer byte before resetting the command character count
	ld hl, $2009
	ld c, (hl)
	push bc
	ld hl, $2010
	ld b, 0
	add hl, bc
	pop bc

	ld a, 0
	ld (hl), a
	dec hl
	ld (hl), a ;you have to do this twice or else it will only delete the character + 1 position to the right of where you backspace


	ld hl, $2009
	ld a, (hl)
	dec a
	ld (hl), a
	call RowsColumnsToVram

	;now put in a nullspace without updating command buffer counter then vram backspace again
	ld a, 0
	call VdpPrintChar

	;a whitespace has now been written, graphically backspacing the thing that the user backspaced
	ld hl, $9EFA
	ld a, (hl)
	dec a
	ld (hl), a
	call RowsColumnsToCursorPos
	call RowsColumnsToVram

	VdpBackspaceExit:

ret

VdpInsertTab:

	;insert code here
	ld hl, $9EFA 	;get the horizontal cursor pos
	ld c, (hl)
	ld d, 8

	;divide number of columns by 8 to obtain the remainder
	call CDivD
	ld b, a
	ld a, 8

	;do 8-remainder. this gets the number of spaces that need to be inserted in order to perform a correct tab operation
	sub b

	ld d, a
	VdpInsertTabSpaceLoop:
		ld a, " "
		call VdpPrintChar
		dec d
		ld a, d
		cp 0
		jr nz, VdpInsertTabSpaceLoop

	call RowsColumnsToCursorPos
	call RowsColumnsToVram
	;there that should be it


ret

;sets vram registor address to something that matches the rows/column bytes
RowsColumnsToVram:
	
	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister

	ld hl, $9EFB
	ld a, (hl)
	ld d, 0
	ld e, 80
	call DE_Times_A
	ex de, hl
	ld hl, $9EFA
	ld c, (hl)
	ld b, 0
	ex de, hl
	add hl, bc
	ld b, $A0
	ld c, $21
	out (c), l
	res 7, h
	set 6, h
	out (c), h

ret


RowsColumnsToCursorPos:
	call eraseCursorTable

	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister

	ld hl, $9EFB 	;rows
	ld a, (hl)
	ld d, 0
	ld e, 10
	call DE_Times_A
	ex de, hl
	push de
	ld hl, $9EFA 	;columns
	ld c, (hl)
	ld b, 0
	ld d, 8
	call CDivD
	pop de
	ex de, hl
	add hl, bc
	ld bc, $0800 	;the additional offset to get the vram address pointer into the cursor sector
	add hl, bc
	;we now have the address
	ld b, $A0
	ld c, $21
	out (c), l
	res 7, h
	set 6, h
	out (c), h

	;now, prepare the data bit
	ld c, $80 
	cp 0
	jr z, byPassRemainder
	remainderLoop:
		srl c
		dec a
		cp 0
		jr nz, remainderLoop
	byPassRemainder:
	ld a, c
	ld c, $20
	out (c), a



ret

;clear first 8kb of vram
clearVram:
	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister
	ld c, $20
	ld a, 0
	out (c), a
	add a, 64
	out (c), a

	ld hl, $2000 	;clear the first 8kb of vram
	ld e, 0

	clearContinue:
		out (c), e
		dec hl
		ld a, h
		or l
		nop
		nop
		jr nz, clearContinue


ret

;clear first 32kb of vram
clearMostVram:
	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister
	ld c, $20
	ld a, 0
	out (c), a
	add a, 64
	out (c), a

	ld hl, $8000 	;clear the first 8kb of vram
	ld e, 0

	clearMostVramContinue:
		out (c), e
		dec hl
		ld a, h
		or l
		nop
		nop
		jr nz, clearMostVramContinue


ret

eraseScreen:

	;a slow but low-memory way of getting all the registers ready and vram pointer in the correct spot
	call RowsColumnsToVram
	ld hl, $77F 				;erase 1920 characters- the entire space of a 80x24 char screen could probably change that to $860 so it'll work in 26.5x80 mode but i haven't tried it yet)
	ld c, $20
	ld e, 0

	eraseScreenContinue:
		out (c), e
		dec hl
		ld a, h
		or l
		nop
		nop
		jr nz, eraseScreenContinue

ret

eraseCursorTable:

	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister
	ld d, 0
	out (c), d
	ld d, %01001000
	out (c), d
	ld hl, $00FE
	ld c, $20
	ld e, 0
	eraseCursorTableContinue:
		out (c), e
		dec hl
		ld a, h
		or l
		nop
		nop
		jr nz, eraseCursorTableContinue

ret

;because a guy on a forum said setting bit 6 of register 1 for screen on after any register command might work
writeRegisterOne:

	ld b, $A0
	ld c, $21
	;set up register 1
	ld d, %01010000
	ld a, 1
	call VdpWriteToStandardRegister

ret

;move screen up 2 rows
shiftScreenUp:

	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister
	ld d, %10100000
	out (c), d
	ld d, %00000000
	out (c), d

	;now that the vram address pointer is at position $A0 - 160 characters away from the start, start copying contents to ram
	;it is faster to copy all this stuff to ram first then copy it back to vram than it is to copy a single value from vram, paste it 1 address lower and do that over and over (due to the way the address pointer increments)
	ld hl, $96F0
	ld de, $06DF 		;(77F-A0) = the size of the text in vram in text mode 2 - the upper 2 rows
	ld c, $20 			;the correct port number for vram since the previous subroutine left it at $21
	shiftScreenUpCopyToRam:
		in a, (c)
		ld (hl), a
		inc hl
		dec de
		ld a, d
		or e
		jr nz, shiftScreenUpCopyToRam


	;don't forget to decrease the row byte by 2 before going into erase screen
	ld hl, $9EFB
	ld a, (hl)
	sub a, 2
	ld (hl), a

	;all the characters except for the top 2 rows should now be in ram
	call eraseScreen 		;run the erase screen subroutine

	ld a, 14
	ld d, 0
	call VdpWriteToStandardRegister
	ld d, %00000000
	out (c), d
	ld d, %01000000
	out (c), d


	ld hl, $96F0 	;the starting ram address where the relevant vram data is temporarily stored
	ld de, $06DF 	;(77F-A0) = the size of the text in vram in text mode 2 - the upper 2 rows
	ld c, $20		;the correct port number for vram since the previous subroutine left it at $21

	shiftScreenUpCopyToVram:
		ld a, (hl)
		out (c), a
		inc hl
		dec de
		ld a, d
		or e
		jr nz, shiftScreenUpCopyToVram

ret

;running this will run the shiftScreenUp subroutine if the cursor is on the lowest row
checkScreenSize:

	ld hl, $9EFB
	ld a, (hl)
	cp 24
	jr c, checkScreenSizeExit 			;if colum row < 24, don't shift the screen up
	call shiftScreenUp

	checkScreenSizeExit:

ret

;this draws a line onto page 0 while in graphics 4 mode
;b = xpos start. c = ypos start.
;d = xpos end. e = ypos end
;a = color index
drawLine:

	push af
	ex de, hl
	push hl
		push bc
		;set x starting point of line
		ld d, b
		ld a, 36
		call VdpWriteToStandardRegister
		ld d, %00000000
		ld a, 37
		call VdpWriteToStandardRegister
		pop bc
		push bc
		;set y starting point of line
		ld d, c
		ld a, 38
		call VdpWriteToStandardRegister
		ld d, %00000000
		ld a, 39
		call VdpWriteToStandardRegister
	pop bc
	pop hl
	;if d is greater than b, I want d to become the result of d-b
	;otherwise, I want d to become the result of b-d
	ex de, hl
	ld hl, $0000

	ld a, d
	cp b
	jr nc, dIsGreater
	jr bIsGreater

	dIsGreater:
		sub b
		ld d, a
		;x transfer diretion = right. Therefore there is no need to change the x transfer direction bit
		jr firstComparisonGTFO
	bIsGreater:
		ld a, b
		sub d
		ld d, a
		;x transfer direction = left
		ld a, l
		or %00000100
		ld l, a

	firstComparisonGTFO:

	ld a, e
	cp c
	jr nc, eIsGreater
	jr cIsGreater

	eIsGreater:
		sub c
		ld e, a
		;y transfer direction = down. Therefore there is no need to change the y transfer direction bit
		jr secondComparisonGTFO
	cIsGreater:
		ld a, c
		sub e
		ld e, a
		;y transfer direction = up
		ld a, l
		or %00001000
		ld l, a

	secondComparisonGTFO:

	;de should now contain x length and y length
	;now I need to figure out which one to assign to long side and low side
	;I also don't need the contents of bc anymore. bc can now be used for variable storage or whatever
	ld a, d
	cp e
	jr nc, dIsLongSide
	jr eIsLongSide

	dIsLongSide:
		ld c, e
		ld b, d
		jr thirdComparisonGTFO
	eIsLongSide:
		ld c, d
		ld b, e
		ld a, l
		or %00000001
		ld l, a

	thirdComparisonGTFO:
		push hl
			push bc
				;set long side dots num
				ld d, b
				ld a, 40
				call VdpWriteToStandardRegister
				ld d, %00000000
				ld a, 41
				call VdpWriteToStandardRegister
			pop bc
			;set short side dots num
			ld d, c
			ld a, 42
			call VdpWriteToStandardRegister
			ld d, %00000000
			ld a, 43
			call VdpWriteToStandardRegister
		pop hl

	pop af
	push hl
		;set line color
		ld d, a
		ld a, 44
		call VdpWriteToStandardRegister
	pop hl
	;set register 45
	ld d, l
	ld a, 45
	call VdpWriteToStandardRegister

	;define logical operation - %01110000 for line command
	ld d, %01110000
	ld a, 46
	call VdpWriteToStandardRegister


ret

;waits until the vdp is finished with a command by checking CE bit (bit 0) of status register S#2
waitVdpCommandFinished:

	ld d, 2
	ld a, 15
	call VdpWriteToStandardRegister
	ld c, $21
	in a, (c)
	and %00000001
	cp 0
	jr nz, waitVdpCommandFinished

ret

;draws a non-filled in rectangle.
;b = x position of rectangle start
;c = y position of recangle start
;d = size x of rectangle
;e = size y of rectangle
;a = color index
drawRectangle:

	;draw top line
	push bc
	push de 
	push af
		ld l, a
		ld a, d
		add a, b
		ld d, a

		ld e, c
		ld a, l
		call drawLine
		call waitVdpCommandFinished
	pop af
	pop de
	pop bc

	;draw bottom line
	push bc
	push de
	push af
		ld l, a
		ld a, d
		add a, b
		ld d, a

		ld a, e
		add a, c
		ld e, a
		ld c, a
		ld a, l
		call drawLine
		call waitVdpCommandFinished
	pop af
	pop de
	pop bc

	;draw leftmost line
	push bc
	push de
	push af
		ld l, a
		ld d, b

		ld a, c
		add a, e
		ld e, a
		ld a, l
		call drawLine
		call waitVdpCommandFinished
	pop af
	pop de
	pop bc

	;draw rightmost line
	push bc
	push de
	push af
		ld l, a
		ld a, b
		add a, d
		ld d, a
		ld b, a

		ld a, c
		add a, e
		ld e, a
		ld a, l
		call drawLine
		call waitVdpCommandFinished
	pop af
	pop de
	pop bc

ret

;draws a non-filled in rectangle.
;b = x position of rectangle start
;c = y position of recangle start
;d = size x of rectangle
;e = size y of rectangle
;a = color index
drawRectangleFilled:
	;first draw the outline
	;call drawRectangle

	push af
		ld a, e
		;add a, e
		ld hl, $2FFE
		ld (hl), a
	pop af
	;calculate first horizontal line
	ld l, a
	ld a, d
	add a, b
	ld d, a

	ld e, c
	drawRectangleFilledContinueLoop:
	ld a, l
	push hl
	push af
	push bc
	push de
		call drawLine
		call waitVdpCommandFinished
	pop de
	pop bc
	pop af
	ld hl, $2FFE
	ld a, (hl)
	dec a
	inc c
	inc e
	ld (hl), a
	pop hl
	cp 0
	jr nz, drawRectangleFilledContinueLoop

ret

;prints a single character to the screen in graphics 4 mode at whatever position is in 2007(x) and 2008(y)
;remember the values in 2007 and 2008 are HALF the value of what gets used in screen space
;for example, 100,100 means it will copy the character to position 200,200 on the screen
;whatever ascii code is in the a register gets copied to the screen as the corresponding character
G4PrintChar:

	;load address of first character font
	ld hl, letters_space

	push hl
		;calculate the position in memory of the requested charcter
		sub 32
		ld de, $0008
		call DE_Times_A
		ex de, hl
	pop hl
	;with any luck, the address of the correct character should now be in hl
	add hl, de

	;copy it to the screen
	call softwareSpriteToVramCompressed
ret

;prints whatever string is pointed to in memory by hl to the screen in g4 mode
;uses whatever position is in $2007,$2008 using the same /2 rule
G4PrintString:
	
	ld a, (hl)
	;check to see if the character is a null. if so, exit the loop
	cp 0
	jr z, G4PrintStringGTFO

	push hl
	;print single character
	call G4PrintChar
	;increment g4 software sprite counter by 4
	ld hl, $2007
	ld a, (hl)
	add 4
	ld (hl), a
	pop hl

	;go to position of next character in memory and then do all that again
	inc hl
	jr G4PrintString

	G4PrintStringGTFO:

ret

;	$2007: screen pos x offset for g4 software sprite function
;	#2008: screen pos y offset for g4 software sprite function
;used for copying text 1 fonts to the screen when in g4 mode
;deadling with characters in g4 mode this way used 8x less memory than using uncompressed multi color sprites as software sprite fonts
softwareSpriteToVramCompressed:

	ld d, 64
	ld e, 0
	;ld hl, letters_00
	softwareSpriteCompressedCopyLoopY:
	softwareSpriteCompressedCopyLoopX:
		;base address of vram
		ld a, 14
		push de
		ld d, 0
		push hl
		call VdpWriteToStandardRegister
		pop hl
		pop de
		;ld c, $21
		;ld a, d
		push de
		push hl
		push bc
		ld hl, $2007
		ld a, (hl)
		add e
		ld e, a
		ld hl, $2008
		ld bc, $0000
		ld c, (hl)
		ld a, c
		sla c
		sla c
		sla c
		sla c
		sla c
		sla c
		sla c
		and %11111110
		ld b, a
		ex de, hl
		add hl, bc
		ex de, hl
		pop bc
		out (c), e
		;ld a, e
		out (c), d
		pop hl
		pop de

		;ld hl, letters_0
		;ld a, (hl)

		call rotateAndMunge


		writeByteCompressed:
			ld b, $A0
			ld c, $20
			out (c), a
			inc e
			;inc hl
			ld a, e
			and %01111111
			cp 4
			jr nz, softwareSpriteCompressedCopyLoopX
			inc hl
			ld a, e
			and %10000000
			ld e, a
			ex de, hl
			ld bc, 128
			add hl, bc
			ex de, hl
			ld a, d
			cp 68
			jr nz, softwareSpriteCompressedCopyLoopY

ret

rotateAndMunge:

	ld a, e
	and %01111111
	cp 0
	jr z, rotateAndMungeDis0
	cp 1
	jr z, rotateAndMungeDis1
	cp 2
	jr z, rotateAndMungeDis2
	jr rotateAndMungeDis3
	rotateAndMungeDis0:
		ld a, (hl)
		and %11000000
		srl a
		srl a
		srl a
		srl a
		srl a
		srl a
		jr rotateAndMungeContinue
	rotateAndMungeDis1:
		ld a, (hl)
		and %00110000
		srl a
		srl a
		srl a
		srl a
		jr rotateAndMungeContinue
	rotateAndMungeDis2:
		ld a, (hl)
		and %00001100
		srl a
		srl a
		jr rotateAndMungeContinue
	rotateAndMungeDis3:
		ld a, (hl)
		and %00000011
		jr rotateAndMungeContinue

	rotateAndMungeContinue:
		cp 0
		jr z, rotateAndMungeIs0
		cp 1
		jr z, rotateAndMungeIs1
		cp 2
		jr z, rotateAndMungeIs2
		jr rotateAndMungeIs3

		rotateAndMungeIs0:
			ld a, %00000000
			jr rotateAndMungeExit
		rotateAndMungeIs1:
			ld a, %00001111
			jr rotateAndMungeExit
		rotateAndMungeIs2:
			ld a, %11110000
			jr rotateAndMungeExit
		rotateAndMungeIs3:
			ld a, %11111111

		rotateAndMungeExit:

ret

donemsg: db "done",0

;here is the font data. Have fun actually copying it to the vram. heh.

letters_space: db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_exclamation: db %00100000, %00100000, %00100000, %00100000, %00100000, %00000000, %00100000, %00000000
letters_dquotes: db %00000000, %01010000, %01010000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_pound: db %00000000, %01010000, %11111000, %01010000, %11111000, %01010000, %00000000, %00000000
letters_dollar: db %00100000, %01111000, %10100000, %01110000, %00101000, %11110000, %00100000, %00000000
letters_percent: db %11101000, %10101000, %11110000, %00100000, %01011000, %10101000, %10111000, %00000000
letters_ampersand: db %00000000, %01110000, %11010000, %11110000, %10010000, %01010000, %01111000, %00000000
letters_quote: db %00011000, %00110000, %00100000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_lparenth: db %00001000, %00010000, %00100000, %00100000, %00100000, %00010000, %00001000, %00000000
letters_rparenth: db %00100000, %00010000, %00001000, %00001000, %00001000, %00010000, %00100000, %00000000
letters_asteri: db %00000000, %00000000, %00100000, %01110000, %00100000, %01010000, %00000000, %00000000
letters_plus: db %00000000, %00100000, %00100000, %11111000, %00100000, %00100000, %00000000, %00000000
letters_comma: db %00000000, %00000000, %00000000, %00000000, %00000000, %00100000, %00100000, %00000000
letters_minus: db %00000000, %00000000, %00000000, %11111000, %00000000, %00000000, %00000000, %00000000
letters_period: db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %01000000, %00000000
letters_fslash: db %00000000, %00001000, %00010000, %00100000, %01000000, %10000000, %00000000, %00000000
letters_0: db %01110000, %10001000, %11001000, %10101000, %10011000, %10001000, %01110000, %00000000
letters_1: db %01100000, %11100000, %00100000, %00100000, %00100000, %00100000, %11111000, %00000000
letters_2: db %11110000, %10001000, %00001000, %01111000, %10000000, %10000000, %11111000, %00000000
letters_3: db %11111000, %10001000, %00001000, %01111000, %00001000, %10001000, %11111000, %00000000
letters_4: db %00110000, %01010000, %10010000, %11111000, %00010000, %00010000, %00010000, %00000000
letters_6: db %11111000, %10000000, %10000000, %11110000, %00001000, %00001000, %11110000, %00000000
letters_7: db %01110000, %10001000, %10000000, %11110000, %10001000, %10001000, %01110000, %00000000
letters_8: db %11111000, %00001000, %00010000, %00100000, %00100000, %00100000, %00100000, %00000000
letters_9: db %01110000, %10001000, %10001000, %01110000, %10001000, %10001000, %01110000, %00000000
letters_colon: db %01110000, %10001000, %10001000, %01111000, %00001000, %00001000, %01110000, %00000000
letters_semicolon: db %00000000, %00100000, %00100000, %00000000, %00100000, %00100000, %00000000, %00000000
letters_leftarrow: db %00000000, %00100000, %00100000, %00000000, %00100000, %01000000, %00000000, %00000000
letters_equal: db %00011000, %00100000, %01000000, %10000000, %01000000, %00100000, %00011000, %00000000
letters_rightarrow: db %00000000, %00000000, %01111000, %00000000, %01111000, %00000000, %00000000, %00000000
letters_question: db %11000000, %00100000, %00010000, %00001000, %00010000, %00100000, %11000000, %00000000
letters_email: db %00110000, %01001000, %00001000, %00010000, %00100000, %00000000, %00100000, %00000000
letters_email2: db %00110000, %01001000, %00001000, %00010000, %00100000, %00000000, %00100000, %00000000;skips it whenever I only put it in once
letters_A: db %00100000, %01010000, %10001000, %10001000, %11111000, %10001000, %10001000, %00000000
letters_B: db %11110000, %10001000, %10001000, %11110000, %10001000, %10001000, %11110000, %00000000
letters_C: db %00111000, %01000000, %10000000, %10000000, %10000000, %01000000, %00111000, %00000000
letters_D: db %11110000, %10001000, %10001000, %10001000, %10001000, %10001000, %11110000, %00000000
letters_E: db %11111000, %10000000, %10000000, %11100000, %10000000, %10000000, %11111000, %00000000
letters_F: db %11111000, %10000000, %10000000, %11100000, %10000000, %10000000, %10000000, %00000000
letters_G: db %01110000, %10001000, %10000000, %10000000, %10011000, %10001000, %01110000, %00000000
letters_H: db %10001000, %10001000, %10001000, %11111000, %10001000, %10001000, %10001000, %00000000
letters_I: db %11111000, %00100000, %00100000, %00100000, %00100000, %00100000, %11111000, %00000000
letters_J: db %01111000, %00010000, %00010000, %00010000, %10010000, %10010000, %01100000, %00000000
letters_K: db %10001000, %10010000, %10100000, %11000000, %10100000, %10010000, %10001000, %00000000
letters_L: db %10000000, %10000000, %10000000, %10000000, %10000000, %10000000, %11111000, %00000000
letters_M: db %10001000, %11011000, %10101000, %10101000, %10001000, %10001000, %10001000, %00000000
letters_N: db %10001000, %11001000, %10101000, %10101000, %10101000, %10011000, %10001000, %00000000
letters_O: db %01110000, %10001000, %10001000, %10001000, %10001000, %10001000, %01110000, %00000000
letters_P: db %11110000, %10001000, %10001000, %11110000, %10000000, %10000000, %10000000, %00000000
letters_Q: db %01100000, %10010000, %10010000, %10010000, %10110000, %10110000, %01111000, %00000000
letters_R: db %11110000, %10001000, %10001000, %11110000, %10100000, %10010000, %10001000, %00000000
letters_S: db %01111000, %10000000, %10000000, %01110000, %00001000, %00001000, %11110000, %00000000
letters_T: db %11111000, %00100000, %00100000, %00100000, %00100000, %00100000, %00100000, %00000000
letters_U: db %10001000, %10001000, %10001000, %10001000, %10001000, %10001000, %01110000, %00000000
letters_V: db %10001000, %10001000, %10001000, %10001000, %10001000, %01010000, %00100000, %00000000
letters_W: db %10001000, %10101000, %10101000, %10101000, %10101000, %10101000, %01010000, %00000000
letters_X: db %10001000, %01010000, %01010000, %00100000, %01010000, %01010000, %10001000, %00000000
letters_Y: db %10001000, %10001000, %01010000, %00100000, %00100000, %00100000, %00100000, %00000000
letters_Z: db %11111000, %00001000, %00010000, %00100000, %01000000, %10000000, %11111000, %00000000
letters_halfsquare1: db %11100000, %10000000, %10000000, %10000000, %10000000, %10000000, %11100000, %00000000
letters_backwardsslash: db %10000000, %01000000, %00100000, %00100000, %00010000, %00001000, %00001000, %00000000
letters_halfsquare2: db %11100000, %00100000, %00100000, %00100000, %00100000, %00100000, %11100000, %00000000
letters_idk2: db %00100000, %01010000, %10001000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_idk3: db %00000000, %00000000, %00000000, %00000000, %00000000, %00000000, %11111000, %00000000
letters_alttilde: db %01000000, %00100000, %00010000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_a: db %00000000, %00000000, %01100000, %00010000, %11110000, %10010000, %01111000, %00000000
letters_b: db %10000000, %10000000, %10000000, %11110000, %10001000, %10001000, %11110000, %00000000
letters_c: db %00000000, %00000000, %01110000, %10000000, %10000000, %10000000, %01110000, %00000000
letters_d: db %00001000, %00001000, %00001000, %01111000, %10001000, %10001000, %01111000, %00000000
letters_e: db %00000000, %00000000, %01110000, %10001000, %11111000, %10000000, %01111000, %00000000
letters_f: db %00111000, %01000000, %01000000, %11111000, %01000000, %01000000, %01000000, %00000000
letters_g: db %00000000, %01111000, %10001000, %10001000, %01111000, %00001000, %01111000, %00000000
letters_h: db %10000000, %10000000, %10000000, %11110000, %10001000, %10001000, %10001000, %00000000
letters_i: db %00000000, %00100000, %00000000, %00100000, %00100000, %00100000, %00100000, %00000000
letters_j: db %00100000, %00000000, %00100000, %00100000, %00100000, %10100000, %01000000, %00000000
letters_k: db %00000000, %10000000, %10001000, %10010000, %11100000, %10010000, %10001000, %00000000
letters_l: db %00000000, %01100000, %00100000, %00100000, %00100000, %00100000, %00110000, %00000000
letters_m: db %00000000, %00000000, %10001000, %11011000, %10101000, %10101000, %10001000, %00000000
letters_n: db %00000000, %00000000, %10000000, %11110000, %10001000, %10001000, %10001000, %00000000
letters_o: db %00000000, %00000000, %01110000, %10001000, %10001000, %10001000, %01110000, %00000000
letters_p: db %00000000, %00000000, %11110000, %10001000, %11110000, %10000000, %10000000, %00000000
letters_q: db %00000000, %00000000, %01111000, %10001000, %01111000, %00001000, %00001000, %00000000
letters_r: db %00000000, %00000000, %10110000, %11001000, %10000000, %10000000, %10000000, %00000000
letters_s: db %00000000, %00000000, %01111000, %10000000, %01110000, %00001000, %11110000, %00000000
letters_t: db %00100000, %00100000, %11111000, %00100000, %00100000, %00101000, %00010000, %00000000
letters_u: db %00000000, %00000000, %10010000, %10010000, %10010000, %10010000, %01111000, %00000000
letters_v: db %00000000, %00000000, %10001000, %10001000, %10001000, %01010000, %00100000, %00000000
letters_w: db %00000000, %00000000, %10001000, %10001000, %10101000, %10101000, %01010000, %00000000
letters_x: db %00000000, %00000000, %10001000, %01010000, %00100000, %01010000, %10001000, %00000000
letters_y: db %00000000, %00000000, %10001000, %01010000, %00100000, %00100000, %11000000, %00000000
letters_z: db %00000000, %00000000, %11111000, %00001000, %01110000, %10000000, %11111000, %00000000
letters_idk4: db %00110000, %01000000, %01000000, %11000000, %01000000, %01000000, %00110000, %00000000
letters_pipeiguess: db %00100000, %00100000, %00100000, %00100000, %00100000, %00100000, %00100000, %00000000
letters_idk5: db %11000000, %00100000, %00100000, %00110000, %00100000, %00100000, %11000000, %00000000
letters_tilde: db %00000000, %01001000, %10110000, %00000000, %00000000, %00000000, %00000000, %00000000
letters_errorchar: db %10101000, %01010100, %10101000, %01010100, %10101000, %01010100, %10101000, %00000000
letters_end: db %11111111	;the termination char - makes ending the vram loading loop take much less code. Just keep in mind that no font sprite can have a straight line across or it will end the loop early resulting in not all the character fonts getting loaded

spritesLoadedOk: db "Sprites loaded",0
