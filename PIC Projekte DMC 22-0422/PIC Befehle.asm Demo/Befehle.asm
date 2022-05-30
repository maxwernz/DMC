;****************************************************************
;*	HS Mannheim
;*	Institut für Embedded Systems
;*	Filename: Befehle.asm
;*	14.11.2018  Zeitschleife + Umbenennungen
;*	16.11.2017  mit RC2
;*	08.05.2013  mit Configuration Bits
;*	25.10.2007
;****************************************************************

	list p=18f452	;Prozessor für Assembler auswählen
#include <p18f452.inc>

	config OSC=HS,WDT=OFF,LVP=OFF ;Configuration Bits - defined in include file
	; HS Oszillator, Watchdog Timer disabled, Low Voltage Programming

BANK0 EQU 0x00
BANK1 EQU 0x100
BANK2 EQU 0x200
BANK3 EQU 0x300
BANK4 EQU 0x400
BANK5 EQU 0x500

;//***** Variables *****
;//

;//Bank0
Zeit_L EQU  0x20
Zeit_H EQU  0x21

;//Bank1
;//Bank2
;//Bank3
zahl_a	EQU	0x300
zahl_b	EQU	0x301
;zahl_c	EQU	0x302
;//Bank4
x	EQU	0x400
y	EQU	0x401
;z	EQU	0x402
;//Bank5
;//***** Main Program *****

	ORG 0x00
ResetVect
	GOTO Init

	ORG 0x08
IntVectHigh
;//No Interrupts Enabled

	ORG 0x18
IntVectLow
;//No Interrupts Enabled

	ORG 0x30
;//Initialisation Code - Placed at some point after IntVect
Init
	MOVLW	0xF0		; RB3..RB0 als Ausgang
	CLRF	PORTB		; clear output latch
	MOVWF	TRISB		; setze Pins RB<3:0> als Ausgang

	BSF		PORTC,RC2	; set output latch für Lautsprecher
	BCF		TRISC,TRISC2 ; RC2 als Ausgang
;	MOVLW	~(1<<2)		; lädt Maske mit Einsen + einer Null an Binärstelle 2 (=0xFB)
;	MOVWF	TRISC		; RC2 als Ausgang

	MOVLW	B'00001100'	; Bitmuster für LEDs
	MOVWF	PORTB		; an LEDs ausgeben
	
;//Main Application Code
MainLoop				; Hauptprogrammschleife
Wait
	BTFSC 	PORTA,RA4	; Taster RA4 abfragen
	BRA Wait

	MOVLW	0x0F		; für RB3..RB0 (LEDs)
	XORWF	PORTB		; LEDs toggeln
	BTG		PORTC,RC2	; Lautsprecher toggeln

	NOP					; No OPeration (hier sehen wir RC2 im Logic Analyzer)

;	MOVLW	0xFF
;	MOVWF	Zeit_H,0	; Access-Bank
;	CALL unterprogramm	; Verzögerungsschleife

;Addition (zahl_a) + (zahl_b) --> zahl_c
;  über BSR-Register (Bank 3)
	MOVLB	3
	MOVLW	0x99
	MOVWF	zahl_a	;w --> zahl_a
	MOVWF	zahl_b	;w --> zahl_b
;	MOVF	zahl_a,0,1	;zahl_a --> w  (file,d,a) d: 0=WOrk
	BSF		STATUS,C
	ADDWFC	zahl_b,0,1	;Summe --> w
	DAW
;Multiplikation (zahl_a) * (zahl_b) --> PRODH:PRODL
;  über BSR-Register (Bank 3)
	MOVLB	3
	MOVLW	0xFF
	MOVWF	zahl_a	;w --> zahl_a
	MOVWF	zahl_b	;w --> zahl_b
	MOVF	zahl_a,0,1	;zahl_a --> w
	MULWF	zahl_b,1	;Produkt --> PRODH:PRODL
	
	BRA MainLoop ;//Do.. Forever

unterprogramm
delay
	DECFSZ	Zeit_L	; verschachtelte Schleife
	BRA	delay
	DECFSZ	Zeit_H
	BRA	delay
   	RETURN

	END

