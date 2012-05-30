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
#define COUNTS_DEGREE 20.5

float gRoll = 0, gPitch = 0, gYaw = 0;
long rTime = 0, pTime = 0, yTime = 0;

/**
 * Take the integral of the gyro with respect to time, and add on the angle
 * @param rateCounts
 * @param time
 * @return
 */
int getGRoll(int rateCounts, long time){
	float rate = rateCounts/COUNTS_DEGREE;
	gRoll += rate * ((time-rTime)*.00000001);
	rTime = time;
	return ((int) gRoll);
}

/**
 * Take the integral of the gyro with respect to time, and add on the angle
 * @param rateCounts
 * @param time
 * @return
 */
int getGPitch(int rateCounts, long time){
	float rate = rateCounts/COUNTS_DEGREE;
	gPitch += rate * ((time-pTime)*.00000001);
	pTime = time;
	return ((int) gPitch);
}

/**
 * Take the integral of the gyro with respect to time, and add on the angle
 * @param rateCounts
 * @param time
 * @return
 */
int getGYaw(int rateCounts, long time){
	float rate = rateCounts/COUNTS_DEGREE;
	gYaw += rate * ((time-yTime)*.00000001);
	yTime = time;
	return ((int) gYaw);
}
/**
 * Returns degrees/second from a gyro offsetted ADC value
 * @param rateCounts
 * @return
 */
int getDegreesSecond(int rateCounts){
	float degrees = rateCounts/COUNTS_DEGREE;
	return ((int) degrees);
}

/**
 * Calculates the roll in degrees, based on the accelerometer values
 * @param y Offsetted Y acceleration
 * @param z Offsetted z acceleration
 * @return Roll in degrees
 */
int getARoll(int y, int z) {
	float rY = y;
	float rZ = z;

	float roll = atan2(y, z) * (float) 180 / PI;
	return ((int) roll);
}

/**
 * Calculates the roll in degrees, based on the accelerometer values
 * @param x Offsetted X acceleration
 * @param y Offsetted Y acceleration
 * @param z Offsetted Z acceleration
 * @return Pitch in degrees
 */
int getAPitch(int x, int y, int z) {
	float rX = x;
	float rY = y;
	float rZ = z;

	float pitch = atan2(x, sqrt(y * y + z * z)) * (float) 180 / PI;
	return ((int) pitch);
}
