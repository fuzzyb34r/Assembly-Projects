;****************************************************************;
; Program Name: Drunkard Walk Implementation					 ;
;																 ;
; Program Description: Professor starts at coordinate 25, 25 &   ;
;					   wanders around the area for some time :)  ;
;																 ;
; Program Author: Parke											 ;
; Creation Date: 10/28/2024										 ;
; Revisions: N/A												 ;
; Date Last Modified: 10/28/2024								 ;
;***************************************************************';

;*********************************************;
; 8386, flat memory model, stack size and	  ;
; ExitProcess prototype initalizations as	  ;
; well as Irvine32 library INCLUDE statements ;
;*********************************************;
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

WalkMax = 50
StartX = 25
StartY = 25

; DrunkardWalk struct below with constants defined above
DrunkardWalk STRUCT
	path COORD WalkMax DUP(<0,0>)
	pathsUsed WORD 0
DrunkardWalk ENDS

DisplayPosition PROTO currX:BYTE, currY:BYTE						; DisplayPosition proc prototype 

; Declared and initialized variables
.data

	aWalk DrunkardWalk <>

	crazy_night BYTE "WOW. THAT WAS QUITE THE NIGHT . . .", 0		; Fun exit msg :)

	rand_val DWORD 0

	msg BYTE "Would you like to re-run the program?", 0				; To be used for re-run program message box prompt
	msg_box_title BYTE "Execution Complete", 0

;*******************************************************************;
; Function: Main program driver									    ;
;																    ;
; Return: Mapped coordinates of drunkards walk					    ;
;																    ;
; Procedure: Receives ESI to point to DrunkardWalk struct, struct   ;
;			 is initialized with random values which cause the	    ;
;			 professor to walk in random directions of east,	    ;
;			 west, north & south								    ;
;*******************************************************************;
.code
main PROC

	CALL Randomize													; Random seed generator
	MOV EAX, 25

TRY_AGAIN:

	CALL RandomRange												; Next 5 lines simply generate rand		
	CMP EAX, 0														; val for professor to drop phone at
	JE TRY_AGAIN
	MOV rand_val, EAX
	MOV ESI, OFFSET aWalk											; Use offset to obtain memory address of 'path', copy to EDI 
	CALL TakeDrunkenWalk											; TakeDrunkenWalk proc call

	MOV EAX, 1000													; Next 20 lines simply close out program, reset vars and
	CALL Delay														; prompt user for program rerun
	MOV EAX, GREEN	
	CALL SetTextColor
	MOV DH, 10
	MOV DL, 10
	CALL GoToXY
	MOV EDX, OFFSET crazy_night
	CALL WriteString
	MOV EAX, 3000
	CALL Delay
	CALL Clrscr

	MOV EAX, WHITE + (BLACK * 16)	
	CALL SetTextColor

	MOV EDX, OFFSET msg												; Set proper registers to offsets of msg box prompts for program
	MOV EBX, OFFSET msg_box_title									; re-run question to end user
	CALL MsgBoxAsk

	CMP EAX, 6														; If EAX == 6, this is pre-defined Windows constant for IDYES,
	JE main															; so we re-run program, otherwise simply exit

	INVOKE ExitProcess, 0											; Return 0, exit success

main ENDP															; Program exit

TakeDrunkenWalk PROC												; Takes walk in random directions

	LOCAL currX:BYTE, currY:BYTE
	PUSHAD
	MOV EDI, ESI
	ADD EDI, OFFSET DrunkardWalk.path
	MOV ECX, WalkMax												; Loop counter
	MOV currX, StartX												; Current X-location
	MOV currY, StartY												; Current Y-location

Again:

	MOVZX AX, currX													; Next few lines insert current location in array
	MOV (COORD PTR[EDI]).X, AX
	CALL GetMaxXY													; Get console windows size
	INVOKE DisplayPosition, currX, currY
	MOV EAX, 4														; Next two lines choose a direction (0 - 3) that corresponds to
	CALL RandomRange												; north, south, east or west

	.IF EAX == 0													; North
		DEC currY
	.ELSEIF EAX == 1												; South
		INC currY
	.ELSEIF EAX == 2												; West
		DEC currX
	.ELSE															; East
		INC currX
	.ENDIF

	ADD EDI, TYPE COORD												; Point to next coordinate

	LOOP Again

Finish:

	MOV (DrunkardWalk PTR[ESI]).pathsUsed, WalkMax
	POPAD

	RET																; Return from proc

TakeDrunkenWalk ENDP



DisplayPosition PROC currX:BYTE, currY:BYTE							; Display position proc prototype

.data

	starStr BYTE "*", 0												; Local var used in proc

.code

	PUSHAD

	MOV EAX, BLUE													; Sets text color & specifies coordinate to locate cursor
	CALL SetTextColor
	MOV DH, currX
	MOV DL, currY
	CALL GoToXY


	CMP ECX, rand_val												; Drop phone at rand interval
	JE DROPPED_PHONE

	MOV AL, starStr
	CALL WriteChar
	MOV EAX, 500													; Delay 500 milliseconds between each step
	CALL Delay

	POPAD
	JMP PASS

DROPPED_PHONE:

	MOV AL, 178														; Using 178 ASCII char as professors cellphone, as it
	CALL WriteChar													; actually looks a bit like one! :)

PASS:

	RET																; Return from proc

DisplayPosition ENDP

END main															; Program end
