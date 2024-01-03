TITLE Project 6 - String Primitives and Macros      (Proj6_danielde.asm)

; Author: Devin Daniels
; Last Modified: 3/19/2023
; OSU email address: danielde@oregonstate.edu
; Course number/section: CS271 Section: 400
; Project Number:6  
; Due Date: 3/19/2023
; Description: This is the portfolio assignment for the course. The focus is on designing, implementing, and calling low-level I/O procedures.
;				; It also requires the implementation and usage of macros. 

INCLUDE Irvine32.inc

; ---------------------------------------------------------------------------------
; Name: mGetString
;
; Prompt the user to enter a string via the console
;
; Preconditions: Prompt and size are defined
;
; Postconditions: Saves, used , and restores EAX, ECX, and EDX
;
; Receives:
; prompt = prompt address
; size = allowable size of input string
; outStr = address of buffer
; outSize = actual size of output buffer
;
; returns: outStr =  string address and outSize = count of string buffer
; ---------------------------------------------------------------------------------

mGetString MACRO prompt:REQ, size:REQ, outStr:REQ, outSize:REQ
	; Preserve regs
	push	EAX
	push	ECX
	push	EDX

	mov		EDX, prompt
	call	WriteString
	mov		EDX, outStr					; Address for storing user input in EDX
	mov		ECX, size					; Max length of user input
	call	ReadString
	mov		[outSize], EAX	; Save length of user input

	; Restore regs
	pop		EDX
	pop		ECX
	pop		EAX
	
ENDM


; ---------------------------------------------------------------------------------
; Name: mDisplayString
;
; Displays a message to the console
;
; Preconditions: Must recieve an address
;
; Postconditions: Saves, used, and restores EDX
;
; Receives:
; strAddress = address of a string to print 
;
; returns: N/A, just prints to console
; ---------------------------------------------------------------------------------

mDisplayString MACRO strAddress:REQ
	push	EDX
	mov		EDX, strAddress
	call	WriteString
	pop		EDX
ENDM



; (insert constant definitions here)
ARRAY_SIZE = 5
MAX_STR_LEN = 12
HI = 39h
LO = 30h
LARGEST EQU 2147483647
SMALLEST EQU -2147483648
PLUS EQU '+'
NEGATIVE EQU '-'

.data

; (insert variable definitions here)
programIntro	BYTE "CS271 Final Project 6: Designing low-level I/O procedures. Written by Devin Daniels", 13, 10, 13, 10, 0
programDesc		BYTE "Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32 bit register. "
				BYTE "After you have finished inputting the raw numbers I will display a list of the integers,"
				BYTE " their sum, and their average value. ", 13, 10, 0

getStrPrompt	BYTE "Please enter an signed number: ", 0
errorMsg		BYTE "ERROR: You did not enter an signed number or your number was too big. ", 13, 10, 0 
inputStr		BYTE MAX_STR_LEN DUP(?)
stringLen		DWORD ?
outputInt		SDWORD ?
errorFlag		DWORD ? 
numsList		SDWORD ARRAY_SIZE DUP(?)
countList		DWORD  ARRAY_SIZE DUP(?)
sum				SDWORD 0
sumMsg			BYTE "The sum of these numbers is: ", 0 
entriesMsg		BYTE "You entered the following numbers:", 13, 10 , 0
average			SDWORD ? 
avgMsg			BYTE "The truncated average is: ", 0

