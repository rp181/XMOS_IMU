/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include "IMU.h"
#include "Sensors/ADC.h"
#include "UART/RX/uart_rx.h"
#include "UART/RX/uart_rx_impl.h"
#include "Sensors/GPS.h"

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

#define BIT_RATE 4800
#define BITS_PER_BYTE 8
#define SET_PARITY 2
#define STOP_BIT 2

unsigned baud_rate = BIT_RATE;

/**
 * The ADC connected to the 3 Axis Gyros and 3 Axis Accelerometer
 * Channels'respective data is define in the header file
 */
ADC adc = { PORT_ADC_CS, PORT_ADC_MOSI, PORT_ADC_MISO, PORT_ADC_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };
buffered in port:1 rx = PORT_GPS_RX;

void testADC();
void testGPS(chanend gps);

int main() {
	chan chanRX, chanGPS;
	par {
		on stdcore[0] :
		{
			unsigned char rx_buffer[1];
			uart_rx(rx, rx_buffer, ARRAY_SIZE(rx_buffer), baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanRX);
		}on stdcore[0] :
		readGPS(chanRX, chanGPS, baud_rate);
		on stdcore[0] :
		testGPS(chanGPS);
		on stdcore[0] : testADC();
	}
}

void testGPS(chanend gps) {
	short latd, latm, latdm, lond, lonm, londm;
	short day, month, year;
	short operationMode, fixStatus, satellitesUsed;
	short utch, utcm, utcs, utcds;
	short altitudeI, altitudeF;
	timer t;
	long time;
	while (1) {
gps		<: ((unsigned char) REQUEST_LATITUDE_D);
		gps :> latd;
		gps <: ((unsigned char) REQUEST_LATITUDE_M);
		gps :> latm;
		gps <: ((unsigned char) REQUEST_LATITUDE_DM);
		gps :> latdm;

		gps <: ((unsigned char) REQUEST_LONGITUDE_D);
		gps :> lond;
		gps <: ((unsigned char) REQUEST_LONGITUDE_M);
		gps :> lonm;
		gps <: ((unsigned char) REQUEST_LONGITUDE_DM);
		gps :> londm;

		gps <: ((unsigned char) REQUEST_DAY);
		gps :> day;
		gps <: ((unsigned char) REQUEST_MONTH);
		gps :> month;
		gps <: ((unsigned char) REQUEST_YEAR);
		gps :> year;

		gps <: ((unsigned char) REQUEST_UTC_H);
		gps :> utch;
		gps <: ((unsigned char) REQUEST_UTC_M);
		gps :> utcm;
		gps <: ((unsigned char) REQUEST_UTC_S);
		gps :> utcs;
		gps <: ((unsigned char) REQUEST_UTC_DS);
		gps :> utcds;

		gps <: ((unsigned char) REQUEST_OPERATION_MODE);
		gps :> operationMode;
		gps <: ((unsigned char) REQUEST_FIX_STATUS);
		gps :> fixStatus;
		gps <: ((unsigned char) REQUEST_SATELLITES_USED);
		gps :> satellitesUsed;

		gps <: ((unsigned char) REQUEST_ALTITUDE_I);
		gps :> altitudeI;
		gps <: ((unsigned char) REQUEST_ALTITUDE_F);
		gps :> altitudeF;

		printf("(%i:%i:%i.%i)\tOP:%i  Fix:%i  Num Sats:%i  %i%c%i.%i, %i%c%i.%i   %i.%im   Date: %i\\%i\\%i\n",utch,utcm,utcs,utcds, operationMode, fixStatus, satellitesUsed, latd, ((char) 176), latm, latdm, lond, ((char) 176), lonm, londm, altitudeI, altitudeF,month, day, year);

		t :> time;
		time += 50000000;
		t when timerafter(time) :> void;
	}
}

void testADC() {
	int adcValues[8];

	configureADC(adc);
	while (1) {
		updateADCValues(adc);
		printf("%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n", adc.adcValues[0], adc.adcValues[1], adc.adcValues[2], adc.adcValues[3], adc.adcValues[4], adc.adcValues[5], adc.adcValues[6], adc.adcValues[7]);
	}
}
