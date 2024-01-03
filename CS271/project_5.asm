TITLE Project 5 - Arrays, Addressing, and Stack-Passed Parameters     (danielde.asm)

; Author: Devin Daniels
; Last Modified: 3/7/2023 (Used 2 grace days)
; OSU email address: danielde@oregonstate.edu
; Course number/section:CS271	Section 400
; Project Number: 4                Due Date: 3/5/2023
; Description: A program that generates an array of random numbers, displays it, sorts it, displays it again, and shows metrics 
;	about the numbers in the array. The goal is to practice concepts related to arrays, the runtime-stack, passing parameters using
;	the stack, procedures, and proper modularization. 

INCLUDE Irvine32.inc

; (insert macro definitions here)
ARRAY_SIZE = 6
LO = 1
HI = 10
RANGE = HI - LO + 1
SPACER = 32

.data
progIntro		BYTE "Welcome to Arrays, Sorting, Counting, and random numbers in Assembly! Written by Devin Daniels", 13, 10,0 
descrt1			BYTE "This program will generate ", 0
descrt2			BYTE " random numbers between ", 0
descrt3			BYTE " and ", 0
descrt4			BYTE " , inclusive. The list of random numbers will be displayed. Next, the list will be sorted, "
				BYTE " and the median number in the list will be displayed, and then the sorted list itself, in ascending order."
				BYTE " Lastly, a final list will be displayed indicating the instances of each number from the given range.", 13, 10, 13, 10, 0
array			DWORD ARRAY_SIZE DUP(?)
countArr		DWORD RANGE DUP(?)
indexI			DWORD ?
indexJ			SDWORD ?
value			DWORD ? 
medianTitle		BYTE "The median value of the array: ", 0
sortedTitle		BYTE "Your sorted random numbers:", 13, 10, 0
unsortedTitle	BYTE "Your unsorted random numbers:", 13, 10, 0
countTitle		BYTE "Your list of instances of each generated number, starting with the smallest value:", 13, 10, 0


.code
main PROC
	; Seed the psuedo- random number generator
	call	Randomize 
	; Introduce the program name and description
	push	OFFSET progIntro
	push	OFFSET descrt1
	push	OFFSET descrt2
	push	OFFSET descrt3
	push	OFFSET descrt4
	call	introduction
	; Fill array with random numbers in range and up to size
	push	OFFSET array
	call	fillArray
	; Display unsorted array
	push	OFFSET ARRAY_SIZE
	push	OFFSET unsortedTitle
	push	OFFSET array
	call	displayList
	; Sort the array
	push	OFFSET value
	push	OFFSET indexI
	push	OFFSET indexJ
	push	OFFSET array
	call	sortList
	; find median number
	push	OFFSET array
	push	OFFSET medianTitle
	call	displayMedian
	; Display sorted array
	push	OFFSET ARRAY_SIZE
	push	OFFSET sortedTitle
	push	OFFSET array
	call	displayList
	; Make count array
	push	OFFSET indexI
	push	OFFSET array
	push	OFFSET countArr
	call	countList
	; Display the count array
	push	OFFSET RANGE
	push	OFFSET countTitle
	push	OFFSET countArr
	call	displayList

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ---------------------------------------------------------------------------------
; Name: introduction
; Description: Print to the console the name of the program as well as the programmer's name.
; Preconditions: progIntro and programmerName must be defined in the .data segment
; Postconditions: EDX and EAX modified, EBP stored at start of PROC and retored at the end. progIntro and programmerName 
;				are both popped off the stack at ret
; Receives: address of both progIntro and programmerName are pushed onto the stack
; Returns: Pop address of progIntro and programmerName off the stack via ret, ret implicitly pops introduction
;			return address into EIP
; ---------------------------------------------------------------------------------
introduction PROC
    push    EBP
    mov     EBP, ESP
	; Print progIntro
	mov		EDX, [EBP + 24]
	call	WriteString
	call	CrLf
	; Print descrt1 
	mov		EDX, [EBP + 20]
	call	WriteString
	; Print total the size of the array 
	mov		EAX, ARRAY_SIZE
	call	WriteDec
	; Put address of descrt2 into EDX
	mov		EDX, [EBP + 16]
	call	WriteString
	; Print Lo
	mov		EAX, LO
	call	WriteDec
	; Print descrt3
	mov		EDX, [EBP + 12]
	call	WriteString
	; Print HI
	mov		EAX, HI
	call	WriteDec
	; Print descrt4
	mov		EDX, [EBP + 8]
	call	WriteString
	call	CrLF
	; Restore stack pointer
	pop		EBP
	ret	20 

introduction ENDP


