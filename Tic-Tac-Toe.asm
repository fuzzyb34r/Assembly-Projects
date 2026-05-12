;****************************************************************;
; Program Name: Tic-Tac-Toe										 ;
; Program Description: Plays a classic game of Tic-Tac-Toe		 ;
; Program Author: Parke											 ;
; Creation Date: 10/01/2024										 ;
; Revisions: N/A												 ;
; Date Last Modified: 10/02/2024								 ;
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

; Declared and initialized variables
.data
																	; Program intro banner 
	banner1 BYTE " ____  ____  ___     ____   __    ___     ____  _____  ____", 0 
	banner2 BYTE "(_  _)(_  _)/ __)___(_  _) /__\  / __)___(_  _)(  _  )( ___)", 0
	banner3 BYTE "  )(   _)(_( (__(___) )(  /(__)\( (__(___) )(   )(_)(  )__)", 0 
	banner4 BYTE " (__) (____)\___)    (__)(__)(__)\___)    (__) (_____)(____)", 0

	space_out1 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	row_split BYTE "-----+-----+------", 0							; Used to seperate board rows visually

	row1 BYTE  "  1  |  2  |  3  ", 0								; Tic-Tac-Toe board
	row2 BYTE  "  4  |  5  |  6  ", 0
	row3 BYTE  "  7  |  8  |  9  ", 0

	space_out2 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	welcome BYTE "WELCOME TO THE GAME OF TIC-TAC-TOE", 0			; Intro msg

	explain BYTE "BOARD NUMBERING IS AS FOLLOWS: PLAY "				; Game instructions
			BYTE "IN A CELL BY SELECTING THE CELL NUMBER", 0

	example BYTE "EXAMPLE: IF YOU WANTED TO PLAY CELL 3, SIMPLY "   ; Example prompt for end user
			BYTE "ENTER THE NUMBER 3", 0

	space_out3 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	cell BYTE ", CHOOSE CELL TO PLAY IN (1-9): ", 0					; Game prompt for end user

	player1_prompt BYTE "PLAYER1 NAME: ", 0							; Player 1 name prompt
	player2_prompt BYTE "PLAYER2 NAME: ", 0							; Player 2 name prompt

	player1_symbol BYTE "$", 0										; Player 1 symbol
	player2_symbol BYTE "@", 0										; Player 2 symbol

	space_out4 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	retry_prompt BYTE "SORRY, INPUT MUST BE BETWEEN 1 & 9, "		; Retry prompt if user enters value outside of 1-9 range 
				 BYTE "TRY AGAIN", 0

	player1_sym_msg BYTE "PLAYER 1 SYMBOL: ", 0						; Msgs for end users to show player 1 & 2s respective game symbols
	player2_sym_msg BYTE "PLAYER 2 SYMBOL: ", 0

	filled_slot BYTE "SLOT ALREADY FULL, TRY AGAIN", 0				; Msg to end user if they choose slot on board that is already filled

	congrats BYTE "CONGRATULATIONS ", 0								; Congratulatory msgs to display to user who wins
	congrats2 BYTE "! YOU ARE THE WINNER!!!", 0

	space_out5 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

																	; Re-run program prompt
	repeat_program BYTE "RE-RUN PROGRAM? ('yes' TO CONTINUE, ANY OTHER KEY TO"  
				   BYTE " QUIT): ", 0

	space_out6 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	draw_msg BYTE "LOOKS LIKE THE GAME IS A DRAW! NO MORE "			; Prompt for end user in case of a draw in the game
			 BYTE "MOVES AVAILABLE :(", 0

	prettify_output BYTE "*************************************"    ; To help make the draw output a bit more pretty :)
					BYTE "*********************", 0

	player1_name BYTE 50 DUP(0)										; Buffer to hold player 1 name
	player2_name BYTE 50 DUP(0)										; Buffer to hold player 2 name

	actual_board DWORD 9 DUP(0)										; Actual game board in memory, to check for wins easier

	player_turn BYTE 1												; Var to keep track of whose turn it is & which symbol to use

	rerun_buffer BYTE 3 DUP(0)										; Var to hold user input when prompted to repeat program or not

	draw_counter DWORD 0											; Var used to determine when draw has occurred
	
