;****************************************************************;
; Program Name: Connect 4										 ;
; Program Description: Plays a classic game of Connect 4		 ;
; Program Author: Parke											 ;
; Creation Date: 10/08/2024										 ;
; Revisions: N/A												 ;
; Date Last Modified: 10/09/2024								 ;
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
	banner1 BYTE "  ______                                                       __            __    __", 0 
	banner2 BYTE " /      \                                                     |  \          |  \  |  \", 0
	banner3 BYTE "|  $$$$$$\  ______   _______   _______    ______    _______  _| $$_         | $$  | $$", 0
	banner4 BYTE "| $$   \$$ /      \ |       \ |       \  /      \  /       \|   $$ \        | $$__| $$", 0
	banner5 BYTE "| $$      |  $$$$$$\| $$$$$$$\| $$$$$$$\|  $$$$$$\|  $$$$$$$ \$$$$$$        | $$    $$", 0
	banner6 BYTE "| $$   __ | $$  | $$| $$  | $$| $$  | $$| $$    $$| $$        | $$ __        \$$$$$$$$", 0
	banner7 BYTE "| $$__/  \| $$__/ $$| $$  | $$| $$  | $$| $$$$$$$$| $$_____   | $$|  \            | $$", 0
	banner8 BYTE " \$$    $$ \$$    $$| $$  | $$| $$  | $$ \$$     \ \$$     \   \$$  $$            | $$", 0
	banner9 BYTE "  \$$$$$$   \$$$$$$  \$$   \$$ \$$   \$$  \$$$$$$$  \$$$$$$$    \$$$$              \$$", 0                                                                                                                                                                

	space_out0 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
															
																	; Used to seperate board rows visually
	row_split BYTE "-----+-----+-----+-----+-----+"
			  BYTE "-----+-----+", 0

	space_out1 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

																	; Connect 4 board
	row_top BYTE "  1  :  2  :  3  :  4  :  5  :  6  :  7  :", 0

	row6 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0	
	space_out2 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
	row5 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0
	space_out3 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
	row4 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0
	space_out4 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
	row3 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0
	space_out5 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
	row2 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0
	space_out6 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space
	row1 BYTE "  x  |  x  |  x  |  x  |  x  |  x  |  x  |", 0

	space_out7 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	welcome BYTE "WELCOME TO THE GAME OF CONNECT 4", 0				; Intro msg

	explain BYTE "BOARD NUMBERING IS AS FOLLOWS: PLAY "				; Game instructions
			BYTE "IN A COLUMN BY SELECTING THE COLUMN NUMBER", 0

	example BYTE "EXAMPLE: IF YOU WANTED TO PLAY COLUMN 3, SIMPLY " ; Example prompt for end user
			BYTE "ENTER THE NUMBER 3", 0

	space_out8 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	col BYTE ", CHOOSE COLUMN TO PLAY IN (1-7): ", 0				; Game prompt for end user

	player1_prompt BYTE "PLAYER1 NAME: ", 0							; Player 1 name prompt
	player2_prompt BYTE "PLAYER2 NAME: ", 0							; Player 2 name prompt

	player1_symbol BYTE "$", 0										; Player 1 symbol
	player2_symbol BYTE "@", 0										; Player 2 symbol

	space_out9 BYTE "                                         ", 0  ; Simply used to space out vars inside memory to avoid running into other address space

	retry_prompt BYTE "SORRY, INPUT MUST BE BETWEEN 1 & 7, "		; Retry prompt if user enters value outside of 1-42 range 
				 BYTE "TRY AGAIN", 0

	player1_sym_msg BYTE "PLAYER 1 SYMBOL: ", 0						; Msgs for end users to show player 1 & 2s respective game symbols
	player2_sym_msg BYTE "PLAYER 2 SYMBOL: ", 0

	filled_col BYTE "COLUMN ALREADY FULL, TRY AGAIN", 0				; Msg to end user if they choose slot on board that is already filled

	congrats BYTE "CONGRATULATIONS ", 0								; Congratulatory msgs to display to user who wins
	congrats2 BYTE "! YOU ARE THE WINNER!!!", 0

	space_out10 BYTE "                                         ", 0 ; Simply used to space out vars inside memory to avoid running into other address space

																	; Re-run program prompt
	repeat_program BYTE "RE-RUN PROGRAM? ('yes' TO CONTINUE, ANY OTHER KEY TO"  
				   BYTE " QUIT): ", 0

	space_out11 BYTE "                                         ", 0 ; Simply used to space out vars inside memory to avoid running into other address space

	draw_msg BYTE "LOOKS LIKE THE GAME IS A DRAW! NO MORE "			; Prompt for end user in case of a draw in the game
			 BYTE "MOVES AVAILABLE :(", 0

	prettify_output BYTE "*************************************"    ; To help make the draw output a bit more pretty :)
					BYTE "*********************", 0

	player1_name BYTE 50 DUP(0)										; Buffer to hold player 1 name
	player2_name BYTE 50 DUP(0)										; Buffer to hold player 2 name

	player_turn BYTE 1												; Var to keep track of whose turn it is & which symbol to use

	rerun_buffer BYTE 3 DUP(0)										; Var to hold user input when prompted to repeat program or not

	draw_counter DWORD 0											; Var used to determine when draw has occurred

	col1_curr_index DWORD 1											; Each of these vars keeps track of each current col index
	col2_curr_index DWORD 1											; in the game to know to move up each space when the one below it is filled
	col3_curr_index DWORD 1
	col4_curr_index DWORD 1
	col5_curr_index DWORD 1
	col6_curr_index DWORD 1
	col7_curr_index DWORD 1

;*******************************************************************;
; Function: Main program driver										;
;																	;
; Return: None													    ;
;																	;
; Procedure: Displays intro msg & instructions, then prompts user	;
;			 1 to pick a col, then begins all processing from there ;
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
	MOV EDX, OFFSET banner5											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner6											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner7											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner8											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET banner9											; WriteStr proc uses EDX as register to read from
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



FIRST_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FIRST_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY
	CMP EAX, 7
	JA RETRY
	JMP PASS2

RETRY:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIRST_COL_FRESH_START

PASS2:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL_CHECK												; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL

FIRST_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[2], AL													; col is already filled or not by looping through each index in that col
	JE NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[2], AL 
	JE NEXT_SLOT_UP0
	JMP PASS4

NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[2], AL
	JE NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[2], AL 
	JE NEXT_SLOT_UP1
	JMP PASS4

NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[2], AL
	JE NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[2], AL 
	JE NEXT_SLOT_UP2
	JMP PASS4

NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[2], AL
	JE NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[2], AL 
	JE NEXT_SLOT_UP3
	JMP PASS4

NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[2], AL
	JE NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[2], AL 
	JE NEXT_SLOT_UP4
	JMP PASS4

NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[2], AL
	JE COL_FILLED
	MOV EAX, 64
	CMP row6[2], AL 
	JE COL_FILLED
	JMP PASS4

COL_FILLED:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIRST_COL_FRESH_START

PASS4:

	CMP col1_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE SET_COL1														; jumps to corresponding label to fill that index
	CMP col1_curr_index, 2
	JE SET_COL2
	CMP col1_curr_index, 3
	JE SET_COL3
	CMP col1_curr_index, 4
	JE SET_COL4
	CMP col1_curr_index, 5
	JE SET_COL5
	CMP col1_curr_index, 6
	JE SET_COL6

SET_COL1:

	MOV row1[2], BL													; Input corresponding users symbol into game board slot user sees
	JMP AFTER_COL_SET0

SET_COL2:

	MOV row2[2], BL													; Input corresponding users symbol into game board slot user sees
	JMP AFTER_COL_SET0

SET_COL3:

	MOV row3[2], BL													; Input corresponding users symbol into game board slot user sees
	JMP AFTER_COL_SET0

SET_COL4:

	MOV row4[2], BL													; Input corresponding users symbol into game board slot user sees
	JMP AFTER_COL_SET0

SET_COL5:

	MOV row5[2], BL													; Input corresponding users symbol into game board slot user sees
	JMP AFTER_COL_SET0

SET_COL6:

	MOV row6[2], BL													; Input corresponding users symbol into game board slot user sees

AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col1_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL

ADD_PLAYER_VAL:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIRST_COL_FRESH_START

SUB_PLAYER_VAL:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIRST_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



SECOND_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SECOND_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY2
	CMP EAX, 7
	JA RETRY2
	JMP PASS6

RETRY2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SECOND_COL_FRESH_START

PASS6:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL_CHECK
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL

SECOND_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[8], AL													; col is already filled or not by looping through each index in that col
	JE COL2_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[8], AL 
	JE COL2_NEXT_SLOT_UP0
	JMP PASS8

COL2_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[8], AL
	JE COL2_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[8], AL 
	JE COL2_NEXT_SLOT_UP1
	JMP PASS8

COL2_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[8], AL
	JE COL2_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[8], AL 
	JE COL2_NEXT_SLOT_UP2
	JMP PASS8

COL2_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[8], AL
	JE COL2_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[8], AL 
	JE COL2_NEXT_SLOT_UP3
	JMP PASS8

COL2_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[8], AL
	JE COL2_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[8], AL 
	JE COL2_NEXT_SLOT_UP4
	JMP PASS8

COL2_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[8], AL
	JE COL2_COL_FILLED2
	MOV EAX, 64
	CMP row6[8], AL 
	JE COL2_COL_FILLED2
	JMP PASS8

COL2_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SECOND_COL_FRESH_START

PASS8:

	CMP col2_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL2_SET_COL1												; jumps to corresponding label to fill that index
	CMP col2_curr_index, 2
	JE COL2_SET_COL2
	CMP col2_curr_index, 3
	JE COL2_SET_COL3
	CMP col2_curr_index, 4
	JE COL2_SET_COL4
	CMP col2_curr_index, 5
	JE COL2_SET_COL5
	CMP col2_curr_index, 6
	JE COL2_SET_COL6

COL2_SET_COL1:

	MOV row1[8], BL													; Input corresponding users symbol into game board slot user sees
	JMP COL2_AFTER_COL_SET0

COL2_SET_COL2:

	MOV row2[8], BL													; Input corresponding users symbol into game board slot user sees
	JMP COL2_AFTER_COL_SET0

COL2_SET_COL3:

	MOV row3[8], BL													; Input corresponding users symbol into game board slot user sees
	JMP COL2_AFTER_COL_SET0

COL2_SET_COL4:

	MOV row4[8], BL													; Input corresponding users symbol into game board slot user sees
	JMP COL2_AFTER_COL_SET0

COL2_SET_COL5:

	MOV row5[8], BL													; Input corresponding users symbol into game board slot user sees
	JMP COL2_AFTER_COL_SET0

COL2_SET_COL6:

	MOV row6[8], BL													; Input corresponding users symbol into game board slot user sees

COL2_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col2_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL2												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL2

ADD_PLAYER_VAL2:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SECOND_COL_FRESH_START

SUB_PLAYER_VAL2:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SECOND_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



THIRD_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



THIRD_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY3
	CMP EAX, 7
	JA RETRY3
	JMP PASS10

RETRY3:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP THIRD_COL_FRESH_START

PASS10:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL_CHECK
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL

THIRD_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[14], AL												; col is already filled or not by looping through each index in that col
	JE COL3_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[14], AL 
	JE COL3_NEXT_SLOT_UP0
	JMP PASS12

COL3_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[14], AL
	JE COL3_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[14], AL 
	JE COL3_NEXT_SLOT_UP1
	JMP PASS12

COL3_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[14], AL
	JE COL3_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[14], AL 
	JE COL3_NEXT_SLOT_UP2
	JMP PASS12

