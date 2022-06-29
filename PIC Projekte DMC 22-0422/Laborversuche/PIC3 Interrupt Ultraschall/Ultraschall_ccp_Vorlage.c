#include <stdio.h>
#include <stdlib.h>

#pragma config OSC=HS,WDT=OFF,LVP=OFF,CCP2MUX=OFF  // HS Oszillator, Watchdog Timer disabled, Low Voltage Programming

// Define für LCD des neuen, grünen Demo-Boards:
//#define NEUE_PLATINE  // Achtung: define vor include! Bei altem braunem Demo-Board auskommentieren!

#include "p18f452.h"
#include "lcd.h"


unsigned char cm_text[]="cm";
unsigned char no_obj_text[]="--              ";
unsigned char zeit_text[]="Zeit: ";
unsigned char colon_text[]=":";
unsigned char abstand_text[]="Abstand: ";

unsigned int abstand=0; 			// Abstand des Objekts
unsigned char vorzaehler=0;
unsigned char Stunde=23;
unsigned char Minute=59;
unsigned char Sekunde=55;


void high_prior_InterruptHandler (void);
void low_prior_InterruptHandler (void);


#pragma code high_prior_InterruptVector = 0x08
void high_prior_InterruptVector(void)
{
	_asm
			goto high_prior_InterruptHandler
	_endasm
}


#pragma code low_prior_InterruptVector = 0x18
void low_prior_InterruptVector(void)
{
	_asm
			goto low_prior_InterruptHandler
	_endasm
}


#pragma code init = 0x30
void init (void)
{
	lcd_init();
	lcd_clear();

	TRISA=0x71;
	TRISB=0xFD;
	
	T1CON=0x80;
	T3CON=0x90;

	CCP2CON=0x05;

	RCONbits.IPEN=1;
	IPR2bits.TMR3IP=0;
	IPR2bits.CCP2IP=1;
	PIE2bits.TMR3IE=1;
	PIE2bits.CCP2IE=1;
	PIR2bits.TMR3IF=1;
	PIR2bits.CCP2IF=1;

	T3CONbits.TMR3ON=1;
	T1CONbits.TMR1ON=1;

	INTCONbits.GIE=1;
	INTCONbits.PEIE=1;
	// weiter siehe Flussdiagramm ...
}


// hochpriorisierte ISR:
// Messung der Dauer des Echoimpulses (an RB3/CCP2) durch Timer 1.
// Steigende Flanke an RB3/CCP2: Capture-Wert speichern; Fallende Flanke: Abstand berechnen
volatile int ccp;
#pragma code
#pragma interrupt high_prior_InterruptHandler
void high_prior_InterruptHandler(void)
{
	// weiter siehe Flussdiagramm ...
	if(CCP2CONbits.CCP2MO) {
		ccp=CCPR2;
		PIR1bits.TMR1IF=0; //oder CCP2IF?
		CCP2CONbits.CCP2M0=0;
	} else {
		if(PIR1bits.TMR1IF) {
			abstand=999;
		} else {
			abstand=(CCPR2 - ccp)/58;
		}
		CCP2CONbits.CCP2M0=1;
	}
	PIR2bits.CCP2IF=0;
}


// niedrigpriorisierte ISR:
// 100ms-Intervalle von Timer 3 verwenden, um die Abstandsmessung darzustellen.
// Die Intervalle dienen zugleich als Zeitbasis für die Uhr.
#pragma code
#pragma interruptlow low_prior_InterruptHandler
void low_prior_InterruptHandler(void)
{
	// weiter siehe Flussdiagramm ...
	TMR3+=0x3CB0;
	if(abstand==999) {
		lcd_gotoxy(1,1);
		lcd_printf(no_obj_text);
	} else {
		lcd_gotoxy(1,1);
		lcd_printf(Abstand_text);
		lcd_printf(abstand);
		lcd_printf(cm_text);
	}
	vorzaehler++;
	if (vorzaehler==10) {
		sekunde+=1;
		if (Sekunde==60) {
			Sekunde=0;
			Minute+=1;
		}
		if (Minute==60) {
			Minute=0;
			Stunde+=1;
		}
		if (Stunde==24) {
			Stunde=0;
		}
		lcd_gotoxy(2,1);
		lcd_printf(zeit_text);
		lcd_printf(Stunde);
		lcd_printf(colon_text);
		lcd_printf(Minute);
		lcd_printf(colon_text);
		lcd_printf(Sekunde);
		TMR1=0;
		PORTBbits.RB1 = 1;
		for (int i=0; i<11; ++i) {
			Nop();
		}
		PIR2bits.TMR3IF=0;
	}
}


void main() {
	init();
	while(1);
}
