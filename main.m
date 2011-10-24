//
//  main.m
//  OpenGL base
//
//  Created by Moises Anthony Aranas on 7/4/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>
#include <GLUT/glut.h>

#include "obj.h"
#include "quaternions.h"

#define kWindowWidth	320
#define kWindowHeight	200

#define KEY_ESCAPE		27
#define KEY_SPACE		32

BOOL key_buff[256];
BOOL spec_key_buff[256];
int time_started;
int prev_time;
int elapsed_time;

//test vars for rotation controls
GLfloat pitch;
GLfloat yaw;
GLfloat roll;
GLfloat throttle;
GLfloat x, y, z;
GLfloat cam_roll;
GLfloat cam_pitch;
GLfloat cam_yaw;
//end test

// Test model (TODO: implement Scenes)
struct objModel testModel;
struct objModel testModel2;

GLvoid initGL(GLvoid)
{
	time_started = glutGet(GLUT_ELAPSED_TIME);
	prev_time = time_started;
	elapsed_time = 0;
	
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0);
	glDepthFunc(GL_LEQUAL);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_LIGHTING);
	
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glShadeModel(GL_SMOOTH);
	glMatrixMode(GL_PROJECTION);
	
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	
	glLoadIdentity();
	
	// TEST VALUES
	// Load our cub
	throttle = 0; x = 0; y = 0; z = -10; roll = 0; pitch = 0; yaw = 0;
	cam_pitch = 0; cam_yaw = 0; cam_roll = 0;
	loadModel("pipercub.obj", &testModel, "cub.png");
	loadModel("skybox.obj", &testModel2, "sky.jpg");
}

