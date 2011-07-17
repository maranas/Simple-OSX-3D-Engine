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

#define kWindowWidth	800
#define kWindowHeight	600

#define KEY_ESCAPE		27
#define KEY_SPACE		32

BOOL key_buff[256];
BOOL spec_key_buff[256];

//test vars for rotation controls
GLfloat rquad;
GLfloat rquad2;
GLfloat rquad3;
//end test

// Test model (TODO: implement Scenes)
struct objModel testModel;

GLvoid initGL(GLvoid)
{
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearDepth(1.0);
	glDepthFunc(GL_LEQUAL);
	glEnable(GL_DEPTH_TEST);
	
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glShadeModel(GL_SMOOTH);
	glMatrixMode(GL_PROJECTION);
	
	glEnable(GL_BLEND);
	
	// Enable 1 light
	glEnable(GL_LIGHTING);
	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_LIGHT0);
	
	glLoadIdentity();
	// initial window perspective calculation
	//gluPerspective(45.0f,(GLfloat)kWindowWidth/(GLfloat)kWindowHeight,0.1f,100.0f);
	//glMatrixMode(GL_MODELVIEW);
	
	// TODO: this is a test load. Remove this when Scenes are implemented
	loadModel("cube.obj", &testModel);
}

GLvoid resizeScene(int width, int height)
{
    glViewport (0, 0, (GLsizei) width, (GLsizei) height);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
	
    gluPerspective(45.0, (GLfloat) width / (GLfloat) height, 0.1, 100.0);
	
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
	// LIGHT0 settings
	GLfloat light0_specular[] = {1.0, 1.0, 1.0};
	GLfloat light0_ambient[] = {0.1, 0.1, 0.1};
	GLfloat light0_diffuse[] = {0.5, 0.5, 0.5};
	glLightfv(GL_LIGHT0, GL_SPECULAR, light0_specular);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light0_ambient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light0_diffuse);	
}
//

void inputFunc(void)
{
	// Quit on ESCAPE
	if (key_buff[KEY_ESCAPE])
		exit(0);
	
	// do things with the inputs here
	if (spec_key_buff[GLUT_KEY_DOWN] || key_buff['s'])
		rquad += 0.15f;
	if (spec_key_buff[GLUT_KEY_LEFT] || key_buff['a'])
		rquad2 -= 0.15f;
	if (spec_key_buff[GLUT_KEY_RIGHT] || key_buff['d'])
		rquad2 += 0.15f;
	if (spec_key_buff[GLUT_KEY_UP] || key_buff['w'])
		rquad -= 0.15f;
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

// This is where the action happens.
GLvoid drawScene(GLvoid)
{
	// Before drawing, check inputs
	inputFunc();
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	// test scene (a shiny teapot); replace.
	glLoadIdentity();
	lightScene();
	GLfloat specularity[] = {0.5, 0.5, 0.5};
	GLfloat shine[] = {128};
	glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, specularity);
	glMaterialfv(GL_FRONT_AND_BACK, GL_SHININESS, shine);
	glTranslatef(0.0f, -0.5f, -6.0f);
	glRotatef(rquad, 1.0f, 0.0f, 0.0f);
	glRotatef(rquad2, 0.0f, 1.0f, 0.0f);
	glRotatef(rquad3, 0.0f, 0.0f, 1.0f);
	drawModel(&testModel);
	// end test
	
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
