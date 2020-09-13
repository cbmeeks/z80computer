;$9EFF
;the asm file for the command interpreter

parseCliInput:

	;check if the inputted command is the print command
	ld hl, $2010
	ld de, printcmd
	ld b, 6
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputPrintString

	;check if the input is the show time command
	ld hl, $2010
	ld de, printtimecmd
	ld b, 4
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputShowTime

	;check if the input is the show date command
	ld hl, $2010
	ld de, printdatecmd
	ld b, 4
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputShowDate

	;check if the input is the set time command
	ld hl, $2010
	ld de, settimecmd
	ld b, 8
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputSetTime

	;check if the input is the set date command
	ld hl, $2010
	ld de, setdatecmd
	ld b, 8
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputSetDate

	;check if the input is the test video command
	ld hl, $2010
	ld de, testvideocmd
	ld b, 9
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputTestVideo

	;check if the input is the vdp status register command
	ld hl, $2010
	ld de, vdpstatuscmd
	ld b, 10
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputVdpStatus

	;check if the input is the vdp manual register set command
	ld hl, $2010
	ld de, setvdpregcmd
	ld b, 7
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputvdpregset

	;check if the input is the load fonts command
	ld hl, $2010
	ld de, loadfontscmd
	ld b, 9
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputLoadFonts

	;check if the input is the clear command
	ld hl, $2010
	ld de, clearscreencmd
	ld b, 5
	call areStringsEqual
	ld a, 1
	cp c
	jp z, parseCliInputClearScreen

	;check if the input is the testvram command
	ld hl, $2010
	ld de, testvramcmd
	ld b, 8
	call areStringsEqual
	ld a, 1
	cp c
	jr z, parseCliInputTestVram

	;check if the input is the togglevmode command
	ld hl, $2010
	ld de, togglevmodecmd
	ld b, 11
	call areStringsEqual
	ld a, 1
	cp c
	jr z, parseCliInputToggleVMode

	;check if the input is the change color command
	ld hl, $2010
	ld de, changecolorcmd
	ld b, 11
	call areStringsEqual
	ld a, 1
	cp c
	jr z, parseCliInputChangeColor

	;check if the input is the help command
	ld hl, $2010
	ld de, helpcmd
	ld b, 4
	call areStringsEqual
	ld a, 1
	cp c
	jr z, parseCliInputHelp

	;check if the input is the get key
	ld hl, $2010
	ld de, getKeyCommandText
	ld b, 6
	call areStringsEqual
	ld a, 1
	cp c
	jr z, parseCliInputGetKey

	jr parseCliInputInvalidCommand

	parseCliInputPrintString:
		call printTextCommand
		jr parseCliInputExit
	parseCliInputShowTime:
		call printTime
		jr parseCliInputExit
	parseCliInputShowDate:
		call printDate
		jr parseCliInputExit
	parseCliInputSetTime:
		call setTime
		jr parseCliInputExit
	parseCliInputSetDate:
		call setDate
		jr parseCliInputExit
	parseCliInputGetKey:
		call getKeyCommand
		jr parseCliInputExit
	parseCliInputTestVideo:
		call initializeVideo
		jr parseCliInputExit
	parseCliInputVdpStatus:
		call VdpStatusManualCommand
		jr parseCliInputExit
	parseCliInputvdpregset:
		call VdpManualSetCommand
		jr parseCliInputExit
	parseCliInputLoadFonts:
		call VdpLoadFonts
		jr parseCliInputExit
	parseCliInputClearScreen:
		call ClearScreen
		jr parseCliInputExit
	parseCliInputTestVram:
		call VdpTestVram
		jr parseCliInputExit
	parseCliInputToggleVMode:
		call togglevmode
		jr parseCliInputExit
	parseCliInputChangeColor:
		call changeColor
		jr parseCliInputExit
	parseCliInputHelp:
		call helpCommand
		jr parseCliInputExit
	parseCliInputInvalidCommand:
		call invalidCommand
	parseCliInputExit:
		call VdpInsertEnter
		call clearCommandBuffer 		;reset command buffer so you dont have to press backspace a bunch after entering a command
ret

