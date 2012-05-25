/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href "www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef GPS_H_
#define GPS_H_

/**
 * Starts the thread to read the GPS data, as well as handle data requests.
 * Requests are always dealt with first, pausing information update. As a
 * result, the rate of requests should be limited, to allow for update.
 * @param uartRX UART data from the UART thread
 * @param gps channel to take and respond to requests
 * @param baud_rate baud rate that the uart thread is running
 */
void readGPS(chanend uartRX, chanend gps, unsigned baud_rate);

#define GPS_DATA_SIZE 18

#define OPERATION_NOFIX 1
#define OPERATION_2D 2
#define OPERATION_3D 3

#define FIX_NONE 0
#define FIX_SPS 1
#define FIX_DIFF 2
#define FIX_PPS 3

#define REQUEST_OPERATION_MODE 0

#define REQUEST_UTC_H 1
#define REQUEST_UTC_M 2
#define REQUEST_UTC_S 3
#define REQUEST_UTC_DS 4

#define REQUEST_LATITUDE_D 5
#define REQUEST_LATITUDE_M 6
#define REQUEST_LATITUDE_DM 7

#define REQUEST_LONGITUDE_D 8
#define REQUEST_LONGITUDE_M 9
#define REQUEST_LONGITUDE_DM 10

#define REQUEST_DAY 11
#define REQUEST_MONTH 12
#define REQUEST_YEAR 13

#define REQUEST_FIX_STATUS 14

#define REQUEST_SATELLITES_USED 15

#define REQUEST_ALTITUDE_I 16
#define REQUEST_ALTITUDE_F 17

#define REQUEST_ALL 18

#endif /* GPS_H_ */
