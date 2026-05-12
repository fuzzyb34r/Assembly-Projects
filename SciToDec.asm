;**********************************************************************************************************;
; Program Name: Precision Display																		   ;
; Program Description: We will take a decimal value input from the user along with how many decimal points ;
;					   they want the value rounded to and display the output to the console window		   ;
; Program Author: Parke																					   ;
; Creation Date: 04/04/2024								 												   ;
; Revisions: Added input validation and exception handling									     		   ;
; Date Last Modified: 04/09/2024																		   ;
;**********************************************************************************************************;

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
INCLUDE C:\masm32\include\Macros.inc

; Declared and initialized (or un-initialized) variables
.data
	floating_tens REAL8 10.0						; Floating point vals to be used in "displayFloat" proc later in program.
	floating_hundreds REAL8 100.0					; One of these will be assigned for calculations based off of what
	floating_thousands REAL8 1000.0					; the user inputs for the value to round the decimal place to
	floating_ten_thousands REAL8 10000.0

    tens DWORD 10									; Integer vals to be used in "displayFloat" proc later in program.
	hundreds DWORD 100								; One of these will be assigned for calculations based off of what
	thousands DWORD 1000							; the user inputs for the value to round the decimal place to
	ten_thousands DWORD 10000

	tmp DWORD ?										; Rand val to help with calculations in main proc call

	tens_counter DWORD 1							; Counter vals to be used in "displayFloat" proc later in program.
	hundreds_counter DWORD 2						; One of these will be assigned for calculations based off of what
	thousands_counter DWORD 3						; the user inputs for the value to round the decimal place to
	ten_thousands_counter DWORD 4

	counter DWORD ?									; Final counter placeholder that will be used in primary proc call later in program

	first REAL8 +1.0000000E+000						; Vals to compare to decimal rounding input for proper branching off conditionals
	second REAL8 +2.0000000E+000
	third REAL8 +3.0000000E+000
	fourth REAL8 +4.0000000E+000

    dwordtmp DWORD ?								; Temp storage val to be used in "displayFloat" proc later in program

	else_conditional BYTE "Sorry, bad input. "		; Error message to be used if decimal rounding input is less than 1 or
					 BYTE "Please re-run the "		; more than 4
					 BYTE "program and follow "
					 BYTE "the instructions "
					 BYTE "provided", 0

; Main program driver
.code
main PROC
	FINIT											; Initialize FPU
	mWrite "Enter a decimal value: "				; Prompt user for floating point value input
	CALL ReadFloat									; Read floating point value from user input
	CALL Crlf										; Insert newline for readability
	mWrite "The original number entered was "		; Write original input value to console
	CALL WriteFloat
	CALL Crlf										; Insert newline for readability
	CALL Crlf										; Insert newline for readability

	mWrite "Enter a value to round to between 1 and 4: "

	CALL ReadFloat									; Prompt user for decimal place to round val to
	CALL Crlf										; Insert newline for readability
	FCOM first										; Compare to 1
	FNSTSW AX										; Move status word into AX
	SAHF											; Copy AH into EFLAGS
	JB ELSE_STATEMENT								; Jump to else statement if less than 1
	JE IF_ONE										; Jump to first conditional branch if input is 1
	FCOM second										; Compare to 2
	FNSTSW AX										; Move status word into AX
	SAHF											; Copy AH into EFLAGS
	JE IF_TWO										; Jump to first conditional branch if input is 2
	FCOM third										; Compare to 3
	FNSTSW AX										; Move status word into AX
	SAHF											; Copy AH into EFLAGS
	JE IF_THREE										; Jump to first conditional branch if input is 3
	FCOM fourth										; Compare to 4
	FNSTSW AX										; Move status word into AX
	SAHF											; Copy AH into EFLAGS
	JA ELSE_STATEMENT								; Jump to else statement if greater than 4
	JE IF_FOUR										; Jump to first conditional branch if input is 4

;**************************;
; CONDITIONAL BRANCHES	   ;
;**************************;
IF_ONE:
	MOV EDI, tens									; Next few lines use EDI as temp register to move
	MOV tmp, EDI									; proper values into variables needed for main proc call
	MOV EDI, tens_counter
	MOV counter, EDI
	FSTP ST(0)										; Logically pop comparison value from FPU stack
	MOV EBX, tens
	FLD floating_tens								; Load proper value for main proc call calculations
	mWrite "The new rounded precision value is "	; Write rounded decimal to console
	CALL displayFloat								; PRIMARY FUNCTION CALL
	CALL Crlf										; Insert newline for readability
	CALL Crlf										; Insert newline for readability
	INVOKE ExitProcess, 0							; Return 0, exit success