;*******************************************************************;
; Function: Main program driver									    ;
;																	;
; Return: None														;
;																	;
; Procedure: Displays opening instructions & banners, prompts both  ;
;			 users to enter their names, prompts for first move &	;
;			 begins to jump/loop to different labels/procs that		;
;			 handle the rest of the game							;
;*******************************************************************;
.code
main PROC
	
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner1											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner2											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner3											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner4											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET welcome											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET explain											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET example											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL display_board												; display_board proc call
	MOV EDX, OFFSET player1_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call

	MOV EDX, OFFSET player1_name									; ReadString uses EDX to point to buffer &
	MOV ECX, 50														; ECX to specify # of chars user can enter - 1

	CALL ReadString													; ReadStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET player2_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call

	MOV EDX, OFFSET player2_name									; ReadString uses EDX to point to buffer &
	MOV ECX, 50														; ECX to specify # of chars user can enter - 1

	CALL ReadString													; ReadStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET player1_sym_msg									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET player1_symbol									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET player2_sym_msg									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET player2_symbol									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability


FIRST_SLOT_FRESH_START:												

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME

PLAYER1_SET_NAME:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS

PLAYER2_SET_NAME:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FIRST_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY
	CMP EAX, 9
	JA RETRY
	JMP PASS2

RETRY:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIRST_SLOT_FRESH_START

PASS2:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL													; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL

FIRST_SYMBOL:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS3

SECOND_SYMBOL:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS3:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT_CHECK												; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

FIRST_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED
	JMP PASS4

SPOT_FILLED:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIRST_SLOT_FRESH_START

PASS4:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row1[2], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL

ADD_PLAYER_VAL:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIRST_SLOT_FRESH_START

SUB_PLAYER_VAL:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIRST_SLOT_FRESH_START



SECOND_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME2											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME2

PLAYER1_SET_NAME2:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS5

PLAYER2_SET_NAME2:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS5:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SECOND_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY2
	CMP EAX, 9
	JA RETRY2
	JMP PASS6

RETRY2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SECOND_SLOT_FRESH_START

PASS6:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 4														; Point to second element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL2												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL2

FIRST_SYMBOL2:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS7

SECOND_SYMBOL2:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS7:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT_CHECK
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

SECOND_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED2
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED2
	JMP PASS8

SPOT_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SECOND_SLOT_FRESH_START

PASS8:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row1[8], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL2												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL2

ADD_PLAYER_VAL2:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SECOND_SLOT_FRESH_START

SUB_PLAYER_VAL2:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SECOND_SLOT_FRESH_START



THIRD_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME3											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME3

PLAYER1_SET_NAME3:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS9

PLAYER2_SET_NAME3:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS9:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



THIRD_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY3
	CMP EAX, 9
	JA RETRY3
	JMP PASS10

RETRY3:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP THIRD_SLOT_FRESH_START

PASS10:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 8														; Point to third element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL3												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL3

FIRST_SYMBOL3:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS11

SECOND_SYMBOL3:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS11:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT_CHECK
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

THIRD_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED3
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED3
	JMP PASS12

SPOT_FILLED3:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP THIRD_SLOT_FRESH_START

PASS12:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row1[14], BL												; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL3												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL3

ADD_PLAYER_VAL3:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP THIRD_SLOT_FRESH_START

SUB_PLAYER_VAL3:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP THIRD_SLOT_FRESH_START



FOURTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME4											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME4

PLAYER1_SET_NAME4:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS13

PLAYER2_SET_NAME4:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS13:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FOURTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY4
	CMP EAX, 9
	JA RETRY4
	JMP PASS14

RETRY4:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FOURTH_SLOT_FRESH_START

PASS14:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 12														; Point to fourth element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL4												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL4

