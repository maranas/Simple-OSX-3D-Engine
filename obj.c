/*
 *  obj.c
 *  Simple-3d-Framework
 *
 *  Created by Moises Anthony Aranas on 7/9/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#include "obj.h"

int loadModel (const char *filename, struct objModel *model)
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
			}
		}
		else if (buffer[0] == 'f')
		{
			//face
			model->f_count++;
			char* toked = strtok(buffer, " "); // remove the f
			toked = strtok(NULL, " ");
			while (toked != NULL) {
				// just get the v for now. these are placeholders
				int vt;
				int vn;
				
				// v/vt/vn
				if (sscanf(toked, "%d/%d/%d", &model->f_indices[f_c], &vt, &vn) != 3) {
					// v//n
					if (sscanf(toked, "%d//%d", &model->f_indices[f_c], &vn) !=2)
					{
						// v/vt
						if (sscanf(toked, "%d/%d", &model->f_indices[f_c], &vt) !=2)
						{
							// v
							sscanf(toked, "%d", &model->f_indices[f_c]);
						}
					}
				}
				model->f_indices[f_c++]--;
				toked = strtok(NULL, " ");
			}
		}
	}
	printf("Faces: %d\n", model->f_count);
	printf("Vertices: %d\n", model->g_verts_count);
	fclose(fp);
	return 1;
}

int drawModel (struct objModel *model)
{
	glEnableClientState(GL_VERTEX_ARRAY);
	glVertexPointer(COORDS_PER_VERTEX, GL_FLOAT, 0, model->g_verts);
	// Draw it
	//glDrawArrays(GL_TRIANGLES, 0, model->g_verts_count);
	
	glDrawElements(GL_TRIANGLES, 3 * model->f_count, GL_UNSIGNED_INT, model->f_indices);
	glDisableClientState(GL_VERTEX_ARRAY);
	return 1;
}