;***********************************************************
;*
;*	This is the RECEIVE skeleton file for Lab 8 of ECE 375
;*
;*	 Author: Enter your name
;*	   Date: Enter Date
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16
.def	mqr = r17				; Multi-Purpose Register

.equ	WskrR = 0				; Right Whisker Input Bit
.equ	WskrL = 1				; Left Whisker Input Bit
.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit

.equ	BotAddress = 1 ;(Enter your robot's address here (8 bits))

;/////////////////////////////////////////////////////////////
;These macros are the values to make the TekBot Move.
;/////////////////////////////////////////////////////////////
.equ	MovFwd =  (1<<EngDirR|1<<EngDirL)	;0b01100000 Move Forward Action Code
.equ	MovBck =  $00						;0b00000000 Move Backward Action Code
.equ	TurnR =   (1<<EngDirL)				;0b01000000 Turn Right Action Code
.equ	TurnL =   (1<<EngDirR)				;0b00100000 Turn Left Action Code
.equ	Halt =    (1<<EngEnR|1<<EngEnL)		;0b10010000 Halt Action Code

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org	$0002
		rcall	INTBC
		reti

.org	$0004
		rcall	INTCB
		reti

.org	$003C
		rcall	func69	
		reti

;Should have Interrupt vectors for:
;- Left whisker
;- Right whisker
;- USART receive

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	;I/O Ports
	;USART1
		;Set baudrate at 2400bps
		;Enable receiver and enable receive interrupts
		;Set frame format: 8 data bits, 2 stop bits
	;External Interrupts
		;Set the External Interrupt Mask
		;Set the Interrupt Sense Control to falling edge detection

	;Other
	ldi mpr, low(RAMEND)
	out SPL, mpr

	ldi mpr, high(RAMEND)
	out SPH, mpr

	ldi mpr, $FF
	out DDRB, mpr

	ldi mpr, $00
	out PORTB, mpr

	ldi mpr, $00
	out DDRD, mpr

	ldi mpr, $03
	out PORTD, mpr

	ldi mpr, $03
	sts UBRR1H, mpr

	ldi mpr, $40
	sts UBRR1L, mpr

	ldi mpr, $02
	sts UCSR1A, mpr

	ldi mpr, $90
	sts UCSR1B, mpr

	ldi mpr, $0E
	sts UCSR1C, mpr

	ldi mpr, $0A
	sts EICRA,mpr

	ldi mpr, $03
	out EIMSK,mpr
	ldi r22, $03

	sei
	

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
	;TODO: ???
		rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************

func69:	push mpr
		lds mpr, UDR1
		cpi mpr, 0b01010101
		brne func6F
		rjmp func9A
func6F:	sbrs mpr, EngEnL
		rjmp func7B
		cpi r20, 0b00000001
		brne func79
		eor r20, r20
		add mpr,mpr
		cpi mpr, 0b11110000
		breq func7F
func77:	out PORTB,mpr
		mov r23, mpr
func79:	pop mpr
		ret

func7B:	cpi mpr, $2A ;bot address
		brne $79
		ldi r20, 0b00000001
		rjmp func79
func7F:	ldi mpr, $0C
		out DDRD, mpr
		ldi mpr, 0b00001000
		sts UCSR1B, mpr

		ldi mpr, 0b01010101
		out PORTB, mpr
func86:	lds mpr, UCSR1A

		sbrs mpr, 5
		rjmp func86
		ldi mpr, 0b01010101
		sts UDR1, mpr

		ldi mqr, 0b00011001
		rcall funcDA
		ldi mqr, $64
		ldi mpr, 0b00000000
		out DDRD, mpr
		ldi mpr, 0b10010000
		sts UCSR1B, mpr
		
		in mpr, $38
		ori mpr, 0b11111111
		out EIFR, mpr
		mov mpr, r23
		rjmp func77
func9A:	dec r22
		cpi r22, 0b00000000
		breq funcB4
		ldi mpr, $90
		out PORTB, mpr
		ldi mpr, $04
		out DDRD, mpr
		ldi mpr, 0b00000000
		sts UCSR1B, mpr

		ldi mqr, $64
		rcall funcDA
		rcall funcDA
		rcall funcDA
		rcall funcDA
		rcall funcDA
		ldi mpr, 0b00000000
		out DDRD, mpr
		ldi mpr, $90
		sts UCSR1B, mpr

		in mpr, $38
		ori mpr, 0b11111111
		out EIFR, mpr
		mov mpr,r23
		rjmp func77

funcB4:	ldi mpr, 0b00001001
		out PORTB, mpr
		ldi mpr, 0b00000111
		out DDRD, mpr
		ldi mpr, 0b00000000
		sts UCSR1B, mpr
		rjmp funcB4

INTBC:	push mpr
		ldi mpr, 0b00000000
		out PORTB, mpr
		ldi mqr, $64
		rcall funcDA
		ldi mpr,$20
		out PORTB, mpr
		ldi mqr, $64
		rcall funcDA
		in mpr, EIFR
		ori mpr, 0b00001111
		out EIFR, mpr
		out PORTB,r23
		pop mpr
		ret

INTCB:	push mpr
		ldi mpr, 0b00000000
		out PORTB, mpr
		ldi mqr, $64
		rcall funcDA
		ldi mpr, $40
		out PORTB, mpr
		ldi mqr, $64
		rcall funcDA
		in mpr, EIFR
		ori mpr, 0b00001111
		out EIFR, mpr
		out PORTB, r23
		pop mpr
		ret


funcDA:	push mqr
		push r18
		push r19
		push r19
funcDD:	ldi r19, $E0
funcDE:	ldi r18, $ED
funcDF:	dec r18
		brne funcDF
		dec r19
		brne funcDE
		dec mqr
		brne funcDD
		pop r19
		pop r18
		pop mqr
		ret


;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************