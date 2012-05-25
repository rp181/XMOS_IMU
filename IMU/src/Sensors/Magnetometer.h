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

void readMagnetometer(short values[], REFERENCE_PARAM(struct r_i2c,i2c));
void initMagnetometer(REFERENCE_PARAM(struct r_i2c,i2c));

#define ADDRESS_7 		0x1E
#define ADDRESS_8_READ 	0x3D
#define ADDRESS_8_WRITE	0x3C
#define ADDRESS_MODE	0x02
#define ADDRESS_XA		0x03
#define ADDRESS_XB		0x04
#define ADDRESS_YA		0x05
#define ADDRESS_YB		0x06
#define ADDRESS_ZA		0x07
#define ADDRESS_ZB		0x08

#endif /* MAGNETOMETER_H_ */
