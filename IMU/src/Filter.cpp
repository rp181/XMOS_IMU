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
#include "Filter.h"
}
#include <stdio.h>
#include "Libs/Math/MathUtils.h"
#include <math.h>
#include <inttypes.h>
#include <stdlib.h>

#define Kp 2.3f			// proportional gain governs rate of convergence to accelerometer/magnetometer
#define Ki 0.005f		// integral gain governs rate of convergence of gyroscope biases
vector MAG_MIN = { -709, -751, -772 };
vector MAG_MAX = { 591, 649, 554 };

vector accelAngles, gyroAngles, magValues;

short rawADCValues[6];
short rawMagValues[3];
long lastTime = 0, lastTime2 = 0;
float gyRoll = 0, gyPitch = 0, gyYaw = 0;

int roll, pitch, yaw;
float rollf, pitchf, yawf;

vector getAccelAngles();
vector getGyroAngles(long time);
float getHeading(vector *a, vector *m, vector *p);
void DCMFilter(long time, float gx, float gy, float gz,
		float ax, float ay, float az,
		float mx, float my, float mz);

float gx, gy, gz;
float q0 = 1, q1 = 0, q2 = 0, q3 = 0; // quaternion elements representing the estimated orientation
float exInt = 0, eyInt = 0, ezInt = 0; // scaled integral error

void initFilter() {

}

void runFilter(long time) {
	gyroAngles = getGyroAngles(time);
	accelAngles = getAccelAngles();

	gx = rawADCValues[3] / 20.5;
	gy = rawADCValues[4] / 20.5;
	gz = rawADCValues[5] / 20.5;

	gx *= 3.141 / 180.0;
	gy *= 3.141 / 180.0;
	gz *= 3.141 / 180.0;

	//KalmanFilter();
	DCMFilter(time, gx, gy, gz,
			rawADCValues[0], rawADCValues[1], rawADCValues[2],
			rawMagValues[0], rawMagValues[1], rawMagValues[2]);

	rollf = atan2(2*(q0*q1+q2*q3), 1-2*(q1*q1+q2*q2));
	pitchf = asin(2*(q0*q2-q3*q1));
	yawf = atan2(2*(q0*q3+q1*q2), 1-2*(q2*q2+q3*q3));

	rollf *= 180.0/3.1415;
	pitchf *= 180.0/3.1415;
	yawf *= 180.0/3.1415;

	roll = (int) rollf;
	pitch = (int) pitchf;
	yaw = (int) yawf;

	//printf("Fil: X: %f \tY: %f \tZ: %f\t\tX: %f \tY: %f \tZ: %f\t\tX: %f \tY: %f \tZ: %f\n", rollf, pitchf, yawf, accelAngles.x, accelAngles.y, accelAngles.z, gyroAngles.x, gyroAngles.y, gyroAngles.z);
}

void DCMFilter(long time, float gx, float gy, float gz, float ax, float ay, float az, float mx, float my, float mz) {
	float norm;
	float hx, hy, hz, bx, bz;
	float vx, vy, vz, wx, wy, wz;
	float ex, ey, ez;

	// auxiliary variables to reduce number of repeated operations
	float q0q0 = q0 * q0;
	float q0q1 = q0 * q1;
	float q0q2 = q0 * q2;
	float q0q3 = q0 * q3;
	float q1q1 = q1 * q1;
	float q1q2 = q1 * q2;
	float q1q3 = q1 * q3;
	float q2q2 = q2 * q2;
	float q2q3 = q2 * q3;
	float q3q3 = q3 * q3;

	// normalise the measurements
	norm = sqrt(ax * ax + ay * ay + az * az);
	ax = ax / norm;
	ay = ay / norm;
	az = az / norm;
	norm = sqrt(mx * mx + my * my + mz * mz);
	mx = mx / norm;
	my = my / norm;
	mz = mz / norm;

	// compute reference direction of flux
	hx = 2 * mx * (0.5 - q2q2 - q3q3) + 2 * my * (q1q2 - q0q3) + 2 * mz * (q1q3 + q0q2);
	hy = 2 * mx * (q1q2 + q0q3) + 2 * my * (0.5 - q1q1 - q3q3) + 2 * mz * (q2q3 - q0q1);
	hz = 2 * mx * (q1q3 - q0q2) + 2 * my * (q2q3 + q0q1) + 2 * mz * (0.5 - q1q1 - q2q2);
	bx = sqrt((hx * hx) + (hy * hy));
	bz = hz;

	// estimated direction of gravity and flux (v and w)
	vx = 2 * (q1q3 - q0q2);
	vy = 2 * (q0q1 + q2q3);
	vz = q0q0 - q1q1 - q2q2 + q3q3;
	wx = 2 * bx * (0.5 - q2q2 - q3q3) + 2 * bz * (q1q3 - q0q2);
	wy = 2 * bx * (q1q2 - q0q3) + 2 * bz * (q0q1 + q2q3);
	wz = 2 * bx * (q0q2 + q1q3) + 2 * bz * (0.5 - q1q1 - q2q2);

	// error is sum of cross product between reference direction of fields and direction measured by sensors
	ex = (ay * vz - az * vy) + (my * wz - mz * wy);
	ey = (az * vx - ax * vz) + (mz * wx - mx * wz);
	ez = (ax * vy - ay * vx) + (mx * wy - my * wx);

	// integral error scaled integral gain
	exInt = exInt + ex * Ki;
	eyInt = eyInt + ey * Ki;
	ezInt = ezInt + ez * Ki;

	// adjusted gyroscope measurements
	gx = gx + Kp * ex + exInt;
	gy = gy + Kp * ey + eyInt;
	gz = gz + Kp * ez + ezInt;

	// integrate quaternion rate and normalise
	q0 = q0 + (-q1 * gx - q2 * gy - q3 * gz) * ((time - lastTime2) * .00000001);
	q1 = q1 + (q0 * gx + q2 * gz - q3 * gy) * ((time - lastTime2) * .00000001);
	q2 = q2 + (q0 * gy - q1 * gz + q3 * gx) * ((time - lastTime2) * .00000001);
	q3 = q3 + (q0 * gz + q1 * gy - q2 * gx) * ((time - lastTime2) * .00000001);

	// normalise quaternion
	norm = sqrt(q0 * q0 + q1 * q1 + q2 * q2 + q3 * q3);
	q0 = q0 / norm;
	q1 = q1 / norm;
	q2 = q2 / norm;
	q3 = q3 / norm;

	lastTime2 = time;
}
vector getGyroAngles(long time) {
	vector angles = { 0, 0, 0 };
	if (lastTime != 0) {
		gyRoll += (float) rawADCValues[3] / 20.5 * ((time - lastTime) * .00000001);
		gyPitch += (float) rawADCValues[4] / 20.5 * ((time - lastTime) * .00000001);
		gyYaw += (float) rawADCValues[5] / 20.5 * ((time - lastTime) * .00000001);

		angles.x = gyRoll;
		angles.y = gyPitch;
		angles.z = gyYaw;
	}
	lastTime = time;
	//printf("Gyr X: %f \tY: %f \tZ: %f\n",angles.x,angles.y,angles.z);

	return angles;
}

