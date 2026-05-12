;***********************************************************************;
; Program Name: Number Guessing Game									;
;																		;
; Program Description: Prompt user to guess a value between 1 &			;
;					   50, then print whether too low or high &			;
;					   have them guess again. Repeat until user			;
;					   has guessed correctly or the user has hit		;
;					   the limit of 10 guesses							;
;																		;
; Program Author: Parke													;
; Creation Date: 09/17/2024												;
; Revisions: N/A														;
; Date Last Modified: 09/17/2024										;
;***********************************************************************;

;*********************************************;
; 8386, flat memory model, stack size and	  ;
; ExitProcess prototype initalizations as	  ;
; well as Irvine32 library INCLUDE statements ;
;*********************************************;
.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
INCLUDE C:\Irvine\Irvine32.inc
INCLUDELIB C:\Irvine\Irvine32.lib

; Declared and initialized variables
.data
	guess_val DWORD 0
	rand_val DWORD 0

	cool_banner1 BYTE "*****************************************", 0	; Just a pretty & cool banner is all, since this program is a bit elementary level :)
	cool_banner2 BYTE "*	  NUMBER GUESSING GAME	        *", 0
	cool_banner3 BYTE "*****************************************", 0

																		; Each 'rand' var simply used to space out vars inside memory
	rand BYTE "                                                                 ", 0

	congrats_banner1 BYTE "*****************************************",0 ; Just a pretty & cool banner is all, since this program is a bit elementary level :)
	congrats_banner2 BYTE "*   CORRECT!!! CONGRATULATIONS :)	*", 0
	congrats_banner3 BYTE "*****************************************", 0

	rand2 BYTE "                                                                 ", 0

	user_prompt BYTE "GUESS A NUMBER BETWEEN 1 & 50"
				BYTE " (YOU HAVE 10 TRIES): ", 0						; Initial guess prompt for end user

	rand3 BYTE "                                                                 ", 0

	low_prompt BYTE "TOO LOW! TRY AGAIN: ", 0

	rand4 BYTE "                                                                 ", 0

	high_prompt BYTE "TOO HIGH! TRY AGAIN: ", 0

	rand5 BYTE "                                                                 ", 0

	bad_input BYTE "SORRY, INPUT MUST BE BETWEEN 1 & 50. TRY AGAIN"		; Bad input messages

	rand6 BYTE "                                                                 ", 0

	bad_input2 BYTE "SORRY, BAD INPUT. GUESS NUMBER DECREASED BY 1", 0

	rand7 BYTE "                                                                 ", 0

	this_was_the_num_msg BYTE "THE NUMBER WAS * ", 0					; Final console output messages
	this_was_the_num_msg2 BYTE " *", 0

																		; Re-run program prompt
	repeat_program BYTE "RE-RUN PROGRAM? ('yes' TO CONTINUE, ANY OTHER KEY TO"			
				   BYTE " QUIT): ", 0

	rand8 BYTE "                                                                 ", 0

	out_guesses BYTE "SORRY, ALL 10 GUESSES HAVE BEEN USED. TRY AGAIN :(", 0

	rerun_buffer BYTE 3 DUP(0)											; Var to hold user input when prompted to repeat program or not
	
	counter DWORD 10													; Var to check whether 10 guesses have been made yet
																		
;***********************************************************************;
; Function: Main program driver, prompts user for guesses, keeps track  ;
;			of 10 guesses counter & controls all console output			;
;																		;
; Return: None															;
;																		;
; Procedure: Prompt user for first guess, set counter to 10, then loop  ;
;			 through & check whether guess was too low, high or input   ;
;			 was correct. Re-prompt & decrement counters as needed		;
;***********************************************************************;
.code
main PROC

	CALL Randomize														; Initialize RandomRange seed value
	MOV ECX, 10															; Store 10 guess counter in ECX for looping
	MOV EAX, 51															; RandomRange uses val in EAX register as limit range can go to
	CALL RandomRange													; RandomRange proc call
	CMP EAX, 1															; Simply try again if random val generated is 0
	JB main
	MOV rand_val, EAX													; Store RandomRange val in 'rand_val' var for later use
	MOV EDX, OFFSET cool_banner1										; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET cool_banner2										; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET cool_banner3										; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET user_prompt											; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL ReadInt														; ReadInt proc call to take initial guess val from user
	CMP EAX, 1															; If user input < 1 or user input > 50, re-run program with bad input message
	JB RE_RUN															
	CMP EAX, 50
	JA RE_RUN
	MOV guess_val, EAX													; Store value guessed by user in 'guess_val' var for later use
	MOV EBX, rand_val													; Store 'guess_val' in EBX for comparison
	CMP EAX, EBX														; If EAX == EBX, guess is correct. Jump to congratulatory message
	JE CORRECT
	JA TOO_HIGH															; Otherwise let user know guess is too low/high
	JB TOO_LOW