FIRST_SYMBOL4:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS15

SECOND_SYMBOL4:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS15:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT_CHECK
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

FOURTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED4
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED4
	JMP PASS16

SPOT_FILLED4:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FOURTH_SLOT_FRESH_START

PASS16:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row2[2], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL4												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL4

ADD_PLAYER_VAL4:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FOURTH_SLOT_FRESH_START

SUB_PLAYER_VAL4:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FOURTH_SLOT_FRESH_START



FIFTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME5											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME5

PLAYER1_SET_NAME5:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS17

PLAYER2_SET_NAME5:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS17:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FIFTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY5
	CMP EAX, 9
	JA RETRY5
	JMP PASS18

RETRY5:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIFTH_SLOT_FRESH_START

PASS18:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 16														; Point to fifth element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL5												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL5

FIRST_SYMBOL5:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS19

SECOND_SYMBOL5:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS19:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT_CHECK
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

FIFTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED5
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED5
	JMP PASS20

SPOT_FILLED5:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIFTH_SLOT_FRESH_START

PASS20:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row2[8], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL5												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL5

ADD_PLAYER_VAL5:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIFTH_SLOT_FRESH_START

SUB_PLAYER_VAL5:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIFTH_SLOT_FRESH_START



SIXTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME6											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME6

PLAYER1_SET_NAME6:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS21

PLAYER2_SET_NAME6:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS21:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SIXTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY6
	CMP EAX, 9
	JA RETRY6
	JMP PASS22

RETRY6:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SIXTH_SLOT_FRESH_START

PASS22:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 20														; Point to sixth element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL6												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL6

FIRST_SYMBOL6:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS23

SECOND_SYMBOL6:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS23:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT_CHECK
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

SIXTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED6
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED6
	JMP PASS24

SPOT_FILLED6:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SIXTH_SLOT_FRESH_START

PASS24:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row2[14], BL												; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL6												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL6

ADD_PLAYER_VAL6:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SIXTH_SLOT_FRESH_START

SUB_PLAYER_VAL6:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SIXTH_SLOT_FRESH_START



SEVENTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME7											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME7

PLAYER1_SET_NAME7:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS25

PLAYER2_SET_NAME7:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS25:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SEVENTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY7
	CMP EAX, 9
	JA RETRY7
	JMP PASS26

RETRY7:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SEVENTH_SLOT_FRESH_START

PASS26:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 24														; Point to seventh element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL7												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL7

FIRST_SYMBOL7:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS27

SECOND_SYMBOL7:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS27:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT_CHECK
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT

SEVENTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED7
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED7
	JMP PASS28

SPOT_FILLED7:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SEVENTH_SLOT_FRESH_START

PASS28:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row3[2], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL7												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL7

ADD_PLAYER_VAL7:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SEVENTH_SLOT_FRESH_START

SUB_PLAYER_VAL7:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SEVENTH_SLOT_FRESH_START



EIGHTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME8											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME8

PLAYER1_SET_NAME8:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS29

PLAYER2_SET_NAME8:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS29:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



EIGHTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY8
	CMP EAX, 9
	JA RETRY8
	JMP PASS30

RETRY8:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP EIGHTH_SLOT_FRESH_START

PASS30:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 28														; Point to eighth element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL8												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL8

FIRST_SYMBOL8:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS31

SECOND_SYMBOL8:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS31:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT_CHECK
	CMP EAX, 9
	JE NINTH_SLOT

EIGHTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED8
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED8
	JMP PASS32

SPOT_FILLED8:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP EIGHTH_SLOT_FRESH_START

PASS32:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row3[8], BL													; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL8												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL8

ADD_PLAYER_VAL8:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP EIGHTH_SLOT_FRESH_START

SUB_PLAYER_VAL8:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP EIGHTH_SLOT_FRESH_START



NINTH_SLOT_FRESH_START:

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE PLAYER1_SET_NAME9											; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE PLAYER2_SET_NAME9

