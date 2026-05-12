;****************************************************************************;
; Program Name: Fun Generator												 ;
;																			 ;
; Program Description: Prompts user for number then prompts user			 ;
;					   to choose from four options: Fibonacci,				 ;
;					   Exchange Elements, Sum Gaps, & Shift Elements.		 ;
;					   Each of these functions will be explaied in			 ;
;					   their own documentation to follow in the code,		 ;
;					   but each function will use that intial number		 ;
;					   taken from the user's first input in their processing ;
;																			 ;
; Program Author: Parke														 ;
; Creation Date: 08/22/2024													 ;
; Revisions: N/A															 ;
; Date Last Modified: 08/26/2024											 ;
;****************************************************************************;

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

; Declared and initialized variables
.data

	initial_integer_prompt BYTE "ENTER AN EVEN INTEGER BETWEEN 8 (INCLUDING 8)"	; Inital prompt for integer value to be used in the 
						   BYTE " AND 50 (EXCLUDING 50): ", 0					; following functions user is able to pick from

	user_prompt BYTE "CHOOSE ONE OF THE FOLLOWING OPTIONS:", 0					; Menu & 2nd prompt for user's choice of functionality

	choice_one BYTE "(1) FIBONACCI", 0											; Next few lines are each choice the user can pick from
	choice_two BYTE "(2) EXCHANGE ELEMENTS", 0
	choice_three BYTE "(3) SUM GAPS", 0
	choice_four BYTE "(4) SHIFT ELEMENTS", 0

	prompt_for_int BYTE "Pick your choice here "
				   BYTE "(Enter input as 1, 2, 3, or 4): ", 0					; Prompt user for integer value corresponding to function they want

	msgA BYTE "PROCESS ONE: FIBONACCI", 0										; Messages to display to user based on their choice
	msgB BYTE "PROCESS TWO: EXCHANGE ELEMENTS", 0
	msgC BYTE "PROCESS THREE: SUM GAPS", 0
	msgD BYTE "PROCESS FOUR: SHIFT ELEMENTS", 0

	verify_input BYTE "YOUR CHOICE", 0											; Tell user what they picked
	prettify_output BYTE "************************", 0							; This is used to make program prompt look a little more pretty :)

	bad_input BYTE "Sorry, bad input, please re-run the program & follow the"	; Message for user if they enter a value less than 8, more than
			  BYTE " instructions provided", 0									; 50, or if the entered value is an odd #. Also handles case of
																				; bad input from 2nd menu choice prompt

	fib_output BYTE "FIBONACCI SEQUENCE", 0										; Message to help prettify fibonacci sequence output

	prettify_elem_output1 BYTE "ORIGINAL ARRAY", 0								; Messages to help prettify Exchange Elements, Sum Gaps, & Shift Elements functionality of program
	prettify_elem_output2 BYTE "EXCHANGED ELEMENT ARRAY", 0

	sum_gaps_output BYTE "ARRAY OF GAP VALUES", 0								; Next three vars hold output for sum of gaps and final sum of gaps value
	sum_gaps_output2 BYTE "TOTAL SUM OF GAP VALUES", 0
	sum_gaps DWORD 0													

	shift_val_prompt BYTE "ENTER A VALUE TO SHIFT THE ARRAY BY"					; Prompt user for shift val inside 'SHIFT_op' proc
					 BYTE " BETWEEN 1 & 47: ", 0								

	shift_output BYTE "SHIFTED ARRAY", 0

	cool_emoji BYTE "[*] ", 0													; Make 'SUM_op' proc output look cool :)

	repeat_program BYTE "RE-RUN PROGRAM? ('yes' TO CONTINUE, ANY OTHER KEY TO"  ; Re-run program prompt
				   BYTE " QUIT): ", 0

	fib_array DWORD 50 DUP(0)													; Array to store up to 50 fibonacci elements, or as little as 8,
																				; depending what the end user decides

	xchng_arr DWORD 50 DUP(0)													; Array to hold properly exchanged elements for 'EXCHANGE_op' proc

	sum_array DWORD 50 DUP(0)													; Array to store sums between gaps in 'SUM_op' proc
	total_sum_gaps DWORD 0														; Var to hold the total sum from all gaps between vals added together

	shifted_array DWORD 50 DUP(0)												; Array to fill with values properly shifted from their original index in 'SHIFT_op' proc

	last_index DWORD 0															; Val to use in 'SHIFT_op' proc processing

	firstVal DWORD 0															; Declared values to first 2 fibonacci sequence values
	secondVal DWORD 1															; for easier processing from beginning

	golden_integer DWORD 0														; Var to hold initial integer from user to be used in all function processing

	shift_val DWORD 0															; Var to hold how many elements array should be shifted by inside 'SHIFT_op' proc
	shift_val_bytes DWORD 0														; Var to hold calculation of how many bytes we need to shift for our 'SHIFT_op' proc algorithm to work

	rerun_buffer BYTE 3 DUP(0)													; Var to hold user input when prompted to repeat program or not

