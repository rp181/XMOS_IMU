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
#include <xclib.h>
#include "ADC.h"

int samplesForNormalize = 5000;
int offsets[8] = {0,0,0,0,0,0,0,0};

void setSamplesForNormalizing(int samples){
	samplesForNormalize = samples;
}

int getSamplesForNormalizing(){
	return samplesForNormalize;
}

/**
 * Average samplesForNormalize samples to offset the ADC values
 * @param adc
 */
void normalizeADCValues(ADC &adc) {
	int localSamplesForNormalize = samplesForNormalize;
	int localOffsets[8] = {0,0,0,0,0,0,0,0};
	timer t;
	long time;

	for (int i = 0; i < localSamplesForNormalize; i++) {
		updateADCValues(adc);
		for (int d = 0; d < 8; d++) {
			localOffsets[d] += adc.adcValues[d];
		}

		t :> time;
		time += 1000;
		t when timerafter(time) :> void;
	}

	for (int i = 0; i < 8; i++) {
		offsets[i] = localOffsets[i]/localSamplesForNormalize;
	}
}

/**
 * Collects data from the SPI ADCs
 *
 * @param adc Structure defining the ADC to read from
 */
void updateADCValues(ADC &adc) {
	unsigned int compositeData;
	unsigned short data1, data2;
	unsigned char address1, address2;

	//Read 4 sets of 2 packets of data (all 8 channels)
	//Each packet of data has the address and data
	for (int i = 0; i < 4; i++) {
		//Read a packet of data, for channel n
adc		.CS <: 0;
		clearbuf(adc.MISO);
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;
		sync(adc.SCLK);
		adc.CS <: 1;

		//Read a packet of data, for channel n+1
		adc.CS <: 0;
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;
		adc.SCLK <: 0xAA;

		adc.MISO :> compositeData;
		adc.CS <: 1;

		compositeData = ((int)bitrev(compositeData));

		//Split the integer into the 2 data sets read
		data1 = ((unsigned short)((compositeData) >> 16));
		data2 = ((unsigned short)((compositeData) & 65535));

		//Obtain the read address
		address1 = (char)((data1 & 57344) >> 13);
		address2 = (char)((data2 & 57344) >> 13);

		//Obtain the data values
		adc.rawAdcValues[address1] = ((data1 & 8191) >> 1);
		adc.rawAdcValues[address2] = ((data2 & 8191) >> 1);
		adc.adcValues[address1] = adc.rawAdcValues[address1] - offsets[address1];
		adc.adcValues[address2] = adc.rawAdcValues[address2] - offsets[address2];
	}
}

/**
 * Configures the ADC pins
 * Bit-bangs configuration data to the ADC:
 * Normal power mode, sequencer 0-7, maximum speed
 * Must be called prior to using the ADCs to ensure proper data return
 * Each ADC must be configured
 *
 * @param adc Structure defining the ADC to configure
 */
void configureADC(ADC &adc) {
	int data;

	configure_clock_rate(adc.blk1, 100, 2);
	configure_out_port(adc.SCLK, adc.blk1, 0);
	configure_clock_src(adc.blk2, adc.SCLK);
	configure_in_port(adc.MISO, adc.blk2);
	clearbuf(adc.SCLK);
	start_clock(adc.blk1);
	start_clock(adc.blk2);
	adc.SCLK <: 0xFF;

	adc.CS <: 1;
	adc.MOSI <: 1;
	adc.CS <: 0;

	clearbuf(adc.MISO);
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;

	sync(adc.SCLK);
	adc.MISO :> data;

	clearbuf(adc.MISO);
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;
	adc.SCLK <: 0xAA;

	sync(adc.SCLK);
	adc.MISO :> data;

	adc.CS <: 1;
	adc.MOSI <: 0;
}