COL3_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[14], AL
	JE COL3_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[14], AL 
	JE COL3_NEXT_SLOT_UP3
	JMP PASS12

COL3_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[14], AL
	JE COL3_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[14], AL 
	JE COL3_NEXT_SLOT_UP4
	JMP PASS12

COL3_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[14], AL
	JE COL3_COL_FILLED2
	MOV EAX, 64
	CMP row6[14], AL 
	JE COL3_COL_FILLED2
	JMP PASS12

COL3_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP THIRD_COL_FRESH_START

PASS12:

	CMP col3_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL3_SET_COL1												; jumps to corresponding label to fill that index
	CMP col3_curr_index, 2
	JE COL3_SET_COL2
	CMP col3_curr_index, 3
	JE COL3_SET_COL3
	CMP col3_curr_index, 4
	JE COL3_SET_COL4
	CMP col3_curr_index, 5
	JE COL3_SET_COL5
	CMP col3_curr_index, 6
	JE COL3_SET_COL6

COL3_SET_COL1:

	MOV row1[14], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL3_AFTER_COL_SET0

COL3_SET_COL2:

	MOV row2[14], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL3_AFTER_COL_SET0

COL3_SET_COL3:

	MOV row3[14], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL3_AFTER_COL_SET0

COL3_SET_COL4:

	MOV row4[14], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL3_AFTER_COL_SET0

COL3_SET_COL5:

	MOV row5[14], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL3_AFTER_COL_SET0

COL3_SET_COL6:

	MOV row6[14], BL												; Input corresponding users symbol into game board slot user sees

COL3_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col3_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL3												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL3

ADD_PLAYER_VAL3:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP THIRD_COL_FRESH_START

SUB_PLAYER_VAL3:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP THIRD_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



FOURTH_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FOURTH_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY4
	CMP EAX, 7
	JA RETRY4
	JMP PASS14

RETRY4:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FOURTH_COL_FRESH_START

PASS14:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL_CHECK
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL

FOURTH_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[20], AL												; col is already filled or not by looping through each index in that col
	JE COL4_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[20], AL 
	JE COL4_NEXT_SLOT_UP0
	JMP PASS16

COL4_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[20], AL
	JE COL4_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[20], AL 
	JE COL4_NEXT_SLOT_UP1
	JMP PASS16

COL4_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[20], AL
	JE COL4_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[20], AL 
	JE COL4_NEXT_SLOT_UP2
	JMP PASS16

COL4_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[20], AL
	JE COL4_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[20], AL 
	JE COL4_NEXT_SLOT_UP3
	JMP PASS16

COL4_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[20], AL
	JE COL4_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[20], AL 
	JE COL4_NEXT_SLOT_UP4
	JMP PASS16

COL4_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[20], AL
	JE COL4_COL_FILLED2
	MOV EAX, 64
	CMP row6[20], AL 
	JE COL4_COL_FILLED2
	JMP PASS16

COL4_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FOURTH_COL_FRESH_START

PASS16:

	CMP col4_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL4_SET_COL1												; jumps to corresponding label to fill that index
	CMP col4_curr_index, 2
	JE COL4_SET_COL2
	CMP col4_curr_index, 3
	JE COL4_SET_COL3
	CMP col4_curr_index, 4
	JE COL4_SET_COL4
	CMP col4_curr_index, 5
	JE COL4_SET_COL5
	CMP col4_curr_index, 6
	JE COL4_SET_COL6

COL4_SET_COL1:

	MOV row1[20], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL4_AFTER_COL_SET0

COL4_SET_COL2:

	MOV row2[20], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL4_AFTER_COL_SET0

COL4_SET_COL3:

	MOV row3[20], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL4_AFTER_COL_SET0

COL4_SET_COL4:

	MOV row4[20], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL4_AFTER_COL_SET0

COL4_SET_COL5:

	MOV row5[20], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL4_AFTER_COL_SET0

COL4_SET_COL6:

	MOV row6[20], BL												; Input corresponding users symbol into game board slot user sees

COL4_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col4_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL4												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL4

ADD_PLAYER_VAL4:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FOURTH_COL_FRESH_START

SUB_PLAYER_VAL4:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FOURTH_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



FIFTH_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



FIFTH_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY5
	CMP EAX, 7
	JA RETRY5
	JMP PASS18

RETRY5:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIFTH_COL_FRESH_START

PASS18:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL_CHECK
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL

FIFTH_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[26], AL												; col is already filled or not by looping through each index in that col
	JE COL5_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[26], AL 
	JE COL5_NEXT_SLOT_UP0
	JMP PASS20

COL5_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[26], AL
	JE COL5_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[26], AL 
	JE COL5_NEXT_SLOT_UP1
	JMP PASS20

COL5_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[26], AL
	JE COL5_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[26], AL 
	JE COL5_NEXT_SLOT_UP2
	JMP PASS20

COL5_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[26], AL
	JE COL5_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[26], AL 
	JE COL5_NEXT_SLOT_UP3
	JMP PASS20

COL5_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[26], AL
	JE COL5_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[26], AL 
	JE COL5_NEXT_SLOT_UP4
	JMP PASS20

COL5_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[26], AL
	JE COL5_COL_FILLED2
	MOV EAX, 64
	CMP row6[26], AL 
	JE COL5_COL_FILLED2
	JMP PASS20

COL5_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP FIFTH_COL_FRESH_START

PASS20:

	CMP col5_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL5_SET_COL1												; jumps to corresponding label to fill that index
	CMP col5_curr_index, 2
	JE COL5_SET_COL2
	CMP col5_curr_index, 3
	JE COL5_SET_COL3
	CMP col5_curr_index, 4
	JE COL5_SET_COL4
	CMP col5_curr_index, 5
	JE COL5_SET_COL5
	CMP col5_curr_index, 6
	JE COL5_SET_COL6

COL5_SET_COL1:

	MOV row1[26], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL5_AFTER_COL_SET0

COL5_SET_COL2:

	MOV row2[26], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL5_AFTER_COL_SET0

COL5_SET_COL3:

	MOV row3[26], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL5_AFTER_COL_SET0

COL5_SET_COL4:

	MOV row4[26], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL5_AFTER_COL_SET0

COL5_SET_COL5:

	MOV row5[26], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL5_AFTER_COL_SET0

COL5_SET_COL6:

	MOV row6[26], BL												; Input corresponding users symbol into game board slot user sees

COL5_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col5_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL5												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL5

ADD_PLAYER_VAL5:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIFTH_COL_FRESH_START

SUB_PLAYER_VAL5:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP FIFTH_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success

	

SIXTH_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SIXTH_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY6
	CMP EAX, 7
	JA RETRY6
	JMP PASS22

RETRY6:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SIXTH_COL_FRESH_START

PASS22:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL_CHECK
	CMP EAX, 7
	JE SEVENTH_COL

SIXTH_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[32], AL												; col is already filled or not by looping through each index in that col
	JE COL6_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[32], AL 
	JE COL6_NEXT_SLOT_UP0
	JMP PASS24

COL6_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[32], AL
	JE COL6_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[32], AL 
	JE COL6_NEXT_SLOT_UP1
	JMP PASS24

COL6_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[32], AL
	JE COL6_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[32], AL 
	JE COL6_NEXT_SLOT_UP2
	JMP PASS24

COL6_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[32], AL
	JE COL6_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[32], AL 
	JE COL6_NEXT_SLOT_UP3
	JMP PASS24

COL6_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[32], AL
	JE COL6_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[32], AL 
	JE COL6_NEXT_SLOT_UP4
	JMP PASS24

COL6_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[32], AL
	JE COL6_COL_FILLED2
	MOV EAX, 64
	CMP row6[32], AL 
	JE COL6_COL_FILLED2
	JMP PASS24

COL6_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SIXTH_COL_FRESH_START

PASS24:

	CMP col6_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL6_SET_COL1												; jumps to corresponding label to fill that index
	CMP col6_curr_index, 2
	JE COL6_SET_COL2
	CMP col6_curr_index, 3
	JE COL6_SET_COL3
	CMP col6_curr_index, 4
	JE COL6_SET_COL4
	CMP col6_curr_index, 5
	JE COL6_SET_COL5
	CMP col6_curr_index, 6
	JE COL6_SET_COL6

COL6_SET_COL1:

	MOV row1[32], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL6_AFTER_COL_SET0

COL6_SET_COL2:

	MOV row2[32], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL6_AFTER_COL_SET0

COL6_SET_COL3:

	MOV row3[32], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL6_AFTER_COL_SET0

COL6_SET_COL4:

	MOV row4[32], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL6_AFTER_COL_SET0

COL6_SET_COL5:

	MOV row5[32], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL6_AFTER_COL_SET0

COL6_SET_COL6:

	MOV row6[32], BL												; Input corresponding users symbol into game board slot user sees

COL6_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col6_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL6												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL6

ADD_PLAYER_VAL6:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SIXTH_COL_FRESH_START

SUB_PLAYER_VAL6:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SIXTH_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



SEVENTH_COL_FRESH_START:												

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
	MOV EDX, OFFSET col												; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL ReadInt													; ReadInt proc call



SEVENTH_COL:

	CMP EAX, 1														; If input < 1 or input > 7, re-prompt user for valid value on board
	JB RETRY7
	CMP EAX, 7
	JA RETRY7
	JMP PASS26

RETRY7:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET retry_prompt									; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SEVENTH_COL_FRESH_START

PASS26:

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

	CMP EAX, 1														; Next 18 lines simply check which column user wants to fill
	JE FIRST_COL													; & jumps to corresponding label for processing
	CMP EAX, 2
	JE SECOND_COL
	CMP EAX, 3
	JE THIRD_COL
	CMP EAX, 4
	JE FOURTH_COL
	CMP EAX, 5
	JE FIFTH_COL
	CMP EAX, 6
	JE SIXTH_COL
	CMP EAX, 7
	JE SEVENTH_COL_CHECK

SEVENTH_COL_CHECK:

	MOV EAX, 36														; Every line under 'FIRST_COL_CHECK' proc simply checks if
	CMP row1[38], AL												; col is already filled or not by looping through each index in that col
	JE COL7_NEXT_SLOT_UP0
	MOV EAX, 64
	CMP row1[38], AL 
	JE COL7_NEXT_SLOT_UP0
	JMP PASS28

COL7_NEXT_SLOT_UP0:

	MOV EAX, 36														
	CMP row2[38], AL
	JE COL7_NEXT_SLOT_UP1
	MOV EAX, 64
	CMP row2[38], AL 
	JE COL7_NEXT_SLOT_UP1
	JMP PASS28

COL7_NEXT_SLOT_UP1:

	MOV EAX, 36													
	CMP row3[38], AL
	JE COL7_NEXT_SLOT_UP2
	MOV EAX, 64
	CMP row3[38], AL 
	JE COL7_NEXT_SLOT_UP2
	JMP PASS28

COL7_NEXT_SLOT_UP2:

	MOV EAX, 36														
	CMP row4[38], AL
	JE COL7_NEXT_SLOT_UP3
	MOV EAX, 64
	CMP row4[38], AL 
	JE COL7_NEXT_SLOT_UP3
	JMP PASS28

COL7_NEXT_SLOT_UP3:

	MOV EAX, 36														
	CMP row5[38], AL
	JE COL7_NEXT_SLOT_UP4
	MOV EAX, 64
	CMP row5[38], AL 
	JE COL7_NEXT_SLOT_UP4
	JMP PASS28

COL7_NEXT_SLOT_UP4:

	MOV EAX, 36														
	CMP row6[38], AL
	JE COL7_COL_FILLED2
	MOV EAX, 64
	CMP row6[38], AL 
	JE COL7_COL_FILLED2
	JMP PASS28

