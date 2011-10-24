/*
 *  quaternions.c
 *  RC-sim
 *
 *  Created by Moises Anthony Aranas on 8/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "quaternions.h"
#include "math.h"
#define RADIANS( degrees ) ( degrees * M_PI / 180 )
#define DEGREES( radians ) ( radians * 180 / M_PI )

void multiplyQuaternions( struct quaternion *Qa, struct quaternion *Qb, struct quaternion *Qprod)
{
	Qprod->w = (Qa->w*Qb->w) - (Qa->x*Qb->x) - (Qa->y*Qb->y) - (Qa->z*Qb->z);
	Qprod->x = (Qa->w*Qb->x) + (Qa->x*Qb->w) + (Qa->y*Qb->z) - (Qa->z*Qb->y);
	Qprod->y = (Qa->w*Qb->y) + (Qa->y*Qb->w) + (Qa->z*Qb->x) - (Qa->x*Qb->z);
	Qprod->z = (Qa->w*Qb->z) + (Qa->z*Qb->w) + (Qa->x*Qb->y) - (Qa->y*Qb->x);
}

void quatFromEuler( GLfloat a, GLfloat b, GLfloat c, struct quaternion *Q )
{
	a = RADIANS(a)/2;
	b = RADIANS(b)/2;
	c = RADIANS(c)/2;
	
	float sina = sin(a);
	float sinb = sin(b);
	float sinc = sin(c);
	float cosa = cos(a);
	float cosb = cos(b);
	float cosc = cos(c);
	
	Q->w = cosb * cosc * cosa - sinb * sinc * sina;
	Q->x = sinb * sinc * cosa + cosb * cosc * sina;
	Q->y = sinb * cosc * cosa + cosb * sinc * sina;
	Q->z = cosb * sinc * cosa - sinb * cosc * sina;
}

void axisAngleFromQuat( struct quaternion *Q, struct axisAngle *A )
{
	GLfloat scale = sqrt((Q->x*Q->x) + (Q->y*Q->y) + (Q->z*Q->z));
	if (scale == 0)
	{
		A->angle = 0;
		A->ax = 0;
		A->ay = 0;
		A->az = 0;
	}
	else A->angle = 2.0 * acos(Q->w);
	{
		A->angle = DEGREES(A->angle);
		A->ax = Q->x / scale;
		A->ay = Q->y / scale;
		A->az = Q->z / scale;
	}	
}

void quatToEuler(struct quaternion *Q, GLfloat *a, GLfloat *b, GLfloat *c)
{
	(*a) = DEGREES(atan2(2 * Q->x * Q->w-2 * Q->y * Q->z, 1 - 2 * Q->x * Q->x - 2 * Q->z * Q->z));
	(*b) = DEGREES(atan2(2 * Q->y * Q->w-2 * Q->x * Q->z, 1 - 2 * Q->y * Q->y - 2 * Q->z * Q->z));
	(*c) = DEGREES(asin(2 * Q->x * Q->y + 2 * Q->z * Q->w));
}