GLvoid resizeScene(int width, int height)
{
    glViewport (0, 0, (GLsizei) width, (GLsizei) height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
    gluPerspective(45.0, (GLfloat) width / (GLfloat) height, 0.1, 100000.0);
	
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
}

GLvoid idleFunc(GLvoid)
{
	glutPostRedisplay();
}

// Lighting and materials
void lightScene()
{
    GLfloat ambient[] = { 1.0f, 1.0f, 1.0f, 1.0f };
    GLfloat diffuse[] = { 1.0f, 1.0f, 1.0f, 1.0f };
    
    glLightfv( GL_LIGHT0, GL_AMBIENT, ambient );
    glLightfv( GL_LIGHT0, GL_DIFFUSE, diffuse );
	
    glEnable( GL_LIGHT0 );
	
    GLfloat lightPosition[] = { -100.0f, 100.0f, 100.0f, 1.0f };
    glLightfv( GL_LIGHT0, GL_POSITION, lightPosition );
}
//

void inputFunc(void)
{
	// Quit on ESCAPE
	if (key_buff[KEY_ESCAPE])
		exit(0);
	
	// do things with the inputs here
	if (spec_key_buff[GLUT_KEY_DOWN] || key_buff['s'])
		pitch += 0.15f * elapsed_time;
	if (spec_key_buff[GLUT_KEY_UP] || key_buff['w'])
		pitch -= 0.15f * elapsed_time;
	if (spec_key_buff[GLUT_KEY_LEFT] || key_buff['q'])
		yaw -= 0.15f * elapsed_time;
	if (spec_key_buff[GLUT_KEY_RIGHT] || key_buff['e'])
		yaw += 0.15f * elapsed_time;
	if (spec_key_buff[GLUT_KEY_LEFT] || key_buff['a'])
		roll -= 0.15f * elapsed_time;
	if (spec_key_buff[GLUT_KEY_RIGHT] || key_buff['d'])
		roll += 0.15f * elapsed_time;
	if (key_buff['r'])
	{
		throttle = 0;
		pitch = 0; roll = 0; yaw = 0;
		x = 0; y = 0; z = -10;
	}
	if (pitch > 360) pitch -= 360;
	if (yaw > 360) yaw -= 360;
	if (roll > 360) roll -= 360;
	if (pitch <= 0) pitch += 360;
	if (yaw <= 0) yaw += 360;
	if (roll <= 0) roll += 360;
	
	if (key_buff['='] || key_buff['+'])
		throttle += 0.00001f * elapsed_time;
	if (key_buff['-'] || key_buff['_'])
		throttle -= 0.00001f * elapsed_time;
	if (throttle < 0)
		throttle = 0;
	if (throttle > 1)
		throttle = 1;
}


// Input callbacks
GLvoid keyDownFunc(unsigned char key, int x, int y)
{
	key_buff[key] = TRUE;
	glutPostRedisplay();
}

GLvoid keyUpFunc(unsigned char key, int x, int y)
{
	key_buff[key] = FALSE;
	glutPostRedisplay();
}

GLvoid keySpecialDownFunc(int key, int x, int y)
{
	spec_key_buff[key] = TRUE;
	glutPostRedisplay();
}

GLvoid keySpecialUpFunc(int key, int x, int y)
{
	spec_key_buff[key] = FALSE;
	glutPostRedisplay();
}

// HUD drawing
void drawHud()
{
    // Our HUD consists of a simple rectangle
	glDisable(GL_DEPTH_TEST);
    glMatrixMode( GL_PROJECTION );
    glPushMatrix();
	glLoadIdentity();
	glOrtho( -100.0f, 100.0f, -100.0f, 100.0f, -100.0f, 100.0f );
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();

	// DRAW HUD ELEMENTS HERE
	glDisable(GL_LIGHTING);
	
	glPushMatrix();
	glColor3f(0.0f, 0.8f, 0.0f);
	glTranslatef( -95.0f, -95.0f, 0.0f );
	glScalef( 0.025f, 0.025f, 0.0f );
	glLineWidth(1.0);
	char message[50];
	sprintf(message, "Throttle: %f", throttle);
	int index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	sprintf(message, " Roll: %f", roll);
	index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	sprintf(message, " Pitch: %f", pitch);
	index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	sprintf(message, " Yaw: %f", yaw);
	index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	sprintf(message, " x: %f", x);
	index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	sprintf(message, " y: %f", y);
	index = 0;
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	index = 0;
	sprintf(message, " z: %f", z);
	while( *( message + index++ ) != '\0' )
		glutStrokeCharacter( GLUT_STROKE_ROMAN, *( message + index -1 ));
	glPopMatrix();
	
	glEnable(GL_LIGHTING);
	// END DRAW HUD ELEMENTS
	
	glEnable(GL_DEPTH_TEST);
    glMatrixMode( GL_PROJECTION );
    glPopMatrix();
	glMatrixMode(GL_MODELVIEW);
}

// This is where the action happens.
GLvoid drawScene(GLvoid)
{
	// frame-independent animation calculations go here
	int curr_time = glutGet(GLUT_ELAPSED_TIME);
	elapsed_time = curr_time - prev_time;
	prev_time = curr_time;
	
	// Before drawing, check inputs
	inputFunc();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	lightScene();
	glLoadIdentity();
	
	glPushMatrix();
	// draw player object
	x = x + (cos(yaw) * (cos(pitch) * throttle));
	y = y + (sin(pitch) * throttle);
	z = z + (sin(yaw) * (cos(pitch) * throttle));
	glTranslatef(x, y, z);
	
	struct axisAngle a_conv;
	struct quaternion Qdiff;
	quatFromEuler(pitch, yaw, roll, &Qdiff);
	axisAngleFromQuat(&Qdiff, &a_conv);
	
	glRotatef(a_conv.angle, a_conv.ax, a_conv.ay, a_conv.az);
	
	drawModel(&testModel);
	
	// end draw player object
	glPopMatrix();

	glPushMatrix();
	// draw scene here
	glTranslatef(0.0f, -3.0f, 0.0f);
	drawModel(&testModel2);
	// end draw scene
	glPopMatrix();
	
	glPushMatrix();
	// translate to camera position, then draw the HUD
	drawHud();
	// end translate
	glPopMatrix();
	
	//to flush or not to flush?
    glFlush();
    glutSwapBuffers(); 
}

int main(int argc, char *argv[])
{
	glutInit(&argc, argv);
	glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH);
	glutInitWindowSize(kWindowWidth, kWindowHeight);
	
	glutInitWindowPosition(100,100);
	glutCreateWindow(argv[0]);
	//glutFullScreen();
	
	initGL();
	glutDisplayFunc(drawScene);
	glutReshapeFunc(resizeScene);
	glutIdleFunc(idleFunc);
	
	// Input callbacks
	glutKeyboardFunc(keyDownFunc);
	glutKeyboardUpFunc(keyUpFunc);
	glutSpecialFunc(keySpecialDownFunc);
	glutSpecialUpFunc(keySpecialUpFunc);
	
	glutMainLoop();
	return 0;
}