COL7_COL_FILLED2:

	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET filled_col										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	CALL Crlf														; Insert newline for readability
	JMP SEVENTH_COL_FRESH_START

PASS28:

	CMP col7_curr_index, 1											; Next 12 lines checks which index col1 is currently on &
	JE COL7_SET_COL1												; jumps to corresponding label to fill that index
	CMP col7_curr_index, 2
	JE COL7_SET_COL2
	CMP col7_curr_index, 3
	JE COL7_SET_COL3
	CMP col7_curr_index, 4
	JE COL7_SET_COL4
	CMP col7_curr_index, 5
	JE COL7_SET_COL5
	CMP col7_curr_index, 6
	JE COL7_SET_COL6

COL7_SET_COL1:

	MOV row1[38], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL7_AFTER_COL_SET0

COL7_SET_COL2:

	MOV row2[38], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL7_AFTER_COL_SET0

COL7_SET_COL3:

	MOV row3[38], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL7_AFTER_COL_SET0

COL7_SET_COL4:

	MOV row4[38], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL7_AFTER_COL_SET0

COL7_SET_COL5:

	MOV row5[38], BL												; Input corresponding users symbol into game board slot user sees
	JMP COL7_AFTER_COL_SET0

COL7_SET_COL6:

	MOV row6[38], BL												; Input corresponding users symbol into game board slot user sees

COL7_AFTER_COL_SET0:

	CALL check_win													; Check if a player has won yet

	INC col7_curr_index												; Point to next index in column 1

	INC draw_counter												; Add 1 to number of turns & check for draw
	CMP draw_counter, 42
	JE MATCH_DRAW

	CMP player_turn, 1												; Compare player_turn & jump to opposite players turn
	JE ADD_PLAYER_VAL7												; based on results
	CMP player_turn, 2
	JE SUB_PLAYER_VAL7

ADD_PLAYER_VAL7:

	INC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SEVENTH_COL_FRESH_START

SUB_PLAYER_VAL7:

	DEC player_turn													; Switch to other players turn 
	CALL display_board												; Display current board
	JMP SEVENTH_COL_FRESH_START


	INVOKE ExitProcess, 0											; Return 0, exit success



main ENDP



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
	JE R1_C4_CHECK
	JMP R2_C1_CHECK

