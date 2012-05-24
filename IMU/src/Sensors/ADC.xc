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
#include "ADC.h"
#include <xclib.h>

/**
 * Collects data from the SPI ADCs
 *
 * @param adc Structure defining the ADC to read from
 */
void updateADCValues(ADC &adc) {
	unsigned int compositeData;
	unsigned short data1,data2;
	unsigned char address1, address2;

	for(int i = 0; i < 4; i++) {
		//Read a packet of data, for channel n
		adc.CS <: 0;
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

		data1 = ((unsigned short)((compositeData) >> 16));
		data2 = ((unsigned short)((compositeData) & 65535));

		address1 = (char)((data1 & 57344) >> 13);
		address2 = (char)((data2 & 57344) >> 13);

		adc.adcValues[address1] = ((data1 & 8191) >> 1);
		adc.adcValues[address2] = ((data2 & 8191) >> 1);
	}
}

/**
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

	adc.CS 		<: 1;
	adc.MOSI 	<: 1;
	adc.CS 		<: 0;

	clearbuf(adc.MISO);
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK	<: 0xAA;
	adc.SCLK	<: 0xAA;
	adc.SCLK	<: 0xAA;

	sync(adc.SCLK);
	adc.MISO 	:> data;

	clearbuf(adc.MISO);
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;
	adc.SCLK 	<: 0xAA;

	sync(adc.SCLK);
	adc.MISO 	:> data;

	adc.CS 		<: 1;
	adc.MOSI 	<: 0;
}
