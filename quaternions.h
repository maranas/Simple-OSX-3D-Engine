/*
 *  quaternions.h
 *  RC-sim
 *
 *  Created by Moises Anthony Aranas on 8/26/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include <GLUT/glut.h>

struct quaternion {
	GLfloat w;
	GLfloat x;
	GLfloat y;
	GLfloat z;
};

struct axisAngle {
	GLfloat angle;
	GLfloat ax;
	GLfloat ay;
	GLfloat az;
};

// Multiplies 2 quaternions, stores result in the last argument
void multiplyQuaternions( struct quaternion *Qa, struct quaternion *Qb, struct quaternion *Qprod);

// Converts Euler angles to a quaternion, then to an axis-angle.
void quatFromEuler( GLfloat a, GLfloat b, GLfloat c, struct quaternion *Q );

void axisAngleFromQuat( struct quaternion *Q, struct axisAngle *A );

void quatToEuler(struct quaternion *Q, GLfloat *a, GLfloat *b, GLfloat *c);