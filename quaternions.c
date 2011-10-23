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

void multiplyQuaternions( struct quaternion *Qa, struct quaternion *Qb)
{
	Qa->w = (Qa->w*Qb->w) - (Qa->x*Qb->x) - (Qa->y*Qb->y) - (Qa->z*Qb->z);
	Qa->x = (Qa->w*Qb->x) + (Qa->x*Qb->w) + (Qa->y*Qb->z) - (Qa->z*Qb->y);
	Qa->y = (Qa->w*Qb->y) + (Qa->y*Qb->w) + (Qa->z*Qb->x) - (Qa->x*Qb->z);
	Qa->z = (Qa->w*Qb->z) + (Qa->z*Qb->w) + (Qa->x*Qb->y) - (Qa->y*Qb->x);
}

void axisAngleFromEuler( GLfloat a, GLfloat b, GLfloat c, struct axisAngle *A )
{
	struct quaternion Qy, Qz, Qquot;
	a = RADIANS(a);
	b = RADIANS(b);
	c = RADIANS(c);
	
	Qquot.w = cos(a/2); Qquot.x = sin(a/2);	Qquot.y = 0;		Qquot.z = 0;
	Qy.w = cos(b/2);	Qy.x = 0;			Qy.y = sin(b/2);	Qy.z = 0;
	Qz.w = cos(c/2);	Qz.x = 0;			Qz.y = 0;			Qz.z = sin(c/2);
	
	multiplyQuaternions(&Qquot, &Qy);
	multiplyQuaternions(&Qquot, &Qz);
	
	GLfloat scale = sqrt((Qquot.x*Qquot.x) + (Qquot.y*Qquot.y) + (Qquot.z*Qquot.z));
	if (scale == 0)
	{
		A->angle = 0;
		A->ax = 0;
		A->ay = 0;
		A->az = 0;
	}
	else A->angle = 2 * acos(Qquot.w);
	{
		A->angle = DEGREES(A->angle);
		A->ax = Qquot.x / scale;
		A->ay = Qquot.y / scale;
		A->az = Qquot.z / scale;
	}
}