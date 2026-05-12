;*****************************************************************;
; Program Name: Hangman											  ;
; Program Description: Simple game of the classic Hangman		  ;
; Program Author: Parke											  ;
; Creation Date: 09/24/2024										  ;
; Revisions: N/A												  ;
; Date Last Modified: 09/25/2024								  ;
;*****************************************************************;

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
																	; If ya want it pretty, I'll make it pretty! ;)
	hangman_banner1 BYTE "888", 0                                                           
	hangman_banner2 BYTE "888", 0                                                           
	hangman_banner3 BYTE "888", 0                                                           
	hangman_banner4 BYTE "88888b.  8888b. 88888b.  .d88b. 88888b.d88b.  8888b. 88888b.", 0 
	hangman_banner5 BYTE "888 -88b    -88b888 -88bd88P-88b888 -888 -88b    -88b888 -88b", 0 
	hangman_banner6 BYTE "888  888.d888888888  888888  888888  888  888.d888888888  888", 0 
	hangman_banner7 BYTE "888  888888  888888  888Y88b 888888  888  888888  888888  888", 0 
	hangman_banner8 BYTE "888  888-Y888888888  888 -Y88888888  888  888-Y888888888  888", 0 
	hangman_banner9 BYTE "				888", 0                              
	hangman_banner10 BYTE "			Y8b d88P", 0                              
	hangman_banner11 BYTE "			-Y88P-", 0   

	user_prompt BYTE "GUESS A LETTER: ", 0							; Prompt for letter guesses from user
	lose_prompt BYTE "SORRY. YOU LOST!", 0							; Losing console message

	win_prompt BYTE "CORRECT!!! YOU AVOIDED "						; Winning console message
			   BYTE "GETTING HUNG. CONGRATULATIONS :)", 0

	prettify_output BYTE "*****************", 0						; Prettify output :)

	prettify_output2 BYTE "***********************************"		; Prettify output :)
					 BYTE "********************", 0	

	correct BYTE "YOUR LETTER IS IN THE WORD! KEEP GOING!", 0		; Correct letter guess message

	str0 BYTE "LOCKED", 0											; Six total 6-lettered words to be used for guessing
	str1 BYTE "ASPECT", 0
	str2 BYTE "BROWSE", 0
	str3 BYTE "FRIEND", 0
	str4 BYTE "FINDER", 0
	str5 BYTE "FILTER", 0
	str6 BYTE "ADVICE", 0
	str7 BYTE "LOCKET", 0
	str8 BYTE "SQUAWK", 0
	str9 BYTE "YACHTS", 0

	space_out BYTE "                                           ", 0 ; Sets vars apart in memory to ensure we dont run into other address space

	this_was_the_word_msg BYTE "THE WORD WAS * ", 0					; Final console output messages
	this_was_the_word_msg2 BYTE " *", 0

	space_out2 BYTE "                                          ", 0 ; Sets vars apart in memory to ensure we dont run into other address space

	hangman_part0 BYTE "HEAD", 0									; Hangman parts
	hangman_part1 BYTE "BODY", 0
	hangman_part2 BYTE "LEFT_ARM", 0
	hangman_part3 BYTE "RIGHT_ARM", 0
	hangman_part4 BYTE "LEFT_LEG", 0
	hangman_part5 BYTE "RIGHT_LEG", 0

	word_to_guess DWORD 0											; Var to store word to guess for each round for final console output
	num_guesses DWORD 6												; Counter to keep track of how many times user has guessed
	guess_word BYTE 7 DUP(0)										; String var to hold each char user guesses in game	
	hangman_part DWORD 0											; Corresponds to which hangman part to output
	rerun_buffer BYTE 3 DUP(0)										; Var to hold user input when prompted to repeat program or not

	space_out3 BYTE "                                          ", 0 ; Sets vars apart in memory to ensure we dont run into other address space

																	; Re-run program prompt
	repeat_program BYTE "RE-RUN PROGRAM? ('yes' TO CONTINUE, ANY OTHER KEY TO"			
				   BYTE " QUIT): ", 0

	losing_message1 BYTE " ___________.._______", 0					; ASCCI art for the extra credit win?? Perhaps... ;) 
	losing_message2 BYTE "| .__________))______|", 0
	losing_message3 BYTE "| | / /      ||", 0
	losing_message4 BYTE "| |/ /       ||", 0
	losing_message5 BYTE "| | /        ||.-''.", 0
	losing_message6 BYTE "| |/         |/  _  \", 0
	losing_message7 BYTE "| |          ||  `/,|", 0
	losing_message8 BYTE "| |          (\\`_.'", 0
	losing_message9 BYTE "| |         .-`--'.", 0
	losing_message10 BYTE "| |        /Y . . Y\", 0
	losing_message11 BYTE "| |       // |   | \\", 0
	losing_message12 BYTE "| |      //  | . |  \\", 0
	losing_message13 BYTE "| |     ')   |   |   (`", 0
	losing_message14 BYTE "| |          ||'||", 0
	losing_message15 BYTE "| |          || ||", 0
	losing_message16 BYTE "| |          || ||", 0
	losing_message17 BYTE "| |          || ||", 0
	losing_message18 BYTE "| |         / | | \", 0
	losing_message19 BYTE "----------|_`-' `-' |---|", 0
	losing_message20 BYTE "|-|-------\ \       --|-|", 0
	losing_message21 BYTE "| |        \ \        | |", 0
	losing_message22 BYTE ": :         \ \       : :", 0
	losing_message23 BYTE ". .          `'       . .", 0

