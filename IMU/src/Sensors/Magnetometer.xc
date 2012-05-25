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

void initMagnetometer(REFERENCE_PARAM(struct r_i2c,i2c)) {
	unsigned char data[1];
	i2c_master_init(i2c);
	data[0] = 0;
	i2c_master_write_reg(ADDRESS_8_WRITE, ADDRESS_MODE, data, 1, i2c);
}

void readMagnetometer(short values[], REFERENCE_PARAM(struct r_i2c,i2c)) {

	i2c_master_read_reg(ADDRESS_7, 0x03, singleData, 1, i2c);
	data[0] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, 0x04, singleData, 1, i2c);
	data[1] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, 0x05, singleData, 1, i2c);
	data[2] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, 0x06, singleData, 1, i2c);
	data[3] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, 0x07, singleData, 1, i2c);
	data[4] = singleData[0];
	i2c_master_read_reg(ADDRESS_7, 0x08, singleData, 1, i2c);
	data[5] = singleData[0];

	values[0] = ((((int) data[0]) << 8) + ((int) data[1]));
	values[1] = ((((int) data[2]) << 8) + ((int) data[3]));
	values[2] = ((((int) data[4]) << 8) + ((int) data[5]));

}