;*******************************************************************************;
; 'rand_array' is a randomly generated array of up to 48 elements to be used in ;
; the Exchange Elements, Sum Gaps, & Shift Elements functionality of program.   ;
; Random array of hex values in valid range of 32-bit integers was generated	;
; and sorted using an external Python script whose corresponding code will be	;
; pasted at the very end of this program, albeit a bit more compact than usual  ;
; Python code :)																;
;*******************************************************************************;

	rand_array DWORD 88858624, 174757566
			   DWORD 270314741, 374587547
			   DWORD 381534027, 637676810
			   DWORD 639057956, 675596746
			   DWORD 1017726912, 1039792130
			   DWORD 1055340937, 1133308629
			   DWORD 1273252632, 1370066560
			   DWORD 1386450506, 1410860439
			   DWORD 1587139956, 1641777782
			   DWORD 1718353252, 1758314848
			   DWORD 1906028739, 2249193648
			   DWORD 2260775578, 2327670318
			   DWORD 2335370792, 2512935525
			   DWORD 2537655527, 2557806658
			   DWORD 2565993224, 2572514601
			   DWORD 2677471464, 2703650884
			   DWORD 2802490817, 2845041350
			   DWORD 2848524659, 2858132941
			   DWORD 2957711056, 3215451353
			   DWORD 3288444750, 3322286063
			   DWORD 3455267978, 3542175382
			   DWORD 3705710465, 3748894316
			   DWORD 3798478492, 3861049020
			   DWORD 3938488783, 4006713884

;*******************************************************************************;
; Next 15 lines simply build our case table to quickly lookup whether the user  ;
; entered a val inside the table or entered bad input if no match is found		;
;*******************************************************************************;

	CaseTable DWORD 1															; Lookup val
			  DWORD FIB_op														; Proc address

	EntrySize = ($ - CaseTable)
				DWORD 2
				DWORD EXCHANGE_op
				DWORD 3
				DWORD SUM_op
				DWORD 4
				DWORD SHIFT_op

	NumOfEntries = ($ - CaseTable) / EntrySize

;***********************************************************************************;
; Function:	Main function, prompts user for initial input and uses value entered in ;
;			following function calls after re-prompting user for function choice	;
;																					;
; Return: None																		;
;																					;
; Procedure: Set EDX register with multiple different strings to ask user for both  ;
;			 inputs and perform all processing on user's behalf from that point on  ;
;***********************************************************************************;
.code
main PROC

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET initial_integer_prompt										; WriteString proc uses EDX register as register to read from 
	CALL WriteString															; WriteStr proc call
	CALL ReadInt																; Take user's initial integer input
	MOV golden_integer, EAX														; Store initial user integer inside 'golden_integer' var for later use
	CMP EAX, 8																	; If user input < 8, jump to BAD_USER_INPUT proc
	JB BAD_USER_INPUT
	CMP EAX, 50																	; If user input > 50, jump to BAD_USER_INPUT proc
	JAE BAD_USER_INPUT

	CDQ																			; Convert doubleword to quadword, AKA we need to extend 
	MOV EBX, 2																	; EAX into EDX for modulo operation

	IDIV EBX																	; Modulo operation

	CMP EDX, 0																	; IDIV leaves remainder in EDX, jump to BAD_USER_INPUT proc
	JNE BAD_USER_INPUT															; if EDX != 0, signifying odd value was given as input

	MOV EDX, OFFSET user_prompt													; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET choice_one													; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET choice_two													; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET choice_three												; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET choice_four													; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prompt_for_int												; WriteString proc uses EDX register as register to read from
	CALL WriteString															; WriteStr proc call
	CALL ReadInt																; Prompt user for choice from 2nd menu
	MOV EBX, OFFSET CaseTable													; Point EBX register to case table
	MOV ECX, NumOfEntries														; Set loop counter