;*******************************************************************;
; Function: Main program driver, displays a nice game banner then   ;
;			generates a random int between 0 and 9 and jumps to		;
;			proc from there that corresponds to random int index	;
;			in list of words to guess from							;
;																	;
; Return: None														;
;																	;
; Procedure: Move multiple messages into the EDX register & use the ;
;			 WriteStr Irvine32 library proc to print these all to   ;
;			 the console. Generate rand int with RandomRange proc   ;
;			 & jump to label that corresponds to that rand ints		;
;			 index in our list of words to guess from				;
;*******************************************************************;
.code
main PROC

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner6									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner7									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner8									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner9									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner10								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET hangman_banner11								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	CALL Randomize													; RandomRange seed
	MOV EAX, 10														; RandomRange proc produces rand int in range of 0 to 'n' - 1, where 'n' is passed in the EAX register
	CALL RandomRange												; RandomRange proc call

	CMP EAX, 0														; Next 20 lines simply jump to the label that corresponds to word that was randomly chosen from list
	JE STR_0
	CMP EAX, 1
	JE STR_1
	CMP EAX, 2
	JE STR_2
	CMP EAX, 3
	JE STR_3
	CMP EAX, 4
	JE STR_4
	CMP EAX, 5
	JE STR_5
	CMP EAX, 6
	JE STR_6
	CMP EAX, 7
	JE STR_7
	CMP EAX, 8
	JE STR_8
	CMP EAX, 9
	JE STR_9


STR_0:
	
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_0_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT1
	JMP PASS1														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT1:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val

PASS1:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND1													; Quit if letter not found & jump to display proper hangman part
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 76														; Next 18 lines simply check which letter in str0 user guessed correctly
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR0_L_LABEL
	MOV EBX, 79
	CMP EAX, EBX
	JE STR0_O_LABEL
	MOV EBX, 67
	CMP EAX, EBX
	JE STR0_C_LABEL
	MOV EBX, 75
	CMP EAX, EBX
	JE STR0_K_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR0_E_LABEL
	MOV EBX, 68
	CMP EAX, EBX
	JE STR0_D_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR0_L_LABEL:

	MOV [ESI], AL													; If user input == 'L', move into proper spot in 'guess_word' var & continue on
	JMP PASS2

STR0_O_LABEL:

	INC ESI															; If user input == 'O', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS2

STR0_C_LABEL:
	
	ADD ESI, 2														; If user input == 'C', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS2

STR0_K_LABEL:

	ADD ESI, 3														; If user input == 'K', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS2

STR0_E_LABEL:

	ADD ESI, 4														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS2

STR0_D_LABEL:

	ADD ESI, 5														; If user input == 'D', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS2:

	INVOKE Str_compare, ADDR str0, ADDR guess_word					; Is 'guess_word' == str0 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND1:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR0_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR0_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR0_HANGMAN_2
	CMP hangman_part, 3
	JE STR0_HANGMAN_3
	CMP hangman_part, 4
	JE STR0_HANGMAN_4
	CMP hangman_part, 5
	JE STR0_HANGMAN_5

STR0_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

STR0_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

STR0_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

STR0_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

STR0_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete

STR0_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str0											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_0_L1													; Loop until 'str0' & 'guess_word' are equal or hangman is complete


STR_1:

	MOV word_to_guess, 1											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_1_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT2
	JMP PASS3														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT2:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS3:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND2													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 65														; Next 18 lines simply check which letter in str1 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR1_A_LABEL
	MOV EBX, 83
	CMP EAX, EBX
	JE STR1_S_LABEL
	MOV EBX, 80
	CMP EAX, EBX
	JE STR1_P_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR1_E_LABEL
	MOV EBX, 67
	CMP EAX, EBX
	JE STR1_C_LABEL
	MOV EBX, 84
	CMP EAX, EBX
	JE STR1_T_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR1_A_LABEL:

	MOV [ESI], AL													; If user input == 'A', move into proper spot in 'guess_word' var & continue on
	JMP PASS4

STR1_S_LABEL:

	INC ESI															; If user input == 'S', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS4

STR1_P_LABEL:
	
	ADD ESI, 2														; If user input == 'P', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS4

STR1_E_LABEL:

	ADD ESI, 3														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS4

STR1_C_LABEL:

	ADD ESI, 4														; If user input == 'C', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS4

STR1_T_LABEL:

	ADD ESI, 5														; If user input == 'T', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS4:

	INVOKE Str_compare, ADDR str1, ADDR guess_word					; Is 'guess_word' == str1 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND2:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR1_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR1_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR1_HANGMAN_2
	CMP hangman_part, 3
	JE STR1_HANGMAN_3
	CMP hangman_part, 4
	JE STR1_HANGMAN_4
	CMP hangman_part, 5
	JE STR1_HANGMAN_5

STR1_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

STR1_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

STR1_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

STR1_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

STR1_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete

STR1_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str1											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_1_L1													; Loop until 'str1' & 'guess_word' are equal or hangman is complete


STR_2:

	MOV word_to_guess, 2											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_2_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT3
	JMP PASS5														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT3:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS5:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND3													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 66														; Next 18 lines simply check which letter in str2 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR2_B_LABEL
	MOV EBX, 82
	CMP EAX, EBX
	JE STR2_R_LABEL
	MOV EBX, 79
	CMP EAX, EBX
	JE STR2_O_LABEL
	MOV EBX, 87
	CMP EAX, EBX
	JE STR2_W_LABEL
	MOV EBX, 83
	CMP EAX, EBX
	JE STR2_S_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR2_E_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR2_B_LABEL:

	MOV [ESI], AL													; If user input == 'B', move into proper spot in 'guess_word' var & continue on
	JMP PASS6

STR2_R_LABEL:

	INC ESI															; If user input == 'R', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS6

STR2_O_LABEL:
	
	ADD ESI, 2														; If user input == 'O', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS6

STR2_W_LABEL:

	ADD ESI, 3														; If user input == 'W', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS6

STR2_S_LABEL:

	ADD ESI, 4														; If user input == 'S', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS6

STR2_E_LABEL:

	ADD ESI, 5														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS6:

	INVOKE Str_compare, ADDR str2, ADDR guess_word					; Is 'guess_word' == str2 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND3:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR2_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR2_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR2_HANGMAN_2
	CMP hangman_part, 3
	JE STR2_HANGMAN_3
	CMP hangman_part, 4
	JE STR2_HANGMAN_4
	CMP hangman_part, 5
	JE STR2_HANGMAN_5

STR2_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

STR2_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

STR2_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

STR2_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

STR2_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete

STR2_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str2											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_2_L1													; Loop until 'str2' & 'guess_word' are equal or hangman is complete


STR_3:

	MOV word_to_guess, 3											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_3_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT4
	JMP PASS7														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT4:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS7:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND4													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 70														; Next 18 lines simply check which letter in str3 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR3_F_LABEL
	MOV EBX, 82
	CMP EAX, EBX
	JE STR3_R_LABEL
	MOV EBX, 73
	CMP EAX, EBX
	JE STR3_I_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR3_E_LABEL
	MOV EBX, 78
	CMP EAX, EBX
	JE STR3_N_LABEL
	MOV EBX, 68
	CMP EAX, EBX
	JE STR3_D_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR3_F_LABEL:

	MOV [ESI], AL													; If user input == 'F', move into proper spot in 'guess_word' var & continue on
	JMP PASS8

STR3_R_LABEL:

	INC ESI															; If user input == 'R', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS8