.code
main PROC

	; Introduce the program
	mDisplayString OFFSET programIntro
	call	CrLF
	mDisplayString OFFSET programDesc
	call	CrLf
	


	; Set up 
	xor		EAX, EAX
	xor		EBX, EBX
	xor		ECX, ECX
	xor		EDX, EDX
	xor		EDI, EDI
	xor		ESI, ESI


	
	; Save starting address of numsList in EDI
	mov		EDI, OFFSET numsList
	; Init starting values for filling the array with user SDWORDS
	mov		EBX, 0 
	mov		ECX, ARRAY_SIZE
	_fillArrayWithIntegersLoop: 
		; Init error flag
		mov		errorFlag, 0
		; Push ReadVal arguements on stack				
		push	OFFSET outputInt			; Holds valid integer after conversion 
		push	OFFSET errorMsg				; Error message to user 
		push	OFFSET errorFlag			; Set if user enters invalid input in ReadVal
		push	OFFSET stringLen			; LENGTHOF output 
		push	OFFSET inputStr				; Used in mGetString to get user input 
		push	OFFSET getStrPrompt			; Message to user to enter a string 
		call	ReadVal
		; Check if user input (outputInt) is valid
		mov		EAX, errorFlag
		cmp		EAX, 1
		je		_fillArrayWithIntegersLoop
		; Valid value, push value and length of value into the arrays
		mov		EAX, outputInt
		mov		[EDI + 4 * EBX], EAX
		; Save the stringLen in adjacency array
		push	EDI
		mov		EDI, OFFSET countList
		mov		EAX, stringLen
		mov		[EDI + 4 * EBX], EAX
		pop		EDI
		; Increment index counter
		inc		EBX
		; Add to running sum 
		mov		EAX, sum
		add		EAX, outputInt
		mov		sum, EAX
	loop _fillArrayWithIntegersLoop


	; Save starting address of numsList in EDI
	mov		EDI, OFFSET numsList
	; Init starting values for filling the array with user SDWORDS
	mov		EBX, 0 
	mov		ECX, ARRAY_SIZE
	mov		inputStr, 0 
	; Display a intro before showing the numbers 
	call	CrLf
	mDisplayString	OFFSET entriesMsg
	_displayArrayLoop:
		; Get the i-th value from the array and push on stack
		mov		EAX, [EDI + 4 * EBX]
		push	EDI
		mov		EDI, OFFSET countList
		mov		EDX, [EDI + 4 * EBX]
		pop		EDI
		push	EDX						; The length of integer to convert
		push	OFFSET inputStr			; buffer
		push	EAX						; The integer to convert
		call	WriteVal
		push	EAX
		mov		AL, TAB
		call	WriteChar
		pop		EAX
		; Increment iterator
		inc		EBX
	loop	_displayArrayLoop


	
	; Print the sum 
	call	CrLf
	call	CrLf
	mDisplayString OFFSET sumMsg
	push	OFFSET inputStr
	push	sum
	call	GetIntegerLen


	; Print the truncated average
	call	CrLf
	call	CrLf
	mDisplayString OFFSET avgMsg
	; Calulcate the average
	xor		EDX, EDX
	mov		EAX, sum
	mov		EBX, ARRAY_SIZE
	cdq
	idiv	EBX
	push	OFFSET inputStr
	push	EAX
	call	GetIntegerLen



	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: ReadVal
