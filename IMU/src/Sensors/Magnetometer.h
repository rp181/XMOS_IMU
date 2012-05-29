/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#include "../Libs/I2C/i2c.h"

#ifndef MAGNETOMETER_H_
#define MAGNETOMETER_H_

#define ADDRESS_7 				0x1E
#define ADDRESS_8_READ 			0x3D
#define ADDRESS_8_WRITE			0x3C
#define ADDRESS_CONFIGURATION_1	0x00
#define ADDRESS_CONFIGURATION_2	0x01
#define ADDRESS_MODE			0x02
#define ADDRESS_XA				0x03
#define ADDRESS_XB				0x04
#define ADDRESS_YA				0x05
#define ADDRESS_YB				0x06
#define ADDRESS_ZA				0x07
#define ADDRESS_ZB				0x08

#define GAIN_07					0b00000000	// (+/-) 0.7
#define GAIN_1					0b00100000	// (+/-) 1.0
#define GAIN_15					0b01000000	// (+/-) 1.5
#define GAIN_2					0b01100000	// (+/-) 2.0
#define GAIN_32					0b10000000	// (+/-) 3.2
#define GAIN_38					0b10100000	// (+/-) 3.8
#define GAIN_45					0b11000000	// (+/-) 4.5

/**
 * Read the magnetometer registers for the most recent heading data
 * @param values the array for the values to be stored in
 * @param i2c the i2c lines the magnetometer is on
 */
void readMagnetometer(short values[], REFERENCE_PARAM(struct r_i2c,i2c));

/**
 * Initialize the I2C prots, as well as the magnetometer
 * @param the i2c ports
 */
void initMagnetometer(REFERENCE_PARAM(struct r_i2c,i2c));

/**
 * Set the magnetometer gain (as defined by the header file)
 * @param gain
 */
void setMagnetometerGain(char gain, REFERENCE_PARAM(struct r_i2c,i2c));

#endif /* MAGNETOMETER_H_ */
