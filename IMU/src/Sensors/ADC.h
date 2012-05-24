/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef ADC_H_
#define ADC_H_

/**
 * A structure containing all of the neccesary components to control a SPI ADC module
 *
 * @param CS Chip Select 1 bit port
 * @param MOSI MOSI 1 bit port
 * @param MISO buffered:32 1 bit input port
 * @param SCLK buffered:8 1 bit output port
 * @param blk1 A clock block
 * @param blk2 A clock block
 */
typedef struct ADC {
	out port CS;
	out port MOSI;
	in buffered port:32 MISO;
	out buffered port:8 SCLK;
	clock blk1;
	clock blk2;
	int adcValues[8];
} ADC;

/**
 * Bit-bangs configuration data to the ADC:
 * Normal power mode, sequencer 0-7, maximum speed
 * Must be called prior to using the ADCs to ensure proper data return
 * Each ADC must be configured
 *
 * @param adc Structure defining the ADC to configure
 */
void configureADC(ADC &adc);

/**
 * Collects data from the SPI ADCs
 *
 * @param adc Structure defining the ADC to read from
 */
void updateADCValues(ADC &adc);

#endif /* ADC_H_ */
