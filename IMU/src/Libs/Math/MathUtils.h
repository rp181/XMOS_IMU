/**
 * @file
 * @author Phani Gaddipati <phanigaddipati@yahoo.com>\n
 * <a href="www.centumengineering.com">Centum Engineering</a>
 * @version 1.0
 * @section License
 * This code can be used only with expressed consent from the owner
 * @section Description
 */

#ifndef MATHUTILS_CPP_
#define MATHUTILS_CPP_

#include <stdlib.h>
#include <stdio.h>

typedef struct vector {
	float x,y,z;
}vector;

extern void vector_cross(const vector *a, const vector *b, vector *out);
extern float vector_dot(const vector *a, const vector *b);
extern void vector_normalize(vector *a);

void addMatricies(float a[3][3], float b[3][3], float result[3][3]);
void subtractMatricies(float a[3][3], float b[3][3], float result[3][3]);
void multiplyMatricies(float a[3][3], float b[3][3], float result[3][3]);
void invertMatrix(float a[3][3], float result[3][3]);

#endif /* MATHUTILS_CPP_ */
