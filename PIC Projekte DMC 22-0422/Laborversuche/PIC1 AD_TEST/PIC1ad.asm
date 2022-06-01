; Dateiname:
; Beschreibung:
;
;
; Entwickler:
; Version: 1.0    Datum:

	list p=18f452		; Select Processor for Assembler
#include <p18f452.inc>	; Registers / ASM Include File in Search Path  C:\Program Files (x86)\Microchip\MPASM Suite

	config OSC=HS,WDT=OFF,LVP=OFF ;Configuration Bits - defined in include file
	; HS Oszillator, Watchdog Timer disabled, Low Voltage Programming

BANK0 EQU 0x000
BANK1 EQU 0x100
BANK2 EQU 0x200
BANK3 EQU 0x300
BANK4 EQU 0x400
BANK5 EQU 0x500

;//***** Variables *****
;//Bank0
;//Bank1
;//Bank2
;//Bank4
;//Bank5

;//***** Vector Table *****
	ORG 0x00
ResetVect
	GOTO Init

	ORG 0x08
IntVectHigh
;//No Interrupts Enabled

	ORG 0x18
IntVectLow
;//No Interrupts Enabled

;//***** Main Program *****
	ORG 0x30
;//Initialisation Code
Init

	CLRF PORTA
	MOVLW 0x7F ;// 7 PINS; alles Eingaenge
	MOVWF TRISA

	CLRF PORTB
	MOVLW 0xF0
	MOVWF TRISB

	CLRF PORTC
	MOVLW 0XFB
	MOVWF TRISC

	MOVLW 0x81
	MOVWF ADCON0
	MOVLW 0x0E
	MOVWF ADCON1

;//Main Application Code
MainLoop

Schleife
	BTFSS PORTA, RA4
	CALL LEDansteuern
	BRA Schleife
	;RETURN ; wird nie aufgerufen

LEDansteuern
	BSF ADCON0, 2, 0
	MOVF ADRESH, 0, 0 	;Wert aus ADCON1 ADRES H, vier hoechste Bit kopieren
	SWAPF WREG, 0, 0
	MOVWF TRISB, 0 		; in PORT B LED <3:0> schreiben
	CALL Zeitschleife
	BTG PORTC, RC2, 0		; Lautsprecher einlesen, invertieren, ausgeben
	RETURN
	
Zeitschleife
	MOVLW 0x64
Start
	NOP ; zusaetzliche Zeitspanne
	DECFSZ WREG, 0, 0
	BRA Start
	RETURN

	BRA MainLoop ;//Do.. Forever  ; wird nicht erreicht
	END