IF_TWO:
	MOV EDI, hundreds								; Next few lines use EDI as temp register to move
	MOV tmp, EDI									; proper values into variables needed for main proc call
	MOV EDI, hundreds_counter
	MOV counter, EDI
	FSTP ST(0)										; Logically pop comparison value from FPU stack
	MOV EBX, hundreds
	FLD floating_hundreds							; Load proper value for main proc call calculations
	mWrite "The new rounded precision value is "	; Write rounded decimal to console
	CALL displayFloat								; PRIMARY FUNCTION CALL
	CALL Crlf										; Insert newline for readability
	CALL Crlf										; Insert newline for readability
	INVOKE ExitProcess, 0							; Return 0, exit success

IF_THREE:
	MOV EDI, thousands								; Next few lines use EDI as temp register to move
	MOV tmp, EDI									; proper values into variables needed for main proc call
	MOV EDI, thousands_counter
	MOV counter, EDI
	FSTP ST(0)										; Logically pop comparison value from FPU stack
	MOV EBX, thousands
	FLD floating_thousands							; Load proper value for main proc call calculations
	mWrite "The new rounded precision value is "	; Write rounded decimal to console
	CALL displayFloat								; PRIMARY FUNCTION CALL
	CALL Crlf										; Insert newline for readability
	CALL Crlf										; Insert newline for readability
	INVOKE ExitProcess, 0							; Return 0, exit success

IF_FOUR:
	MOV EDI, ten_thousands							; Next few lines use EDI as temp register to move
	MOV tmp, EDI									; proper values into variables needed for main proc call
	MOV EDI, ten_thousands_counter
	MOV counter, EDI
	FSTP ST(0)										; Logically pop comparison value from FPU stack
	MOV EBX, ten_thousands
	FLD floating_ten_thousands						; Load proper value for main proc call calculations
	mWrite "The new rounded precision value is "	; Write rounded decimal to console
	CALL displayFloat								; PRIMARY FUNCTION CALL
	CALL Crlf										; Insert newline for readability
	CALL Crlf										; Insert newline for readability
	INVOKE ExitProcess, 0							; Return 0, exit success

ELSE_STATEMENT:										; Logical else conditional branch statement
	MOV EDX, OFFSET else_conditional				; WriteString uses EDX register for str to read from
	CALL WriteString								; Write error message to console
	CALL Crlf										; Insert newline for readability
	INVOKE ExitProcess, 0							; Return 0, exit success

main ENDP											; Program end

;**********************************************************************************************************************;
; Function: Displays floating point vals in decimal notation														   ;
;																													   ;
; Return: Integer val, followed by a dot ('.'), and then the decimal section digit by digit,						   ;
;		  successfully representing a human-friendly decimal notation of the val inserted as input from the user	   ;
;																													   ;
; Procedure: First, we calculate the integer part of the floating-point number and display it on the screen using	   ;
;			 the WriteInt proc. We then multiply the floating-point number by 1000 and convert it to an integer,	   ;
;			 which gives the number of thousandths in the decimal part. It then displays a dot '.' on the screen	   ;
;			 to represent decimal notation. Next, the proc subtracts the integer part and the thousandths from the	   ;
;			 floating-point number to get the remaining decimal part. It then extracts the digits of the decimal part, ;
;	         starting from the tenths place and moving to the right, using repeated divisions by 10. For each digit,   ;
;			 the proc pushes it onto the floating-point register stack and continues to the next digit until it has	   ;
;			 extracted all three decimal digits. Finally, it pops each digit off the register stack one by one and	   ;
;			 displays each on the screen using the WriteDec proc													   ;
;**********************************************************************************************************************;
displayFloat PROC

    FMUL ST(0), ST(1)
    FIST dwordtmp
    MOV EAX, dwordtmp
    MOV EDX, EAX
    PUSH EDX
    CDQ
	IDIV EBX
	CALL WriteInt
	PUSH EAX
	MOV AL, '.'
	CALL WriteChar
	POP EAX
	IMUL EAX, tmp
    POP EDX
	SUB EDX, EAX
	MOV EAX, EDX
	MOV EBX, 10
	MOV ECX, counter
	LOOP1:
		MOV ESI, ECX
		CDQ
		IDIV EBX
		PUSH EDX
	loop LOOP1

	MOV ECX, counter

	LOOP2:
		POP EDX
		MOV EAX, EDX
		CALL WriteDec
	loop LOOP2

    RET
displayfloat ENDP

END main

;***************************************************************************************;
;							displayFloat FUNCTION CITATION								;
;						   ********************************								;
;																						;
; Shahmeerather. �Shahmeerather/Assembly-MASM-8086-Display-Float-in-Decimal.�			;
;				  GitHub, 1 Apr. 2023,													;
;				  github.com/shahmeerather/assembly-masm-8086-display-float-in-decimal. ;
;																						;
;***************************************************************************************;