L1:																				; Start looping through CaseTable to find proc call user wants, or exit if user provides bad input

	CMP EAX, [EBX]																; Match found??
	JNE L2																		; No, continue
	CALL NEAR PTR[EBX + 4]														; Yes, call proc

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET repeat_program												; WriteString proc uses EDX register as register to read from											
	CALL WriteString															; WriteStr proc call
	MOV EDX, OFFSET rerun_buffer												; ReadString uses EDX to point to buffer & ECX to specify # of chars user can enter - 1
	MOV ECX, 4
	CALL ReadString																; ReadStr proc call
	MOV EBX, OFFSET rerun_buffer												; Point to first letter in user input from re-run prompt
	MOV EAX, 7562617															; 4-byte val for 'y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]																; If first val in user input is 'y', jump to main to rerun program
	JE main
	MOV EAX, 5457241															; 4-byte val for 'Y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]																; If first val in user input is 'Y', jump to main to rerun program
	JE main
																				; If user's input first letter is not 'y' or 'Y', exit program
	INVOKE ExitProcess, 0														; Return 0, exit success

L2:

	ADD EBX, EntrySize															; Increase table pointer

	CMP ECX, 0																	; If counter makes it to 0, we can jump to exit/error processing
	JE NO_MATCH_FOUND															; in NO_MATCH_FOUND label since user's input was not a menu option

	LOOP L1																		; Loop back to L1 and check next value in table

NO_MATCH_FOUND:

	MOV EDX, OFFSET DWORD PTR[bad_input]										; WriteString uses EDX register for str to read from
	CALL Crlf																	; Insert newline for readability
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability

	INVOKE ExitProcess, 0														; Return 0, exit success	

main ENDP																		; Program exit

;***********************************************************************************;
; Function:	Fibonacci functionality of program, option 1 for user to choose from in ;
;		    the 2nd initial menu prompt												;
;																					;
; Return: 'N' iterations of Fibonacci sequence, where 'N' cooresponds to user's		;
;		  choice from 1st initial integer prompt									;
;																					;
; Procedure: Moves our 'golden_integer' var into ECX to use as counter for when Fib ;
;			 sequence should stop generating in memory. Each item in Fib sequence   ;
;			 is added to our next available 'fib_array' index position. Finally, we ;
;			 output our 'fib_array' var to the user, showcasing 'N' correct			;
;			 iterations of the Fibonacci sequence									;
;***********************************************************************************;
FIB_op PROC

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[verify_input]										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call		
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]									; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET msgA														; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for Fib sequence
	DEC ECX																		; Decrement counter once, since counting starts at 0, 'golden_integer' by itself will be 1 too many
	LEA ESI, fib_array															; Allocates space for 'fib_array' on the stack and assigns the address to ESI, an indirect operand
	ADD ESI, TYPE fib_array

FIB_L1:

	MOV EAX, firstVal															; Set EAX & EBX registers to first values in Fib sequence
	MOV EBX, secondVal
	ADD EAX, EBX																; Add together
	MOV EDX, EAX																; Store value in EDX, set firstVal & secondVal to next sequence values
	MOV firstVal, EBX
	MOV secondVal, EDX
	MOV [ESI], EBX																; Store current value in our_array's current index then increment index
	ADD ESI, TYPE fib_array
	LOOP FIB_L1																	; Loop until 'N' iterations of Fib sequence have been generated

	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET fib_output													; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Reset counter to display Fib sequence that was generated
	MOV ESI, OFFSET fib_array													; Move 'fib_array' beginning to ESI register to begin loop

