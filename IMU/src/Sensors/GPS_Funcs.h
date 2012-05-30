/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href "www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef GPS_FUNCS_H_
#define GPS_FUNCS_H_

#ifdef __XC__
#define EXTERNAL extern
#else
#define EXTERNAL extern "C"
#endif

/**
 * Distance between 2 lat/lon coordinates in meters, using the Spherical law of cosines
 * @param lat1
 * @param lon1
 * @param lat2
 * @param lon2
 */
EXTERNAL unsigned short getDistance(short lat1[3], short lon1[3], short lat2[3], short lon2[3]);

/**
 * Returns the bearing, in degrees, from two GPS coordinates
 * @param lat1
 * @param lon1
 * @param lat2
 * @param lon2
 */
unsigned short getBearing(short lat1[3], short lon1[3], short lat2[3], short lon2[3]);
#endif /* GPS_FUNCS_H_ */