PLAYER1_SET_NAME9:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	JMP PASS33

PLAYER2_SET_NAME9:

	MOV EDX, OFFSET player2_name									; WriteStr proc uses EDX as register to read from

PASS33:

	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET cell											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



NINTH_SLOT:

	CMP EAX, 1														; If input < 1 or input > 9, re-prompt user for valid value on board
	JB RETRY9
	CMP EAX, 9
	JA RETRY9
	JMP PASS34

RETRY9:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP NINTH_SLOT_FRESH_START

PASS34:

	MOV EDI, OFFSET actual_board									; Point to underlying game board in memory
	ADD EDI, 32														; Point to ninth element in board

	CMP player_turn, 1												; Next few lines simply determine whose turn it is & moves
	JE FIRST_SYMBOL9												; corresponding symbol into EBX register for further processing
	CMP player_turn, 2
	JE SECOND_SYMBOL9

FIRST_SYMBOL9:

	MOV EBX, 36														; If player 1 turn, move $ into EBX register
	JMP PASS35

SECOND_SYMBOL9:

	MOV EBX, 64														; If player 2 turn, move @ into EBX register

PASS35:

	CMP EAX, 1														; Next 18 lines simply check which slot user wants to fill
	JE FIRST_SLOT													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_SLOT
	CMP EAX, 3
	JE THIRD_SLOT
	CMP EAX, 4
	JE FOURTH_SLOT
	CMP EAX, 5
	JE FIFTH_SLOT
	CMP EAX, 6
	JE SIXTH_SLOT
	CMP EAX, 7
	JE SEVENTH_SLOT
	CMP EAX, 8
	JE EIGHTH_SLOT
	CMP EAX, 9
	JE NINTH_SLOT_CHECK

NINTH_SLOT_CHECK:

	MOV EAX, 36														; Next 5 lines simply check if slot is already filled or not
	CMP [EDI], EAX													
	JE SPOT_FILLED9
	MOV EAX, 64
	CMP [EDI], EAX
	JE SPOT_FILLED9
	JMP PASS36

SPOT_FILLED9:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_slot										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP NINTH_SLOT_FRESH_START

PASS36:

	MOV [EDI], EBX													; If slot not already taken, input corresponding users symbol into underlying game board slot
	MOV row3[14], BL												; Input corresponding users symbol into game board slot user sees as well

	CALL check_win													; Check if a player has won yet
	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 9
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL9												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL9

ADD_PLAYER_VAL9:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP NINTH_SLOT_FRESH_START

SUB_PLAYER_VAL9:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP NINTH_SLOT_FRESH_START



	INVOKE ExitProcess, 0											; Return 0, program success

main ENDP															; Program exit



;*******************************************************************;
; Function: This function checks each column/row on the game board  ;
;			to determine if one of the players has won the game		;
;																	;
; Return: Congratulatory msg to winner, if no winner returns none	;
;																	;
; Procedure: Loops through each possible winning combination in the ;
;			 game & determines if there is a winner yet or not		;
;*******************************************************************;
check_win PROC

