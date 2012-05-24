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
#include <stdio.h>
#include "Sensors/ADC.h"

#define ADC_PORT_CS 	XS1_PORT_1J
#define ADC_PORT_SCLK	XS1_PORT_1H
#define ADC_PORT_MISO	XS1_PORT_1G
#define ADC_PORT_MOSI	XS1_PORT_1I

#define CHANNEL_GYRO_Z	0 //Correct, others are dummy for now
#define CHANNEL_GYRO_Y	1
#define CHANNEL_GYRO_X	2

#define CHANNEL_ACEL_Z	3
#define CHANNEL_ACEL_Y	4
#define CHANNEL_ACEL_X	5


ADC adc = { ADC_PORT_CS, ADC_PORT_MOSI, ADC_PORT_MISO, ADC_PORT_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };

int main() {
	int adcValues[8];

	configureADC(adc);

	while (1) {
		updateADCValues(adc);
		printf("%i\t%i\t%i\t%i\t%i\t%i\t%i\t%i\n",
				adc.adcValues[0],adc.adcValues[1],adc.adcValues[2],adc.adcValues[3],
				adc.adcValues[4],adc.adcValues[5],adc.adcValues[6],adc.adcValues[7]);
	}
}
