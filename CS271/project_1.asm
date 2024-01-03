TITLE Basic Logic and Arithmetic Program  (proj1_danielde.asm)

; Author: Devin Daniels
; Last Modified: 01/29/2023
; OSU email address: danielde@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: Project 1                Due Date: 01/29/2023
; Description: Basic program that takes user input, performs calculations, returns results, and follows the CS271 Style Guide

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

.data
; Variable definitions here
programmerName		BYTE "Programmer: Devin Daniels",0
programTitle		BYTE "Program title: Basic Logic and Artithmetic Program",0
instructions		BYTE "Enter 3 numbers A > B > C, and I'll show you the sums and differences.",0
promptNumberOne		BYTE "First number: ", 0
promptNumberTwo		BYTE "Second number: ",0
promptNumberThree	BYTE "Third number: ",0 
sayGoodbye			BYTE "Thanks for using Elementary Arithmetic!  Goodbye!",0
firstNumber			DWORD ? 
secondNumber		DWORD ?
thirdNumber			DWORD ? 
firstPlusSecond		DWORD ?
firstMinusSecond	DWORD ?
firstPlusThird		DWORD ? 
firstMinusThird		DWORD ? 
secondPlusThird		DWORD ? 
secondMinusThird	DWORD ? 
sumTotal			DWORD ?
plus				BYTE " + ",0
minus				BYTE " - ",0
equals				BYTE " = ",0

.code
main PROC
; Introduction: Display programmer name and program title
	MOV		EDX, OFFSET programmerName
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET programTitle
	CALL	WriteString
	CALL	CrLf
	MOV		EDX, OFFSET instructions
	CALL	WriteString
	CALL	CrLf
	CALL	CrLf

; User input: Get three numbers from the user
	MOV		EDX, OFFSET promptNumberOne
	CALL	WriteString
	; Preconditinos of ReadDec: N/A
	CALL	ReadDec
	; Postconditions of ReadDec: value is stored in EAX
	MOV		firstNumber, EAX
	; Get second number
	MOV		EDX, OFFSET promptNumberTwo
	CALL	WriteString
	CALL	ReadDec
	MOV		secondNumber, EAX
	; Get third number
	MOV		EDX, OFFSET promptNumberThree
	CALL	WriteString
	CALL	ReadDec
	MOV		thirdNumber, EAX
	CALL	CrLf

; Calculate user values
	; First + Second
	MOV		EAX, firstNumber		
	ADD		EAX, secondNumber
	MOV		firstPlusSecond, EAX

	; First - Second
	MOV		EAX, firstNumber
	SUB		EAX, secondNumber
	MOV		firstMinusSecond, EAX

	; First + Third 
	MOV		EAX, firstNumber
	ADD		EAX, thirdNumber
	MOV		firstPlusThird, EAX

	; First - Third
	MOV		EAX, firstNumber
	SUB		EAX, thirdNumber
	MOV		firstMinusThird, EAX

	; Second + Third
	MOV		EAX, secondNumber
	ADD		EAX, thirdNumber
	MOV		secondPlusThird, EAX

	; Second - Third
	MOV		EAX, secondNumber
	SUB		EAX, thirdNumber
	MOV		secondMinusThird, EAX

	; First + Second + Third
	MOV		EAX, firstNumber
	ADD		EAX, secondNumber
	ADD		EAX, thirdNumber
	MOV		sumTotal, EAX
	
; Display results of calculations
	; Dispay First + Second
	MOV		EAX, firstNumber
	CALL	WriteDec
	MOV		EDX, OFFSET plus
	CALL	WriteString 
	MOV		EAX, secondNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, firstPlusSecond
	CALL	WriteDec
	CALL	CrLf

	; Dispay First - Second
	MOV		EAX, firstNumber
	CALL	WriteDec
	MOV		EDX, OFFSET minus
	CALL	WriteString 
	MOV		EAX, secondNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, firstMinusSecond
	CALL	WriteDec
	CALL	CrLf

	; Dispay First + Third
	MOV		EAX, firstNumber
	CALL	WriteDec
	MOV		EDX, OFFSET plus
	CALL	WriteString 
	MOV		EAX, thirdNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, firstPlusThird
	CALL	WriteDec
	CALL	CrLf

	; Dispay First - Third
	MOV		EAX, firstNumber
	CALL	WriteDec
	MOV		EDX, OFFSET minus
	CALL	WriteString 
	MOV		EAX, thirdNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, firstMinusThird
	CALL	WriteDec
	CALL	CrLf

	; Dispay Second + Third
	MOV		EAX, secondNumber
	CALL	WriteDec
	MOV		EDX, OFFSET plus
	CALL	WriteString 
	MOV		EAX, thirdNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, secondPlusThird
	CALL	WriteDec
	CALL	CrLf

	; Dispay Second - Third
	MOV		EAX, secondNumber
	CALL	WriteDec
	MOV		EDX, OFFSET minus
	CALL	WriteString 
	MOV		EAX, thirdNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, secondMinusThird
	CALL	WriteDec
	CALL	CrLf

	; Dispay First + Second + Third
	MOV		EAX, firstNumber
	CALL	WriteDec
	MOV		EDX, OFFSET plus
	CALL	WriteString 
	MOV		EAX, secondNumber
	CALL	WriteDec
	MOV		EDX, OFFSET plus
	CALL	WriteString 
	MOV		EAX, thirdNumber
	CALL	WriteDec 
	MOV		EDX, OFFSET equals
	CALL	WriteString
	MOV		EAX, sumTotal
	CALL	WriteDec
	CALL	CrLf
	CALL	CrLf

; Say Goodbye 
	MOV		EDX, OFFSET sayGoodbye
	CALL	WriteString
	CALL	Crlf

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; (insert additional procedures here)

END main