R1_C1_CHECK:

	CMP row1[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C2_CHECK
	JMP R2_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R1_C2_CHECK:

	CMP row1[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C3_CHECK
	JMP R2_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R1_C3_CHECK:

	CMP row1[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE WINNER



R2_C1_CHECK:

	CMP row2[2], 36													; If 4 == player1s symbol, jmp to next row/column & check
	JE R2_C2_CHECK
	JMP R3_C1_CHECK													; Skip to next row/column if 4 != player1s symbol

R2_C2_CHECK:

	CMP row2[8], 36													; If 5 == player1s symbol, jmp to next row/column & check
	JE R2_C3_CHECK
	JMP R3_C1_CHECK													; Skip to next row/column if 5 != player1s symbol

R2_C3_CHECK:

	CMP row2[14], 36												; If 6 == player1s symbol, jmp to winning msg/process
	JE WINNER



R3_C1_CHECK:

	CMP row3[2], 36													; If 7 == player1s symbol, jmp to next row/column & check
	JE R3_C2_CHECK
	JMP C1_R1_CHECK													; Skip to next row/column if 7 != player1s symbol

R3_C2_CHECK:

	CMP row3[8], 36													; If 8 == player1s symbol, jmp to next row/column & check
	JE R3_C3_CHECK
	JMP C1_R1_CHECK													; Skip to next row/column if 8 != player1s symbol

R3_C3_CHECK:

	CMP row3[14], 36												; If 9 == player1s symbol, jmp to winning msg/process
	JE WINNER



C1_R1_CHECK:

	CMP row1[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE C1_R2_CHECK
	JMP C2_R1_CHECK													; Skip to next row/column if 1 != player1s symbol

C1_R2_CHECK:

	CMP row2[2], 36													; If 4 == player1s symbol, jmp to next row/column & check
	JE C1_R3_CHECK
	JMP C2_R1_CHECK													; Skip to next row/column if 4 != player1s symbol

C1_R3_CHECK:

	CMP row3[2], 36													; If 7 == player1s symbol, jmp to winning msg/process
	JE WINNER



C2_R1_CHECK:

	CMP row1[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE C2_R2_CHECK
	JMP C3_R1_CHECK													; Skip to next row/column if 2 != player1s symbol

C2_R2_CHECK:

	CMP row2[8], 36													; If 5 == player1s symbol, jmp to next row/column & check
	JE C2_R3_CHECK
	JMP C3_R1_CHECK													; Skip to next row/column if 5 != player1s symbol

C2_R3_CHECK:

	CMP row3[8], 36													; If 8 == player1s symbol, jmp to winning msg/process
	JE WINNER



C3_R1_CHECK:

	CMP row1[14], 36												; If 3 == player1s symbol, jmp to next row/column & check
	JE C3_R2_CHECK
	JMP DIAG_RIGHT_CHECK											; Skip to diagonal checks if 3 != player1s symbol

C3_R2_CHECK:

	CMP row2[14], 36												; If 6 == player1s symbol, jmp to next row/column & check
	JE C3_R3_CHECK
	JMP DIAG_RIGHT_CHECK											; Skip to diagonal checks if 6 != player1s symbol
	
C3_R3_CHECK:

	CMP row3[14], 36												; If 9 == player1s symbol, jmp to winning msg/process
	JE WINNER



DIAG_RIGHT_CHECK:

	CMP row1[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE DIAG_RIGHT_MIDDLE_CHECK
	JMP DIAG_LEFT_CHECK												; Skip to diagonal checks if 1 != player1s symbol

DIAG_RIGHT_MIDDLE_CHECK:

	CMP row2[8], 36													; If 5 == player1s symbol, jmp to next row/column & check
	JE DIAG_RIGHT_BOTTOM_CHECK
	JMP DIAG_LEFT_CHECK												; Skip to diagonal checks if 5 != player1s symbol

DIAG_RIGHT_BOTTOM_CHECK:

	CMP row3[14], 36												; If 9 == player1s symbol, jmp to winning msg/process
	JE WINNER



DIAG_LEFT_CHECK:

	CMP row1[14], 36												; If 3 == player1s symbol, jmp to next row/column & check
	JE DIAG_LEFT_MIDDLE_CHECK
	JMP R1_C1_CHECK_PLAYER2											; Skip to player2 checks if 3 != player1s symbol

DIAG_LEFT_MIDDLE_CHECK:

	CMP row2[8], 36													; If 5 == player1s symbol, jmp to next row/column & check
	JE DIAG_LEFT_BOTTOM_CHECK
	JMP R1_C1_CHECK_PLAYER2											; Skip to player2 checks if 5 != player1s symbol

DIAG_LEFT_BOTTOM_CHECK:

	CMP row3[2], 36													; If 7 == player1s symbol, jmp to winning msg/process
	JE WINNER



R1_C1_CHECK_PLAYER2:

	CMP row1[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE R1_C2_CHECK_PLAYER2
	JMP R2_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R1_C2_CHECK_PLAYER2:

	CMP row1[8], 64													; If 2 == player2s symbol, jmp to next row/column & check
	JE R1_C3_CHECK_PLAYER2
	JMP R2_C1_CHECK_PLAYER2											; Skip to next row/column if 2 != player2s symbol

R1_C3_CHECK_PLAYER2:

	CMP row1[14], 64												; If 3 == player2s symbol, jmp to winning msg/process
	JE WINNER



R2_C1_CHECK_PLAYER2:

	CMP row2[2], 64													; If 4 == player2s symbol, jmp to next row/column & check
	JE R2_C2_CHECK_PLAYER2
	JMP R3_C1_CHECK_PLAYER2											; Skip to next row/column if 4 != player2s symbol

R2_C2_CHECK_PLAYER2:

	CMP row2[8], 64													; If 5 == player2s symbol, jmp to next row/column & check
	JE R2_C3_CHECK_PLAYER2
	JMP R3_C1_CHECK_PLAYER2											; Skip to next row/column if 5 != player2s symbol

R2_C3_CHECK_PLAYER2:

	CMP row2[14], 64												; If 6 == player2s symbol, jmp to winning msg/process
	JE WINNER



R3_C1_CHECK_PLAYER2:

	CMP row3[2], 64													; If 7 == player2s symbol, jmp to next row/column & check
	JE R3_C2_CHECK_PLAYER2
	JMP C1_R1_CHECK_PLAYER2											; Skip to next row/column if 7 != player2s symbol

R3_C2_CHECK_PLAYER2:

	CMP row3[8], 64													; If 8 == player2s symbol, jmp to next row/column & check
	JE R3_C3_CHECK_PLAYER2
	JMP C1_R1_CHECK_PLAYER2											; Skip to next row/column if 8 != player2s symbol

R3_C3_CHECK_PLAYER2:

	CMP row3[14], 64												; If 9 == player2s symbol, jmp to winning msg/process
	JE WINNER



C1_R1_CHECK_PLAYER2:

	CMP row1[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE C1_R2_CHECK_PLAYER2
	JMP C2_R1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

C1_R2_CHECK_PLAYER2:

	CMP row2[2], 64													; If 4 == player2s symbol, jmp to next row/column & check
	JE C1_R3_CHECK_PLAYER2
	JMP C2_R1_CHECK_PLAYER2											; Skip to next row/column if 4 != player2s symbol

C1_R3_CHECK_PLAYER2:

	CMP row3[2], 64													; If 7 == player2s symbol, jmp to winning msg/process
	JE WINNER



C2_R1_CHECK_PLAYER2:

	CMP row1[8], 64													; If 2 == player2s symbol, jmp to next row/column & check
	JE C2_R2_CHECK_PLAYER2
	JMP C3_R1_CHECK_PLAYER2											; Skip to next row/column if 2 != player2s symbol

C2_R2_CHECK_PLAYER2:

	CMP row2[8], 64													; If 5 == player2s symbol, jmp to next row/column & check
	JE C2_R3_CHECK_PLAYER2
	JMP C3_R1_CHECK_PLAYER2											; Skip to next row/column if 5 != player2s symbol

C2_R3_CHECK_PLAYER2:

	CMP row3[8], 64													; If 8 == player2s symbol, jmp to winning msg/process
	JE WINNER



C3_R1_CHECK_PLAYER2:

	CMP row1[14], 64												; If 3 == player2s symbol, jmp to next row/column & check
	JE C3_R2_CHECK_PLAYER2
	JMP DIAG_RIGHT_CHECK_PLAYER2									; Skip to diagonal checks if 3 != player2s symbol

C3_R2_CHECK_PLAYER2:

	CMP row2[14], 64												; If 6 == player2s symbol, jmp to next row/column & check
	JE C3_R3_CHECK_PLAYER2
	JMP DIAG_RIGHT_CHECK_PLAYER2									; Skip to diagonal checks if 6 != player2s symbol

C3_R3_CHECK_PLAYER2:

	CMP row3[14], 64												; If 9 == player2s symbol, jmp to winning msg/process
	JE WINNER



DIAG_RIGHT_CHECK_PLAYER2:

	CMP row1[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE DIAG_RIGHT_MIDDLE_CHECK_PLAYER2
	JMP DIAG_LEFT_CHECK_PLAYER2										; Skip to diagonal checks if 1 != player2s symbol

DIAG_RIGHT_MIDDLE_CHECK_PLAYER2:

	CMP row2[8], 64													; If 5 == player2s symbol, jmp to next row/column & check
	JE DIAG_RIGHT_BOTTOM_CHECK_PLAYER2
	JMP DIAG_LEFT_CHECK_PLAYER2										; Skip to diagonal checks if 5 != player2s symbol

DIAG_RIGHT_BOTTOM_CHECK_PLAYER2:

	CMP row3[14], 64												; If 9 == player2s symbol, jmp to winning msg/process
	JE WINNER



DIAG_LEFT_CHECK_PLAYER2:

	CMP row1[14], 64												; If 3 == player2s symbol, jmp to next row/column & check
	JE DIAG_LEFT_MIDDLE_CHECK_PLAYER2
	JMP CHECK_WIN_EXIT												; Skip to exit process if 3 != player2s symbol

DIAG_LEFT_MIDDLE_CHECK_PLAYER2:

	CMP row2[8], 64													; If 5 == player2s symbol, jmp to next row/column & check
	JE DIAG_LEFT_BOTTOM_CHECK_PLAYER2
	JMP CHECK_WIN_EXIT												; Skip to exit process if 5 != player2s symbol

DIAG_LEFT_BOTTOM_CHECK_PLAYER2:

	CMP row3[2], 64													; If 7 == player2s symbol, jmp to winning msg/process
	JE WINNER

	JMP CHECK_WIN_EXIT



WINNER:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET congrats										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CMP player_turn, 1
	JE PLAYER1_WINNER
	CMP player_turn, 2
	JE PLAYER2_WINNER

PLAYER1_WINNER:

	MOV EDX, OFFSET player1_name									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET congrats2										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL display_board												; display_board proc call



	MOV EDI, OFFSET player1_name									; Mov ESI & EDI as pointers to player names
	MOV ESI, OFFSET player2_name
	MOV ECX, LENGTHOF player1_name									; Move length of player_name arrays into loop counter
	DEC ECX															; Decrement once so as not to effect terminating null byte
	
L1:

	MOV EAX, 0
	MOV [EDI], EAX													; Move zeroes into current player1 & player2 array indexes
	MOV [ESI], EAX
	ADD EDI, 4														; Increment index pointers & loop until both full names have
	ADD ESI, 4														; been properly reset

	LOOP L1


	
	MOV EDI, OFFSET actual_board									; Set EDI to point to beginning of underlying board array in memory
	MOV ECX, LENGTH actual_board									; Set length of actual_board array as loop counter

L2:

	MOV [EDI], EAX													; Reset each element in underlying board array in memory to zeroes,
	ADD EDI, 4														; move pointer forward and loop until full array is reset

	LOOP L2

	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run



	MOV row1[2], 49													; Next 9 rows simply resets the visual board that
	MOV row1[8], 50													; end user sees from 1-9
	MOV row1[14], 51

	MOV row2[2], 52
	MOV row2[8], 53
	MOV row2[14], 54

	MOV row3[2], 55
	MOV row3[8], 56
	MOV row3[14], 57



	MOV EDX, OFFSET repeat_program									; WriteString proc uses EDX register as register to read from											
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

	INVOKE ExitProcess, 0											; Return 0, exit success		

PLAYER2_WINNER:

	MOV EDX, OFFSET player2_name									; WriteString proc uses EDX register as register to read from								
	CALL WriteString												; WriteStr proc call
	MOV EDX, OFFSET congrats2										; WriteString proc uses EDX register as register to read from
	CALL WriteString												; WriteStr proc call
	CALL display_board												; display_board proc call


	MOV EDI, OFFSET player1_name									; Mov ESI & EDI as pointers to player names
	MOV ESI, OFFSET player2_name
	MOV ECX, LENGTHOF player1_name									; Move length of player_name arrays into loop counter
	DEC ECX															; Decrement once so as not to effect terminating null byte
	
L3:

	MOV EAX, 0
	MOV [EDI], EAX													; Move zeroes into current player1 & player2 array indexes
	MOV [ESI], EAX
	ADD EDI, 4														; Increment index pointers & loop until both full names have
	ADD ESI, 4														; been properly reset

	LOOP L3


	
	MOV EDI, OFFSET actual_board									; Set EDI to point to beginning of underlying board array in memory
	MOV ECX, LENGTH actual_board									; Set length of actual_board array as loop counter

L4:

	MOV [EDI], EAX													; Reset each element in underlying board array in memory to zeroes,
	ADD EDI, 4														; move pointer forward and loop until full array is reset

	LOOP L4

	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run



	MOV row1[2], 49													; Next 9 rows simply resets the visual board that
	MOV row1[8], 50													; end user sees from 1-9
	MOV row1[14], 51

	MOV row2[2], 52
	MOV row2[8], 53
	MOV row2[14], 54

	MOV row3[2], 55
	MOV row3[8], 56
	MOV row3[14], 57


	
	MOV EDX, OFFSET repeat_program									; WriteString proc uses EDX register as register to read from											
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

	INVOKE ExitProcess, 0											; Return 0, exit success

CHECK_WIN_EXIT:

	RET																; Return from proc if not match found

check_win ENDP



;*******************************************************************;
; Function: Displays current game board to end user					;
;																	;
; Return: Current game board displayed to console				    ;
;																	;
; Procedure: Use EDX & the WriteString proc to display current game ;
;			 board state throughout the gameplay					;
;*******************************************************************;
display_board PROC

	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row1											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row2											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row3											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	RET																; Return from proc call

display_board ENDP



;*******************************************************************;
; Function: Procedure used in case of match result being a draw		;
;																	;
; Return: Match draw displayed to console, prompt for game re-run	;
;																	;
; Procedure: Use EDX & WriteString proc to display match draw msg   ;
;			 to end user along with game re-run prompt				;
;*******************************************************************;
MATCH_DRAW PROC

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET draw_msg										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET prettify_output									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL display_board												; display_board proc call



	MOV EDI, OFFSET player1_name									; Mov ESI & EDI as pointers to player names
	MOV ESI, OFFSET player2_name
	MOV ECX, LENGTHOF player1_name									; Move length of player_name arrays into loop counter
	DEC ECX															; Decrement once so as not to effect terminating null byte
	
L5:

	MOV EAX, 0
	MOV [EDI], EAX													; Move zeroes into current player1 & player2 array indexes
	MOV [ESI], EAX
	ADD EDI, 4														; Increment index pointers & loop until both full names have
	ADD ESI, 4														; been properly reset

	LOOP L5


	
	MOV EDI, OFFSET actual_board									; Set EDI to point to beginning of underlying board array in memory
	MOV ECX, LENGTH actual_board									; Set length of actual_board array as loop counter

L6:

	MOV [EDI], EAX													; Reset each element in underlying board array in memory to zeroes,
	ADD EDI, 4														; move pointer forward and loop until full array is reset

	LOOP L6

	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run



	MOV row1[2], 49													; Next 9 rows simply resets the visual board that
	MOV row1[8], 50													; end user sees from 1-9
	MOV row1[14], 51

	MOV row2[2], 52
	MOV row2[8], 53
	MOV row2[14], 54

	MOV row3[2], 55
	MOV row3[8], 56
	MOV row3[14], 57


	
	MOV EDX, OFFSET repeat_program									; WriteString proc uses EDX register as register to read from											
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

	INVOKE ExitProcess, 0											; Return 0, exit success

MATCH_DRAW ENDP

END main															; Program end
