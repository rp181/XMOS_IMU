/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#include <xs1.h>
#include <platform.h>
#include <stdio.h>
#include "IMU.h"
#include "Sensors/ADC.h"
#include "UART/RX/uart_rx.h"
#include "UART/RX/uart_rx_impl.h"
#include "UART/TX/uart_tx.h"
#include "UART/TX/uart_tx_impl.h"
#include "Sensors/GPS.h"
#include "Sensors/Magnetometer.h"
#include "Sensors/GPS_Funcs.h"
#include "Sensors/ADC_Funcs.h"

#define ARRAY_SIZE(a) (sizeof(a) / sizeof(a[0]))

#define GPS_BIT_RATE 4800
#define SERVER_BIT_RATE 115200
#define BITS_PER_BYTE 8
#define SET_PARITY 2
#define STOP_BIT 2

#define PRINT_GPS 0
#define PRINT_MAG 0
#define PRINT_ADC 1

unsigned gps_baud_rate = GPS_BIT_RATE;
unsigned server_baud_rate = SERVER_BIT_RATE;

ADC adc = { PORT_ADC_CS, PORT_ADC_MOSI, PORT_ADC_MISO, PORT_ADC_SCLK, XS1_CLKBLK_1, XS1_CLKBLK_2 };

buffered in port:1 gpsRx = PORT_GPS_RX;

buffered in port:1 serverRx = PORT_COM0;
out port serverTx = PORT_COM1;

struct r_i2c magnetometer = { PORT_MAG_SCL, PORT_MAG_SDA };

void testADC();
void testGPS(chanend gps);
void testMagnetometer();
void testAllWithServer(chanend serverTx);

int main() {
	chan chanGPSRx, chanGPS, chanServerRx, chanServerTx;
	par {
		/*
		on stdcore[0] :
		{
			unsigned char rx_buffer[1];
			uart_rx(gpsRx, rx_buffer, ARRAY_SIZE(rx_buffer), gps_baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanGPSRx);
		}
		*/
		/*on stdcore[0] :
		{
			unsigned char rx_buffer[1];
			uart_rx(serverRx, rx_buffer, ARRAY_SIZE(rx_buffer), server_baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanServerRx);
		}
		*/
		on stdcore[0] :
		{
			unsigned char tx_buffer[1];
			uart_tx(serverTx, tx_buffer, ARRAY_SIZE(tx_buffer), server_baud_rate, BITS_PER_BYTE, SET_PARITY, STOP_BIT, chanServerTx);
		}
		//on stdcore[0] :	readGPS(chanGPSRx, chanGPS, gps_baud_rate);
		on stdcore[0] : testAllWithServer(chanServerTx);
		/*
		 on stdcore[0] :
		 testGPS(chanGPS);
		 on stdcore[0] :
		 testADC();
		 on stdcore[0] : testMagnetometer();
		 */
	}
}

void testAllWithServer(chanend chanServerTx) {
	int adcValues[8], gRoll, gPitch, gYaw, aRoll, aPitch;
	timer t;
	long time;
	unsigned char txBuffer[1024];
	int bufferLength = 0;

	configureADC(adc);
	printf("Normalizing ADC Values...\n");
	setSamplesForNormalizing(50000);
	normalizeADCValues(adc);
	while (1) {
		updateADCValues(adc);
t		:> time;
		gRoll = getGRoll(adc.adcValues[GYRO_X], time);
		t :> time;
		gPitch = getGPitch(adc.adcValues[GYRO_Y], time);
		t :> time;
		gYaw = getGYaw(adc.adcValues[GYRO_Z], time);

		aRoll = getARoll(adc.rawAdcValues[ACCEL_Y] - Y_OFFSET, adc.rawAdcValues[ACCEL_Z] - Z_OFFSET);
		aPitch = getAPitch(adc.rawAdcValues[ACCEL_X] - X_OFFSET, adc.rawAdcValues[ACCEL_Y] - Y_OFFSET, adc.rawAdcValues[ACCEL_Z] - Z_OFFSET);

		bufferLength = sprintf(txBuffer, "A:%i,%i,%i,%i,%i,%i,%i,%i,%i,%i,%i\n",
				adc.adcValues[ACCEL_X],adc.adcValues[ACCEL_Y],adc.adcValues[ACCEL_Z],
				adc.adcValues[GYRO_X],adc.adcValues[GYRO_Y],adc.adcValues[GYRO_Z],
				aRoll, aPitch, gRoll, gPitch, gYaw);

		for(int i = 0; i < bufferLength; i++) {
			uart_tx_send_byte(chanServerTx,((unsigned char)txBuffer[i]));
		}

	}
}

