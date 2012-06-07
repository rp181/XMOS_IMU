/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <stddef.h>
#include "MathUtils.h"

// Vector functions
void vector_cross(const vector *a, const vector *b, vector *out) {
	out->x = a->y * b->z - a->z * b->y;
	out->y = a->z * b->x - a->x * b->z;
	out->z = a->x * b->y - a->y * b->x;
}

float vector_dot(const vector *a, const vector *b) {
	return a->x * b->x + a->y * b->y + a->z * b->z;
}

void vector_normalize(vector *a) {
	float mag = sqrt(vector_dot(a, a));
	a->x /= mag;
	a->y /= mag;
	a->z /= mag;
}

void addMatricies(float a[3][3], float b[3][3], float result[3][3]) {
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			result[i][j] = a[i][j] + b[i][j];
		}
	}
}
void subtractMatricies(float a[3][3], float b[3][3], float result[3][3]) {
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			result[i][j] = a[i][j] - b[i][j];
		}
	}
}
void multiplyMatricies(float a[3][3], float b[3][3], float result[3][3]) {
	int k;
	for (int i = 0; i < 3; i++) {
		for (int j = 0; j < 3; j++) {
			for (k = 0, result[i][j] = 0.0; k < 3; k++) {
				result[i][j] += a[i][k] * b[k][j];
			}
		}
	}
}
void invertMatrix(float a[3][3], float result[3][3]) {
	float det = a[0][0] * a[1][1] * a[2][2] + a[0][1] * a[1][2] * a[2][0] + a[0][2] * a[1][0] * a[2][1] - a[0][2] * a[1][1] * a[2][0] - a[1][2] * a[2][1] * a[0][0] - a[2][2] * a[0][1] * a[1][0];

	result[0][0] = (a[1][1] * a[2][2] - a[1][2] * a[2][1]) / det;
	result[0][1] = (a[0][2] * a[2][1] - a[0][1] * a[2][2]) / det;
	result[0][2] = (a[0][1] * a[2][1] - a[1][1] * a[2][0]) / det;

	result[1][0] = (a[1][2] * a[2][0] - a[1][0] * a[2][2]) / det;
	result[1][1] = (a[0][0] * a[2][2] - a[0][2] * a[2][0]) / det;
	result[1][2] = (a[0][2] * a[1][0] - a[0][0] * a[1][2]) / det;

	result[2][0] = (a[1][0] * a[2][1] - a[1][1] * a[2][0]) / det;
	result[2][1] = (a[0][1] * a[2][0] - a[0][0] * a[2][1]) / det;
	result[2][2] = (a[0][0] * a[1][1] - a[0][1] * a[1][0]) / det;

}
