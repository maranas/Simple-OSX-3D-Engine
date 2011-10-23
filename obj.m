/*
 *  obj.c
 *  Simple-3d-Framework
 *
 *  Created by Moises Anthony Aranas on 7/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#include "obj.h"

int loadModel (const char *filename, struct objModel *model, const char *tex_file)
{
	FILE* fp = fopen(filename, "r"); //read only
	if (!fp)
	{
		return 0;
	}
	NSAutoreleasePool *autoReleasePool = [[NSAutoreleasePool alloc] init];
	
	// load texture using Apple's suggested Quartz way
	NSURL* url = [NSURL fileURLWithPath:[NSString stringWithUTF8String:tex_file]];
	
	CGImageSourceRef myImageSourceRef = CGImageSourceCreateWithURL((CFURLRef) url, NULL);
	CGImageRef myImageRef = CGImageSourceCreateImageAtIndex (myImageSourceRef, 0, NULL);
	size_t width = CGImageGetWidth(myImageRef);
	size_t height = CGImageGetHeight(myImageRef);
	CGRect rect = {{0, 0}, {width, height}};
	void * myData = calloc(width * 4, height);
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGContextRef myBitmapContext = CGBitmapContextCreate (myData,
														  width, height, 8,
														  width*4, space,
														  kCGBitmapByteOrder32Host |
														  kCGImageAlphaPremultipliedFirst);
	CGContextSetBlendMode(myBitmapContext, kCGBlendModeCopy);
	CGContextDrawImage(myBitmapContext, rect, myImageRef);
	CGContextRelease(myBitmapContext);
	glPixelStorei(GL_UNPACK_ROW_LENGTH, width);
	glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
	glGenTextures(1, &model->texture);
	glBindTexture(GL_TEXTURE_2D, model->texture);
	glTexParameteri(GL_TEXTURE_2D,
                    GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, width, height,
				 0, GL_BGRA_EXT, GL_UNSIGNED_INT_8_8_8_8_REV, myData);
	free(myData);
	CFRelease(space);
	CFRelease(myImageRef);
	CFRelease(myImageSourceRef);
	
	// Initializa bounding box min, max values.
	model->min_x = 0; model->min_y = 0; model->min_z = 0;
	model->max_x = 0; model->max_y = 0; model->max_z = 0;
	
	// load geometry
	// TODO: Currently just loads geometric vertices.
	model->g_verts_count = 0;
	model->f_count = 0;
	int v_c = 0;
	int f_c = 0;
	int t_c = 0;
	int n_c = 0;
	int tf_c = 0;
	int nf_c = 0;
	
	// store here before arranging according to f data
	GLfloat t_verts_temp[MAX_VERTICES * COORDS_PER_VERTEX];
	GLfloat n_verts_temp[MAX_VERTICES * COORDS_PER_VERTEX];
	GLuint t_indices[MAX_VERTICES * COORDS_PER_VERTEX];
	GLuint n_indices[MAX_VERTICES * COORDS_PER_VERTEX];
	
	while (MAX_VERTICES * COORDS_PER_VERTEX > v_c &&
		   MAX_VERTICES * COORDS_PER_VERTEX > f_c &&
		   !feof(fp)) {
		char buffer[256] = "";
		fgets(buffer, sizeof(buffer), fp);
		if (buffer[0] == 'v')
		{
			if  (buffer[1] == ' ')
			{
				//geom verts
				model->g_verts_count++;
				char* toked = strtok(buffer, " "); // remove the v
				toked = strtok(NULL, " ");
				int which_coord = 0;
				while (toked != NULL) {
					model->g_verts[v_c] = atof(toked);
					toked = strtok(NULL, " ");
					if (which_coord == 0) // x
					{
						if (v_c == 0)
						{
							model->min_x = model->g_verts[v_c];
							model->max_x = model->g_verts[v_c];
						}
						if (model->min_x > model->g_verts[v_c])
							model->min_x = model->g_verts[v_c];
						else if (model->max_x < model->g_verts[v_c])
							model->max_x = model->g_verts[v_c];
					}
					else if (which_coord == 1) // y
					{
						if (v_c == 0)
						{
							model->min_y = model->g_verts[v_c];
							model->max_y = model->g_verts[v_c];
						}
						if (model->min_y > model->g_verts[v_c])
							model->min_y = model->g_verts[v_c];
						else if (model->max_y < model->g_verts[v_c])
							model->max_y = model->g_verts[v_c];
					}
					else if (which_coord == 2) // z
					{
						if (v_c == 0)
						{
							model->min_z = model->g_verts[v_c];
							model->max_z = model->g_verts[v_c];
						}
						if (model->min_z > model->g_verts[v_c])
							model->min_z = model->g_verts[v_c];
						else if (model->max_z < model->g_verts[v_c])
							model->max_z = model->g_verts[v_c];
					}
					which_coord++;
					v_c++;
				}
			}
			else if (buffer[1] == 't') {
				//texture coords
				model->t_verts_count++;
				char* toked = strtok(buffer, " "); // remove the vt
				toked = strtok(NULL, " ");
				while (toked != NULL) {
					t_verts_temp[t_c] = atof(toked);
					toked = strtok(NULL, " ");
					t_c++;
				}
			}
			else if (buffer[1] == 'n') {
				//normal coords
				model->n_verts_count++;
				char* toked = strtok(buffer, " "); // remove the vn
				toked = strtok(NULL, " ");
				while (toked != NULL) {
					n_verts_temp[n_c] = atof(toked);
					toked = strtok(NULL, " ");
					n_c++;
				}
			}
		}
		else if (buffer[0] == 'f')
		{
			//face
			model->f_count++;
			char* toked = strtok(buffer, " "); // remove the f
			toked = strtok(NULL, " ");
			while (toked != NULL) {
				// v/vt/vn
				if (sscanf(toked, "%d/%d/%d", &model->f_indices[f_c], &t_indices[tf_c], &n_indices[nf_c]) != 3) {
					// v//n
					if (sscanf(toked, "%d//%d", &model->f_indices[f_c], &n_indices[nf_c]) !=2)
					{
						// v/vt
						if (sscanf(toked, "%d/%d", &model->f_indices[f_c], &t_indices[tf_c]) !=2)
						{
							// v
							sscanf(toked, "%d", &model->f_indices[f_c]);
						}
					}
				}
				model->f_indices[f_c++]--;
				t_indices[tf_c++]--;
				n_indices[nf_c++]--;
				toked = strtok(NULL, " ");
			}
		}
	}
	
	// fix vt and vn according to indices
	int c = 0;
	while (c <= f_c && model->t_verts_count > 0)
	{
		model->t_verts[(model->f_indices[c]*2)]     = t_verts_temp[(t_indices[c]*2)];
		// Do some magic - opengl's Y origin is at the lower left.
		model->t_verts[(model->f_indices[c]*2) + 1] = 1.0 - t_verts_temp[(t_indices[c]*2) + 1];
		c++;
	}
	c = 0;
	while (c <= f_c && model->n_verts_count > 0)
	{
		model->n_verts[(model->f_indices[c]*3)]     = n_verts_temp[(n_indices[c]*3)];
		model->n_verts[(model->f_indices[c]*3) + 1] = n_verts_temp[(n_indices[c]*3) + 1];
		model->n_verts[(model->f_indices[c]*3) + 2] = n_verts_temp[(n_indices[c]*3) + 2];
		c++;
	}
	fclose(fp);
	[autoReleasePool release];
	return 1;
}

int drawModel (struct objModel *model)
{
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(COORDS_PER_VERTEX, GL_FLOAT, 0, model->g_verts);
	if  (model->n_verts_count > 0)
	{
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT, 0, model->n_verts);
	}
	if (model->t_verts_count > 0)
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, model->t_verts);
		glBindTexture(GL_TEXTURE_2D, model->texture);
	}

	// Draw it
	//glDrawArrays(GL_TRIANGLES, 0, model->g_verts_count);
	glDrawElements(GL_TRIANGLES, COORDS_PER_VERTEX * model->f_count, GL_UNSIGNED_INT, model->f_indices);
	
	if (model->t_verts_count > 0) glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	if (model->n_verts_count > 0) glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	
	return 1;
}