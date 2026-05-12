;****************************************************************;
; Program Name: Encryption Practice 							 ;
; Program Description: We will write a proc that performs a		 ;
;					   simple encryption algorithm by rotating	 ;
;					   each plaintext byte a varying number of	 ;
;					   positions in different directions		 ;
; Program Author: Parke											 ;
; Creation Date: 04/27/2024										 ;
; Revisions: N/A												 ;
; Date Last Modified: 04/27/2024								 ;
;****************************************************************;

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
	key BYTE -2, 4, 1, 0, -3, 5, 2, -4, -4, 6			; Array of rotation vals to iterate through for plaintext rotations
	encrypt_me BYTE "Hello There My Friend!", 0			; Plaintext var to encrypt, change to any string you want to encrypt
	encrypt_message BYTE "Original String: ", 0			; Message for console output

	encrypted_string_message BYTE "Encrypted "			; Message for console output
							 BYTE "String: ", 0	

	counter BYTE 0										; Arbitrary counter val to count through each 'key' rotation val and reset
														; after each iteration through 'key' array

	exit_counter BYTE 0									; Exit loop counter after full origin plaintext str is encrypted. Can't use ECX,
														; as CL will be used for bit rotations

.code
main PROC
	MOV EDX, OFFSET encrypt_message						; WriteString uses EDX as register to read from
	CALL WriteString
	MOV EDX, OFFSET encrypt_me							; WriteString uses EDX as register to read from
	CALL WriteString
	CALL Crlf											; Insert newline for readability
	CALL Crlf											; Insert newline for readability
	MOV EDX, OFFSET encrypted_string_message			; WriteString uses EDX as register to read from
	CALL WriteString
	MOV exit_counter, LENGTHOF encrypt_me - 2			; Exit loop after full origin plaintext str is encrypted. Can't use ECX, as CL will be used for bit rotations
	CALL ENCRYPT_INPUT									; Encrypt_Input proc call
	MOV EDX, OFFSET encrypt_me							; WriteString uses EDX as register to read from
	CALL WriteString
	CALL Crlf											; Insert newline for readability
	CALL Crlf											; Insert newline for readability
	INVOKE ExitProcess,0								; Return 0, exit success
main ENDP

;*****************************************************************;
; Function: Encrypt_Input										  ;
; Return: Encrypted String										  ;
; Procedure: Loops through each char in plaintext string and	  ;
;			 rotates each char by val in index of 'key' array.	  ;
;			 'Key' array resets to beginning index after all 10	  ;
;			 vals have been looped through & plaintext isn't done ;
;			 encrypting yet										  ;
;*****************************************************************;
ENCRYPT_INPUT PROC
	MOV EBX, OFFSET encrypt_me							; Use EBX register as ptr to origin plaintext str
	XOR ECX, ECX										; Clear full ECX register
	MOV CL, key[0]										; Move first encryption shift val into CL

L1:														; Primary proc loop

	CMP CL, 0											; If shift val is negative, jump to left rotate instructions
	JL negative
	CMP CL, 0											; If shift is val positive, jump to right rotate instructions
	JG positive
	CMP CL, 0											; Else if shift val is 0, simply continue
	JE zero

negative:												; Label to rotate bits to the left
	ROL BYTE PTR[EBX], CL
	JMP ADJUST

positive:												; Label to rotate bits to the right
	ROR BYTE PTR[EBX], CL
	JMP ADJUST

zero:													; If zero, simply continue

ADJUST:													; Label to re-adjust some vals before looping back
	CMP exit_counter, 0									; If exit_counter == 0, then full origin plaintext str has been encrypted. Proc can ret
	JE EXIT_PROCESS

	CMP counter, 0										; The next 10 comparisons are for grabbing each index from our key array and re-setting to first
	JE ZERO_INDEX										; val again when we've looped through all 10 vals before origin str is done encrypting
	CMP counter, 1										
	JE ONE												
	CMP counter, 2
	JE TWO
	CMP counter, 3
	JE THREE
	CMP counter, 4
	JE FOUR
	CMP counter, 5
	JE FIVE
	CMP counter, 6
	JE SIX
	CMP counter, 7
	JE SEVEN
	CMP counter, 8
	JE EIGHT
	CMP counter, 9
	JE NINE

ZERO_INDEX:												; Each label from here until end of code is self-explanatory, simply conditional branches geared
	MOV CL, key[1]										; towards selecting next rotation val in 'key' array and re-setting to first val in the case where
	INC counter											; 'key' array has been looped through but origin plaintext str is not done encrypting
	DEC exit_counter
	INC EBX
	JMP L1

ONE:													; Condition if 'key' array index needs to be 2
	MOV CL, key[2]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

TWO:													; Condition if 'key' array index needs to be 3
	MOV CL, key[3]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

THREE:													; Condition if 'key' array index needs to be 4
	MOV CL, key[4]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

FOUR:													; Condition if 'key' array index needs to be 5
	MOV CL, key[5]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

FIVE:													; Condition if 'key' array index needs to be 6
	MOV CL, key[6]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

SIX:													; Condition if 'key' array index needs to be 7
	MOV CL, key[7]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

SEVEN:													; Condition if 'key' array index needs to be 8
	MOV CL, key[8]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1
		
EIGHT:													; Condition if 'key' array index needs to be 9
	MOV CL, key[9]
	INC counter
	DEC exit_counter
	INC EBX
	JMP L1

NINE:													; Condition if 'key' array index is at final index in 'key' array and needs to
	MOV CL, key[0]										; loop back to first index
	MOV counter, 0
	DEC exit_counter
	INC EBX
	JMP L1

EXIT_PROCESS:											; Label to ret when full origin plaintext str is encrypted
	RET													; Return from proc

ENCRYPT_INPUT ENDP
END main												; Program exit
