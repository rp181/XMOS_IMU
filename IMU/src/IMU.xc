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

/**
 * The ADC connected to the 3 Axis Gyros and 3 Axis Accelerometer
 * Channels'respective data is define in the header file
 */
ADC adc = { PORT_ADC_CS, PORT_ADC_MOSI, PORT_ADC_MISO, PORT_ADC_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };

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