printTime:
	call VdpInsertEnter
	;ld a, %11000000 					;the lcd's address for the 2nd line
	;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command

	ld hl, time
	;call printString
	call VPrintString

	;hours
	ld hl, $A014
	ld a, (hl)
	call aToScreenHex
	ld a, ":"
	;call printChar 
	call VdpPrintChar

	;minutes
	ld hl, $A012
	ld a, (hl)
	call aToScreenHex
	ld a, ":"
	;call printChar
	call VdpPrintChar

	;seconds
	ld hl, $A010
	ld a, (hl)
	call aToScreenHex

	;call backToPrevCursorPos

ret

printDate:
	;ld a, %11000000 					;the lcd's address for the 2nd line
	;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command
	call VdpInsertEnter

	;months
	ld hl, $A019
	ld a, (hl)
	call aToScreenHex
	ld a, "/"
	;call printChar
	call VdpPrintChar

	;days
	ld hl, $A016
	ld a, (hl)
	call aToScreenHex
	ld a, "/"
	;call printChar
	call VdpPrintChar

	;years
	ld hl, $A01A
	ld a, (hl)
	call aToScreenHex

	;call backToPrevCursorPos
ret

setTime:
	;inhibit updating to allow time to be set
	call VdpInsertEnter
	ld hl, $A01E
	ld a, %00001110
	ld (hl), a

	ld hl, $2018
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %00110000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current hour.
	ld hl, $A014
	ld (hl), a

	ld hl, $201A
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %01110000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current minute.
	ld hl, $A012
	ld (hl), a

	ld hl, $201C
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %01110000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current second.
	ld hl, $A010
	ld (hl), a

	;re-enable updating now that time has been set
	ld hl, $A01E
	ld a, %00000110
	ld (hl), a

	;ld a, %11000000 					;the lcd's address for the 2nd line
	;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command
	ld hl, genericok
	;call printString
	call VPrintString
	;call backToPrevCursorPos

ret

setDate:
	call VdpInsertEnter
	;inhibit updating to allow time to be set
	ld hl, $A01E
	ld a, %00001110
	ld (hl), a

	ld hl, $2018
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %00010000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current month.
	ld hl, $A019
	ld (hl), a

	ld hl, $201A
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %00110000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current day.
	ld hl, $A016
	ld (hl), a

	ld hl, $201C
	ld a, (hl)
	sub a, 48
	sla a
	sla a
	sla a
	sla a
	and %11110000
	ld b, a
	inc hl
	ld a, (hl)
	sub a, 48
	add a, b 							;now we have the 1s and 10s place for the current year.
	ld hl, $A01A
	ld (hl), a

	;re-enable updating now that time has been set
	ld hl, $A01E
	ld a, %00000110
	ld (hl), a

	;ld a, %11000000 					;the lcd's address for the 2nd line
	;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command
	ld hl, genericok
	;call printString
	call VPrintString
	;call backToPrevCursorPos

ret

;display next pressed key to the screen
getKeyCommand:
	call VdpInsertEnter
	;ld a, %11000000
	;call lcdBlankLine

	printAnotherKey_getKeyCommand:
	call waitChar
	push af
	call aToScreenHex
	pop af

	;esc currently returns "2A" (the ascii value for *). So if that happens, exit the program
	cp $2A
	jr nz, printAnotherKey_getKeyCommand

	;call backToPrevCursorPos

ret

printTextCommand:
	call VdpInsertEnter
	;;ld a, %11000000 					;the lcd's address for the 2nd line
	;;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command
	;call waitForLcdReady
	;ld hl, $A000
	;ld (hl), %11000000 			;the text is going to be printed on the second line of the lcd
	ld hl, $2016	 			;print whatever's in the saved command variable as a string, discarding the first 6 characters since they are part of the command
	;call printString
	call VPrintString
	;call backToPrevCursorPos
ret

invalidCommand:
	call VdpInsertEnter
	;ld a, %11000000 					;the lcd's address for the 2nd line
	;call lcdBlankLine 					;print a blank line on the 2nd line on the lcd to discard any data from the previous command
	;call waitForLcdReady
	;ld hl, $A000
	;ld (hl), %11000000 			;the text is going to be printed on the second line of the lcd
	ld hl, badcommand	 			;print whatever's in the saved command variable as a string to see just how accurate that thing actually is
	;call printString
	call VPrintString
	;call backToPrevCursorPos