CORRECT:

	MOV EDX, OFFSET congrats_banner1									; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET congrats_banner2									; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET congrats_banner3									; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET repeat_program										; WriteString proc uses EDX register as register to read from											
	CALL WriteString													; WriteStr proc call
	MOV EDX, OFFSET rerun_buffer										; ReadString uses EDX to point to buffer & ECX to specify # of chars user can enter - 1
	MOV ECX, 4
	CALL ReadString														; ReadStr proc call
	MOV EBX, OFFSET rerun_buffer										; Point to first letter in user input from re-run prompt
	MOV EAX, 7562617													; 4-byte val for 'y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]														; If first val in user input is 'y', jump to main to rerun program
	JE main
	MOV EAX, 5457241													; 4-byte val for 'Y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]														; If first val in user input is 'Y', jump to main to rerun program
	JE main

	INVOKE ExitProcess, 0												; Return 0, program success

TOO_LOW:

	DEC ECX
	CMP ECX, 0
	JE NO_MORE_GUESSES
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET low_prompt											; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL ReadInt														; ReadInt proc call
	CMP EAX, 1															; If user input < 1 or user input > 50, re-run program with bad input message
	JB RE_RUN															; If input outside of range, re-run program
	CMP EAX, 50
	JA RE_RUN
	MOV guess_val, EAX													; Store value guessed by user in 'guess_val' var for later use
	MOV EAX, rand_val
	MOV EBX, guess_val
	CMP EAX, EBX														; If EAX == EBX, guess is correct. Jump to congratulatory message
	JE CORRECT
	JA TOO_LOW															; Otherwise let user know guess is too low/high
	JB TOO_HIGH

	INVOKE ExitProcess, 0												; Return 0, program success

TOO_HIGH:

	DEC ECX
	CMP ECX, 0
	JE NO_MORE_GUESSES
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET high_prompt											; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL ReadInt														; ReadInt proc call
	CMP EAX, 1															; If user input < 1 or user input > 50, re-run program with bad input message
	JB RE_RUN															; If input outside of range, re-run program
	CMP EAX, 50
	JA RE_RUN
	MOV guess_val, EAX													; Store value guessed by user in 'guess_val' var for later use
	MOV EAX, rand_val
	MOV EBX, guess_val
	CMP EAX, EBX														; If EAX == EBX, guess is correct. Jump to congratulatory message
	JE CORRECT
	JA TOO_LOW															; Otherwise let user know guess is too low/high
	JB TOO_HIGH

	INVOKE ExitProcess, 0												; Return 0, program success

NO_MORE_GUESSES:

	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET out_guesses											; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET this_was_the_num_msg								; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	MOV EAX, rand_val													; WriteDec proc uses EAX as register to read int from
	CALL WriteDec														; WriteDec proc call
	MOV EDX, OFFSET this_was_the_num_msg2								; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	CALL Crlf															; Insert newline for readability
	CALL main															; Restart program

main ENDP																; Program exit

RE_RUN PROC

	CALL Crlf															; Insert newline for readability
	MOV EDX, OFFSET bad_input											; WriteString uses EDX register for str to read from
	CALL WriteString													; Write str proc call
	CALL Crlf															; Insert newline for readability
	CALL Crlf															; Insert newline for readability
	MOV EAX, 2000														; Delay 2 seconds before re-running program
	CALL Delay															; Delay proc call
	CALL main															; Restart program
	RET

RE_RUN ENDP

END main																; Program end
