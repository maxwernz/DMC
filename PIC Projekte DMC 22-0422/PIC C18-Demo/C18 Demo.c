// Hochschule Mannheim
// Institut für Embedded Systems
//
// Demoprojekt für C18-Compiler:
// LEDs als Binärzähler + Lautsprecher Toggle
// oder binärer Zufallszahlen-Generator an den LED-Ports RB3..RB0
//
// Autor: Bernhard Pohlner 24.05.2020

#pragma config OSC=HS,WDT=OFF,LVP=OFF  // HS Oszillator, Watchdog Timer disabled, Low Voltage Programming

#include "p18f452.h"

/* globale Variablen */
unsigned char LED_Pattern;
unsigned int delay;
unsigned int count;	// als globale Variable

void Delay(int delay)
{
	//unsigned int count;	// als lokale Variable

	for (count=0;count<=delay;count++);	// Verzögerungsschleife
}

void main (void)
{
	/* Init */
	PORTB=0;			// LED-Port RB3..RB0 rücksetzen und
	TRISB=0xF0;			// als Ausgänge

	PORTCbits.RC2=1;	// Lautsprecher macht einen Tick -
	TRISCbits.TRISC2=0;	// jetzt (Ausgang)

	TRISAbits.TRISA4=1;	// Taster RA4 als Eingang (optional / per Reset schon gemacht)

	LED_Pattern=0;		// LED-Bitmuster

	while(1)	// Main Loop
	{
		while(PORTAbits.RA4);	// Warten bis Taster RA4 gedrückt

		LED_Pattern++;
		if (LED_Pattern==0x10) LED_Pattern=0;	// Überlauf
		PORTB= (PORTB & 0xF0) | LED_Pattern;

		PORTCbits.RC2=~PORTCbits.RC2;	// Lautsprecher Toggle

		Delay(2);		// für SIM
		//Delay(10000);	// auf der Hardware, um Wechsel der LEDs zu beobachten
	}
}