ret

;put the cursor back to whereever it was before typing in the command (not the best thing to do but I will change it later after I get a few other things working)
;will probably no longer be used if I ever get a video card for this
backToPrevCursorPos:
	call waitForLcdReady
	ld hl, $2009
	ld a, (hl)					;get whatever value the character counter has
	add a, %10000000 			;add it to the starting lcd ram address
	ld hl, $A000
	ld (hl), a 					;put the cursor back to whereever it was before typing in the command (not the best thing to do but I will change it later after I get a few other things working)
ret

;if the first b characters of string in de is equal to the string in hl, c becomes set. otherwise, c gets reset
areStringsEqual:
	ld c, 0
	areStringsEqualDoAgain:
	ld a, (de)
	cp (hl)
	jr z, areStringsEqualContinue 
	jr nz, areStringsEqualExit

	areStringsEqualContinue:
	 	inc hl
	 	inc de
	 	dec b

	 	ld a, 0
	 	cp b 

	 	jr nz, areStringsEqualDoAgain
	 	ld c, 1
	 	jr areStringsEqualGTFO
	areStringsEqualExit:
		ld c, 0
	areStringsEqualGTFO:
ret

VdpStatusManualCommand:

	ld a, %11000000
	call lcdBlankLine

	ld a, "R"
	call printChar

	ld hl, $201A		;ram address of whatever command parameter is in the correct place
	ld a, (hl)
	push af
	call printChar
	ld a, "="
	call printChar
	pop af
	sub a, 48
	call VdpReadStatus

	call aToScreenHex
	call backToPrevCursorPos

ret

VdpManualSetCommand:
	ld hl, $2017
	ld a, (hl)
	call aToHex
	sla a
	sla a
	sla a
	sla a
	ld b, a
	inc hl
	ld a, (hl)
	call aToHex
	add a, b
	;assuming the user typed a hex value, we now we have the hex value of the register to use
	ld c, a ;save it to c for temporary safe keeping

	ld hl, $2020
	ld a, (hl)
	call aToHex
	sla a
	sla a
	sla a
	sla a
	ld b, a
	inc hl
	ld a, (hl)
	call aToHex
	add a, b
	
	;now load register a into d and c into a in preparation for the write register subroutine
	ld d, a
	ld a, c

	call VdpWriteToStandardRegister
	ld hl, genericok
	call printString


ret

VdpLoadFonts:

	call VdpCharsIntoRam

	ld a, %11000000
	call lcdBlankLine
	ld hl, fontLoaded
	call printString
	call backToPrevCursorPos
ret

;TO-DO: Fix the bug where it puts the cursor on row 1 and not row zero
ClearScreen:
	
	;set column and row counters to zero
	ld a, 0
	ld hl, $9EFA
	ld (hl), a
	inc hl
	ld (hl), a

	ld hl, $2009
	ld (hl), a

	;fill the 40 character keyboard input store-er with null characters
	inc hl
	ld c, 80
	call clearRangeInRam

	;only thing left is to clear the screen in vram
	call eraseScreen
	;now run this so the vram addres pointer will be at top of screen area and ready to be used some more
	call RowsColumnsToVram


ret

VdpTestVram:
	ld a, %11000000
	call lcdBlankLine	;clear second row of lcd to make room for the test results

	ld a, 14
	ld d, %00000000
	call VdpWriteToStandardRegister
	ld a, %00000010
	out (c), a
	ld a, %01010010
	out (c), a

	ld c, $20
	ld a, %00000000
	out (c), a
	ld a, %11111111
	out (c), a
	ld a, $69
	out (c), a
	ld a, 69
	out (c), a

	ld a, 14
	ld d, %00000000
	call VdpWriteToStandardRegister
	ld a, %00000010
	out (c), a
	ld a, %00010010
	out (c), a

	;start writing results of the vram reads to the screen. Let's see if this son of a bitch actually works or not
	ld c, $20
	in a,(c)
	call aToScreenHex
	in a,(c)
	call aToScreenHex
	in a,(c)
	call aToScreenHex
	in a,(c)
	call aToScreenHex

	ld hl, genericok
	call printString
	call backToPrevCursorPos