vector getAccelAngles() {
	vector a = { rawADCValues[0], rawADCValues[1], rawADCValues[2] };
	vector m = { rawMagValues[0], rawMagValues[1], rawMagValues[2] };
	vector p = { 0, -1, 0 };
	vector angles = { 0, 0, 0 };

	a.x /= 12.65;
	a.y /= 12.65;
	a.z /= 12.65;

	float heading = getHeading(&a, &m, &p);

	double R = sqrt((a.x * a.x) + (a.y * a.y) + (a.z * a.z));

	angles.x = atan2(a.y, a.z) * 57.29;
	angles.y = atan2(a.x, sqrt(a.y * a.y + a.z * a.z)) * 57.29;
	angles.z = heading;

	//printf("Acl X: %f \tY: %f \tZ: %f\t\t%f\t%f\t%f\n",angles.x,angles.y,angles.z,a.x,a.y,a.z);
	return angles;
}

float getHeading(vector *a, vector *m, vector *p) {
	// shift and scale
	m->x = (m->x - MAG_MIN.x) / (MAG_MAX.x - MAG_MIN.x) * 2 - 1.0;
	m->y = (m->y - MAG_MIN.y) / (MAG_MAX.y - MAG_MIN.y) * 2 - 1.0;
	m->z = (m->z - MAG_MIN.z) / (MAG_MAX.z - MAG_MIN.z) * 2 - 1.0;

	vector E;
	vector N;

	// cross magnetic vector (magnetic north + inclination) with "down" (acceleration vector) to produce "east"
	vector_cross(m, a, &E);
	vector_normalize(&E);

	// cross "down" with "east" to produce "north" (parallel to the ground)
	vector_cross(a, &E, &N);
	vector_normalize(&N);

	// compute heading
	float heading = (atan2(vector_dot(&E, p), vector_dot(&N, p)) * 180 / M_PI);
	heading -= 90;
	return heading;
}

void updateFilterADCValues(int vals[8]) {
	rawADCValues[0] = vals[4] - 947;
	rawADCValues[1] = vals[5] - 1372;
	rawADCValues[2] = vals[3] - 1820;

	rawADCValues[3] = vals[1];
	rawADCValues[4] = vals[2];
	rawADCValues[5] = vals[0];
}

void updateFilterMagValues(short vals[3]) {
	for (int i = 0; i < 3; i++) {
		rawMagValues[i] = vals[i];
	}
}

void printVariance(int sum, int sum2, int n) {
	float variance = ((float) sum2 - (float) (sum * sum) / (float) n) / (float) (n - 1);
	printf("Variance: %f\t %i,%i,%i\n", variance, sum, sum2, n);
}

void getRPY(int rpy[3]) {
	rpy[0] = (int)(rollf*1000000.0);
	rpy[1] = (int)(pitchf*1000000.0);
	rpy[2] = (int)(yawf*1000000.0);
}