FIB_L2:

	MOV EAX, [ESI]																; Move each iteration in Fib sequence into EAX register 
	CALL WriteDec																; WriteDec proc call, uses EAX as register to read from
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, 4																	; Increment 'fib_array' index
	LOOP FIB_L2																	; Loop until all 'N' iterations of Fib sequence have been printed to console

	CALL Crlf																	; Insert newline for readability
	RET																			; Return from proc

FIB_op ENDP

;***********************************************************************************;
; Function: Element exchange functionality of program. Using 'N' elements from		;
;			'rand_array' we generated, we will loop through the array while		    ;
;			exchanging each element along the way									;
;																					;
; Return: Array with alternating elements exchanged properly						;
;																					;
; Procedure: Moves our 'golden_integer' var into ECX to use as counter for when our ;
;			 array is done exchanging elements. Initial proc entry, along with		;
;			'EXCHANGE_L1' & 'EXCHANGE_L3' loops are simply for console output to    ;
;			 end user. However, in our 'EXCHANGE_L2' loop, we set ESI to the offset ;
;			 of 'rand_array' & EDI to the offset of 'rand_array' plus an element.   ;
;			 Loop exchanges alternating vals in 'N' sized 'rand_array' specified by ;
;			 user's initial input													;
;***********************************************************************************;
EXCHANGE_op PROC
	
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[verify_input]										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call		
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]									; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET msgB														; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_elem_output1										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is												
	MOV ESI, OFFSET rand_array													

EXCHANGE_L1:

	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE rand_array													; Increment counter
	LOOP EXCHANGE_L1

	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_elem_output2
	CALL WriteString
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteDec proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	MOV EDX, OFFSET xchng_arr													; Use EDX to hold pointer to new array
	MOV ESI, OFFSET rand_array													; Next few lines set pointers to 1st & 2nd elements in 'rand_array'
	MOV EDI, OFFSET rand_array
	ADD EDI, TYPE rand_array

EXCHANGE_L2:

	MOV EAX, [ESI]																; Use EAX & EBX as temp registers to store each pair of elements that need to be swapped
	MOV EBX, [EDI]
	XCHG EAX, EBX																; Next 3 lines exchange current pair of elements
	MOV [EDX], EAX																; Next few lines move proper elements into their respective slots in 'xchng_arr'
	ADD EDX, TYPE xchng_arr
	MOV [EDX], EBX
	ADD ESI, 8																	; Since we are swapping alternating elements, we need to move forward 2 elements each iteration
	ADD EDI, 8
	ADD EDX, TYPE xchng_arr
	LOOP EXCHANGE_L2															; Loop until each element in the 'N' length array has been swapped
	
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	MOV ESI, OFFSET xchng_arr

EXCHANGE_L3:

	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE xchng_arr														; Increment counter
	LOOP EXCHANGE_L3

	CALL Crlf																	; Insert newline for readability
	RET																			; Return from proc

EXCHANGE_op ENDP

;***********************************************************************************;
; Function: Sum Gaps functionality of program. Using 'N' elements from 'rand_array' ;
;			we generated, we will loop through the array while subtracting each     ;
;			index element from the (index + 1) element and add it to its own array, ;
;			then we will add all the vals together from the array of gaps & print	;
;			this output to the console for the end user to see						;
;																					;
; Return: Array with each difference value collected from subtracting each val from ;
;		  the other in our 'rand_array'												;
;																					;
; Procedure: Moves our 'golden_integer' var into ECX to use as counter for when our ;
;			 loop is done calculating the differences. We then use EAX & EBX as tmp ;
;			 registers to hold 2 vals to be subtracted from each other each loop	;
;			 iteration. After adding each of these to their own array, we loop      ;
;			 through that array and calculate the sum from each difference value.	;
;			 Finally, we output all our findings to the console in a pretty format  ;
;			 for the end user														;
;***********************************************************************************;
SUM_op PROC

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[verify_input]										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call		
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]									; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET msgC														; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_elem_output1										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	MOV ESI, OFFSET rand_array

SUM_L1:

	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE rand_array													; Increment counter
	LOOP SUM_L1

	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV ESI, OFFSET rand_array													; Next few lines set pointers to 1st & 2nd 'rand_array' elements for easier processing
	MOV EDI, OFFSET rand_array
	ADD EDI, TYPE rand_array
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	MOV EDX, OFFSET sum_array													; Set pointer to beginning of 'sum_array' to begin filling it 