; ---------------------------------------------------------------------------------
; Name: fillArray
; Description: Fills an array with random numbers between global range values of HI and LO up to ARRAY_SIZE
; Preconditions: Randomize is seeded in main, LO, HI, and ARRAY_SIZE are defined as constants
; Postconditions: ECX, EDI, EBX modified
; Receives: An address to an array 
; Returns: Contents of array is modified and pops address of the array off the stack
; ---------------------------------------------------------------------------------
fillArray PROC
	; Preserve the stack pointer
    push    EBP						
    mov     EBP, ESP				
	mov		ECX, ARRAY_SIZE	
	; Save starting address of array
	mov		EDI, [EBP + 8]			
	mov		EBX, 0					
	mov		EAX, 0

	_fillLoop: 
		mov		EAX, HI
		inc		EAX
		call	RandomRange
		cmp		EAX, LO
		jl		_fillLoop
		MOV		[EDI + EBX], EAX	
		; Increment pointer by type size, point to next value.
		ADD		EBX, 4				
		loop	_fillLoop

	; Restore stack pointer
	pop		EBP
	ret	4
fillArray ENDP


; ---------------------------------------------------------------------------------
; Name: sortList (Insertion sort)
; Description: O(N^2) sorting algorithm that takes an unsorted array and sorts it in-place
; Preconditions: ARRAY_SIZE defined as constant, address for value, indexI, indexJ, and array on stack
; Postconditions: EAX, EBX, ECX, EDX,EDI, modified
; Receives: Address to an unsorted array 
; Returns: Pops 4-byte address for indexI, indexJ, value, and array off stack
; ---------------------------------------------------------------------------------
sortList PROC
	; Preserve the stack pointer
	push    EBP								
    mov     EBP, ESP
	; Store size of array
	mov		ECX, ARRAY_SIZE					
	mov		EDI, [EBP + 8]	
	
	; init indexI = 1 
	mov		DWORD PTR [EBP + 16 ], 1			
	_forLoop:
		cmp		 [EBP + 16]	, ECX				
		jnl		_finished
		; let value = array[i]
		mov		EBX, [EBP + 16 ]				
		mov		EAX, [EDI + EBX * 4]			
		mov		DWORD PTR [EBP + 20], EAX		
		; let indexJ = indexI - 1
		mov		EAX, EBX
		dec		EAX
		mov		DWORD PTR [EBP + 12 ], EAX		

	_whileLoopConditions:
		; Check if indexJ is < 0 
		mov		EAX, [EBP + 12 ]			
		cmp		EAX , 0						
		jl		_callExchangeElements
		; Put value of array[j] in EDX
		mov		EAX, [EDI + EAX * 4]		
		; Put value into EAX
		mov		EDX, [EBP + 20]
		; Compare array[j] > value
		cmp		EAX, EDX	
		jng		_callExchangeElements


	_whileLoopBody:
		; Next, get indexJ
		mov		EAX, [EBP + 12]
		; array[j + 1] = array[j];
		mov		EBX,  [EDI + EAX * 4]
		mov		DWORD PTR [EDI + EAX * 4 + 4], EBX
		; Decrement and update indexJ
		dec		EAX
		mov		SDWORD PTR [EBP + 12 ], EAX
		jmp		_whileLoopConditions

	_callExchangeElements:
		; Pass Reference to inexdJ
		push	SDWORD PTR [EBP + 12 ]		
		; Reference to value to swap 
		push	DWORD PTR [EBP + 20 ]			
		call	exchangeElements
		; Increment indexI
		mov		EAX,  [EBP + 16 ]
		inc		EAX
		mov		DWORD PTR [EBP + 16], EAX
		jmp		_forLoop


	_finished:
		pop    EBP	
		ret 16
sortList ENDP


; ---------------------------------------------------------------------------------
; Name: exchangeElements
; Description: Takes an index and a value and puts the value in the array at EDI from sortList at given index
; Preconditions: Starting address of array in EDI, address of value and index on stack
; Postconditions: EAX and EBX changed
; Receives: Address for value and address for index
; Returns: Pops 4-byte address for value and address off the stack, returns to sortList PROC
; ---------------------------------------------------------------------------------
exchangeElements PROC
	;Preserve stack pointer
	push    EBP
    mov     EBP, ESP
	; Get the value 
	mov		EBX, [EBP + 8 ]	
	; Get indexJ
	mov		EAX, [EBP + 12 ]
	; array[j + 1] = value
	mov		DWORD PTR [EDI + EAX * 4 + 4], EBX	
	; Restore stack pointer
	pop		EBP
	ret  8
exchangeElements ENDP