R1_C4_CHECK:

	CMP row1[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C1_CHECK



R2_C1_CHECK:

	CMP row2[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C2_CHECK
	JMP R3_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R2_C2_CHECK:

	CMP row2[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C3_CHECK
	JMP R3_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R2_C3_CHECK:

	CMP row2[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C4_CHECK
	JE R3_C1_CHECK

R2_C4_CHECK:

	CMP row2[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R3_C1_CHECK



R3_C1_CHECK:

	CMP row3[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C2_CHECK
	JMP R4_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R3_C2_CHECK:

	CMP row3[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C3_CHECK
	JMP R4_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R3_C3_CHECK:

	CMP row3[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C4_CHECK
	JE R4_C1_CHECK

R3_C4_CHECK:

	CMP row3[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R4_C1_CHECK



R4_C1_CHECK:

	CMP row4[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C2_CHECK
	JMP R5_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R4_C2_CHECK:

	CMP row4[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C3_CHECK
	JMP R5_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R4_C3_CHECK:

	CMP row4[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C4_CHECK
	JE R5_C1_CHECK

R4_C4_CHECK:

	CMP row4[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R5_C1_CHECK



R5_C1_CHECK:

	CMP row5[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C2_CHECK
	JMP R6_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R5_C2_CHECK:

	CMP row5[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C3_CHECK
	JMP R6_C1_CHECK													; Skip to next row/column if 1 != player1s symbol

R5_C3_CHECK:

	CMP row5[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C4_CHECK
	JE R6_C1_CHECK

R5_C4_CHECK:

	CMP row5[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R6_C1_CHECK



R6_C1_CHECK:

	CMP row6[2], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C2_CHECK
	JMP R1_C2_CHECK_PT2 											; Skip to next row/column if 1 != player1s symbol

R6_C2_CHECK:

	CMP row6[8], 36													; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C3_CHECK
	JMP R1_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R6_C3_CHECK:

	CMP row6[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C4_CHECK
	JE R1_C2_CHECK_PT2

R6_C4_CHECK:

	CMP row6[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R1_C2_CHECK_PT2



R1_C2_CHECK_PT2:

	CMP row1[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C3_CHECK_PT2
	JMP R2_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R1_C3_CHECK_PT2:

	CMP row1[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C4_CHECK_PT2
	JMP R2_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R1_C4_CHECK_PT2:

	CMP row1[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C5_CHECK_PT2
	JMP R2_C2_CHECK_PT2

R1_C5_CHECK_PT2:

	CMP row1[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C2_CHECK_PT2



R2_C2_CHECK_PT2:

	CMP row2[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C3_CHECK_PT2
	JMP R3_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R2_C3_CHECK_PT2:

	CMP row2[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C4_CHECK_PT2
	JMP R3_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R2_C4_CHECK_PT2:

	CMP row2[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C5_CHECK_PT2
	JMP R3_C2_CHECK_PT2

R2_C5_CHECK_PT2:

	CMP row2[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C2_CHECK_PT2



R3_C2_CHECK_PT2:

	CMP row3[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C3_CHECK_PT2
	JMP R4_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R3_C3_CHECK_PT2:

	CMP row3[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C4_CHECK_PT2
	JMP R4_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R3_C4_CHECK_PT2:

	CMP row3[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C5_CHECK_PT2
	JMP R4_C2_CHECK_PT2

R3_C5_CHECK_PT2:

	CMP row3[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C2_CHECK_PT2



R4_C2_CHECK_PT2:

	CMP row4[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C3_CHECK_PT2
	JMP R5_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R4_C3_CHECK_PT2:

	CMP row4[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C4_CHECK_PT2
	JMP R5_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R4_C4_CHECK_PT2:

	CMP row4[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C5_CHECK_PT2
	JMP R5_C2_CHECK_PT2

R4_C5_CHECK_PT2:

	CMP row4[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C2_CHECK_PT2



R5_C2_CHECK_PT2:

	CMP row5[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C3_CHECK_PT2
	JMP R6_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R5_C3_CHECK_PT2:

	CMP row5[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C4_CHECK_PT2
	JMP R6_C2_CHECK_PT2												; Skip to next row/column if 1 != player1s symbol

R5_C4_CHECK_PT2:

	CMP row5[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C5_CHECK_PT2
	JMP R6_C2_CHECK_PT2

R5_C5_CHECK_PT2:

	CMP row5[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C2_CHECK_PT2



R6_C2_CHECK_PT2:

	CMP row6[8], 36													; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C3_CHECK_PT2
	JMP R1_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R6_C3_CHECK_PT2:

	CMP row6[14], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C4_CHECK_PT2
	JMP R1_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R6_C4_CHECK_PT2:

	CMP row6[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C5_CHECK_PT2
	JMP R1_C3_CHECK_PT3

R6_C5_CHECK_PT2:

	CMP row6[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R1_C3_CHECK_PT3



R1_C3_CHECK_PT3:

	CMP row1[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C4_CHECK_PT3
	JMP R2_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R1_C4_CHECK_PT3:

	CMP row1[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C5_CHECK_PT3
	JMP R2_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R1_C5_CHECK_PT3:

	CMP row1[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C6_CHECK_PT3
	JMP R2_C3_CHECK_PT3

R1_C6_CHECK_PT3:

	CMP row1[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C3_CHECK_PT3



R2_C3_CHECK_PT3:

	CMP row2[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C4_CHECK_PT3
	JMP R3_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R2_C4_CHECK_PT3:

	CMP row2[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C5_CHECK_PT3
	JMP R3_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R2_C5_CHECK_PT3:

	CMP row2[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C6_CHECK_PT3
	JMP R3_C3_CHECK_PT3

R2_C6_CHECK_PT3:

	CMP row2[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C3_CHECK_PT3



R3_C3_CHECK_PT3:

	CMP row3[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C4_CHECK_PT3
	JMP R4_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R3_C4_CHECK_PT3:

	CMP row3[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C5_CHECK_PT3
	JMP R4_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R3_C5_CHECK_PT3:

	CMP row3[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C6_CHECK_PT3
	JMP R4_C3_CHECK_PT3

R3_C6_CHECK_PT3:

	CMP row3[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C3_CHECK_PT3



R4_C3_CHECK_PT3:

	CMP row4[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C4_CHECK_PT3
	JMP R5_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R4_C4_CHECK_PT3:

	CMP row4[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C5_CHECK_PT3
	JMP R5_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R4_C5_CHECK_PT3:

	CMP row4[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C6_CHECK_PT3
	JMP R5_C3_CHECK_PT3

R4_C6_CHECK_PT3:

	CMP row4[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C3_CHECK_PT3



R5_C3_CHECK_PT3:

	CMP row5[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C4_CHECK_PT3
	JMP R6_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R5_C4_CHECK_PT3:

	CMP row5[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C5_CHECK_PT3
	JMP R6_C3_CHECK_PT3												; Skip to next row/column if 1 != player1s symbol

R5_C5_CHECK_PT3:

	CMP row5[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C6_CHECK_PT3
	JMP R6_C3_CHECK_PT3

R5_C6_CHECK_PT3:

	CMP row5[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C3_CHECK_PT3



R6_C3_CHECK_PT3:

	CMP row6[14], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C4_CHECK_PT3
	JMP R1_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R6_C4_CHECK_PT3:

	CMP row6[20], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C5_CHECK_PT3
	JMP R1_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R6_C5_CHECK_PT3:

	CMP row6[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C6_CHECK_PT3
	JMP R1_C4_CHECK_PT4

R6_C6_CHECK_PT3:

	CMP row6[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R1_C4_CHECK_PT4



R1_C4_CHECK_PT4:

	CMP row1[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C5_CHECK_PT4
	JMP R2_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R1_C5_CHECK_PT4:

	CMP row1[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C6_CHECK_PT4
	JMP R2_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R1_C6_CHECK_PT4:

	CMP row1[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C7_CHECK_PT4
	JMP R2_C4_CHECK_PT4

R1_C7_CHECK_PT4:

	CMP row1[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C4_CHECK_PT4



R2_C4_CHECK_PT4:

	CMP row2[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C5_CHECK_PT4
	JMP R3_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R2_C5_CHECK_PT4:

	CMP row2[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C6_CHECK_PT4
	JMP R3_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R2_C6_CHECK_PT4:

	CMP row2[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C7_CHECK_PT4
	JMP R3_C4_CHECK_PT4

R2_C7_CHECK_PT4:

	CMP row2[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C4_CHECK_PT4



R3_C4_CHECK_PT4:

	CMP row3[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C5_CHECK_PT4
	JMP R4_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R3_C5_CHECK_PT4:

	CMP row3[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C6_CHECK_PT4
	JMP R4_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R3_C6_CHECK_PT4:

	CMP row3[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C7_CHECK_PT4
	JMP R4_C4_CHECK_PT4

R3_C7_CHECK_PT4:

	CMP row3[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C4_CHECK_PT4



R4_C4_CHECK_PT4:

	CMP row4[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C5_CHECK_PT4
	JMP R5_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R4_C5_CHECK_PT4:

	CMP row4[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C6_CHECK_PT4
	JMP R5_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R4_C6_CHECK_PT4:

	CMP row4[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C7_CHECK_PT4
	JMP R5_C4_CHECK_PT4

R4_C7_CHECK_PT4:

	CMP row4[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C4_CHECK_PT4



R5_C4_CHECK_PT4:

	CMP row5[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C5_CHECK_PT4
	JMP R6_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R5_C5_CHECK_PT4:

	CMP row5[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C6_CHECK_PT4
	JMP R6_C4_CHECK_PT4												; Skip to next row/column if 1 != player1s symbol

R5_C6_CHECK_PT4:

	CMP row5[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C7_CHECK_PT4
	JMP R6_C4_CHECK_PT4

R5_C7_CHECK_PT4:

	CMP row5[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C4_CHECK_PT4



R6_C4_CHECK_PT4:

	CMP row6[20], 36												; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C5_CHECK_PT4
	JMP C1_R1_CHECK													; Skip to next row/column if 1 != player1s symbol

R6_C5_CHECK_PT4:

	CMP row6[26], 36												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C6_CHECK_PT4
	JMP C1_R1_CHECK													; Skip to next row/column if 1 != player1s symbol

R6_C6_CHECK_PT4:

	CMP row6[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C7_CHECK_PT4
	JMP C1_R1_CHECK 

R6_C7_CHECK_PT4:

	CMP row6[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C1_R1_CHECK 



C1_R1_CHECK:

	CMP row1[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R2_CHECK
	JMP C2_R1_CHECK 

C1_R2_CHECK:

	CMP row2[2], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R3_CHECK
	JMP C2_R1_CHECK 

C1_R3_CHECK:

	CMP row3[2], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK
	JMP C2_R1_CHECK

C1_R4_CHECK:

	CMP row4[2], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C2_R1_CHECK



C2_R1_CHECK:

	CMP row1[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R2_CHECK
	JMP C3_R1_CHECK 

C2_R2_CHECK:

	CMP row2[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R3_CHECK
	JMP C3_R1_CHECK 

C2_R3_CHECK:

	CMP row3[8], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK
	JMP C3_R1_CHECK

C2_R4_CHECK:

	CMP row4[8], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C3_R1_CHECK



C3_R1_CHECK:

	CMP row1[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R2_CHECK
	JMP C4_R1_CHECK 

C3_R2_CHECK:

	CMP row2[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R3_CHECK
	JMP C4_R1_CHECK 

C3_R3_CHECK:

	CMP row3[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK
	JMP C4_R1_CHECK

C3_R4_CHECK:

	CMP row4[14], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C4_R1_CHECK



C4_R1_CHECK:

	CMP row1[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R2_CHECK
	JMP C5_R1_CHECK 

C4_R2_CHECK:

	CMP row2[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R3_CHECK
	JMP C5_R1_CHECK 

C4_R3_CHECK:

	CMP row3[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK
	JMP C5_R1_CHECK

C4_R4_CHECK:

	CMP row4[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C5_R1_CHECK



C5_R1_CHECK:

	CMP row1[26], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R2_CHECK
	JMP C6_R1_CHECK 

C5_R2_CHECK:

	CMP row2[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R3_CHECK
	JMP C6_R1_CHECK 

C5_R3_CHECK:

	CMP row3[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK
	JMP C6_R1_CHECK

C5_R4_CHECK:

	CMP row4[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C6_R1_CHECK



C6_R1_CHECK:

	CMP row1[32], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R2_CHECK
	JMP C7_R1_CHECK 

C6_R2_CHECK:

	CMP row2[32], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R3_CHECK
	JMP C7_R1_CHECK 

C6_R3_CHECK:

	CMP row3[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK
	JMP C7_R1_CHECK

C6_R4_CHECK:

	CMP row4[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C7_R1_CHECK



C7_R1_CHECK:

	CMP row1[38], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R2_CHECK
	JMP C1_R2_CHECK_PT2 

C7_R2_CHECK:

	CMP row2[38], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R3_CHECK
	JMP C1_R2_CHECK_PT2  

C7_R3_CHECK:

	CMP row3[38], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK
	JMP C1_R2_CHECK_PT2 

C7_R4_CHECK:

	CMP row4[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C1_R2_CHECK_PT2 



C1_R2_CHECK_PT2:

	CMP row2[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R3_CHECK_PT2
	JMP C2_R2_CHECK_PT2

C1_R3_CHECK_PT2:

	CMP row3[2], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK_PT2
	JMP C2_R2_CHECK_PT2 

C1_R4_CHECK_PT2:
	
	CMP row4[2], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R5_CHECK_PT2
	JMP C2_R2_CHECK_PT2

C1_R5_CHECK_PT2:

	CMP row5[2], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C2_R2_CHECK_PT2



C2_R2_CHECK_PT2:

	CMP row2[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R3_CHECK_PT2
	JMP C3_R2_CHECK_PT2

C2_R3_CHECK_PT2:

	CMP row3[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK_PT2
	JMP C3_R2_CHECK_PT2 

C2_R4_CHECK_PT2:
	
	CMP row4[8], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R5_CHECK_PT2
	JMP C3_R2_CHECK_PT2

C2_R5_CHECK_PT2:

	CMP row5[8], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C3_R2_CHECK_PT2



C3_R2_CHECK_PT2:

	CMP row2[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R3_CHECK_PT2
	JMP C4_R2_CHECK_PT2

C3_R3_CHECK_PT2:

	CMP row3[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK_PT2
	JMP C4_R2_CHECK_PT2 

C3_R4_CHECK_PT2:
	
	CMP row4[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R5_CHECK_PT2
	JMP C4_R2_CHECK_PT2

C3_R5_CHECK_PT2:

	CMP row5[14], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C4_R2_CHECK_PT2



C4_R2_CHECK_PT2:

	CMP row2[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R3_CHECK_PT2
	JMP C5_R2_CHECK_PT2

C4_R3_CHECK_PT2:

	CMP row3[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK_PT2
	JMP C5_R2_CHECK_PT2 

C4_R4_CHECK_PT2:
	
	CMP row4[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R5_CHECK_PT2
	JMP C5_R2_CHECK_PT2

C4_R5_CHECK_PT2:

	CMP row5[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C5_R2_CHECK_PT2



C5_R2_CHECK_PT2:

	CMP row2[26], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R3_CHECK_PT2
	JMP C6_R2_CHECK_PT2

C5_R3_CHECK_PT2:

	CMP row3[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK_PT2
	JMP C6_R2_CHECK_PT2 

C5_R4_CHECK_PT2:
	
	CMP row4[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R5_CHECK_PT2
	JMP C6_R2_CHECK_PT2

C5_R5_CHECK_PT2:

	CMP row5[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C6_R2_CHECK_PT2



C6_R2_CHECK_PT2:

	CMP row2[32], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R3_CHECK_PT2
	JMP C7_R2_CHECK_PT2

C6_R3_CHECK_PT2:

	CMP row3[32], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK_PT2
	JMP C7_R2_CHECK_PT2 

C6_R4_CHECK_PT2:
	
	CMP row4[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R5_CHECK_PT2
	JMP C7_R2_CHECK_PT2

C6_R5_CHECK_PT2:

	CMP row5[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C7_R2_CHECK_PT2



C7_R2_CHECK_PT2:

	CMP row2[38], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R3_CHECK_PT2
	JMP C1_R3_CHECK_PT3

C7_R3_CHECK_PT2:

	CMP row3[38], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK_PT2
	JMP C1_R3_CHECK_PT3 

C7_R4_CHECK_PT2:
	
	CMP row4[38], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R5_CHECK_PT2
	JMP C1_R3_CHECK_PT3

C7_R5_CHECK_PT2:

	CMP row5[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C1_R3_CHECK_PT3



C1_R3_CHECK_PT3:

	CMP row3[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK_PT3
	JMP C2_R3_CHECK_PT3

C1_R4_CHECK_PT3:

	CMP row4[2], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R5_CHECK_PT3
	JMP C2_R3_CHECK_PT3

C1_R5_CHECK_PT3:

	CMP row5[2], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R6_CHECK_PT3
	JMP C2_R3_CHECK_PT3

C1_R6_CHECK_PT3:

	CMP row6[2], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C2_R3_CHECK_PT3



C2_R3_CHECK_PT3:

	CMP row3[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK_PT3
	JMP C3_R3_CHECK_PT3

C2_R4_CHECK_PT3:

	CMP row4[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R5_CHECK_PT3
	JMP C3_R3_CHECK_PT3

C2_R5_CHECK_PT3:

	CMP row5[8], 36													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R6_CHECK_PT3
	JMP C3_R3_CHECK_PT3

C2_R6_CHECK_PT3:

	CMP row6[8], 36													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C3_R3_CHECK_PT3



C3_R3_CHECK_PT3:

	CMP row3[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK_PT3
	JMP C4_R3_CHECK_PT3

C3_R4_CHECK_PT3:

	CMP row4[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R5_CHECK_PT3
	JMP C4_R3_CHECK_PT3

C3_R5_CHECK_PT3:

	CMP row5[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R6_CHECK_PT3
	JMP C4_R3_CHECK_PT3

C3_R6_CHECK_PT3:

	CMP row6[14], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C4_R3_CHECK_PT3



C4_R3_CHECK_PT3:

	CMP row3[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK_PT3
	JMP C5_R3_CHECK_PT3

C4_R4_CHECK_PT3:

	CMP row4[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R5_CHECK_PT3
	JMP C5_R3_CHECK_PT3

C4_R5_CHECK_PT3:

	CMP row5[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R6_CHECK_PT3
	JMP C5_R3_CHECK_PT3

C4_R6_CHECK_PT3:

	CMP row6[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C5_R3_CHECK_PT3



C5_R3_CHECK_PT3:

	CMP row3[26], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK_PT3
	JMP C6_R3_CHECK_PT3

C5_R4_CHECK_PT3:

	CMP row4[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R5_CHECK_PT3
	JMP C6_R3_CHECK_PT3

C5_R5_CHECK_PT3:

	CMP row5[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R6_CHECK_PT3
	JMP C6_R3_CHECK_PT3

C5_R6_CHECK_PT3:

	CMP row6[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C6_R3_CHECK_PT3



C6_R3_CHECK_PT3:

	CMP row3[32], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK_PT3
	JMP C7_R3_CHECK_PT3

C6_R4_CHECK_PT3:

	CMP row4[32], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R5_CHECK_PT3
	JMP C7_R3_CHECK_PT3

C6_R5_CHECK_PT3:

	CMP row5[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R6_CHECK_PT3
	JMP C7_R3_CHECK_PT3

C6_R6_CHECK_PT3:

	CMP row6[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C7_R3_CHECK_PT3



C7_R3_CHECK_PT3:

	CMP row3[38], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK_PT3
	JMP DIAG_CHECK1

C7_R4_CHECK_PT3:

	CMP row4[38], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R5_CHECK_PT3
	JMP DIAG_CHECK1

C7_R5_CHECK_PT3:

	CMP row5[38], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R6_CHECK_PT3
	JMP DIAG_CHECK1

C7_R6_CHECK_PT3:

	CMP row6[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK1



DIAG_CHECK1:

	CMP row4[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT2
	JMP DIAG_CHECK2

DIAG_CHECK1_PT2:

	CMP row3[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT3
	JMP DIAG_CHECK2

DIAG_CHECK1_PT3:

	CMP row2[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT4
	JMP DIAG_CHECK2

DIAG_CHECK1_PT4:

	CMP row1[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK2



DIAG_CHECK2:

	CMP row5[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT2
	JMP DIAG_CHECK3

DIAG_CHECK2_PT2:

	CMP row4[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT3
	JMP DIAG_CHECK3

DIAG_CHECK2_PT3:

	CMP row3[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT4
	JMP DIAG_CHECK3

DIAG_CHECK2_PT4:

	CMP row2[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK3



DIAG_CHECK3:

	CMP row4[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT2
	JMP DIAG_CHECK4

DIAG_CHECK3_PT2:

	CMP row3[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT3
	JMP DIAG_CHECK4

DIAG_CHECK3_PT3:

	CMP row2[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT4
	JMP DIAG_CHECK4

DIAG_CHECK3_PT4:

	CMP row1[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK4



DIAG_CHECK4:

	CMP row6[2], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT2
	JMP DIAG_CHECK5

DIAG_CHECK4_PT2:

	CMP row5[8], 36													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT3
	JMP DIAG_CHECK5

DIAG_CHECK4_PT3:

	CMP row4[14], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT4
	JMP DIAG_CHECK5

DIAG_CHECK4_PT4:

	CMP row3[20], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK5



DIAG_CHECK5:

	CMP row5[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT2
	JMP DIAG_CHECK6

DIAG_CHECK5_PT2:

	CMP row4[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT3
	JMP DIAG_CHECK6

DIAG_CHECK5_PT3:

	CMP row3[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT4
	JMP DIAG_CHECK6

DIAG_CHECK5_PT4:

	CMP row2[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK6



DIAG_CHECK6:

	CMP row4[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT2
	JMP DIAG_CHECK7

DIAG_CHECK6_PT2:

	CMP row3[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT3
	JMP DIAG_CHECK7

DIAG_CHECK6_PT3:

	CMP row2[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT4
	JMP DIAG_CHECK7

DIAG_CHECK6_PT4:

	CMP row1[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK7



DIAG_CHECK7:

	CMP row6[8], 36													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT2
	JMP DIAG_CHECK8

DIAG_CHECK7_PT2:

	CMP row5[14], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT3
	JMP DIAG_CHECK8

DIAG_CHECK7_PT3:

	CMP row4[20], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT4
	JMP DIAG_CHECK8

DIAG_CHECK7_PT4:

	CMP row3[26], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK8



DIAG_CHECK8:

	CMP row5[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT2
	JMP DIAG_CHECK9

DIAG_CHECK8_PT2:

	CMP row4[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT3
	JMP DIAG_CHECK9

DIAG_CHECK8_PT3:

	CMP row3[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT4
	JMP DIAG_CHECK9

DIAG_CHECK8_PT4:

	CMP row2[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK9



DIAG_CHECK9:

	CMP row4[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT2
	JMP DIAG_CHECK10

DIAG_CHECK9_PT2:

	CMP row3[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT3
	JMP DIAG_CHECK10

DIAG_CHECK9_PT3:

	CMP row2[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT4
	JMP DIAG_CHECK10

DIAG_CHECK9_PT4:

	CMP row1[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK10



DIAG_CHECK10:

	CMP row6[14], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT2
	JMP DIAG_CHECK11

DIAG_CHECK10_PT2:

	CMP row5[20], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT3
	JMP DIAG_CHECK11

DIAG_CHECK10_PT3:

	CMP row4[26], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT4
	JMP DIAG_CHECK11

DIAG_CHECK10_PT4:

	CMP row3[32], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK11



DIAG_CHECK11:

	CMP row5[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT2
	JMP DIAG_CHECK12

DIAG_CHECK11_PT2:

	CMP row4[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT3
	JMP DIAG_CHECK12

DIAG_CHECK11_PT3:

	CMP row3[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT4
	JMP DIAG_CHECK12

DIAG_CHECK11_PT4:

	CMP row2[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK12



DIAG_CHECK12:

	CMP row6[20], 36												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT2
	JMP R1_C1_CHECK_PLAYER2

DIAG_CHECK12_PT2:

	CMP row5[26], 36												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT3
	JMP R1_C1_CHECK_PLAYER2

DIAG_CHECK12_PT3:

	CMP row4[32], 36												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT4
	JMP R1_C1_CHECK_PLAYER2

DIAG_CHECK12_PT4:

	CMP row3[38], 36												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R1_C1_CHECK_PLAYER2



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
	JE R1_C4_CHECK_PLAYER2
	JMP R2_C1_CHECK_PLAYER2

R1_C4_CHECK_PLAYER2:

	CMP row1[20], 64												; If 4 == player2s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C1_CHECK_PLAYER2



R2_C1_CHECK_PLAYER2:

	CMP row2[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE R2_C2_CHECK_PLAYER2
	JMP R3_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R2_C2_CHECK_PLAYER2:

	CMP row2[8], 64													; If 2 == player2s symbol, jmp to next row/column & check
	JE R2_C3_CHECK_PLAYER2
	JMP R3_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R2_C3_CHECK_PLAYER2:

	CMP row2[14], 64												; If 3 == player2s symbol, jmp to winning msg/process
	JE R2_C4_CHECK_PLAYER2
	JE R3_C1_CHECK_PLAYER2

R2_C4_CHECK_PLAYER2:

	CMP row2[20], 64												; If 4 == player2s symbol, jmp to winning msg/process
	JE WINNER
	JE R3_C1_CHECK_PLAYER2



R3_C1_CHECK_PLAYER2:

	CMP row3[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE R3_C2_CHECK_PLAYER2
	JMP R4_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R3_C2_CHECK_PLAYER2:

	CMP row3[8], 64													; If 2 == player2s symbol, jmp to next row/column & check
	JE R3_C3_CHECK_PLAYER2
	JMP R4_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R3_C3_CHECK_PLAYER2:

	CMP row3[14], 64												; If 3 == player2s symbol, jmp to winning msg/process
	JE R3_C4_CHECK_PLAYER2
	JE R4_C1_CHECK_PLAYER2

R3_C4_CHECK_PLAYER2:

	CMP row3[20], 64												; If 4 == player2s symbol, jmp to winning msg/process
	JE WINNER
	JE R4_C1_CHECK_PLAYER2



R4_C1_CHECK_PLAYER2:

	CMP row4[2], 64													; If 1 == player2s symbol, jmp to next row/column & check
	JE R4_C2_CHECK_PLAYER2
	JMP R5_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R4_C2_CHECK_PLAYER2:

	CMP row4[8], 64													; If 2 == player2s symbol, jmp to next row/column & check
	JE R4_C3_CHECK_PLAYER2
	JMP R5_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player2s symbol

R4_C3_CHECK_PLAYER2:

	CMP row4[14], 64												; If 3 == player2s symbol, jmp to winning msg/process
	JE R4_C4_CHECK_PLAYER2
	JE R5_C1_CHECK_PLAYER2

R4_C4_CHECK_PLAYER2:

	CMP row4[20], 64												; If 4 == player2s symbol, jmp to winning msg/process
	JE WINNER
	JE R5_C1_CHECK_PLAYER2



R5_C1_CHECK_PLAYER2:

	CMP row5[2], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C2_CHECK_PLAYER2
	JMP R6_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player1s symbol

R5_C2_CHECK_PLAYER2:

	CMP row5[8], 64													; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C3_CHECK_PLAYER2
	JMP R6_C1_CHECK_PLAYER2											; Skip to next row/column if 1 != player1s symbol

R5_C3_CHECK_PLAYER2:

	CMP row5[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C4_CHECK_PLAYER2
	JE R6_C1_CHECK_PLAYER2

R5_C4_CHECK_PLAYER2:

	CMP row5[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R6_C1_CHECK_PLAYER2



R6_C1_CHECK_PLAYER2:

	CMP row6[2], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C2_CHECK_PLAYER2
	JMP R1_C2_CHECK_PT2_PLAYER2 									; Skip to next row/column if 1 != player1s symbol

R6_C2_CHECK_PLAYER2:

	CMP row6[8], 64													; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C3_CHECK_PLAYER2
	JMP R1_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R6_C3_CHECK_PLAYER2:

	CMP row6[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C4_CHECK_PLAYER2
	JE R1_C2_CHECK_PT2_PLAYER2

R6_C4_CHECK_PLAYER2:

	CMP row6[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JE R1_C2_CHECK_PT2_PLAYER2



R1_C2_CHECK_PT2_PLAYER2:

	CMP row1[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C3_CHECK_PT2_PLAYER2
	JMP R2_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C3_CHECK_PT2_PLAYER2:

	CMP row1[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C4_CHECK_PT2_PLAYER2
	JMP R2_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C4_CHECK_PT2_PLAYER2:

	CMP row1[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C5_CHECK_PT2_PLAYER2
	JMP R2_C2_CHECK_PT2_PLAYER2

R1_C5_CHECK_PT2_PLAYER2:

	CMP row1[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C2_CHECK_PT2_PLAYER2



R2_C2_CHECK_PT2_PLAYER2:

	CMP row2[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C3_CHECK_PT2_PLAYER2
	JMP R3_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C3_CHECK_PT2_PLAYER2:

	CMP row2[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C4_CHECK_PT2_PLAYER2
	JMP R3_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C4_CHECK_PT2_PLAYER2:

	CMP row2[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C5_CHECK_PT2_PLAYER2
	JMP R3_C2_CHECK_PT2_PLAYER2

R2_C5_CHECK_PT2_PLAYER2:

	CMP row2[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C2_CHECK_PT2_PLAYER2



R3_C2_CHECK_PT2_PLAYER2:

	CMP row3[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C3_CHECK_PT2_PLAYER2
	JMP R4_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C3_CHECK_PT2_PLAYER2:

	CMP row3[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C4_CHECK_PT2_PLAYER2
	JMP R4_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C4_CHECK_PT2_PLAYER2:

	CMP row3[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C5_CHECK_PT2_PLAYER2
	JMP R4_C2_CHECK_PT2_PLAYER2

R3_C5_CHECK_PT2_PLAYER2:

	CMP row3[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C2_CHECK_PT2_PLAYER2



R4_C2_CHECK_PT2_PLAYER2:

	CMP row4[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C3_CHECK_PT2_PLAYER2
	JMP R5_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C3_CHECK_PT2_PLAYER2:

	CMP row4[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C4_CHECK_PT2_PLAYER2
	JMP R5_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C4_CHECK_PT2_PLAYER2:

	CMP row4[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C5_CHECK_PT2_PLAYER2
	JMP R5_C2_CHECK_PT2_PLAYER2

R4_C5_CHECK_PT2_PLAYER2:

	CMP row4[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C2_CHECK_PT2_PLAYER2



R5_C2_CHECK_PT2_PLAYER2:

	CMP row5[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C3_CHECK_PT2_PLAYER2
	JMP R6_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C3_CHECK_PT2_PLAYER2:

	CMP row5[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C4_CHECK_PT2_PLAYER2
	JMP R6_C2_CHECK_PT2_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C4_CHECK_PT2_PLAYER2:

	CMP row5[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C5_CHECK_PT2_PLAYER2
	JMP R6_C2_CHECK_PT2_PLAYER2

R5_C5_CHECK_PT2_PLAYER2:

	CMP row5[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C2_CHECK_PT2_PLAYER2



R6_C2_CHECK_PT2_PLAYER2:

	CMP row6[8], 64													; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C3_CHECK_PT2_PLAYER2
	JMP R1_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R6_C3_CHECK_PT2_PLAYER2:

	CMP row6[14], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C4_CHECK_PT2_PLAYER2
	JMP R1_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R6_C4_CHECK_PT2_PLAYER2:

	CMP row6[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C5_CHECK_PT2_PLAYER2
	JMP R1_C3_CHECK_PT3_PLAYER2

R6_C5_CHECK_PT2_PLAYER2:

	CMP row6[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R1_C3_CHECK_PT3_PLAYER2



R1_C3_CHECK_PT3_PLAYER2:

	CMP row1[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C4_CHECK_PT3_PLAYER2
	JMP R2_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C4_CHECK_PT3_PLAYER2:

	CMP row1[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C5_CHECK_PT3_PLAYER2
	JMP R2_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C5_CHECK_PT3_PLAYER2:

	CMP row1[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C6_CHECK_PT3_PLAYER2
	JMP R2_C3_CHECK_PT3_PLAYER2

R1_C6_CHECK_PT3_PLAYER2:

	CMP row1[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C3_CHECK_PT3_PLAYER2



R2_C3_CHECK_PT3_PLAYER2:

	CMP row2[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C4_CHECK_PT3_PLAYER2
	JMP R3_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C4_CHECK_PT3_PLAYER2:

	CMP row2[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C5_CHECK_PT3_PLAYER2
	JMP R3_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C5_CHECK_PT3_PLAYER2:

	CMP row2[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C6_CHECK_PT3_PLAYER2
	JMP R3_C3_CHECK_PT3_PLAYER2

R2_C6_CHECK_PT3_PLAYER2:

	CMP row2[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C3_CHECK_PT3_PLAYER2



R3_C3_CHECK_PT3_PLAYER2:

	CMP row3[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C4_CHECK_PT3_PLAYER2
	JMP R4_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C4_CHECK_PT3_PLAYER2:

	CMP row3[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C5_CHECK_PT3_PLAYER2
	JMP R4_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C5_CHECK_PT3_PLAYER2:

	CMP row3[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C6_CHECK_PT3_PLAYER2
	JMP R4_C3_CHECK_PT3_PLAYER2

R3_C6_CHECK_PT3_PLAYER2:

	CMP row3[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C3_CHECK_PT3_PLAYER2



R4_C3_CHECK_PT3_PLAYER2:

	CMP row4[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C4_CHECK_PT3_PLAYER2
	JMP R5_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C4_CHECK_PT3_PLAYER2:

	CMP row4[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C5_CHECK_PT3_PLAYER2
	JMP R5_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C5_CHECK_PT3_PLAYER2:

	CMP row4[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C6_CHECK_PT3_PLAYER2
	JMP R5_C3_CHECK_PT3_PLAYER2

R4_C6_CHECK_PT3_PLAYER2:

	CMP row4[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C3_CHECK_PT3_PLAYER2



R5_C3_CHECK_PT3_PLAYER2:

	CMP row5[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C4_CHECK_PT3_PLAYER2
	JMP R6_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C4_CHECK_PT3_PLAYER2:

	CMP row5[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C5_CHECK_PT3_PLAYER2
	JMP R6_C3_CHECK_PT3_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C5_CHECK_PT3_PLAYER2:

	CMP row5[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C6_CHECK_PT3_PLAYER2
	JMP R6_C3_CHECK_PT3_PLAYER2

R5_C6_CHECK_PT3_PLAYER2:

	CMP row5[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C3_CHECK_PT3_PLAYER2



R6_C3_CHECK_PT3_PLAYER2:

	CMP row6[14], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C4_CHECK_PT3_PLAYER2
	JMP R1_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R6_C4_CHECK_PT3_PLAYER2:

	CMP row6[20], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C5_CHECK_PT3_PLAYER2
	JMP R1_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R6_C5_CHECK_PT3_PLAYER2:

	CMP row6[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C6_CHECK_PT3_PLAYER2
	JMP R1_C4_CHECK_PT4_PLAYER2

R6_C6_CHECK_PT3_PLAYER2:

	CMP row6[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R1_C4_CHECK_PT4_PLAYER2



R1_C4_CHECK_PT4_PLAYER2:

	CMP row1[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R1_C5_CHECK_PT4_PLAYER2
	JMP R2_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C5_CHECK_PT4_PLAYER2:

	CMP row1[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R1_C6_CHECK_PT4_PLAYER2
	JMP R2_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R1_C6_CHECK_PT4_PLAYER2:

	CMP row1[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R1_C7_CHECK_PT4_PLAYER2
	JMP R2_C4_CHECK_PT4_PLAYER2

R1_C7_CHECK_PT4_PLAYER2:

	CMP row1[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R2_C4_CHECK_PT4_PLAYER2



R2_C4_CHECK_PT4_PLAYER2:

	CMP row2[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R2_C5_CHECK_PT4_PLAYER2
	JMP R3_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C5_CHECK_PT4_PLAYER2:

	CMP row2[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R2_C6_CHECK_PT4_PLAYER2
	JMP R3_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R2_C6_CHECK_PT4_PLAYER2:

	CMP row2[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R2_C7_CHECK_PT4_PLAYER2
	JMP R3_C4_CHECK_PT4_PLAYER2

R2_C7_CHECK_PT4_PLAYER2:

	CMP row2[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R3_C4_CHECK_PT4_PLAYER2



R3_C4_CHECK_PT4_PLAYER2:

	CMP row3[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R3_C5_CHECK_PT4_PLAYER2
	JMP R4_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C5_CHECK_PT4_PLAYER2:

	CMP row3[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R3_C6_CHECK_PT4_PLAYER2
	JMP R4_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R3_C6_CHECK_PT4_PLAYER2:

	CMP row3[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R3_C7_CHECK_PT4_PLAYER2
	JMP R4_C4_CHECK_PT4_PLAYER2

R3_C7_CHECK_PT4_PLAYER2:

	CMP row3[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R4_C4_CHECK_PT4_PLAYER2



R4_C4_CHECK_PT4_PLAYER2:

	CMP row4[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R4_C5_CHECK_PT4_PLAYER2
	JMP R5_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C5_CHECK_PT4_PLAYER2:

	CMP row4[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R4_C6_CHECK_PT4_PLAYER2
	JMP R5_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R4_C6_CHECK_PT4_PLAYER2:

	CMP row4[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R4_C7_CHECK_PT4_PLAYER2
	JMP R5_C4_CHECK_PT4_PLAYER2

R4_C7_CHECK_PT4_PLAYER2:

	CMP row4[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R5_C4_CHECK_PT4_PLAYER2



R5_C4_CHECK_PT4_PLAYER2:

	CMP row5[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R5_C5_CHECK_PT4_PLAYER2
	JMP R6_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C5_CHECK_PT4_PLAYER2:

	CMP row5[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R5_C6_CHECK_PT4_PLAYER2
	JMP R6_C4_CHECK_PT4_PLAYER2										; Skip to next row/column if 1 != player1s symbol

R5_C6_CHECK_PT4_PLAYER2:

	CMP row5[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R5_C7_CHECK_PT4_PLAYER2
	JMP R6_C4_CHECK_PT4_PLAYER2

R5_C7_CHECK_PT4_PLAYER2:

	CMP row5[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP R6_C4_CHECK_PT4_PLAYER2



R6_C4_CHECK_PT4_PLAYER2:

	CMP row6[20], 64												; If 1 == player1s symbol, jmp to next row/column & check
	JE R6_C5_CHECK_PT4_PLAYER2
	JMP C1_R1_CHECK_PLAYER2											; Skip to next row/column if 1 != player1s symbol

R6_C5_CHECK_PT4_PLAYER2:

	CMP row6[26], 64												; If 2 == player1s symbol, jmp to next row/column & check
	JE R6_C6_CHECK_PT4_PLAYER2
	JMP C1_R1_CHECK_PLAYER2											; Skip to next row/column if 1 != player1s symbol

R6_C6_CHECK_PT4_PLAYER2:

	CMP row6[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE R6_C7_CHECK_PT4_PLAYER2
	JMP C1_R1_CHECK_PLAYER2 

R6_C7_CHECK_PT4_PLAYER2:

	CMP row6[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C1_R1_CHECK_PLAYER2 



C1_R1_CHECK_PLAYER2:

	CMP row1[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R2_CHECK_PLAYER2
	JMP C2_R1_CHECK_PLAYER2 

C1_R2_CHECK_PLAYER2:

	CMP row2[2], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R3_CHECK_PLAYER2
	JMP C2_R1_CHECK_PLAYER2 

C1_R3_CHECK_PLAYER2:

	CMP row3[2], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK_PLAYER2
	JMP C2_R1_CHECK_PLAYER2

C1_R4_CHECK_PLAYER2:

	CMP row4[2], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C2_R1_CHECK_PLAYER2



C2_R1_CHECK_PLAYER2:

	CMP row1[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R2_CHECK_PLAYER2
	JMP C3_R1_CHECK_PLAYER2 

C2_R2_CHECK_PLAYER2:

	CMP row2[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R3_CHECK_PLAYER2
	JMP C3_R1_CHECK_PLAYER2 

C2_R3_CHECK_PLAYER2:

	CMP row3[8], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK_PLAYER2
	JMP C3_R1_CHECK_PLAYER2

C2_R4_CHECK_PLAYER2:

	CMP row4[8], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C3_R1_CHECK_PLAYER2



C3_R1_CHECK_PLAYER2:

	CMP row1[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R2_CHECK_PLAYER2
	JMP C4_R1_CHECK_PLAYER2 

C3_R2_CHECK_PLAYER2:

	CMP row2[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R3_CHECK_PLAYER2
	JMP C4_R1_CHECK_PLAYER2 

C3_R3_CHECK_PLAYER2:

	CMP row3[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK_PLAYER2
	JMP C4_R1_CHECK_PLAYER2

C3_R4_CHECK_PLAYER2:

	CMP row4[14], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C4_R1_CHECK_PLAYER2



C4_R1_CHECK_PLAYER2:

	CMP row1[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R2_CHECK_PLAYER2
	JMP C5_R1_CHECK_PLAYER2 

C4_R2_CHECK_PLAYER2:

	CMP row2[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R3_CHECK_PLAYER2
	JMP C5_R1_CHECK_PLAYER2 

C4_R3_CHECK_PLAYER2:

	CMP row3[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK_PLAYER2
	JMP C5_R1_CHECK_PLAYER2

C4_R4_CHECK_PLAYER2:

	CMP row4[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C5_R1_CHECK_PLAYER2



C5_R1_CHECK_PLAYER2:

	CMP row1[26], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R2_CHECK_PLAYER2
	JMP C6_R1_CHECK_PLAYER2 

C5_R2_CHECK_PLAYER2:

	CMP row2[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R3_CHECK_PLAYER2
	JMP C6_R1_CHECK_PLAYER2 

C5_R3_CHECK_PLAYER2:

	CMP row3[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK_PLAYER2
	JMP C6_R1_CHECK_PLAYER2

C5_R4_CHECK_PLAYER2:

	CMP row4[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C6_R1_CHECK_PLAYER2



C6_R1_CHECK_PLAYER2:

	CMP row1[32], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R2_CHECK_PLAYER2
	JMP C7_R1_CHECK_PLAYER2 

C6_R2_CHECK_PLAYER2:

	CMP row2[32], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R3_CHECK_PLAYER2
	JMP C7_R1_CHECK_PLAYER2 

C6_R3_CHECK_PLAYER2:

	CMP row3[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK_PLAYER2
	JMP C7_R1_CHECK_PLAYER2

C6_R4_CHECK_PLAYER2:

	CMP row4[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C7_R1_CHECK_PLAYER2



C7_R1_CHECK_PLAYER2:

	CMP row1[38], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R2_CHECK_PLAYER2
	JMP C1_R2_CHECK_PT2_PLAYER2 

C7_R2_CHECK_PLAYER2:

	CMP row2[38], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R3_CHECK_PLAYER2
	JMP C1_R2_CHECK_PT2_PLAYER2  

C7_R3_CHECK_PLAYER2:

	CMP row3[38], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK_PLAYER2
	JMP C1_R2_CHECK_PT2_PLAYER2 

C7_R4_CHECK_PLAYER2:

	CMP row4[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C1_R2_CHECK_PT2_PLAYER2 



C1_R2_CHECK_PT2_PLAYER2:

	CMP row2[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R3_CHECK_PT2_PLAYER2
	JMP C2_R2_CHECK_PT2_PLAYER2

C1_R3_CHECK_PT2_PLAYER2:

	CMP row3[2], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK_PT2_PLAYER2
	JMP C2_R2_CHECK_PT2_PLAYER2 

C1_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[2], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R5_CHECK_PT2_PLAYER2
	JMP C2_R2_CHECK_PT2_PLAYER2

C1_R5_CHECK_PT2_PLAYER2:

	CMP row5[2], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C2_R2_CHECK_PT2_PLAYER2



C2_R2_CHECK_PT2_PLAYER2:

	CMP row2[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R3_CHECK_PT2_PLAYER2
	JMP C3_R2_CHECK_PT2_PLAYER2

C2_R3_CHECK_PT2_PLAYER2:

	CMP row3[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK_PT2_PLAYER2
	JMP C3_R2_CHECK_PT2_PLAYER2 

C2_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[8], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R5_CHECK_PT2_PLAYER2
	JMP C3_R2_CHECK_PT2_PLAYER2

C2_R5_CHECK_PT2_PLAYER2:

	CMP row5[8], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C3_R2_CHECK_PT2_PLAYER2



C3_R2_CHECK_PT2_PLAYER2:

	CMP row2[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R3_CHECK_PT2_PLAYER2
	JMP C4_R2_CHECK_PT2_PLAYER2

C3_R3_CHECK_PT2_PLAYER2:

	CMP row3[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK_PT2_PLAYER2
	JMP C4_R2_CHECK_PT2_PLAYER2 

C3_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R5_CHECK_PT2_PLAYER2
	JMP C4_R2_CHECK_PT2_PLAYER2

C3_R5_CHECK_PT2_PLAYER2:

	CMP row5[14], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C4_R2_CHECK_PT2_PLAYER2



C4_R2_CHECK_PT2_PLAYER2:

	CMP row2[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R3_CHECK_PT2_PLAYER2
	JMP C5_R2_CHECK_PT2_PLAYER2

C4_R3_CHECK_PT2_PLAYER2:

	CMP row3[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK_PT2_PLAYER2
	JMP C5_R2_CHECK_PT2_PLAYER2 

C4_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R5_CHECK_PT2_PLAYER2
	JMP C5_R2_CHECK_PT2_PLAYER2

C4_R5_CHECK_PT2_PLAYER2:

	CMP row5[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C5_R2_CHECK_PT2_PLAYER2



C5_R2_CHECK_PT2_PLAYER2:

	CMP row2[26], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R3_CHECK_PT2_PLAYER2
	JMP C6_R2_CHECK_PT2_PLAYER2

C5_R3_CHECK_PT2_PLAYER2:

	CMP row3[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK_PT2_PLAYER2
	JMP C6_R2_CHECK_PT2_PLAYER2 

C5_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R5_CHECK_PT2_PLAYER2
	JMP C6_R2_CHECK_PT2_PLAYER2

C5_R5_CHECK_PT2_PLAYER2:

	CMP row5[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C6_R2_CHECK_PT2_PLAYER2



C6_R2_CHECK_PT2_PLAYER2:

	CMP row2[32], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R3_CHECK_PT2_PLAYER2
	JMP C7_R2_CHECK_PT2_PLAYER2

C6_R3_CHECK_PT2_PLAYER2:

	CMP row3[32], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK_PT2_PLAYER2
	JMP C7_R2_CHECK_PT2_PLAYER2 

C6_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R5_CHECK_PT2_PLAYER2
	JMP C7_R2_CHECK_PT2_PLAYER2

C6_R5_CHECK_PT2_PLAYER2:

	CMP row5[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C7_R2_CHECK_PT2_PLAYER2



C7_R2_CHECK_PT2_PLAYER2:

	CMP row2[38], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R3_CHECK_PT2_PLAYER2
	JMP C1_R3_CHECK_PT3_PLAYER2

C7_R3_CHECK_PT2_PLAYER2:

	CMP row3[38], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK_PT2_PLAYER2
	JMP C1_R3_CHECK_PT3_PLAYER2 

C7_R4_CHECK_PT2_PLAYER2:
	
	CMP row4[38], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R5_CHECK_PT2_PLAYER2
	JMP C1_R3_CHECK_PT3_PLAYER2

C7_R5_CHECK_PT2_PLAYER2:

	CMP row5[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER 
	JMP C1_R3_CHECK_PT3_PLAYER2



C1_R3_CHECK_PT3_PLAYER2:

	CMP row3[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C1_R4_CHECK_PT3_PLAYER2
	JMP C2_R3_CHECK_PT3_PLAYER2

C1_R4_CHECK_PT3_PLAYER2:

	CMP row4[2], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C1_R5_CHECK_PT3_PLAYER2
	JMP C2_R3_CHECK_PT3_PLAYER2

C1_R5_CHECK_PT3_PLAYER2:

	CMP row5[2], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C1_R6_CHECK_PT3_PLAYER2
	JMP C2_R3_CHECK_PT3_PLAYER2

C1_R6_CHECK_PT3_PLAYER2:

	CMP row6[2], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C2_R3_CHECK_PT3_PLAYER2



C2_R3_CHECK_PT3_PLAYER2:

	CMP row3[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE C2_R4_CHECK_PT3_PLAYER2
	JMP C3_R3_CHECK_PT3_PLAYER2

C2_R4_CHECK_PT3_PLAYER2:

	CMP row4[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE C2_R5_CHECK_PT3_PLAYER2
	JMP C3_R3_CHECK_PT3_PLAYER2

C2_R5_CHECK_PT3_PLAYER2:

	CMP row5[8], 64													; If 3 == player1s symbol, jmp to winning msg/process
	JE C2_R6_CHECK_PT3_PLAYER2
	JMP C3_R3_CHECK_PT3_PLAYER2

C2_R6_CHECK_PT3_PLAYER2:

	CMP row6[8], 64													; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C3_R3_CHECK_PT3_PLAYER2



C3_R3_CHECK_PT3_PLAYER2:

	CMP row3[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C3_R4_CHECK_PT3_PLAYER2
	JMP C4_R3_CHECK_PT3_PLAYER2

C3_R4_CHECK_PT3_PLAYER2:

	CMP row4[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C3_R5_CHECK_PT3_PLAYER2
	JMP C4_R3_CHECK_PT3_PLAYER2

C3_R5_CHECK_PT3_PLAYER2:

	CMP row5[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C3_R6_CHECK_PT3_PLAYER2
	JMP C4_R3_CHECK_PT3_PLAYER2

C3_R6_CHECK_PT3_PLAYER2:

	CMP row6[14], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C4_R3_CHECK_PT3_PLAYER2



C4_R3_CHECK_PT3_PLAYER2:

	CMP row3[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C4_R4_CHECK_PT3_PLAYER2
	JMP C5_R3_CHECK_PT3_PLAYER2

C4_R4_CHECK_PT3_PLAYER2:

	CMP row4[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C4_R5_CHECK_PT3_PLAYER2
	JMP C5_R3_CHECK_PT3_PLAYER2

C4_R5_CHECK_PT3_PLAYER2:

	CMP row5[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C4_R6_CHECK_PT3_PLAYER2
	JMP C5_R3_CHECK_PT3_PLAYER2

C4_R6_CHECK_PT3_PLAYER2:

	CMP row6[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C5_R3_CHECK_PT3_PLAYER2



C5_R3_CHECK_PT3_PLAYER2:

	CMP row3[26], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C5_R4_CHECK_PT3_PLAYER2
	JMP C6_R3_CHECK_PT3_PLAYER2

C5_R4_CHECK_PT3_PLAYER2:

	CMP row4[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C5_R5_CHECK_PT3_PLAYER2
	JMP C6_R3_CHECK_PT3_PLAYER2

C5_R5_CHECK_PT3_PLAYER2:

	CMP row5[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C5_R6_CHECK_PT3_PLAYER2
	JMP C6_R3_CHECK_PT3_PLAYER2

C5_R6_CHECK_PT3_PLAYER2:

	CMP row6[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C6_R3_CHECK_PT3_PLAYER2



C6_R3_CHECK_PT3_PLAYER2:

	CMP row3[32], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C6_R4_CHECK_PT3_PLAYER2
	JMP C7_R3_CHECK_PT3_PLAYER2

C6_R4_CHECK_PT3_PLAYER2:

	CMP row4[32], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C6_R5_CHECK_PT3_PLAYER2
	JMP C7_R3_CHECK_PT3_PLAYER2

C6_R5_CHECK_PT3_PLAYER2:

	CMP row5[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C6_R6_CHECK_PT3_PLAYER2
	JMP C7_R3_CHECK_PT3_PLAYER2

C6_R6_CHECK_PT3_PLAYER2:

	CMP row6[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP C7_R3_CHECK_PT3_PLAYER2



C7_R3_CHECK_PT3_PLAYER2:

	CMP row3[38], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE C7_R4_CHECK_PT3_PLAYER2
	JMP DIAG_CHECK1_PLAYER2

C7_R4_CHECK_PT3_PLAYER2:

	CMP row4[38], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE C7_R5_CHECK_PT3_PLAYER2
	JMP DIAG_CHECK1_PLAYER2

C7_R5_CHECK_PT3_PLAYER2:

	CMP row5[38], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE C7_R6_CHECK_PT3_PLAYER2
	JMP DIAG_CHECK1_PLAYER2

C7_R6_CHECK_PT3_PLAYER2:

	CMP row6[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK1_PLAYER2



DIAG_CHECK1_PLAYER2:

	CMP row4[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT2_PLAYER2
	JMP DIAG_CHECK2_PLAYER2

DIAG_CHECK1_PT2_PLAYER2:

	CMP row3[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT3_PLAYER2
	JMP DIAG_CHECK2_PLAYER2

DIAG_CHECK1_PT3_PLAYER2:

	CMP row2[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK1_PT4_PLAYER2
	JMP DIAG_CHECK2_PLAYER2

DIAG_CHECK1_PT4_PLAYER2:

	CMP row1[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK2_PLAYER2



DIAG_CHECK2_PLAYER2:

	CMP row5[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT2_PLAYER2
	JMP DIAG_CHECK3_PLAYER2

DIAG_CHECK2_PT2_PLAYER2:

	CMP row4[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT3_PLAYER2
	JMP DIAG_CHECK3_PLAYER2

DIAG_CHECK2_PT3_PLAYER2:

	CMP row3[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK2_PT4_PLAYER2
	JMP DIAG_CHECK3_PLAYER2

DIAG_CHECK2_PT4_PLAYER2:

	CMP row2[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK3_PLAYER2



DIAG_CHECK3_PLAYER2:

	CMP row4[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT2_PLAYER2
	JMP DIAG_CHECK4_PLAYER2

DIAG_CHECK3_PT2_PLAYER2:

	CMP row3[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT3_PLAYER2
	JMP DIAG_CHECK4_PLAYER2

DIAG_CHECK3_PT3_PLAYER2:

	CMP row2[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK3_PT4_PLAYER2
	JMP DIAG_CHECK4_PLAYER2

DIAG_CHECK3_PT4_PLAYER2:

	CMP row1[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK4_PLAYER2



DIAG_CHECK4_PLAYER2:

	CMP row6[2], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT2_PLAYER2
	JMP DIAG_CHECK5_PLAYER2

DIAG_CHECK4_PT2_PLAYER2:

	CMP row5[8], 64													; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT3_PLAYER2
	JMP DIAG_CHECK5_PLAYER2

DIAG_CHECK4_PT3_PLAYER2:

	CMP row4[14], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK4_PT4_PLAYER2
	JMP DIAG_CHECK5_PLAYER2

DIAG_CHECK4_PT4_PLAYER2:

	CMP row3[20], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK5_PLAYER2



DIAG_CHECK5_PLAYER2:

	CMP row5[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT2_PLAYER2
	JMP DIAG_CHECK6_PLAYER2

DIAG_CHECK5_PT2_PLAYER2:

	CMP row4[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT3_PLAYER2
	JMP DIAG_CHECK6_PLAYER2

DIAG_CHECK5_PT3_PLAYER2:

	CMP row3[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK5_PT4_PLAYER2
	JMP DIAG_CHECK6_PLAYER2

DIAG_CHECK5_PT4_PLAYER2:

	CMP row2[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK6_PLAYER2



DIAG_CHECK6_PLAYER2:

	CMP row4[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT2_PLAYER2
	JMP DIAG_CHECK7_PLAYER2

DIAG_CHECK6_PT2_PLAYER2:

	CMP row3[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT3_PLAYER2
	JMP DIAG_CHECK7_PLAYER2

DIAG_CHECK6_PT3_PLAYER2:

	CMP row2[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK6_PT4_PLAYER2
	JMP DIAG_CHECK7_PLAYER2

DIAG_CHECK6_PT4_PLAYER2:

	CMP row1[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK7_PLAYER2



DIAG_CHECK7_PLAYER2:

	CMP row6[8], 64													; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT2_PLAYER2
	JMP DIAG_CHECK8_PLAYER2

DIAG_CHECK7_PT2_PLAYER2:

	CMP row5[14], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT3_PLAYER2
	JMP DIAG_CHECK8_PLAYER2

DIAG_CHECK7_PT3_PLAYER2:

	CMP row4[20], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK7_PT4_PLAYER2
	JMP DIAG_CHECK8_PLAYER2

DIAG_CHECK7_PT4_PLAYER2:

	CMP row3[26], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK8_PLAYER2



DIAG_CHECK8_PLAYER2:

	CMP row5[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT2_PLAYER2
	JMP DIAG_CHECK9_PLAYER2

DIAG_CHECK8_PT2_PLAYER2:

	CMP row4[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT3_PLAYER2
	JMP DIAG_CHECK9_PLAYER2

DIAG_CHECK8_PT3_PLAYER2:

	CMP row3[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK8_PT4_PLAYER2
	JMP DIAG_CHECK9_PLAYER2

DIAG_CHECK8_PT4_PLAYER2:

	CMP row2[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK9_PLAYER2



DIAG_CHECK9_PLAYER2:

	CMP row4[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT2_PLAYER2
	JMP DIAG_CHECK10_PLAYER2

DIAG_CHECK9_PT2_PLAYER2:

	CMP row3[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT3
	JMP DIAG_CHECK10_PLAYER2

DIAG_CHECK9_PT3_PLAYER2:

	CMP row2[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK9_PT4_PLAYER2
	JMP DIAG_CHECK10_PLAYER2

DIAG_CHECK9_PT4_PLAYER2:

	CMP row1[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK10_PLAYER2



DIAG_CHECK10_PLAYER2:

	CMP row6[14], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT2_PLAYER2
	JMP DIAG_CHECK11_PLAYER2

DIAG_CHECK10_PT2_PLAYER2:

	CMP row5[20], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT3_PLAYER2
	JMP DIAG_CHECK11_PLAYER2

DIAG_CHECK10_PT3_PLAYER2:

	CMP row4[26], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK10_PT4_PLAYER2
	JMP DIAG_CHECK11_PLAYER2

DIAG_CHECK10_PT4_PLAYER2:

	CMP row3[32], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK11_PLAYER2



DIAG_CHECK11_PLAYER2:

	CMP row5[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT2_PLAYER2
	JMP DIAG_CHECK12_PLAYER2

DIAG_CHECK11_PT2_PLAYER2:

	CMP row4[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT3_PLAYER2
	JMP DIAG_CHECK12_PLAYER2

DIAG_CHECK11_PT3_PLAYER2:

	CMP row3[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK11_PT4_PLAYER2
	JMP DIAG_CHECK12_PLAYER2

DIAG_CHECK11_PT4_PLAYER2:

	CMP row2[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
	JE WINNER
	JMP DIAG_CHECK12_PLAYER2



DIAG_CHECK12_PLAYER2:

	CMP row6[20], 64												; If 1 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT2_PLAYER2
	JMP CHECK_WIN_EXIT

DIAG_CHECK12_PT2_PLAYER2:

	CMP row5[26], 64												; If 2 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT3_PLAYER2
	JMP CHECK_WIN_EXIT

DIAG_CHECK12_PT3_PLAYER2:

	CMP row4[32], 64												; If 3 == player1s symbol, jmp to winning msg/process
	JE DIAG_CHECK12_PT4_PLAYER2
	JMP CHECK_WIN_EXIT

DIAG_CHECK12_PT4_PLAYER2:

	CMP row3[38], 64												; If 4 == player1s symbol, jmp to winning msg/process
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



	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run
	
	MOV col1_curr_index, 1											; Next 7 lines reset column pointers
	MOV col2_curr_index, 1
	MOV col3_curr_index, 1
	MOV col4_curr_index, 1
	MOV col5_curr_index, 1
	MOV col6_curr_index, 1
	MOV col7_curr_index, 1


	MOV row1[2], 120												; Next 7 lines simply resets the visual board that
	MOV row1[8], 120												; end user sees with the char x
	MOV row1[14], 120
	MOV row1[20], 120
	MOV row1[26], 120
	MOV row1[32], 120
	MOV row1[38], 120

	MOV row2[2], 120												; Next 7 lines simply resets the visual board that
	MOV row2[8], 120												; end user sees with the char x
	MOV row2[14], 120
	MOV row2[20], 120
	MOV row2[26], 120
	MOV row2[32], 120
	MOV row2[38], 120

	MOV row3[2], 120												; Next 7 lines simply resets the visual board that
	MOV row3[8], 120												; end user sees with the char x
	MOV row3[14], 120
	MOV row3[20], 120
	MOV row3[26], 120
	MOV row3[32], 120
	MOV row3[38], 120

	MOV row4[2], 120												; Next 7 lines simply resets the visual board that
	MOV row4[8], 120												; end user sees with the char x
	MOV row4[14], 120
	MOV row4[20], 120
	MOV row4[26], 120
	MOV row4[32], 120
	MOV row4[38], 120

	MOV row5[2], 120												; Next 7 lines simply resets the visual board that
	MOV row5[8], 120												; end user sees with the char x
	MOV row5[14], 120
	MOV row5[20], 120
	MOV row5[26], 120
	MOV row5[32], 120
	MOV row5[38], 120

	MOV row6[2], 120												; Next 7 lines simply resets the visual board that
	MOV row6[8], 120												; end user sees with the char x
	MOV row6[14], 120
	MOV row6[20], 120
	MOV row6[26], 120
	MOV row6[32], 120
	MOV row6[38], 120



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
	
L1_PLAYER2:

	MOV EAX, 0
	MOV [EDI], EAX													; Move zeroes into current player1 & player2 array indexes
	MOV [ESI], EAX
	ADD EDI, 4														; Increment index pointers & loop until both full names have
	ADD ESI, 4														; been properly reset

	LOOP L1_PLAYER2



	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run

	MOV col1_curr_index, 1											; Next 7 lines reset column pointers
	MOV col2_curr_index, 1
	MOV col3_curr_index, 1
	MOV col4_curr_index, 1
	MOV col5_curr_index, 1
	MOV col6_curr_index, 1
	MOV col7_curr_index, 1


	MOV row1[2], 120												; Next 7 lines simply resets the visual board that
	MOV row1[8], 120												; end user sees with the char x
	MOV row1[14], 120
	MOV row1[20], 120
	MOV row1[26], 120
	MOV row1[32], 120
	MOV row1[38], 120

	MOV row2[2], 120												; Next 7 lines simply resets the visual board that
	MOV row2[8], 120												; end user sees with the char x
	MOV row2[14], 120
	MOV row2[20], 120
	MOV row2[26], 120
	MOV row2[32], 120
	MOV row2[38], 120

	MOV row3[2], 120												; Next 7 lines simply resets the visual board that
	MOV row3[8], 120												; end user sees with the char x
	MOV row3[14], 120
	MOV row3[20], 120
	MOV row3[26], 120
	MOV row3[32], 120
	MOV row3[38], 120

	MOV row4[2], 120												; Next 7 lines simply resets the visual board that
	MOV row4[8], 120												; end user sees with the char x
	MOV row4[14], 120
	MOV row4[20], 120
	MOV row4[26], 120
	MOV row4[32], 120
	MOV row4[38], 120

	MOV row5[2], 120												; Next 7 lines simply resets the visual board that
	MOV row5[8], 120												; end user sees with the char x
	MOV row5[14], 120
	MOV row5[20], 120
	MOV row5[26], 120
	MOV row5[32], 120
	MOV row5[38], 120

	MOV row6[2], 120												; Next 7 lines simply resets the visual board that
	MOV row6[8], 120												; end user sees with the char x
	MOV row6[14], 120
	MOV row6[20], 120
	MOV row6[26], 120
	MOV row6[32], 120
	MOV row6[38], 120


	
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
	MOV EDX, OFFSET row_top											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row6											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row5											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row_split										; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
	CALL Crlf														; Insert newline for readability
	MOV EDX, OFFSET row4											; WriteStr proc uses EDX as register to read from
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
	MOV EDX, OFFSET row2											; WriteStr proc uses EDX as register to read from
	CALL WriteString												; WriteStr proc call
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
	
L1_PLAYER2:

	MOV EAX, 0
	MOV [EDI], EAX													; Move zeroes into current player1 & player2 array indexes
	MOV [ESI], EAX
	ADD EDI, 4														; Increment index pointers & loop until both full names have
	ADD ESI, 4														; been properly reset

	LOOP L1_PLAYER2

	MOV player_turn, 1												; Restart from player 1 turn
	MOV draw_counter, 0												; Reser draw_counter to 0 for program re-run

	MOV col1_curr_index, 1											; Next 7 lines reset column pointers
	MOV col2_curr_index, 1
	MOV col3_curr_index, 1
	MOV col4_curr_index, 1
	MOV col5_curr_index, 1
	MOV col6_curr_index, 1
	MOV col7_curr_index, 1

	MOV row1[2], 120												; Next 7 lines simply resets the visual board that
	MOV row1[8], 120												; end user sees with the char x
	MOV row1[14], 120
	MOV row1[20], 120
	MOV row1[26], 120
	MOV row1[32], 120
	MOV row1[38], 120

	MOV row2[2], 120												; Next 7 lines simply resets the visual board that
	MOV row2[8], 120												; end user sees with the char x
	MOV row2[14], 120
	MOV row2[20], 120
	MOV row2[26], 120
	MOV row2[32], 120
	MOV row2[38], 120

	MOV row3[2], 120												; Next 7 lines simply resets the visual board that
	MOV row3[8], 120												; end user sees with the char x
	MOV row3[14], 120
	MOV row3[20], 120
	MOV row3[26], 120
	MOV row3[32], 120
	MOV row3[38], 120

	MOV row4[2], 120												; Next 7 lines simply resets the visual board that
	MOV row4[8], 120												; end user sees with the char x
	MOV row4[14], 120
	MOV row4[20], 120
	MOV row4[26], 120
	MOV row4[32], 120
	MOV row4[38], 120

	MOV row5[2], 120												; Next 7 lines simply resets the visual board that
	MOV row5[8], 120												; end user sees with the char x
	MOV row5[14], 120
	MOV row5[20], 120
	MOV row5[26], 120
	MOV row5[32], 120
	MOV row5[38], 120

	MOV row6[2], 120												; Next 7 lines simply resets the visual board that
	MOV row6[8], 120												; end user sees with the char x
	MOV row6[14], 120
	MOV row6[20], 120
	MOV row6[26], 120
	MOV row6[32], 120
	MOV row6[38], 120


	
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