SUM_L2:
	MOV EAX, [ESI]																; Use EAX & EBX as tmp registers to hold 2 vals to be subtracted each iteration
	MOV EBX, [EDI]
	SUB EBX, EAX																; Subtract vals, add difference to corresponding index of 'sum_array'
	MOV [EDX], EBX
	ADD ESI, TYPE rand_array													; Next few lines move our pointers forward
	ADD EDI, TYPE rand_array
	ADD EDX, TYPE rand_array
	LOOP SUM_L2																	; Loop until 'N' pair of vals have been subtracted from each opther, where 'N' is specified by user in initial prompt

	MOV EDX, OFFSET sum_gaps_output
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	DEC ECX																		; Dec counter once, as 'golden_integer' itself would be 1 too many in this use case
	MOV ESI, OFFSET sum_array													; Point to beginning of 'sum_array'

SUM_L3:
	
	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE sum_array														; Increment counter
	LOOP SUM_L3

	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET sum_gaps_output2											; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET cool_emoji													; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	DEC ECX																		; Dec counter once, as 'golden_integer' itself would be 1 too many in this use case
	MOV ESI, OFFSET sum_array													; Point to beginning of 'sum_array'

SUM_L4:

	MOV EBX, [ESI]																; Use EBX as tmp register to store each val from 'sum_array' in current iterations index
	ADD total_sum_gaps, EBX														; Add current index val to our 'total_sum_gaps' var
	ADD ESI, TYPE sum_array														; Move pointer forward
	LOOP SUM_L4																	; Loop until all vals from 'sum_array' have been added together																

	MOV EAX, total_sum_gaps														; WriteDec uses EAX as register to read from
	CALL WriteDec																; WriteDec proc call

	CALL Crlf																	; Insert newline for readability
	RET																			; Return from proc

SUM_op ENDP

;***********************************************************************************;
; Function:	Shift Elements functionality of program. Using our 'N' element array,	;
;			we prompt the user for a shift value between 1 & 47, as 0 would be no   ;
;			shift & 48 would shift all vals the full length of the array, resulting ;
;			in the same array as the original										;
;																					;
; Return: Array shifted by 'M' elements, as specified by user from input			;
;																					;
; Procedure: Set ESI & EDI to original and shifted array offsets, set ECX to value  ;
;			 from user input using var 'shift_val'. Perform calculations to set the ;
;			 'shift_val_bytes' var to the amount of bytes we need to travel up in   ;
;			 memory. Add that many bytes to pointer in memory, then subtract the    ;
;			 val taken from user input multiplied by 4 since we are handling 32-bit ;
;			 vars and registers. This will now give us a pointer to the val that    ;
;			 will be set first in the shifted array. We then increment all pointers ;
;			 and continue for as many vals as was specified by user from input.		;
;			 Finally, we resume proc at the index pointed to by EDI & shift this    ;
;			 val into the next array sequence. We do this for as many iterations as ;
;			 specified by user from input, represented by the 'shift_val' var. We   ;
;			 finally finish off by printing our newly shifted array to the console  ;
;			 for our end user														;
;***********************************************************************************;
SHIFT_op PROC

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[verify_input]										; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call		
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET DWORD PTR[prettify_output]									; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET msgD														; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is												
	MOV ESI, OFFSET rand_array													
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_elem_output1
	CALL WriteString
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteDec proc call
	CALL Crlf																	; Insert newline for readability

SHIFT_L1:

	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE rand_array													; Increment counter
	LOOP SHIFT_L1

	CALL Crlf																	; Insert newline for readability
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET shift_val_prompt											; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteDec proc call
	CALL ReadInt																; ReadInt proc call
	CMP EAX, 1																	; If user input < 1, jump to BAD_USER_INPUT proc
	JB BAD_USER_INPUT
	CMP EAX, 47																	; If user input > 47, jump to BAD_USER_INPUT proc
	JA BAD_USER_INPUT
	MOV shift_val, EAX
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET shift_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET prettify_output												; WriteString uses EDX register for str to read from
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability
	MOV ECX, shift_val															; Use ECX as counter for how many times array should shift

	MOV EBX, 4																	; Multiply 'shift_val' that's currently in EAX by EBX, which holds 4.
																				; This gives us the amount of bytes to go back from end of array in order to get to valid index
	MUL EBX
	MOV shift_val_bytes, EAX													; Next few lines multiply product from 'shift_val' by 4 to get amount of bytes we need to jump to get to end of array 
	MOV EAX, golden_integer														
	MUL EBX
	MOV last_index, EAX
	MOV ESI, OFFSET rand_array													; Set array pointers												
	MOV EDI, OFFSET shifted_array

