;******************************************************************;
; Program Name: Boolean Calc #2									   ;
; Program Description: Simple boolean calc for 32-bit integers     ;
; Program Author: Parke											   ;
; Creation Date: 04/11/2024										   ;
; Revisions: N/A												   ;
; Date Last Modified: 04/12/2024								   ;
;******************************************************************;

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

; Declared and initialized (or un-initialized) variables
.data
	user_prompt BYTE "CHOOSE ONE OF THE FOLLOWING OPTIONS:", 0  ; Prompt user for choice
	choice_one BYTE "(1) x AND y", 0							; Next few lines are each choice the user can pick from
	choice_two BYTE "(2) x OR y", 0
	choice_three BYTE "(3) NOT x", 0
	choice_four BYTE "(4) x XOR y", 0
	choice_five BYTE "(5) EXIT PROGRAM", 0
	prompt_for_int BYTE "Pick your choice here "
				   BYTE "(Enter input as 1, 2, 3, 4 or 5): ", 0	; Prompt user for input corresponding to which integer value

	msgA BYTE "PROCESS ONE: x AND y", 0							; Messages to display to user based on their choice
	msgB BYTE "PROCESS TWO: x OR y", 0
	msgC BYTE "PROCESS THREE: NOT x", 0
	msgD BYTE "PROCESS FOUR: x XOR y", 0
	msgE BYTE "PROCESS FIVE: EXIT PROGRAM", 0
	read_hex_val1 BYTE "Enter a hexadecimal number: ", 0
	read_hex_val2 BYTE "Enter another hexadecimal number: ", 0
	exit_message BYTE "Goodbye!", 0
	error_message BYTE "Sorry, bad input. Please re-run the program "
				  BYTE "and follow the instructions provided", 0
	prettify_output BYTE "YOUR CHOICE", 0
	prettify_output2 BYTE "************", 0
	final_output BYTE "Your final calculated value is: ", 0

	first_hex_val DWORD ?
	second_hex_val DWORD ?

	; Next 15 lines simply build our case table to quickly lookup whether the user
	; entered a val inside the table or entered bad input if no match is found
	CaseTable DWORD 1											; Lookup val
			  DWORD AND_op										; Proc address

	EntrySize = ($ - CaseTable)
				DWORD 2
				DWORD OR_op
				DWORD 3
				DWORD NOT_op
				DWORD 4
				DWORD XOR_op
				DWORD 5
				DWORD EXIT_PROCESS

	NumOfEntries = ($ - CaseTable) / EntrySize

.code
main PROC
	MOV EDX, OFFSET user_prompt									; This and next 15 or so lines are all simply prompts for the end user
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET choice_one
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET choice_two
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[choice_three]
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET choice_four
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET choice_five
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET prompt_for_int
	CALL WriteString
	CALL ReadInt												; Prompt user for choice
	MOV EBX, OFFSET CaseTable									; Point EBX register to case table
	MOV ECX, NumOfEntries										; Set loop counter

L1:
	CMP EAX, [EBX]												; Match found??
	JNE L2														; No, continue
	CALL NEAR PTR[EBX + 4]										; Yes, call proc
	MOV EDX, OFFSET final_output								; WriteString uses EDX register for str to read from
	CALL Crlf													; Insert newline for readability
	CALL WriteString
	CALL WriteHex												; Write output to console
	CALL Crlf													; Insert newline for readability
	INVOKE ExitProcess, 0										; Return 0, exit success

L2:
	ADD EBX, EntrySize											; Increase table pointer
	CMP ECX, 0
	JE no_match_found
	LOOP L1														; Loop back to L1 and check next value in table

NO_MATCH_FOUND:
	MOV EDX, OFFSET DWORD PTR[error_message]					; WriteString uses EDX register for str to read from
	CALL Crlf													; Insert newline for readability
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	INVOKE ExitProcess, 0										; Return 0, exit success

main ENDP														; Program exit

;**********************************************************************************;
; Each of the following procs for the rest of the code are all procs to be		   ;
; called based on what the user enters as their choice for the desired calculation ;
;**********************************************************************************;
AND_op PROC
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]					; WriteString uses EDX register for str to read from
	CALL WriteString			
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET msgA										; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[read_hex_val1]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read first hex val from input
	MOV first_hex_val, EAX										; Move input into memory
	MOV EDX, OFFSET DWORD PTR[read_hex_val2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read second hex val from input
	AND first_hex_val, EAX										; Logical AND the two values
	MOV EAX, first_hex_val
	RET
AND_op ENDP

OR_op PROC	
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]					; WriteString uses EDX register for str to read from
	CALL WriteString			
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET msgB
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[read_hex_val1]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read first hex val from input
	MOV first_hex_val, EAX										; Move input into memory
	MOV EDX, OFFSET DWORD PTR[read_hex_val2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read second hex val from input
	OR first_hex_val, EAX										; Logical OR the two values
	MOV EAX, first_hex_val
	RET
OR_op ENDP

NOT_op PROC
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]					; WriteString uses EDX register for str to read from
	CALL WriteString			
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET msgC
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[read_hex_val1]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read first hex val from input
	MOV first_hex_val, EAX										; Move input into memory
	NOT first_hex_val											; Logical NOT the value entered
	MOV EAX, first_hex_val									
	RET
NOT_op ENDP

XOR_op PROC
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]					; WriteString uses EDX register for str to read from
	CALL WriteString			
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET msgD
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[read_hex_val1]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read first hex val from input
	MOV first_hex_val, EAX										; Move input into memory
	MOV EDX, OFFSET DWORD PTR[read_hex_val2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL ReadHex												; Read second hex val from input
	XOR first_hex_val, EAX										; Logical XOR the two values
	MOV EAX, first_hex_val
	RET
XOR_op ENDP

EXIT_PROCESS PROC
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]					; WriteString uses EDX register for str to read from
	CALL WriteString			
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output2]					; WriteString uses EDX register for str to read from
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET msgE
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	MOV EDX, OFFSET exit_message
	CALL WriteString
	CALL Crlf													; Insert newline for readability
	INVOKE ExitProcess, 0
EXIT_PROCESS ENDP

END main