STR3_I_LABEL:
	
	ADD ESI, 2														; If user input == 'I', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS8

STR3_E_LABEL:

	ADD ESI, 3														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS8

STR3_N_LABEL:

	ADD ESI, 4														; If user input == 'N', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS8

STR3_D_LABEL:

	ADD ESI, 5														; If user input == 'D', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS8:

	INVOKE Str_compare, ADDR str3, ADDR guess_word					; Is 'guess_word' == str3 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND4:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR3_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR3_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR3_HANGMAN_2
	CMP hangman_part, 3
	JE STR3_HANGMAN_3
	CMP hangman_part, 4
	JE STR3_HANGMAN_4
	CMP hangman_part, 5
	JE STR3_HANGMAN_5

STR3_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

STR3_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

STR3_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

STR3_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

STR3_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete

STR3_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str3											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_3_L1													; Loop until 'str3' & 'guess_word' are equal or hangman is complete


STR_4:

	MOV word_to_guess, 4											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_4_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT5
	JMP PASS9														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT5:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS9:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND5													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 70														; Next 18 lines simply check which letter in str4 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR4_F_LABEL
	MOV EBX, 73
	CMP EAX, EBX
	JE STR4_I_LABEL
	MOV EBX, 78
	CMP EAX, EBX
	JE STR4_N_LABEL
	MOV EBX, 68
	CMP EAX, EBX
	JE STR4_D_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR4_E_LABEL
	MOV EBX, 82
	CMP EAX, EBX
	JE STR4_R_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR4_F_LABEL:

	MOV [ESI], AL													; If user input == 'F', move into proper spot in 'guess_word' var & continue on
	JMP PASS10

STR4_I_LABEL:

	INC ESI															; If user input == 'I', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS10

STR4_N_LABEL:
	
	ADD ESI, 2														; If user input == 'N', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS10

STR4_D_LABEL:

	ADD ESI, 3														; If user input == 'D', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS10

STR4_E_LABEL:

	ADD ESI, 4														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS10

STR4_R_LABEL:

	ADD ESI, 5														; If user input == 'R', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS10:

	INVOKE Str_compare, ADDR str4, ADDR guess_word					; Is 'guess_word' == str4 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND5:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR4_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR4_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR4_HANGMAN_2
	CMP hangman_part, 3
	JE STR4_HANGMAN_3
	CMP hangman_part, 4
	JE STR4_HANGMAN_4
	CMP hangman_part, 5
	JE STR4_HANGMAN_5

STR4_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

STR4_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

STR4_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

STR4_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

STR4_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete

STR4_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str4											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_4_L1													; Loop until 'str4' & 'guess_word' are equal or hangman is complete


STR_5:

	MOV word_to_guess, 5											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_5_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT6
	JMP PASS11														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT6:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS11:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND6													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 70														; Next 18 lines simply check which letter in str5 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR5_F_LABEL
	MOV EBX, 73
	CMP EAX, EBX
	JE STR5_I_LABEL
	MOV EBX, 76
	CMP EAX, EBX
	JE STR5_L_LABEL
	MOV EBX, 84
	CMP EAX, EBX
	JE STR5_T_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR5_E_LABEL
	MOV EBX, 82
	CMP EAX, EBX
	JE STR5_R_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR5_F_LABEL:

	MOV [ESI], AL													; If user input == 'F', move into proper spot in 'guess_word' var & continue on
	JMP PASS12

STR5_I_LABEL:

	INC ESI															; If user input == 'I', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS12

STR5_L_LABEL:
	
	ADD ESI, 2														; If user input == 'L', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS12

STR5_T_LABEL:

	ADD ESI, 3														; If user input == 'T', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS12

STR5_E_LABEL:

	ADD ESI, 4														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS12

STR5_R_LABEL:

	ADD ESI, 5														; If user input == 'R', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS12:

	INVOKE Str_compare, ADDR str5, ADDR guess_word					; Is 'guess_word' == str5 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND6:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR5_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR5_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR5_HANGMAN_2
	CMP hangman_part, 3
	JE STR5_HANGMAN_3
	CMP hangman_part, 4
	JE STR5_HANGMAN_4
	CMP hangman_part, 5
	JE STR5_HANGMAN_5

STR5_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

STR5_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

STR5_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

STR5_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

STR5_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete

STR5_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str5											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_5_L1													; Loop until 'str5' & 'guess_word' are equal or hangman is complete


STR_6:

	MOV word_to_guess, 6											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_6_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT7
	JMP PASS13														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT7:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS13:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND7													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 65														; Next 18 lines simply check which letter in str6 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR6_A_LABEL
	MOV EBX, 68
	CMP EAX, EBX
	JE STR6_D_LABEL
	MOV EBX, 86
	CMP EAX, EBX
	JE STR6_V_LABEL
	MOV EBX, 73
	CMP EAX, EBX
	JE STR6_I_LABEL
	MOV EBX, 67
	CMP EAX, EBX
	JE STR6_C_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR6_E_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR6_A_LABEL:

	MOV [ESI], AL													; If user input == 'A', move into proper spot in 'guess_word' var & continue on
	JMP PASS14

STR6_D_LABEL:

	INC ESI															; If user input == 'D', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS14

STR6_V_LABEL:
	
	ADD ESI, 2														; If user input == 'V', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS14

STR6_I_LABEL:

	ADD ESI, 3														; If user input == 'I', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS14

STR6_C_LABEL:

	ADD ESI, 4														; If user input == 'C', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS14

STR6_E_LABEL:

	ADD ESI, 5														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS14:

	INVOKE Str_compare, ADDR str6, ADDR guess_word					; Is 'guess_word' == str6 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND7:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR6_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR6_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR6_HANGMAN_2
	CMP hangman_part, 3
	JE STR6_HANGMAN_3
	CMP hangman_part, 4
	JE STR6_HANGMAN_4
	CMP hangman_part, 5
	JE STR6_HANGMAN_5

STR6_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

STR6_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

STR6_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

STR6_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

STR6_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete

STR6_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str6											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_6_L1													; Loop until 'str6' & 'guess_word' are equal or hangman is complete


STR_7:

	MOV word_to_guess, 7											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_7_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT8
	JMP PASS15														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT8:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS15:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND8													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 76														; Next 18 lines simply check which letter in str7 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR7_L_LABEL
	MOV EBX, 79
	CMP EAX, EBX
	JE STR7_O_LABEL
	MOV EBX, 67
	CMP EAX, EBX
	JE STR7_C_LABEL
	MOV EBX, 75
	CMP EAX, EBX
	JE STR7_K_LABEL
	MOV EBX, 69
	CMP EAX, EBX
	JE STR7_E_LABEL
	MOV EBX, 84
	CMP EAX, EBX
	JE STR7_T_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR7_L_LABEL:

	MOV [ESI], AL													; If user input == 'L', move into proper spot in 'guess_word' var & continue on
	JMP PASS16

STR7_O_LABEL:

	INC ESI															; If user input == 'O', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS16

STR7_C_LABEL:
	
	ADD ESI, 2														; If user input == 'C', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS16

STR7_K_LABEL:

	ADD ESI, 3														; If user input == 'K', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS16

STR7_E_LABEL:

	ADD ESI, 4														; If user input == 'E', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS16

STR7_T_LABEL:

	ADD ESI, 5														; If user input == 'T', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS16:

	INVOKE Str_compare, ADDR str7, ADDR guess_word					; Is 'guess_word' == str7 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND8:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR7_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR7_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR7_HANGMAN_2
	CMP hangman_part, 3
	JE STR7_HANGMAN_3
	CMP hangman_part, 4
	JE STR7_HANGMAN_4
	CMP hangman_part, 5
	JE STR7_HANGMAN_5

STR7_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

STR7_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

STR7_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

STR7_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

STR7_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete

STR7_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str7											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_7_L1													; Loop until 'str7' & 'guess_word' are equal or hangman is complete


STR_8:

	MOV word_to_guess, 8											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_8_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT9
	JMP PASS17														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT9:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS17:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND9													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 83														; Next 18 lines simply check which letter in str8 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR8_S_LABEL
	MOV EBX, 81
	CMP EAX, EBX
	JE STR8_Q_LABEL
	MOV EBX, 85
	CMP EAX, EBX
	JE STR8_U_LABEL
	MOV EBX, 65
	CMP EAX, EBX
	JE STR8_A_LABEL
	MOV EBX, 87
	CMP EAX, EBX
	JE STR8_W_LABEL
	MOV EBX, 75
	CMP EAX, EBX
	JE STR8_K_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR8_S_LABEL:

	MOV [ESI], AL													; If user input == 'S', move into proper spot in 'guess_word' var & continue on
	JMP PASS18

