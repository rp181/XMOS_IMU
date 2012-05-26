/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

/**
 * !!!The GPS data will not update if requests are made too often!!!
 */
#include <xs1.h>
#include <platform.h>
#include "../Libs/UART/RX/uart_rx.h"
#include "../Libs/UART/RX/uart_rx_impl.h"
#include "GPS.h"

/**
 * Determine NMEA String type and offload for parsing
 * @param buffer read line
 * @param length buffer length
 */
void parseNMEAString(char buffer[], int length);

/**
 * Parse the $GPGSA NMEA strings
 * @param buffer read line
 * @param length buffer length
 */
void parseGSA(char buffer[], int length);

/**
 * Parse the $GPRMC NMEA strings
 * @param buffer read line
 * @param length buffer length
 */
void parseRMC(char buffer[], int length);

/**
 * Parse the $GPGGA NMEA strings
 * @param buffer read line
 * @param length buffer length
 */
void parseGGA(char buffer[], int length);

/**
 * Most up-to-date GPS data
 */
short GPSData[GPS_DATA_SIZE];

/**
 * Starts the thread to read the GPS data, as well as handle data requests.
 * Requests are always dealt with first, pausing information update. As a
 * result, the rate of requests should be limited, to allow for update.
 * @param uartRX UART data from the UART thread
 * @param gps channel to take and respond to requests
 * @param baud_rate baud rate that the uart thread is running
 */
void readGPS(chanend uartRX, chanend gps, unsigned baud_rate) {
	unsigned char byte;
	unsigned char buffer[256];
	unsigned char request;
	int bufferLength;

	//Configure the UART Portion
	uart_rx_client_state rxState;
	uart_rx_init(uartRX, rxState);
	uart_rx_set_baud_rate(uartRX, rxState, baud_rate);

	//Continuosly update GPA data, while handling requests first
	while (1) {
		bufferLength = 0;
		do {
			select {
				case gps :> request:
					if(request != REQUEST_ALL){
						gps <: GPSData[request];
					}
					else{
						master {
							for(int i = 0; i < GPS_DATA_SIZE; i++){
								gps <: GPSData[i];
							}
						}
					}
				break;
				default:
				uart_rx_get_byte_byref(uartRX, rxState, byte);
				buffer[bufferLength] = byte;
				bufferLength++;
				break;
			}
		}while (byte != '\n');
		parseNMEAString(buffer, bufferLength);
	}
}

/**
 * Parses the GSA String. This updates the GPS Operational Mode
 * @param buffer
 * @param length
 */
void parseGSA(char buffer[], int length) {
	GPSData[REQUEST_OPERATION_MODE] = (int) (buffer[9] - '0');
}

/**
 * Parse the RMC String. This updates the UTC time, Lat/Lon, and Date
 * @param buffer
 * @param length
 */
void parseRMC(char buffer[], int length) {
	short commaCounter = 0;
	char dateStart = 0;
	//Check for Data Valid
	if (buffer[18] == 'A') {
		//UTC Time
		GPSData[REQUEST_UTC_H] = (int) (((buffer[7] - '0') * 10) + ((buffer[8] - '0')));
		GPSData[REQUEST_UTC_M] = (int) (((buffer[9] - '0') * 10) + ((buffer[10] - '0')));
		GPSData[REQUEST_UTC_S] = (int) (((buffer[11] - '0') * 10) + ((buffer[12] - '0')));
		GPSData[REQUEST_UTC_DS] = (int) (((buffer[14] - '0') * 100) + ((buffer[15] - '0') * 10) + ((buffer[16] - '0')));

		//Latitude
		GPSData[REQUEST_LATITUDE_D] = (int) (((buffer[20] - '0') * 10) + ((buffer[21] - '0')));
		GPSData[REQUEST_LATITUDE_M] = (int) (((buffer[22] - '0') * 10) + ((buffer[23] - '0')));
		GPSData[REQUEST_LATITUDE_DM] = (int) (((buffer[25] - '0') * 1000) + ((buffer[26] - '0') * 100) + ((buffer[27] - '0') * 10) + ((buffer[28] - '0')));
		if (buffer[30] == 'S') {
			GPSData[REQUEST_LATITUDE_D] = -GPSData[REQUEST_LATITUDE_D];
		}

		//Longitude
		GPSData[REQUEST_LONGITUDE_D] = (int) (((buffer[32] - '0') * 100) + ((buffer[33] - '0') * 10) + ((buffer[34] - '0')));
		GPSData[REQUEST_LONGITUDE_M] = (int) (((buffer[35] - '0') * 10) + ((buffer[36] - '0')));
		GPSData[REQUEST_LONGITUDE_DM] = (int) (((buffer[38] - '0') * 1000) + ((buffer[39] - '0') * 100) + ((buffer[40] - '0') * 10) + ((buffer[41] - '0')));
		if (buffer[43] == 'W') {
			GPSData[REQUEST_LONGITUDE_D] = -GPSData[REQUEST_LONGITUDE_D];
		}

		//Find where the date starts
		for (int i = 0; i < length; i++) {
			if (buffer[i] == ',') {
				commaCounter++;
			}
			if (commaCounter == 9) {
				dateStart = i + 1;
				break;
			}
		}
		//Date
		GPSData[REQUEST_DAY] = (((buffer[dateStart + 0] - '0') * 10) + ((buffer[dateStart + 1] - '0')));
		GPSData[REQUEST_MONTH] = (((buffer[dateStart + 2] - '0') * 10) + ((buffer[dateStart + 3] - '0')));
		GPSData[REQUEST_YEAR] = (((buffer[dateStart + 4] - '0') * 10) + ((buffer[dateStart + 5] - '0')));
	}
}

