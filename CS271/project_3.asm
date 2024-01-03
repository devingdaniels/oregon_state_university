TITLE Project 3 - Data Validation, Looping, and Constants     (Proj3_danielde.asm)

; Author: Devin Daniels
; Last Modified: 2/12/2023
; OSU email address: danielde@oregonstate.edu
; Course number/section:   CS271 Section: 400
; Project Number: 3             Due Date: 02/12/2023
; Description:  This project aims to practice looping, data validation, branching, and using constants
; **EC: DESCRIPTION:  Adding line numbers for each time a valid number is entered. If latest input is not valid, line number will not increment. 
INCLUDE Irvine32.inc

; Global constants
NEG200 = -200
NEG100 = -100
NEG50 = -50
NEG1 = -1


.data
greeting		BYTE "Welcome to the Integer Accumulator by Devin Daniels ", 13, 10, 0
instructions	BYTE "We will be accumulating user-input negative integers between the specified bounds, then displaying "
				BYTE "statistics of the input values including minimum, maximum, and average values values, total sum, and "
				BYTE "total number of valid inputs.", 13, 10, 0
namePrompt		BYTE "What is your name: ",0
userName		BYTE 33 DUP(0)
sayHello		BYTE "Nice to meet you, ",0
numberPrompt	BYTE "Enter a number in bounds of [-200, -100] or [-50, -1] (inclusive): ", 0
badNumMessage	BYTE "Number is outside the range of [-200, -100] or [-50, -1]...Number discarded.",13,10,0
nonNegMessage	BYTE "Non-negative number entered, ending program and performing computations...", 13, 10, 0
countMessage	BYTE "Count of valid numbers: ", 0
sumMessage		BYTE "Sum of valid numbers: ", 0
minNumber		BYTE "Minimum number: ", 0
maxNumber		BYTE "Maximum number: ", 0 
avgNumber		BYTE "Average number: ", 0
sayGoodbye		BYTE "Have a nice day, humaniod!", 13, 10, 0
specialMsg		BYTE "What, you don't like playing number games???  :---(", 13, 10, 0
lineNumber		BYTE ": ", 0
min				SDWORD	-99
max				SDWORD	-51
sum				SDWORD	0
average			SDWORD	0
remainder		SDWORD	0
temp			SDWORD 0
current			SDWORD	?
count			DWORD	0
extraCredit		BYTE "**EC: DESCRIPTION: Adding line numbers for each time a valid number is entered. If latest input is not valid, line number will not increment. "
				BYTE "Line numbering starts at 1 since only cool non-humanoids start counting at 0 ;-)", 13, 10, 0

.code
main PROC

; INTRODUCTION
	mov		edx, offset greeting		; Display the program title, programmer�s name
	call	WriteString					
	call	CrLf
	mov		edx, offset extraCredit
	call	WriteString
	call	CrLf
	mov		edx, offset instructions	; Display instructions for the user.
	call	WriteString
	call	CrLf
	mov		edx, offset namePrompt		; Get the user's name and greet the user.
	call	WriteString
	mov		edx, offset userName		; Preconditions of Readstring: (1) Max length saved in ECX, EDX holds pointer to string
	mov		ecx, 33
	call	ReadString
	call	CrLf
	mov		edx, offset sayHello		; Greet the user using their name
	call	WriteString
	mov		edx, offset userName
	call	WriteString
	call	CrLf
	call	CrLf


; LOOPING
_getCurrent: 
	mov		eax, 0					; Init eax for temp storage of line number
	mov		eax, count				
	inc		eax						
	call	writeDec
	mov		edx, offset lineNumber
	call	WriteString
	mov		edx, offset numberPrompt
	call	WriteString
	call	ReadInt
	mov		current, eax
	jns		_nonNegativeInput			; check non-zero flag, if set, jump to display results
	cmp		eax, NEG100
	jle		_lessThanEqual100			; jump if current(EAX) <= -100
	cmp		eax, NEG50					; current is > -100
	jge		_greaterThanEqual50			; jump if current >= -50
	jmp		_badNumMessage				; Jump, current > -100 and < -50, 


	

; DATA VALIDATION AND COMPUTATIONS
_lessThanEqual100:						; Current is less than or = -100 
	mov		eax, current				; to be safe
	cmp		eax, NEG200
	jl		_badNumMessage				; current < -200, jmp to invalid input label
	cmp		eax, min					; Check if current is new min
	jge		_incrementSumAndTotal
	mov		min, eax					; Update with new min
	jmp		_incrementSumAndTotal


_greaterThanEqual50:					; current >= -50
	mov		eax, current
	cmp		eax, NEG1					; Now  check upper bound (-1)
	jg		_badNumMessage
	cmp		eax, max					; Check if current is new max
	jle		_incrementSumAndTotal
	mov		max, eax					; Update with new max
	jmp		_incrementSumAndTotal


_badNumMessage:
	mov		edx, OFFSET badNumMessage
	call	WriteString
	jmp		_getCurrent


	
_incrementSumAndTotal: 
	inc		count
	mov		eax, 0
	mov		eax, sum
	add		eax, current
	mov		sum, eax
	jmp		_getCurrent


_calculateAverage:
	mov		eax, 0						; init eax
	mov		eax, sum
	cdq
	idiv	count			
	mov		average, eax				; Average result in EAX, remainder in EDX
	mov		remainder, edx	
	mov		eax, -2						; if remainder > count / 2, round up; else round down
	cdq
	idiv	count			
	mov		temp, eax					; Temp is remainder after dividing count by -2 (-2 because working with strickly negative numbers but remainders will always be postitive)
	mov		eax, remainder
	cmp		eax, temp
	jl		_roundUp
	jmp		_display


_roundUp:
	dec		average	
	jmp		_display


_nonNegativeInput:
	call	CrLf
	mov		eax, count					; Check for any valid user inputs
	cmp		eax, 0
	je		_specialMessage				; If true, no valid inputs
	mov		edx, OFFSET nonNegMessage	; False, one valid input, update min and max
	call	WriteString
	call	CrLf
	jmp		_checkMinMax


_checkMinMax: 
	mov		eax, min			
	cmp		eax, -99					; Update min to = max if min = -99
	je		_updateMin							
	mov		eax, max
	cmp		eax, -51					; Update max to = min if max = -51
	je		_updateMax
	jmp		_calculateAverage			; Both set, nothing to check


_updateMin:
	mov		eax, max
	mov		min, eax
	jmp		_calculateAverage


_updateMax:
	mov		eax, min
	mov		max, eax
	jmp		_calculateAverage


; DISPLAY
_display:
	mov		edx, offset countMessage	; Display count
	call	WriteString
	mov		eax, count 
	call	WriteDec
	call	CrLf
	mov		edx, offset sumMessage		; Display the sum
	call	WriteString
	mov		eax, sum
	call	WriteInt
	call	CrLf
	mov		edx, offset minNumber		; Display minimum
	call	WriteString
	mov		eax, min
	call	WriteInt
	call	CrLf
	mov		edx, offset maxNumber		; Display maximum
	call	WriteString
	mov		eax, max
	call	WriteInt
	call	CrLf
	mov		edx, offset avgNumber		; Display average
	call	WriteString
	mov		eax, average
	call	WriteInt
	call	CrLf
	call	CrLf
	jmp		_finished
	

; GOODBYE
_specialMessage:
	mov		edx, OFFSET specialMsg	
	call	WriteString
	call	CrLf

_finished: 
	mov		edx, OFFSET sayGoodbye
	call	WriteString


	Invoke ExitProcess,0	; exit to operating system
main ENDP

END main