STR8_Q_LABEL:

	INC ESI															; If user input == 'Q', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS18

STR8_U_LABEL:
	
	ADD ESI, 2														; If user input == 'U', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS18

STR8_A_LABEL:

	ADD ESI, 3														; If user input == 'A', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS18

STR8_W_LABEL:

	ADD ESI, 4														; If user input == 'W', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS18

STR8_K_LABEL:

	ADD ESI, 5														; If user input == 'K', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS18:

	INVOKE Str_compare, ADDR str8, ADDR guess_word					; Is 'guess_word' == str8 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND9:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR8_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR8_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR8_HANGMAN_2
	CMP hangman_part, 3
	JE STR8_HANGMAN_3
	CMP hangman_part, 4
	JE STR8_HANGMAN_4
	CMP hangman_part, 5
	JE STR8_HANGMAN_5

STR8_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

STR8_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

STR8_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

STR8_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

STR8_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete

STR8_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str8											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_8_L1													; Loop until 'str8' & 'guess_word' are equal or hangman is complete


STR_9:

	MOV word_to_guess, 9											; This var will be an int from 0-9 & will tell us which 'word_to_guess' it was in final output
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	MOV ESI, OFFSET guess_word										; Set ESI to point to empty string we will fill with user char guesses

STR_9_L1:

	MOV EDX, OFFSET user_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadChar													; ReadChar proc call, user first letter guess

	SUB AH, AH														; ReadChar stores keystroke inside AL, want to clear AH for easier processing, otherwise
																	; AH will hold junk val leftover from the ReadChar processing 

	CMP AL, 97														; If guess char is lowercase, convert to uppercase
	JAE U_CASE_CONVERT10
	JMP PASS19														; Do not convert to uppercase if uppercase was already entered

U_CASE_CONVERT10:
	
	SUB AL, 32														; Convert lowercase to uppercase by subtracting 32 to get uppercase ASCII val												

PASS19:

	MOV ECX, 6														; Set str len as search count
	CLD																; Direction = Forward
	REPNE SCASB														; Repeat while letter is not found
	JNZ NOT_FOUND10													; Quit if letter not found
	DEC EDI															; Letter found, back up EDI as it will point 1 position past matching char

	MOV EBX, 89														; Next 18 lines simply check which letter in str9 user guessed correctly													
	CMP EAX, EBX													; & jumps to the corresponding label
	JE STR9_Y_LABEL
	MOV EBX, 65
	CMP EAX, EBX
	JE STR9_A_LABEL
	MOV EBX, 67
	CMP EAX, EBX
	JE STR9_C_LABEL
	MOV EBX, 72
	CMP EAX, EBX
	JE STR9_H_LABEL
	MOV EBX, 84
	CMP EAX, EBX
	JE STR9_T_LABEL
	MOV EBX, 83
	CMP EAX, EBX
	JE STR9_S_LABEL

	INVOKE ExitProcess, 0											; Return 0, program success

STR9_Y_LABEL:

	MOV [ESI], AL													; If user input == 'Y', move into proper spot in 'guess_word' var & continue on
	JMP PASS20

STR9_A_LABEL:

	INC ESI															; If user input == 'A', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	DEC ESI
	JMP PASS20

STR9_C_LABEL:
	
	ADD ESI, 2														; If user input == 'C', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 2
	JMP PASS20

STR9_H_LABEL:

	ADD ESI, 3														; If user input == 'H', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 3
	JMP PASS20

STR9_T_LABEL:

	ADD ESI, 4														; If user input == 'T', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 4
	JMP PASS20

STR9_S_LABEL:

	ADD ESI, 5														; If user input == 'S', move into proper spot in 'guess_word' var & continue on
	MOV [ESI], AL
	SUB ESI, 5

PASS20:

	INVOKE Str_compare, ADDR str9, ADDR guess_word					; Is 'guess_word' == str9 ?
	JE WIN_PROCESS													; Jump to congratulatory message if so
	CALL Crlf														; Insert newline for readability													
	MOV EDX, OFFSET correct											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

	INVOKE ExitProcess, 0											; Return 0, program success

