/*
 *  obj.c
 *  Simple-3d-Framework
 *
 *  Created by Moises Anthony Aranas on 7/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "obj.h"

int loadModel (const char *filename, struct objModel *model, const char *tex_file, int width, int height)
{
	FILE* fp = fopen(filename, "r"); //read only
	if (!fp)
	{
		return 0;
	}
	
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
				while (toked != NULL) {
					model->g_verts[v_c] = atof(toked);
					toked = strtok(NULL, " ");
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
				char* toked = strtok(buffer, " "); // remove the vt
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
	
	printf("Faces: %d\n", model->f_count);
	printf("Geom vertices: %d\n", model->g_verts_count);
	printf("Texture vertices: %d\n", model->t_verts_count);
	printf("Normal vertices: %d\n", model->n_verts_count);
	
	// fix vt and vn according to indices
	while (tf_c > 0 && model->t_verts_count > 0)
	{
		tf_c--;
		model->t_verts[model->f_indices[tf_c]] = t_verts_temp[t_indices[tf_c]];
	}
	while (nf_c > 0 && model->n_verts_count > 0)
	{
		nf_c--;
		model->n_verts[model->f_indices[nf_c]] = n_verts_temp[n_indices[nf_c]];
	}
	fclose(fp);
	return 1;
}

int drawModel (struct objModel *model)
{
	glEnableClientState(GL_VERTEX_ARRAY);
	if  (model->n_verts_count > 0)
	{
		glEnableClientState(GL_NORMAL_ARRAY);
		glNormalPointer(GL_FLOAT, 0, model->n_verts);
	}
	if (model->t_verts_count > 0)
	{
		glEnableClientState(GL_TEXTURE_COORD_ARRAY);
		glTexCoordPointer(2, GL_FLOAT, 0, model->t_verts);
	}
	glVertexPointer(COORDS_PER_VERTEX, GL_FLOAT, 0, model->g_verts);

	// Draw it
	//glDrawArrays(GL_TRIANGLES, 0, model->g_verts_count);
	glDrawElements(GL_TRIANGLES, 3 * model->f_count, GL_UNSIGNED_INT, model->f_indices);
	
	if (model->t_verts_count > 0) glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	if (model->n_verts_count > 0) glDisableClientState(GL_NORMAL_ARRAY);
	glDisableClientState(GL_VERTEX_ARRAY);
	return 1;
}