SHIFT_L2:

	MOV EBX, ESI																; Use EBX to hold tmp offset address
	ADD EBX, last_index															; Go to last array index
	SUB EBX, shift_val_bytes													; Go back however many elements get us to proper index, as calculated earlier
	MOV EAX, [EBX]																; Move val at address held in EBX into EAX
	MOV [EDI], EAX																; Move val in EAX into proper slot in 'shifted_array'
	CMP ECX, 1																	; If ECX == 1, jump to next processing steps, as going to 0 will be 1 index too far
	JE SHIFT_L2_EXIT
	ADD ESI, TYPE shifted_array													; Move pointers forward
	ADD EDI, TYPE shifted_array
	LOOP SHIFT_L2																; Loop until 'M' vals have been shifted, as speicified by user

SHIFT_L2_EXIT:

	ADD EDI, 4																	; If back-side of array has been shifted, move pointer forward & continue with front-side of array

	MOV ECX, golden_integer														; Use 'golden_integer' var as counter for how large array is
	SUB ECX, shift_val															; Decrement counter by 'shift_val', to only process elements that haven't been shifted yet
	MOV ESI, OFFSET rand_array													; Set pointer to 'rand_array' beginning

SHIFT_L3:

	MOV EAX, [ESI]																; Move val in memory location held in ESI register into EAX
	MOV [EDI], EAX																; Move EAX into proper index specified by EDI pointer
	CMP ECX, 1																	; If ECX == 1, jump to next processing steps, as going to 0 will be 1 index too far
	JE SHIFT_L3_EXIT
	ADD ESI, 4																	; Move pointers forward
	ADD EDI, 4
	LOOP SHIFT_L3																; Loop until rest of array has been shifted

SHIFT_L3_EXIT:

	MOV ECX, golden_integer														; Set counter and pointers for final console output loop
	MOV ESI, OFFSET shifted_array

SHIFT_L3_EXIT_LOOP:

	MOV EAX, [ESI]																; Use EAX as tmp register to read current 'rand_array' index and print to console
	CALL WriteDec																; WriteDec proc call
	MOV AL, " "																	; Insert space between each element for readability
	CALL WriteChar																; WriteChar proc call, uses AL as register to read from
	ADD ESI, TYPE rand_array													; Increment counter
	LOOP SHIFT_L3_EXIT_LOOP														; Loop until full shifted array has been printed

	CALL Crlf
	RET																			; Return from proc

SHIFT_op ENDP

;***********************************************************************************;
; Function:	In our main function, we prompt user for initial input and use that     ;
;           value entered in following function calls. This handles the case where 	;
;			our user enters any bad input											;
;																					;
; Return: Error message printed to console for end user								;
;																					;
; Procedure: Set EDX register with string to warn user about improper input, & then ;
;			 ask them politely to re-run the program & try again					;
;***********************************************************************************;
BAD_USER_INPUT PROC

	CALL Crlf																	; Insert newline for readability
	MOV EDX, OFFSET bad_input													; WriteString proc uses EDX register as register to read from 
	CALL WriteString															; WriteStr proc call
	CALL Crlf																	; Insert newline for readability

	INVOKE ExitProcess, 0														; Return 0, exit success	

BAD_USER_INPUT ENDP

END main																		; Program end

;*************************************;
; 'rand_array' Generation Python Code ;									     
;*************************************;

; from random import randrange
; rand_array = []
; for element in range(0, 48):
;     rand_array.append(randrange(4294967295)) # Valid 32-bit int range, using following formula: 0 to (2^bit_count) - 1
; print(sorted(rand_array))