NOT_FOUND10:

	CMP hangman_part, 0												; 'hangman_part' var simply used to display proper hangman part
	JE STR9_HANGMAN_0
	CMP hangman_part, 1												; 'hangman_part' is increased each loop through & will match whichever hangman body
	JE STR9_HANGMAN_1												; part user is currently on which corresponds to how many wrong guesses/strikes they have
	CMP hangman_part, 2
	JE STR9_HANGMAN_2
	CMP hangman_part, 3
	JE STR9_HANGMAN_3
	CMP hangman_part, 4
	JE STR9_HANGMAN_4
	CMP hangman_part, 5
	JE STR9_HANGMAN_5

STR9_HANGMAN_0:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on				
	MOV EDX, OFFSET hangman_part0									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Decrement guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

STR9_HANGMAN_1:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

STR9_HANGMAN_2:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

STR9_HANGMAN_3:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

STR9_HANGMAN_4:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

STR9_HANGMAN_5:

	CALL Crlf														; Insert newline for readability
	INC hangman_part												; Increased each loop through & will match whichever hangman body part user is on
	MOV EDX, OFFSET hangman_part5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	DEC num_guesses													; Increment guess counter

	CMP num_guesses, 0												; If user has guessed 6 times and str != str to guess
	JE EXIT_PROCESS													; display losing message & prompt user for program re-run

	CALL Crlf														; Insert newline for readability
	MOV EDI, OFFSET str9											; Point to str to guess corresponding to index in randomly generated int in start of program
	JMP STR_9_L1													; Loop until 'str9' & 'guess_word' are equal or hangman is complete

main ENDP

EXIT_PROCESS PROC

	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET lose_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET prettify_output									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET this_was_the_word_msg							; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call

	CMP word_to_guess, 0											; Next 20 lines simply put proper word to guess into EDX for WriteStr proc
	JE ZERO_CASE
	CMP word_to_guess, 1
	JE ONE_CASE
	CMP word_to_guess, 2
	JE TWO_CASE
	CMP word_to_guess, 3
	JE THREE_CASE
	CMP word_to_guess, 4
	JE FOUR_CASE
	CMP word_to_guess, 5
	JE FIVE_CASE
	CMP word_to_guess, 6
	JE SIX_CASE
	CMP word_to_guess, 7
	JE SEVEN_CASE
	CMP word_to_guess, 8
	JE EIGHT_CASE
	CMP word_to_guess, 9
	JE NINE_CASE

ZERO_CASE:															; If 'word_to_guess' was 0, print 'str0' to console

	MOV EDX, OFFSET str0											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

ONE_CASE:															; If 'word_to_guess' was 1, print 'str1' to console

	MOV EDX, OFFSET str1											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

TWO_CASE:															; If 'word_to_guess' was 2, print 'str2' to console

	MOV EDX, OFFSET str2											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

THREE_CASE:															; If 'word_to_guess' was 3, print 'str3' to console

	MOV EDX, OFFSET str3											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

FOUR_CASE:															; If 'word_to_guess' was 4, print 'str4' to console

	MOV EDX, OFFSET str4											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

FIVE_CASE:															; If 'word_to_guess' was 5, print 'str5' to console

	MOV EDX, OFFSET str5											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

SIX_CASE:															; If 'word_to_guess' was 6, print 'str6' to console

	MOV EDX, OFFSET str6											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

SEVEN_CASE:															; If 'word_to_guess' was 7, print 'str7' to console

	MOV EDX, OFFSET str7											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

EIGHT_CASE:															; If 'word_to_guess' was 8, print 'str8' to console

	MOV EDX, OFFSET str8											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

NINE_CASE:															; If 'word_to_guess' was 9, print 'str9' to console

	MOV EDX, OFFSET str9											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS21

PASS21:

	MOV EDX, OFFSET this_was_the_word_msg2							; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message1									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message2									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message3									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message4									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message5									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message6									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message7									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message8									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message9									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message10								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message11								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message12								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message13								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message14								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message15								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message16								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message17								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message18								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message19								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message20								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message21								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message22								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET losing_message23								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability

	MOV hangman_part, 0												; Next 4 lines simply reset vars/ptrs for program rerun
	MOV num_guesses, 6
	MOV EDI, OFFSET guess_word											
	MOV ECX, 6