; ---------------------------------------------------------------------------------
; Name: displayMedian
; Description: Prints the median number in an array
; Preconditions: Array must be sorted, ARRAY_SIZE defined as constant
; Postconditions: EAX, EBX, EDX modified
; Receives: Address to sorted array, address to titleString
; Returns: Pop 4-byte address of array and titleString off the stack
; ---------------------------------------------------------------------------------
displayMedian PROC
	; Preserve stack frame
	push    EBP
    mov     EBP, ESP
	; Save starting address of array
	mov		EDI, [EBP + 12]
	; Print medianTitle
	mov		EDX, [EBP + 8]
	call	WriteString
	; Get middle and save in EAX
	mov		EAX, ARRAY_SIZE
	mov		EDX, 0 
	mov		EBX, 2
	div		EBX
	cmp		EDX, 0
	je		_noRemainder
	; Case: remainder, return array[middle]
	mov		EAX, [EDI + EAX * 4]
	call	WriteDec
	jmp		_finished

	_noRemainder:
	mov		EBX, [EDI + EAX * 4 - 4]
	add		EBX, [EDI + EAX * 4]
	mov		EAX, EBX
	mov		EDX, 0 
	mov		EBX, 2
	div		EBX				
	call	WriteDec

	_finished: 
	call	CrLf
	call	CrLf
	pop		EBP
	ret 8
displayMedian ENDP


; ---------------------------------------------------------------------------------
; Name: displayList
; Description: Displays the contents of an array 
; Preconditions:  ARRAY_SIZE and defined array 
; Postconditions: EAX, EBX, ECX, EDI modified
; Receives: Starting address of an array, address for a title, arraySize
; Returns: Pop 3 4-byte addresses off the stack
; ---------------------------------------------------------------------------------
displayList PROC
	; Preserve the stack pointer
    push    EBP					
    mov     EBP, ESP
	; Init ECX counter with array size
	mov		ECX, [EBP + 16]	
	; Save array starting address
	mov		EDI, [EBP + 8 ]		
	; Display title
	mov		EDX,[EBP + 12]
	call	WriteString
	; Init column counter
	mov		EBX, 0
	_traverse: 
		mov		EAX, [EDI]
		add		EDI, 4
		call	WriteDec
		mov		AL, SPACER
		call	WriteChar
		inc		EBX
		cmp		EBX, 20
		je		_printNewLine
		loop	_traverse
		jmp		_finished

	_printNewLine:
		call	CrLf
		mov		EBX, 0
		loop	_traverse

	_finished:
		call	CrLf
		call	CrLf
		; Restore stack pointer
		pop		EBP				
		ret		12
displayList ENDP


; ---------------------------------------------------------------------------------
; Name: countList
; Description: Counts the number of instances of each number between LO and HI in a sorted array
; Preconditions: Sorted array, countArr, LO, HI all defined
; Postconditions: EDI, ESI, EAX, EBX, ECX, EDX modified
; Receives: Sorted array, empty array, address for index variable
; Returns: Pop 3 4-BYTE addresses off the stack
; ---------------------------------------------------------------------------------
countList PROC
	; Preserve stack pointer
	push    EBP								
    mov     EBP, ESP
	; Address of sorted array
	mov		EDI, [EBP + 12]
	; Address of countArr
	mov		ESI, [EBP + 8 ]
	; Init indexI
	mov		ECX, LO
	; EDX will track which index to put the total count of each number
	mov		EDX, 0 
	_outerForLoop:
		cmp		ECX, HI
		jnle	_finished
		; Preserve indexI
		push	ECX
		; Init indexJ
		mov		ECX, 0 
		; Init count
		mov		DWORD PTR [EBP + 16], 0
	_innerForLoop:
		cmp		ECX, ARRAY_SIZE
		jge		_endInnerForLoop
		; Get aray[j]
		mov		EAX, [EDI + ECX * 4]
		; Get indexI
		pop		EBX
		cmp		EAX, EBX
		jne		_notEqual
		; Increment count if equal
		add		DWORD PTR [EBP + 16], 1
		_notEqual: 
			; put indexI back on stack
			push	EBX
			; Increment indexJ
			inc		ECX
			jmp		_innerForLoop
	

	_endInnerForLoop:
		; Add count to countArr
		mov		EAX, [EBP + 16 ]
		mov		DWORD PTR [ESI + EDX * 4], EAX
		; Increment EDX
		inc		EDX
		; Increment indexI
		pop		ECX
		inc		ECX
		jmp		_outerForLoop

	_finished:
	; Restore stack pointer
	pop		EBP
	ret	12
countList ENDP

END main