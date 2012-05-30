/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href "www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

extern "C" {
#include "ADC_Funcs.h"
}
#include <math.h>

#define PI 3.141592653

int getRoll(int y, int z) {
	float rY = y;
	float rZ = z;

	float roll = atan2(y, z) * (float) 180 / PI;
	return ((int) roll);
}

int getPitch(int x, int y, int z) {
	float rX = x;
	float rY = y;
	float rZ = z;

	float pitch = atan2(x, sqrt(y * y + z * z)) * (float) 180 / PI;
	return ((int) pitch);
}