void testMagnetometer() {
	short values[3];

	initMagnetometer(magnetometer);
	while (1) {
		readMagnetometer(values, magnetometer);
		if (PRINT_MAG == 1) {
			printf("Mag: %i\t%i\t%i\n", values[0], values[1], values[2]);
		}
	}
}

void testGPS(chanend gps) {
	short GPSData[GPS_DATA_SIZE];
	timer t;
	long time;
	short lat1[3], lon1[3];
	short lat2[3], lon2[3];

	while (1) {

		lon1[0] = lon2[0];
		lon1[1] = lon2[1];
		lon1[2] = lon2[2];
		lat1[0] = lat2[0];
		lat1[1] = lat2[1];
		lat1[2] = lat2[2];

gps		<: ((unsigned char) REQUEST_ALL);
		slave {
			for(int i = 0; i < GPS_DATA_SIZE; i++) {
				gps :> GPSData[i];
			}
		}

		lat2[0] = GPSData[REQUEST_LATITUDE_D];
		lat2[1] = GPSData[REQUEST_LATITUDE_M];
		lat2[2] = GPSData[REQUEST_LATITUDE_DM];

		lon2[0] = GPSData[REQUEST_LONGITUDE_D];
		lon2[1] = GPSData[REQUEST_LONGITUDE_M];
		lon2[2] = GPSData[REQUEST_LONGITUDE_DM];

		if(PRINT_GPS) {
			printf("GPS: (%i:%i:%i.%i) :   OP:%i  Fix:%i  Num Sats:%i  %i%c%i.%i, %i%c%i.%i   %i.%im   Date: %i\\%i\\%i   Dist: %i\n",
					GPSData[REQUEST_UTC_H],GPSData[REQUEST_UTC_M],GPSData[REQUEST_UTC_S],
					GPSData[REQUEST_UTC_DS], GPSData[REQUEST_OPERATION_MODE],
					GPSData[REQUEST_FIX_STATUS], GPSData[REQUEST_SATELLITES_USED],
					GPSData[REQUEST_LATITUDE_D], ((char) 176), GPSData[REQUEST_LATITUDE_M],
					GPSData[REQUEST_LATITUDE_DM], GPSData[REQUEST_LONGITUDE_D],
					((char) 176), GPSData[REQUEST_LONGITUDE_M], GPSData[REQUEST_LONGITUDE_DM],
					GPSData[REQUEST_ALTITUDE_I], GPSData[REQUEST_ALTITUDE_F],
					GPSData[REQUEST_MONTH], GPSData[REQUEST_DAY], GPSData[REQUEST_YEAR], getDistance(lat1,lon1, lat2, lon2));
		}

		t :> time;
		time += 50000000;
		t when timerafter(time) :> void;
	}
}

void testADC() {
	int adcValues[8], gRoll, gPitch, gYaw, aRoll, aPitch;
	timer t;
	long time;

	configureADC(adc);
	printf("Normalizing ADC Values...\n");
	setSamplesForNormalizing(50000);
	normalizeADCValues(adc);
	while (1) {
		for (int i = 0; i < 5; i++) {
			updateADCValues(adc);
t			:> time;
			gRoll = getGRoll(adc.adcValues[GYRO_X], time);
			t :> time;
			gPitch = getGPitch(adc.adcValues[GYRO_Y], time);
			t :> time;
			gYaw = getGYaw(adc.adcValues[GYRO_Z], time);

			aRoll = getARoll(adc.rawAdcValues[ACCEL_Y] - Y_OFFSET, adc.rawAdcValues[ACCEL_Z] - Z_OFFSET);
			aPitch = getAPitch(adc.rawAdcValues[ACCEL_X] - X_OFFSET, adc.rawAdcValues[ACCEL_Y] - Y_OFFSET, adc.rawAdcValues[ACCEL_Z] - Z_OFFSET);
		}
		if (PRINT_ADC) {
			printf("ADC:\t%i\t%i\t%i\t%i\t%i\t%i\tA_Roll: %i \tA_Pitch: %i \tG_Roll: %i \tG_Pitch: %i \tG_Yaw: %i\n",
					adc.adcValues[ACCEL_X], adc.adcValues[ACCEL_Y], adc.adcValues[ACCEL_Z],
					getDegreesSecond(adc.adcValues[GYRO_X]), getDegreesSecond(adc.adcValues[GYRO_Y]), getDegreesSecond(adc.adcValues[GYRO_Z]),
					aRoll,aPitch, gRoll, gPitch, gYaw);

		}
	}
}
