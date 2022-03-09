;***********************************************************
;*
;*	This is the TRANSMIT skeleton file for Lab 8 of ECE 375
;*
;*	 Author: Phillip Renaud & Nat Bourassa
;*	   Date: March 1, 2022
;*
;***********************************************************

.include "m128def.inc"			; Include definition file

;***********************************************************
;*	Internal Register Definitions and Constants
;***********************************************************
.def	mpr = r16				; Multi-Purpose Register
.def	mqr = r17				; Multi-Qurpose Register

.equ	Button0 = 0
.equ	Button1 = 1

.equ	EngEnR = 4				; Right Engine Enable Bit
.equ	EngEnL = 7				; Left Engine Enable Bit
.equ	EngDirR = 5				; Right Engine Direction Bit
.equ	EngDirL = 6				; Left Engine Direction Bit

; Register Summary - UCSR1A address
.equ	BotAddr = $9B

; Use these action codes between the remote and robot
; MSB = 1 thus:
; control signals are shifted right by one and ORed with 0b10000000 = $80
.equ	MovFwd =  ($80|1<<(EngDirR-1)|1<<(EngDirL-1))	;0b10110000 Move Forward Action Code
.equ	MovBck =  ($80|$00)								;0b10000000 Move Backward Action Code
.equ	TurnR =   ($80|1<<(EngDirL-1))					;0b10100000 Turn Right Action Code
.equ	TurnL =   ($80|1<<(EngDirR-1))					;0b10010000 Turn Left Action Code
.equ	Halt =    ($80|1<<(EngEnR-1)|1<<(EngEnL-1))		;0b11001000 Halt Action Code

;***********************************************************
;*	Start of Code Segment
;***********************************************************
.cseg							; Beginning of code segment

;***********************************************************
;*	Interrupt Vectors
;***********************************************************
.org	$0000					; Beginning of IVs
		rjmp 	INIT			; Reset interrupt

.org	$0046					; End of Interrupt Vectors

;***********************************************************
;*	Program Initialization
;***********************************************************
INIT:
	;Stack Pointer (VERY IMPORTANT!!!!)
	ldi mpr, high(RAMEND)
	out SPH, mpr
	ldi mpr, low(RAMEND)
	out SPL, mpr

	;I/O Ports
	ldi mpr, $FF
	out DDRB, mpr

	ldi mpr, $00
	out PORTB, mpr

	ldi mpr, 0b0000_1000
	out DDRD, mpr

	ldi mpr, 0b1111_0011
	out PORTD, mpr

	ldi mpr, $03
	sts UBRR1H, mpr

	ldi mpr, $40
	sts UBRR1L, mpr


	;USART1
	ldi mpr, ( 1 << U2X1 )  ; Set double data rate
	sts UCSR1A, mpr

	;Set baudrate at 2400bps
	;ldi mpr, high( 832 )	; Load high byte of 0x0340
	;sts UBRR1H, mpr			; UBRROH in extended I/O space
	;ldi mpr, low( 832 )		; Load low byte of 0x0340
	;sts UBRR1L, mpr
	
	;Enable transmitter
	;ldi mpr, ( 1 << TXEN1 )
	;sts UCSR1B, mpr
	ldi mpr, $08
	sts UCSR1B, mpr

	;Set frame format: 8 data bits, 2 stop bits
	ldi mpr, $0E
	sts UCSR1C, mpr

;***********************************************************
;*	Main Program
;***********************************************************
MAIN:
		;sbis PIND, Button0
		;rcall MoveBackward
		;sbis PIND, Button1
		;rcall MoveForward
		;sbis PIND, EngEnR
		;rcall TurnRight
		;sbis PIND, EngDirR
		;rcall TurnLeft
		;sbis PIND, EngDirL
		;rcall Halt
					in mpr, $10
					sbrc mpr, 0
					rjmp SkipForward
					rcall MoveForward
SkipForward:		sbrc mpr, 1
					rjmp SkipBack
					rcall MoveBack
SkipBack:			sbrc mpr, 4
					rjmp SkipLeft
					rcall TurnLeft
SkipLeft:			sbrc mpr, 5
					rjmp SkipRight
					rcall TurnRight
SkipRight:			sbrc mpr, 6
					rjmp SkipHalt
					rcall DoHalt
SkipHalt:			sbrs mpr, 7
					rcall Freeze
					rjmp	MAIN

;***********************************************************
;*	Functions and Subroutines
;***********************************************************
MoveForward:
		
		;push mpr
		;in mpr, SREG
		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr
		
		sbrs mpr, 5
		rjmp MoveForward
		ldi mpr, $2A
		sts UDR1, mpr

CheckForward:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckForward

		ldi mpr, 0b1011_0000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret

MoveBack:
		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr

		sbrs mpr, 5
		rjmp MoveBack
		ldi mpr, $2A
		sts UDR1, mpr

CheckBack:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckBack

		ldi mpr, 0b1000_0000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret

TurnRight:

		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr
		
		sbrs mpr, 5
		rjmp TurnRight
		ldi mpr, 0x2A
		sts UDR1, mpr

CheckRight:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckRight

		ldi mpr, 0b1010_0000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret

TurnLeft:
		
		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr
		
		sbrs mpr, 5
		rjmp TurnLeft
		ldi mpr, 0x2A
		sts UDR1, mpr

CheckLeft:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckLeft

		ldi mpr, 0b1001_0000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret

DoHalt:
		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr
		
		sbrs mpr, 5
		rjmp DoHalt
		ldi mpr, 0x2A
		sts UDR1, mpr

CheckHalt:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckHalt

		ldi mpr, 0b1100_1000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret

Freeze:
		push mpr

		;rcall USATR_Transmit
		lds mpr, BotAddr
		
		sbrs mpr, 5
		rjmp Freeze
		ldi mpr, 0x2A
		sts UDR1, mpr

CheckFreeze:			
		lds mpr, BotAddr
		sbrs mpr, 5
		rjmp CheckForward

		ldi mpr, 0b1111_1000
		sts UDR1, mpr

		out PORTB, mpr


		;rcall USATR_Transmit
		;ldi mpr, MovFwd
		;sts UDR1, mpr

		pop mpr
		;out SREG, mpr
		;pop mpr

		ret


;USATR_Transmit:
		
;		pop mpr
;Tloop:
;		ldi	mpr, UCSR1A
;		sbrs mpr, UDRE1
;		rjmp Tloop
;		pop mpr
;		ret

;***********************************************************
;*	Stored Program Data
;***********************************************************

;***********************************************************
;*	Additional Program Includes
;***********************************************************
