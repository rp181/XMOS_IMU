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
#include "GPS_Funcs.h"
}
#include <math.h>
#include <stdio.h>

#define PI 3.141592653
#define EARTH_RADIUS 6371000 //Radius of the earth in m (assuming perfect sphere)
#define DEG_TO_RAD 0.0174532925
#define RAD_TO_DEG 57.295779500

double getRadiansDouble(short array[3]);

/**
 * Distance between 2 lat/lon coordinates in meters, using the Spherical law of cosines
 * @param lat1
 * @param lon1
 * @param lat2
 * @param lon2
 */
unsigned short getDistance(short lat1[3], short lon1[3], short lat2[3], short lon2[3]) {

	//Convert ddmm.mmmm to dd.dddd and consolidate into a double, and convert to radians
	double latitude1 = getRadiansDouble(lat1);
	double latitude2 = getRadiansDouble(lat2);
	double longitude1 = getRadiansDouble(lon1);
	double longitude2 = getRadiansDouble(lon2);

	double distance = acos(sin(latitude1) * sin(latitude2) + cos(latitude1) * cos(latitude2) * cos(longitude2 - longitude1)) * EARTH_RADIUS;

	return ((unsigned short) distance);
}

/**
 * Returns the bearing, in degrees, from two GPS coordinates
 * @param lat1
 * @param lon1
 * @param lat2
 * @param lon2
 */
unsigned short getBearing(short lat1[3], short lon1[3], short lat2[3], short lon2[3]) {
	//Convert ddmm.mmmm to dd.dddd and consolidate into a double, and convert to radians
	double latitude1 = getRadiansDouble(lat1);
	double latitude2 = getRadiansDouble(lat2);
	double longitude1 = getRadiansDouble(lon1);
	double longitude2 = getRadiansDouble(lon2);

	double dLon = longitude2 - longitude1;
	double x = cos(latitude1) * sin(latitude2) - sin(latitude1) * cos(latitude2) * cos(dLon);
	double y = sin(dLon) * cos(latitude2);

	double bearing = (atan2(y, x) * RAD_TO_DEG) + 180;
	while (bearing > 360) {
		bearing -= 360;
	}
	return ((unsigned short) bearing);
}

/**
 *Consoloidates the array (degree, minutes, decimal minutes) into a double and converts to radians
 * @param array
 * @return
 */
double getRadiansDouble(short array[3]) {
	return (array[0] + ((((double) array[1]) + (((double) array[2]) / ((double) 10000))) / (double) 60)) * DEG_TO_RAD;
}