/**
 * Parses the GGA String. This updates the UTC Time, Lat/Lon, Altitude,
 * Fix Status, and Number of Satellites in view
 * @param buffer
 * @param length
 */
void parseGGA(char buffer[], int length) {
	short tempAltitude, commaCounter, counter;

	//UTC Time
	GPSData[REQUEST_UTC_H] = (int) (((buffer[7] - '0') * 10) + ((buffer[8] - '0')));
	GPSData[REQUEST_UTC_M] = (int) (((buffer[9] - '0') * 10) + ((buffer[10] - '0')));
	GPSData[REQUEST_UTC_S] = (int) (((buffer[11] - '0') * 10) + ((buffer[12] - '0')));
	GPSData[REQUEST_UTC_DS] = (int) (((buffer[14] - '0') * 100) + ((buffer[15] - '0') * 10) + ((buffer[16] - '0')));

	//Latitude
	GPSData[REQUEST_LATITUDE_D] = (int) (((buffer[18] - '0') * 10) + ((buffer[19] - '0')));
	GPSData[REQUEST_LATITUDE_M] = (int) (((buffer[20] - '0') * 10) + ((buffer[21] - '0')));
	GPSData[REQUEST_LATITUDE_DM] = (int) (((buffer[23] - '0') * 1000) + ((buffer[24] - '0') * 100) + ((buffer[25] - '0') * 10) + ((buffer[26] - '0')));
	if (buffer[28] == 'S') {
		GPSData[REQUEST_LATITUDE_D] = -GPSData[REQUEST_LATITUDE_D];
	}

	//Longitude
	GPSData[REQUEST_LONGITUDE_D] = (int) (((buffer[30] - '0') * 100) + ((buffer[31] - '0') * 10) + ((buffer[32] - '0')));
	GPSData[REQUEST_LONGITUDE_M] = (int) (((buffer[33] - '0') * 10) + ((buffer[34] - '0')));
	GPSData[REQUEST_LONGITUDE_DM] = (int) (((buffer[36] - '0') * 1000) + ((buffer[37] - '0') * 100) + ((buffer[38] - '0') * 10) + ((buffer[39] - '0')));
	if (buffer[41] == 'W') {
		GPSData[REQUEST_LONGITUDE_D] = -GPSData[REQUEST_LONGITUDE_D];
	}

	//GPS Fix Status
	GPSData[REQUEST_FIX_STATUS] = (int) (buffer[43] - '0');

	//Satellites Used
	GPSData[REQUEST_SATELLITES_USED] = (int) (((buffer[45] - '0') * 10) + ((buffer[46] - '0')));

	//Find where the altitude starts
	for (int i = 0; i < length; i++) {
		if (buffer[i] == ',') {
			commaCounter++;
		}
		if (commaCounter == 9) {
			counter = i + 1;
			break;
		}
	}
	//Altitude
	tempAltitude = 0;
	do {
		tempAltitude = (tempAltitude * 10) + (buffer[counter] - '0');
		counter++;
	} while (buffer[counter] != '.');
	GPSData[REQUEST_ALTITUDE_I] = tempAltitude;

	tempAltitude = 0;
	do {
		tempAltitude = (tempAltitude * 10) + (buffer[52 + counter] - '0');
		counter++;
	} while (buffer[52 + counter] != ',');
	GPSData[REQUEST_ALTITUDE_F] = tempAltitude;
}

/**
 * Determine the NMEA String type and parse, as well as cursory validity tests
 * @param buffer
 * @param length
 */
void parseNMEAString(char buffer[], int length) {
	if (buffer[0] != '$') {
		//Incomplete String, invalid NMEA inital character
		return;
	}

	if (buffer[3] == 'G' && buffer[4] == 'S' && buffer[5] == 'A' && length > 9) {
		//GNSS DOP and Active Satellites
		parseGSA(buffer, length);
	} else if (buffer[3] == 'R' && buffer[4] == 'M' && buffer[5] == 'C' && length > 43) {
		//Recommended Minimum Specific GNSS Data
		parseRMC(buffer, length);
	} else if (buffer[3] == 'G' && buffer[4] == 'G' && buffer[5] == 'A' && length > 46) {
		//Global Positioning System Fixed Data
		parseGGA(buffer, length);
	}
}