RESET_LOOP:

	MOV EAX, 0														; Loop simply goes through 'guess_word' var and resets it to all 0's for program rerun
	MOV [EDI], EAX
	INC EDI
	LOOP RESET_LOOP

	MOV EDX, OFFSET repeat_program									; WriteStr proc uses EDX register as register to read from											
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET rerun_buffer									; ReadString uses EDX to point to buffer & ECX to specify # of chars user can enter - 1
	MOV ECX, 4
	CALL ReadString													; ReadStr proc call
	MOV EBX, OFFSET rerun_buffer									; Point to first letter in user input from re-run prompt
	MOV EAX, 7562617												; 4-byte val for 'y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]													; If first val in user input is 'y', jump to main to rerun program
	JE main
	MOV EAX, 5457241												; 4-byte val for 'Y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]													; If first val in user input is 'Y', jump to main to rerun program
	JE main

	INVOKE ExitProcess, 0											; Return 0, program success

EXIT_PROCESS ENDP

WIN_PROCESS PROC
	
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET win_prompt										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET prettify_output2								; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET this_was_the_word_msg							; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET word_to_guess									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call



	CMP word_to_guess, 0											; Next 20 lines simply put proper word to guess into EDX for WriteStr proc
	JE ZERO_CASE2
	CMP word_to_guess, 1
	JE ONE_CASE2
	CMP word_to_guess, 2
	JE TWO_CASE2
	CMP word_to_guess, 3
	JE THREE_CASE2
	CMP word_to_guess, 4
	JE FOUR_CASE2
	CMP word_to_guess, 5
	JE FIVE_CASE2
	CMP word_to_guess, 6
	JE SIX_CASE2
	CMP word_to_guess, 7
	JE SEVEN_CASE2
	CMP word_to_guess, 8
	JE EIGHT_CASE2
	CMP word_to_guess, 9
	JE NINE_CASE2

ZERO_CASE2:															; If 'word_to_guess' was 0, print 'str0' to console

	MOV EDX, OFFSET str0											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

ONE_CASE2:															; If 'word_to_guess' was 1, print 'str1' to console

	MOV EDX, OFFSET str1											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

TWO_CASE2:															; If 'word_to_guess' was 2, print 'str2' to console

	MOV EDX, OFFSET str2											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

THREE_CASE2:														; If 'word_to_guess' was 3, print 'str3' to console

	MOV EDX, OFFSET str3											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

FOUR_CASE2:															; If 'word_to_guess' was 4, print 'str4' to console

	MOV EDX, OFFSET str4											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

FIVE_CASE2:															; If 'word_to_guess' was 5, print 'str5' to console

	MOV EDX, OFFSET str5											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

SIX_CASE2:															; If 'word_to_guess' was 6, print 'str6' to console

	MOV EDX, OFFSET str6											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

SEVEN_CASE2:														; If 'word_to_guess' was 7, print 'str7' to console

	MOV EDX, OFFSET str7											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

EIGHT_CASE2:														; If 'word_to_guess' was 8, print 'str8' to console

	MOV EDX, OFFSET str8											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

NINE_CASE2:															; If 'word_to_guess' was 9, print 'str9' to console

	MOV EDX, OFFSET str9											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	JMP PASS22

PASS22:

	MOV EDX, OFFSET this_was_the_word_msg2							; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability

	MOV hangman_part, 0												; Next 4 lines simply reset vars/ptrs for program rerun
	MOV num_guesses, 6
	MOV EDI, OFFSET guess_word
	MOV ECX, 6

RESET_LOOP:

	MOV EAX, 0														; Loop simply goes through 'guess_word' var and resets it to all 0's for program rerun
	MOV [EDI], EAX
	INC EDI
	LOOP RESET_LOOP

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET repeat_program									; WriteStr proc uses EDX register as register to read from											
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET rerun_buffer									; ReadString uses EDX to point to buffer & ECX to specify # of chars user can enter - 1
	MOV ECX, 4
	CALL ReadString													; ReadStr proc call
	MOV EBX, OFFSET rerun_buffer									; Point to first letter in user input from re-run prompt
	MOV EAX, 7562617												; 4-byte val for 'y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]													; If first val in user input is 'y', jump to main to rerun program
	JE main
	MOV EAX, 5457241												; 4-byte val for 'Y' since we are dealing with 32-bit registers/vals
	CMP EAX, [EBX]													; If first val in user input is 'Y', jump to main to rerun program
	JE main

	INVOKE ExitProcess, 0											; Return 0, program success

WIN_PROCESS ENDP

END main															; Program end