ret

togglevmode:
	;first, set cursor to second row of lcd in preparation to print the results
	ld a, %11000000
	call lcdBlankLine	;clear second row of lcd to make room for the test results

	;0 = ntsc. 1 = pal
	ld hl, $9EFD
	ld a, (hl)
	and a, %00000001
	cp %00000001
	jr z, togglevmodePal
		;ntsc. switch to pal

		;write 1 to area in ram to indicate pal
		ld a, 1
		ld (hl), a

		ld a, 9
		ld d, %00000010 	;change respective vdp register. bit 1 = 1 means pal
		call VdpWriteToStandardRegister
		
		;put visual confirmation on lcd that video mode as been changed to correct format
		ld hl, palmsg
		call printString
		jr togglevmodeExit
	togglevmodePal:
		;pal. switch to ntsc

		;write 0 to area in ram to indicate ntsc
		ld a, 0
		ld (hl), a

		ld a, 9
		ld d, %00000000 	;change respective vdp register. bit 1 = 0 means ntsc
		call VdpWriteToStandardRegister

		;put visual confirmation on lcd that video mode as been changed to correct format
		ld hl, ntscmsg
		call printString
		jr togglevmodeExit
	togglevmodeExit:
	call backToPrevCursorPos
ret

changeColor:

	;blank the screen because this didn't work before I blanked it
	ld d, %00000000
	ld a, 1
	call VdpWriteToStandardRegister

	ld hl, $9EFC
	ld a, (hl)
	and a, %00000001
	cp %00000001
	jr z, makeColorRed
		ld a, 1
		ld hl, $9EFC
		ld (hl), a
		ld a, 0
		ld d, %01110000
		ld e, %00000000
		jr changeColorContinue

	makeColorRed:
		ld a, 0
		ld hl, $9EFC
		ld (hl), a
		ld a, 0
		ld d, %00000111
		ld e, %00000000
	changeColorContinue:
	call VdpWriteToPaletteRegister

	;put the screen back to the way it was before
	ld d, %01010000
	ld a, 1
	call VdpWriteToStandardRegister

	ld a, %11000000
	call lcdBlankLine	;clear second row of lcd to make room for the test results
	ld hl, genericok
	call printString
	call backToPrevCursorPos
ret

helpCommand:

	call VdpInsertEnter
	ld hl, availableCommands
	call VPrintString

	call VdpInsertEnter
	ld hl, clearscreencmd
	call VPrintString

	call VdpInsertEnter
	ld hl, printdatecmd
	call VPrintString

	call VdpInsertEnter
	ld hl, helpcmd
	call VPrintString
	
	call VdpInsertEnter
	ld hl, printcmd
	call VPrintString

	call VdpInsertEnter
	ld hl, setdatecmd
	call VPrintString
	ld hl, dateformat
	call VPrintString

	call VdpInsertEnter
	ld hl, settimecmd
	call VPrintString
	ld hl, timeformat
	call VPrintString

	call VdpInsertEnter
	ld hl, printtimecmd
	call VPrintString

ret

time: db "time= ",0
badcommand: db "invalid syntax",0
printcmd: db "print ",0
printtimecmd: db "time",0
printdatecmd: db "date",0
settimecmd: db "settime ",0
getKeyCommandText: db "getkey",0
setdatecmd: db "setdate ",0
testvideocmd: db "testvideo",0
vdpstatuscmd: db "vdpstatus ",0
setvdpregcmd: db "setreg ",0
loadfontscmd: db "loadfonts",0
clearscreencmd: db "clear",0
testvramcmd: db "testvram",0
helpcmd: db "help",0
togglevmodecmd: db "togglevmode",0
changecolorcmd: db "changecolor",0
genericok: db "OK",0
ntscmsg: db "video mode is ntsc",0
palmsg: db "video mode is pal",0
genericfailed: db "failed",0
timeformat: db " [hhmmss]",0
dateformat: db " [MMDDYY]",0
availableCommands: db "Available commands:",0
fontLoaded: db "fonts loaded",0