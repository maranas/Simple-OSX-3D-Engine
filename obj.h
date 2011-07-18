/*
 *  obj.h
 *  Simple-3d-Framework's wavefront obj loader.
 *  Used http://www.martinreddy.net/gfx/3d/OBJ.spec as a reference for the OBJ format specifications.
 *
 *  Created by Moises Anthony Aranas on 7/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <GLUT/glut.h>

#define MAX_VERTICES 2000 // let's keep it low poly for now
#define COORDS_PER_VERTEX 3

/* Model structure */
struct objModel {
	int g_verts_count;
	int t_verts_count;
	int n_verts_count;
	int f_count;
	
	GLuint texture;
	
	GLfloat g_verts[MAX_VERTICES * COORDS_PER_VERTEX];
	GLfloat t_verts[MAX_VERTICES * COORDS_PER_VERTEX];
	GLfloat n_verts[MAX_VERTICES * COORDS_PER_VERTEX];
	GLuint f_indices[MAX_VERTICES * COORDS_PER_VERTEX]; 
};

// loads a model off a .obj file into an objModel struct
int loadModel (const char *filename, struct objModel *model, const char *tex_file, int width, int height);

// draws a model
int drawModel (struct objModel *model);