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
#include "Magnetometer.h"

unsigned char data[6], singleData[1];

/**
 * Initialize the I2C prots, as well as the magnetometer
 * @param the i2c ports
 */
void initMagnetometer(REFERENCE_PARAM(struct r_i2c,i2c)) {
	i2c_master_init(i2c);

	//50 Hz normal measurement mode
	singleData[0] = 0b00011000;
	i2c_master_write_reg(ADDRESS_7, ADDRESS_CONFIGURATION_1, singleData, 1, i2c);

	//Default gain (+/- 1Ga)
	singleData[0] = GAIN_1;
	i2c_master_write_reg(ADDRESS_7, ADDRESS_CONFIGURATION_2, singleData, 1, i2c);

	//Continous conversion mode
	singleData[0] = 0b00000000;
	i2c_master_write_reg(ADDRESS_7, ADDRESS_MODE, singleData, 1, i2c);
}

/**
 * Set the magnetometer gain (as defined by the header file)
 * @param gain
 */
void setMagnetometerGain(char gain, REFERENCE_PARAM(struct r_i2c,i2c)){
	singleData[0] = gain;
	i2c_master_write_reg(ADDRESS_7, ADDRESS_CONFIGURATION_2, singleData, 1, i2c);
}

/**
 * Read the magnetometer registers for the most recent heading data
 * @param values the array for the values to be stored in
 * @param i2c the i2c lines the magnetometer is on
 */
void readMagnetometer(short values[], REFERENCE_PARAM(struct r_i2c,i2c)) {
	i2c_master_read_reg(ADDRESS_7, ADDRESS_XA, singleData, 1, i2c);
	data[0] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, ADDRESS_XB, singleData, 1, i2c);
	data[1] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, ADDRESS_YA, singleData, 1, i2c);
	data[2] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, ADDRESS_YB, singleData, 1, i2c);
	data[3] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, ADDRESS_ZA, singleData, 1, i2c);
	data[4] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, ADDRESS_ZB, singleData, 1, i2c);
	data[5] = singleData [0];

	values[0] = ((((int) data[0]) << 8) + ((int) data[1]));
	values[1] = ((((int) data[2]) << 8) + ((int) data[3]));
	values[2] = ((((int) data[4]) << 8) + ((int) data[5]));

}