;
; Description: Uses mGetString MACRO to get a user input as string. Convert (using string primitives) the string of ascii digits to its
;			numeric value representation (SDWORD),
;			validating the user�s input is a valid number (no letters, symbols, etc). 
;
; Preconditions: mGetString must be defined. Parameters for the MACRO must be passed on the stack along with I/O parameters for this PROC.
;
; Postconditions: Must clean up the stack frame. Must restore registers. EBP, EAX, EBX, ECX, EDX, EDI, ESI are changed. 
;
; Receives: 
; [ebp+32] = local variable for various purposes (doesn't recieve, is used locally)
; [ebp+28] = address output variable (holds integer after successful conversion from string)
; [ebp+24] = address of error message
; [ebp+20] = address of errorFlag variable
; [ebp+16] = address of stringLen variable
; [ebp+12] = address inputStr variable
; [ebp+8] =  address of getStrPrompt variable
; arrayMsg, arrayError are global variables
;
; Returns: Pops 

; Notes: [EBP + 32] is local variable for tracking status of sign of inputString
;	0: Not checked yet
;	1: +
;	2: -
;	3: no sign
; ---------------------------------------------------

ReadVal PROC
	; Build Stack Frame
	push	EBP             
	mov		EBP, ESP
	; Preserve registers
	push	EAX
	push	EBX
	push	ECX
	push	EDX
	push	EDI
	push	ESI

	; get a string from the user 
	
	; Address is overwritten in MACRO, save before assigning length stringLen
	push	EDI
	mov		EDI, [EBP + 16]
	
	mGetString [EBP + 8], MAX_STR_LEN, [EBP + 12], [EBP + 16]

	xor		EAX, EAX
	mov		EAX, [EBP + 16]
	mov		DWORD PTR [EDI], EAX
	mov		[EBP + 16], EDI
	pop		EDI
	; Check if stringLen is 0
	cmp		EAX, 0 
	je		_error
	 ; Clear direction flag
	cld
	; ESI holds the user string
	mov		ESI, [EBP + 12 ]	
	; EDI holds the converted string-to-integer (outputInt)
	mov		EDI, [EBP + 28]
	; Init EDI to 0 
	mov		EDI, [EBP + 28]
	mov		SDWORD PTR [EDI], 0
	; init local hasSign variable to 0 
	mov		DWORD PTR [EBP + 32], 0
	; Init ECX register for buffer use
	xor		ECX, ECX
	xor		EAX, EAX
	mov		EDX, 0 
	_iterate_char:
	; Reset EAX on each iteration 
		mov		EAX, 0
		; Load the next string bit pointed to by ESI
		LODSB	
		; Check for null terminating 0
		cmp		AL, 0
		je		_determineSign
		; If zero, then at index 0 of EDI and need to check for sign 
		cmp		DWORD PTR [EBP + 32], 0
		jne		_continue_iterate_char
		cmp		AL, PLUS
		je		_hasPostitive
		cmp		AL, NEGATIVE
		je		_hasNegative
		; No sign, set local variable to indicate this and continue
		; Set local variable [EBP + 32] 3 = no sign 
		mov		DWORD PTR [EBP + 32], 3
	_continue_iterate_char:
		cmp		AL, LO
		jl		_error
		cmp		AL, HI
		jg		_error
		; At this point, AL holds a valid string num -- now convert and add 
		; Convert char to integer
		sub		AL, 48
		push	EAX
		; Perform calculation
		mov		EAX, ECX
		mov		EBX, 10
		mul		EBX
		pop		EBX
		jo		_error
		add		EAX, EBX
		; Converted number now in EAX, check if it fits in SDWORD
		jo		_error
		; Valid numnber, add to ECX buffer
		mov		ECX, EAX
		jmp		_iterate_char
	

	_hasPostitive:
		; Decrement stringLen by 1
		mov		EAX, [EBP + 16]
		dec		DWORD PTR [EAX]
		; Set local variable [EBP + 32] = 1
		mov		DWORD PTR [EBP + 32], 1
		; Check if stringLen is 1
		mov		EBX, [ EAX]
		cmp		EBX, 0
		je		_error
		jmp		_iterate_char
		
	_hasNegative:
		; Decrement stringLen by 1
		mov		EAX, [EBP + 16]
		dec		DWORD PTR [EAX]
		; Set local variable [EBP + 32] =  2
		mov		DWORD PTR [EBP + 32], 2
		mov		EBX, [ EAX]
		cmp		EBX, 0
		je		_error
		jmp		_iterate_char


	_error:
		mov		EBX, [EBP + 20]
		; Set errorFlag used in main
		mov		DWORD PTR [EBX], 1 
		mDisplayString [EBP + 24]
		jmp		_finished


	_determineSign: 
		; Get the sign flag
		mov		EAX, [EBP + 32]
		cmp		EAX, 2
		je		_handleNeg
		; Not negative, save variables and finish
		mov		EAX, [EBP + 28]
		mov		[EAX], ECX
		jmp		_finished


	_handleNeg: 
	; Two's complement negation
		neg		ECX
		mov		EAX, [EBP + 28]
		mov		[EAX], ECX
		jmp		_finished


	_finished:
		;Restore registers 
		pop		ESI
		pop		EDI
		pop		EDX
		pop		ECX
		pop		EBX
		pop		EAX
		; Restore stack frame
		pop		EBP

	ret 24
ReadVal ENDP



; ---------------------------------------------------------------------------------
; Name: WriteVal
;
; Description: Converts a integer SDWORD to string using ASCII by adding it to an output buffer and then passes
;			the address of the buffer to a macro called mDisplayString to be printed
;
; Preconditions: The value to be converted needs to be a valid SDWORD, the output string needs to be a pointer with empty contents, and the value for length of string
;				needs to match the actual length 
;
; Postconditions: EBP, EAX, EBX, ECX, ESI, and EDI are also saved, used, and restored
;
; Receives: 
; [ ebp + 16 ] = length of string
; [ ebp + 12 ] = pointer to outStr
; [ ebp + 8 ] = value of integer to convert

; Returns: Returns 12 and calls mDisplayString which will print the value as a string to the console 

; ---------------------------------------------------

WriteVal PROC
	
		push	EBP
		mov		EBP, ESP
		push	EAX
		push	EBX
		push	ECX
		push	ESI
		push	EDI

		mov		EAX, [EBP + 8]			; Integer value to convert
		mov		EDI, [EBP + 12]			; Pointer to output string
		mov		ECX, [EBP + 16]			; Length of string
		mov		ESI, 10					; divisor for decimal conversion
		mov		EBX, 0					; Index for writing to output string


		; Check if the input integer is negative
		cmp		EAX, 0
		jge		_convertToStringPositive
		; True, need to negate and prepend a '-'
		mov		BYTE PTR [EDI], '-' 
		neg		EAX
		inc		EBX
		inc		ECX
		jmp		_convertToStringNegative
		

	_convertToStringPositive:
		; Clear all 4-BYTES of EDX
		xor		EDX,EDX
		; Begin calculation
		div		ESI
		add		EDX, 48
		; Append char to output string in reverse order
		mov		BYTE PTR [ EDI + ECX - 1 ], DL
		inc		EBX
		dec		ECX
		; Check for end of string
		cmp		ECX, 0 
		jne		_convertToStringPositive
		jmp		_finished


	_convertToStringNegative:
		; Clear all 4-BYTES of EDX
		xor		EDX,EDX
		; Begin calculation
		div		ESI
		add		EDX, 48
		; Append char to output string in reverse order
		mov		BYTE PTR [EDI + ECX - 1 ], DL
		inc		EBX
		dec		ECX
		; Check for end of string
		cmp		ECX, 1 
		jne		_convertToStringNegative


	_finished:
		; Converted string now in EDI --- EBX = stringLen + 1
		mov		BYTE PTR [EDI + EBX], 0 


		; Display the string by passing the address of the output buffer
		mDisplayString [EBP + 12]
		

		; Restore used regs
		pop		EDI
		pop		ESI
		pop		ECX
		pop		EBX
		pop		EAX
		pop		EBP
	
		ret 12

WriteVal ENDP


; ---------------------------------------------------------------------------------
; Name: GetIntegerLen
;
; Description: Takes in a SDOWRD integer and calculates the number of digits excluding the negative sign if it exists. 
;
; Preconditions: Input integer needs to be a valid 32-bit signed integer 
;
; Postconditions:  EBP, EAX, EBX, ECX, EDI, and EDI are also saved, used, and restored. Calls WriteVal which will then convert the integer,
;				using its length, add it to the address of the output string and display it by calling mDisplayString
;
; Receives: 
; [ ebp + 12 ] = pointer to outStr
; [ ebp + 8 ] = value of integer to convert

; Returns: Returns 8 and calls WriteVal which will convert and then call macro to display it on the console. 

; ---------------------------------------------------

GetIntegerLen PROC

	; Set stack frame
		push	EBP
		mov		EBP, ESP
		push	EAX
		push	EBX
		push	ECX
		push	EDX
		push	EDI
		
		mov		EAX, [EBP + 8 ]			; The value 
		mov		ECX, 0					; Init count of digits in value
		mov		EBX, 10					
		

		cmp		EAX, 0 
		jge		_countValLen
		; Value is negative, negate
		neg		EAX

		
	_countValLen:
		; Clear 4-BYTES so we start fresh for remainder
		xor		EDX,EDX
		div		EBX
		inc		ECX
		; Go until EAX = 0
		cmp		EAX, 0 
		jnz		_countValLen

		
		; Pass parameters to WriteVal
		mov		EDI, [EBP + 12]			; Address of output buffer into EDI
		push	ECX						; the number of digits
		push	EDI						; pointer to buffer
		push	[EBP + 8 ]				; the integer to convert
		call	WriteVal


		; Restore regs
		pop		EDI
		pop		EDX
		pop		ECX
		pop		EBX
		pop		EAX
		pop		EBP

	ret 8 

GetIntegerLen ENDP


END main
