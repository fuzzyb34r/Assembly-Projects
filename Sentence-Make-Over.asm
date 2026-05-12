;**********************************************************************************************************************;
; Program Name: Sentence Make-Over																					   ;
; Program Description: Take string from user input and strip out all												   ;
;					   white space, digits, punctuation & special characters										   ;
; Program Author: Parke																								   ;
; Creation Date: 03/30/2024			  																				   ;
; Revisions: N/A																									   ;
; Date Last Modified: 03/30/2024																					   ;
;**********************************************************************************************************************;

;*********************************************;
; 8386, flat memory model, stack size and	  ;
; ExitProcess prototype initalizations as	  ;
; well as Irvine32 library INCLUDE statements ;
;*********************************************;
.386
.model flat,stdcall
.stack 4096
ExitProcess PROTO, dwExitCode:DWORD
INCLUDELIB C:\masm32\lib\Irvine32.lib
INCLUDE C:\masm32\include\Irvine32.inc

; Declared and initialized variables
.data
	user_prompt BYTE "Enter a sentence: ", 0	; Prompt for user input
	buffer DWORD 101 DUP(0)						; Input buffer size
	char_count DWORD ?							; Length of str counter for proc calls
	counter BYTE 1								; Mischellaneous couter to be used in final program loop to print letter frequency table properly

	letter_count BYTE 26 DUP(0)					; Array containing 26 0's to use when counting each letter in user
												; input in order to create our letter frequency list for final output

.code
main PROC
	MOV EDX, OFFSET user_prompt					; WriteString uses EDX register for location of str to write to console
	CALL WriteString							; Write user_prompt to console
	MOV EDX, OFFSET buffer						; Pointer to buffer
	MOV ECX, SIZEOF buffer / TYPE buffer		; Specify max chars user can enter, if more chars are entered they will be truncated
	CALL ReadString								; Input str from user
	MOV ECX, EAX								; Use char count from user input for loop counter
	MOV char_count, EAX							; Store loop counter in char_count to restore ECX later on in program after input stripping
	MOV ESI, OFFSET buffer						; We will use ESI register for pointer to each char in str

STRIP_INPUT_LOOP:								; Begin loop to strip input of anything but letters

	MOV EBX, 65d								; Move capital 'A' into EBX for letter comparison
	CMP BYTE PTR[ESI], BL						; Compare each element in str to capital 'A' ASCII value
	JB ELSE_CLAUSE								; If less than 'A' ASCII value, jump to final ELSE_CLAUSE label for alternate processing
	MOV EBX, 90d								; Move capital 'Z' into EBX for letter comparison
	CMP BYTE PTR[ESI], BL						; Compare each element in str to capital 'Z' ASCII value
	JA ALTERNATE_PROCESS						; If greater than 'Z' ASCII value, jump to 2nd label for alternate processing
	AND BYTE PTR[ESI], 11011111b				; Convert each valid char to UPPERCASE using AND instruction for easier processing
	INC ESI										; Get next char in str
	LOOP STRIP_INPUT_LOOP						; Loop back until each char is validated

ALTERNATE_PROCESS:								; Label for alternate processing of invalid chars

	CMP ECX, 0									; Ensure counter != 0, as counter can increase back to 0xFFFFFFFF causing eternal loop 
	JE CONTINUE									; Exit if counter == 0
	MOV EBX, 97d								; Move lowercase 'a' into EBX for letter comparison
	CMP BYTE PTR[ESI], BL						; Compare each element in str to lowercase 'a' ASCII value
	JB ELSE_CLAUSE								; If less than 'a' ASCII value, jump to final ELSE_CLAUSE label for alternate processing
	MOV EBX, 122d								; Move lowercase 'z' into EBX for letter comparison
	CMP BYTE PTR[ESI], BL						; Compare each element in str to lowercase 'z' ASCII value
	JA ELSE_CLAUSE								; If more than 'z' ASCII value, jump to final ELSE_CLAUSE label for alternate processing
	AND BYTE PTR[ESI], 11011111b				; Convert each valid char to UPPERCASE using AND instruction for easier processing
	INC ESI										; Get next char in str
	LOOP STRIP_INPUT_LOOP						; Loop back until each char is validated

ELSE_CLAUSE:
	CMP ECX, 0									; Ensure counter != 0, as counter can increase back to 0xFFFFFFFF causing eternal loop 
	JE CONTINUE									; Exit if counter == 0
	MOV BYTE PTR[ESI], 127						; Otherwise, replace value at str[index] with ASCII value for empty char
	INC ESI										; Get next char in str
	LOOP STRIP_INPUT_LOOP						; Loop back until each char is validated

CONTINUE:										; Label for beginning of letter frequency section

	MOV EAX, char_count							; Move O.G. str length into EAX
	MOV ECX, EAX								; Set loop counter to iterate through each char in stripped input
	MOV EBX, 65									; Move capital 'A' into EBX to be used as comparison register with current letter in stripped input
	MOV ESI, EDX								; We will use ESI register for pointer to each char in str
	MOV EDI, OFFSET letter_count				; Use EDI register for pointer to each letter frequency alphabet list

INNER_LOOP_LABEL:

	CMP BYTE PTR[ESI], BL						; Determine whether each letter in alphabet is equal to current letter in stripped input
	JE LETTER_FREQUENCY							; If letter is equal to alphabet letter, jump to final label for increasing each chars count
	INC ESI										; Otherwise, increment pointer & continue loop
	LOOP INNER_LOOP_LABEL

	MOV ECX, char_count							; Reset loop counter
	JE BEGIN_EXIT_PROCESS
	MOV ESI, EDX								; Reset ESI to point to beginning of user input str again
	CMP EBX, 90									; If letter is 'Z', no need to continue further, proceed to exit process on next line
	JE BEGIN_EXIT_PROCESS
	INC EBX										; Increment EBX register to point to next alphabet letter
	INC EDI										; Increment alphabet array pointer & continue loop
	LOOP INNER_LOOP_LABEL

LETTER_FREQUENCY:

	INC BYTE PTR[EDI]							; Add 1 to letter_count array position
	INC ESI										; Increment pointer & continue loop
	LOOP INNER_LOOP_LABEL

BEGIN_EXIT_PROCESS:

	CALL Crlf
	CALL WriteString							; Write final string to console
	CALL Crlf									; Print 2 newlines
	CALL Crlf
	INVOKE ExitProcess, 0						; Return 0, program exit
main ENDP
END main
