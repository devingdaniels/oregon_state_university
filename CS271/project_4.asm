TITLE Project 4 - Nested Loops and Procedures		(danielde.asm)

; Author: Devin Daniels
; Last Modified: 2/26/2023
; OSU email address: danielde@oregonstate.edu
; Course number/section: CS271  CS271 Section 400
; Project Number: Project 4             Due Date: 2/26/23
; Description: This program allows a user to enter a number within a specified range, performs validation on the number, 
;	and upon valid entry, will find all primes less than or equal to that number. It will then display those
;	in ascending order. The core concepts of this program are procedures, loops, nested loops, and data validation. 

INCLUDE Irvine32.inc

MIN = 1
MAX = 200

.data
progIntro		BYTE "Prime numbers programmed by Devin Daniels", 13 , 10 , 0
prompt1			BYTE "Enter a number between [1 ... 200]: ", 0
promptBad		BYTE "You don't like primes? Please try again.", 13, 10 ,0
userNum			DWORD ?
currentNum		DWORD ?
goodbye			BYTE "Goodbye humanoid, have a nice day, and thanks for playing!", 13, 10 , 0
isPrimeInd		DWORD ?
totalPrimes		DWORD ?
spaces3			BYTE "   ", 0

.code
main PROC

	call	introduction
	call	getUserData
	call	showPrimes
	call	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; --------------------------------------------------------------------------------- 
; Display the name of the program and the programmer name
; Preconditions: progIntro global variable is initialized
; Postconditions:  EDX changed
; Receives: N/A  
; returns: N/ A
; --------------------------------------------------------------------------------- 
introduction PROC
	mov		edx, OFFSET progIntro
	call	WriteString
	call	CrLf
	ret
introduction ENDP


; --------------------------------------------------------------------------------- 
; Prompt user to enter a number within the given range
; Preconditions: prompt1 global variable is intitialized string. validate PROC is defined. 
; Postconditions:  EAX, EBX, EDX modified
; Receives: user input via ReadInt
; returns: user number is saved in userNum global variable
; --------------------------------------------------------------------------------- 
getUserData PROC

getValidUserNumber:
	mov		edx, OFFSET prompt1
	call	WriteString
	call	ReadInt
	call	validate
	cmp		ebx, 1				; 1 = false = bad input. 0 = true = valid input
	je		getValidUserNumber
	mov		userNum, eax		; Save user num and return to main
	ret

getUserData ENDP



; --------------------------------------------------------------------------------- 
; Validate the user number
; Preconditions: value to compare is read into EAX, global MIN and MAX are defined as bounds
; Postconditions:  ebx modified
; Receives: value in EAX
; returns: Sets EBX to 0 for valid input and 1 for bad input
; --------------------------------------------------------------------------------- 
validate PROC
	cmp		eax, MIN
	jl		badInput
	cmp		eax, MAX
	jg		badInput
	mov		ebx, 0			; No bad input, return to getUserData proc
	ret
badInput: 
	mov		edx, OFFSET promptBad
	call	WriteString
	mov		ebx, 1			; Num outside range, store flag and return to getUserData proc
	ret
validate ENDP



; --------------------------------------------------------------------------------- 
; Displays every prime number <= userNum with 10 primes per line in the console by using nested loops and calling isPrime subPROC
; Preconditions: userNum has been validated and set in the global variable. 
;	EAX, EBX, and totalPrimes are initialized to 0
;	ECX is initialized with userNum
;	currentNum is initialized to 1
; Postconditions: EAX, EBX, ECX, EDX, currentNum, totalPrimes are all modified. userNum is not modified
; Receives: Global variable of userNum
; returns: Returns nothing but primes each viable prime
; --------------------------------------------------------------------------------- 
showPrimes PROC
	mov		eax, 0
	mov		ebx, 0
	mov		ecx, userNum			; Total number of primes to be shown
	mov		currentNum, 1
	mov		totalPrimes, 0
	call	CrLf
outer_loop:
	inc		currentNum
	inner_loop:
		call	isPrime				
		cmp		ebx, 1				; Return 1 = prime, 0 = not prime in ebx
		je		currentNumIsPrime
		inc		currentNum
		jmp		inner_loop

currentNumIsPrime:
		inc		totalPrimes
		mov		eax, totalPrimes
		mov		edx, 0
		mov		ebx, 10
		div		ebx
		cmp		edx, 0
		je		printNewLine
		mov		eax, currentNum
		call	WriteDec
		mov	edx, OFFSET spaces3
		call	WriteString
		loop	outer_loop
		jmp		finished

printNewLine:
		mov		eax, currentNum
		call	WriteDec
		mov	edx, OFFSET spaces3
		call	WriteString
		call	CrLf
		loop	outer_loop


finished:
	ret

showPrimes ENDP


; --------------------------------------------------------------------------------- 
; Checks if the value in currentNum is prime and returns 1 if it is prime and 0 if it is not prime
; Preconditions: currentNum has been initialized in showPrimes
; Postconditions:  EAX, EBX, EDX, isPrimeInd are all modified
; Receives: uses currentNum global variable  
; returns: 1 or 0 in EBX, where 1 indicates currentNum is prime and 0 indicates !prime
; --------------------------------------------------------------------------------- 
isPrime PROC

	; Case 1: n = 2
	cmp		currentNum, 2
	je		validPrime	

	; Case 2: n < 2
	cmp		currentNum, 2
	jl		notValidPrime

	; Case 3: n % 2 = 0 (any even !prime)
	mov		eax, currentNum
	mov		edx, 0
	mov		ebx, 2
	div		ebx
	cmp		edx, 0
	je		notValidPrime

	; Case 4:
	mov		isPrimeInd, 3				; Init
	forLoop:
		mov		eax, isPrimeInd
		mov		ebx, isPrimeInd
		mul		ebx
		cmp		eax, currentNum			; Conditional
		jg		validPrime
		mov		eax, currentNum
		mov		edx, 0 
		mov		ebx, isPrimeInd
		div		ebx						; EAX / isPrimeInd
		cmp		edx, 0					; Not prime if remainder is zero
		je		notValidPrime
		inc		isPrimeInd
		inc		isPrimeInd
		jmp		forLoop


validPrime:
	mov		ebx, 1
	ret
		
notValidPrime:
	mov		ebx, 0 
	ret

isPrime ENDP


; --------------------------------------------------------------------------------- 
; Display a farewell message to the user and end program
; Preconditions: goodbye global variable is initialized
; Postconditions:  EDX changed
; Receives: N/A
; returns: N/ A
; --------------------------------------------------------------------------------- 
farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	ret
farewell ENDP


END main
